unit HCmdQuery.Compiler;

{$I HCmdQuery.inc}

{#! [1] Types need to be commented and described }

interface

uses
    SysUtils,
    HCL.Core.GenericList,
    HCL.Core.HashTable,
    HCL.Core.StringUtils,
    HCmdQuery.Types,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Compiler.StringStream;

type
    THCmdQueryCompilerNodeType = (
        Integer,
        Double,
        Variable,
        UnicodeString,
        Evaluated,
        LongEvaluated,
        Body,
        Indexing,
        FieldIndexing,
        MethodCall,
        Parameter
    );

type
    {#! [1] }
    (* THCmdQueryCompilerNode
    *)
    THCmdQueryCompilerNode = class(THCmdQueryObject)
    public var
        NodeType: THCmdQueryCompilerNodeType;
        NodePosition: THCmdQueryPosition;
        Children: HList<THCmdQueryCompilerNode>;
    public
        DataInt64: Int64;
        DataDouble: Double;
        DataString: UnicodeString;
    public
        function ToString: UnicodeString; reintroduce;
    public
        constructor Create(const ANodeType: THCmdQueryCompilerNodeType; const APosition: THCmdQueryPosition);
        constructor CreateInt64(const AValue: Int64; const APosition: THCmdQueryPosition);
        constructor CreateDouble(const AValue: Double; const APosition: THCmdQueryPosition);
        constructor CreateString(const AValue: UnicodeString; const APosition: THCmdQueryPosition);
        constructor CreateVariable(const AName: UnicodeString; const APosition: THCmdQueryPosition);
        destructor Destroy; override;
    end;

type
    {#! [1] }
    (* THCmdQueryCompiler
    *)
    THCmdQueryCompiler = class(THCmdQueryObject)
    public
        class function DecodeEscapeChar(const AChar: UnicodeChar): UnicodeChar; static;
    private var
        FStringStream: THCmdQueryCompilerStringStream;
    public
        property Position: THCmdQueryPosition read FStringStream.StringStream.Position;
        property FileName: UnicodeString read FStringStream.StringStream.Position.FileName write FStringStream.StringStream.Position.FileName;
    public
        function ReadConstantString: UnicodeString;
    public
        function ReadArgumentIndexing(const AParent: THCmdQueryCompilerNode): THCmdQueryCompilerNode;
        function ReadArgumentFieldIndexing(const AParent: THCmdQueryCompilerNode): THCmdQueryCompilerNode;
        function ReadParameter(const AParent: THCmdQueryCompilerNode): THCmdQueryCompilerNode;
    public
        function ReadArgument(const ADisablePostProcessing: Boolean = False; const AAllowParameters: Boolean = False): THCmdQueryCompilerNode;
        function ReadNumber: THCmdQueryCompilerNode;
        function ReadVariable: THCmdQueryCompilerNode;
        function ReadUnquotedString: THCmdQueryCompilerNode;
        function ReadString: THCmdQueryCompilerNode;
        function ReadBigString: THCmdQueryCompilerNode;
        function ReadEvaluatedArgument: THCmdQueryCompilerNode;
        function ReadLastEvaluatedArgument: THCmdQueryCompilerNode;
        function ReadLongEvaluatedArgument: THCmdQueryCompilerNode;
        function ReadBody: THCmdQueryCompilerNode;
    public
        procedure ReadArguments(var ATo: THCmdQueryCompilerNode);
    public
        function ReadSentence: THCmdQueryCompilerNode;
        function ReadText: THCmdQueryCompilerNode;
    public
        function CompileText(const ASourceCode: UnicodeString; const AFileName: UnicodeString = '<In-Memory>'): THCmdQueryCompilerNode;
    public
        constructor Create;
    end;

implementation

{ THCmdQueryCompilerNode }

function THCmdQueryCompilerNode.ToString: UnicodeString;
var i: Integer;
begin
    case NodeType of
        THCmdQueryCompilerNodeType.Integer:
            Result := UnicodeString(IntToStr(DataInt64));
        THCmdQueryCompilerNodeType.Double:
            Result := UnicodeString(FloatToStr(DataDouble));
        THCmdQueryCompilerNodeType.Variable:
            Result := '$' + DataString;
        THCmdQueryCompilerNodeType.UnicodeString:
            Result := '"' + DataString + '"';
        THCmdQueryCompilerNodeType.Evaluated:
            begin
                Result := '(' + DataString;

                for i := 0 to Children.Count - 1 do begin
                    if i > 0 then
                        Result := Result + ',';
                    Result := Result + ' ' + Children.Items[i].ToString;
                end;

                Result := Result + ')';
            end;
        THCmdQueryCompilerNodeType.LongEvaluated:
            begin
                Result := '(#!LONG_EVAL)';
            end;
        THCmdQueryCompilerNodeType.Body:
            begin
                Result := '{ ';
                for i := 0 to Children.Count - 1 do
                    Result := Result + Children.Items[i].ToString + '; ';

                Result := Result + '}';
            end;
        THCmdQueryCompilerNodeType.Indexing:
            begin
                Result := Children.Items[0].ToString + '[' + Children.Items[1].ToString + ']';
            end;
        THCmdQueryCompilerNodeType.FieldIndexing:
            begin
                Result := Children.Items[0].ToString + '.' + Children.Items[1].ToString;
            end;
        THCmdQueryCompilerNodeType.MethodCall:
            begin
                Result := '(' + Children.Items[0].ToString + '.' + Children.Items[1].ToString + '!';
                for i := 2 to Children.Count - 1 do begin
                    if i > 0 then
                        Result := Result + ',';
                    Result := Result + ' ' + Children.Items[i].ToString;
                end;
            end;
        THCmdQueryCompilerNodeType.Parameter:
            begin
                Result := Children.Items[0].ToString + '=' + Children.Items[1].ToString;
            end;
    end;
end;

constructor THCmdQueryCompilerNode.Create(const ANodeType: THCmdQueryCompilerNodeType; const APosition: THCmdQueryPosition);
begin
    inherited Create;

    NodeType := ANodeType;
    NodePosition := APosition;
    Children.Nullify;
end;

constructor THCmdQueryCompilerNode.CreateInt64(const AValue: Int64; const APosition: THCmdQueryPosition);
begin
    Create(THCmdQueryCompilerNodeType.Integer, APosition);

    DataInt64 := AValue;
end;

constructor THCmdQueryCompilerNode.CreateDouble(const AValue: Double; const APosition: THCmdQueryPosition);
begin
    Create(THCmdQueryCompilerNodeType.Double, APosition);

    DataDouble := AValue;
end;

constructor THCmdQueryCompilerNode.CreateString(const AValue: UnicodeString; const APosition: THCmdQueryPosition);
begin
    Create(THCmdQueryCompilerNodeType.UnicodeString, APosition);

    DataString := AValue;
    // DataInt64 will contain hash of static string, just in case to boost a speed of access, if possible
    DataInt64 := HashUnicodeString(DataString);
end;

constructor THCmdQueryCompilerNode.CreateVariable(const AName: UnicodeString; const APosition: THCmdQueryPosition);
begin
    Create(THCmdQueryCompilerNodeType.Variable, APosition);
    DataString := AName;
    DataInt64 := HashUnicodeString(DataString);
end;

destructor THCmdQueryCompilerNode.Destroy;
var Child: THCmdQueryCompilerNode;
begin
    for Child in Children do begin
        if Assigned(Child) then
            Child.Free;
    end;

    inherited Destroy;
end;

{ THCmdQueryCompiler }

class function THCmdQueryCompiler.DecodeEscapeChar(const AChar: UnicodeChar): UnicodeChar;
begin
    case AChar of
        'r': Result := #13;
        'n': Result := #10;
    else
        Result := AChar;
    end;
end;

function THCmdQueryCompiler.ReadConstantString: UnicodeString;
var Next: UnicodeChar;
begin
    Result := '';

    while not FStringStream.EOF and not CharInSet(FStringStream.PeekChar, [' ', '[', '(', '{', ']', ')', '}', ';']) do begin
        Next := FStringStream.PeekNextOrDefault(1);

        if CharInSet(FStringStream.PeekChar, [ '=', '.' ]) and not Result.IsEmpty and CharInSet(Next, [ '(', '[', '{', '$', '<', '''', '"', 'a'..'z', 'A'..'Z', '_', '+', '-', '0'..'9' ]) then
            Break;
        if (FStringStream.PeekChar = '!') and not Result.IsEmpty and ((Next <= ' ') or CharInSet(Next, [' ', '[', '(', '{', ']', ')', '}', ';'])) then
            Break;

        Result := Result + FStringStream.ReadChar;
    end;
end;

function THCmdQueryCompiler.ReadArgumentIndexing(const AParent: THCmdQueryCompilerNode): THCmdQueryCompilerNode;
var C: UnicodeChar;
begin
    Result := THCmdQueryCompilerNode.Create(THCmdQueryCompilerNodeType.Indexing, Position);
    Result.Children.Add(AParent);

    //FStringStream.ReadChar;

    try
        Result.Children.Add(ReadArgument(False));

        if FStringStream.EOF then
            raise EHCmdQueryCompilationException.Create('Argument indexing is not closed', Result.NodePosition);

        C := FStringStream.ReadChar;
        if not (C = ']') then
            raise EHCmdQueryCompilationException.Create('Argument indexing should be closed with `]`, but `%s` was found', [ C ], Result.NodePosition);
    except
        Result.Free;
        Result := nil;

        raise;
    end;
end;

function THCmdQueryCompiler.ReadArgumentFieldIndexing(const AParent: THCmdQueryCompilerNode): THCmdQueryCompilerNode;
begin
    Result := THCmdQueryCompilerNode.Create(THCmdQueryCompilerNodeType.FieldIndexing, Position);
    Result.Children.Add(AParent);

    //FStringStream.ReadChar;

    try
        Result.Children.Add(ReadArgument(True));
    except
        Result.Free;
        Result := nil;

        raise;
    end;
end;

function THCmdQueryCompiler.ReadParameter(const AParent: THCmdQueryCompilerNode): THCmdQueryCompilerNode;
var Start: THCmdQueryPosition;
begin
    Result := THCmdQueryCompilerNode.Create(THCmdQueryCompilerNodeType.Parameter, AParent.NodePosition);
    Result.Children.Add(AParent);

    FStringStream.ReadChar;

    try
        Result.Children.Add(ReadArgument);

        //if Result.Children[1].NodeType = THCmdQueryCompilerNodeType.LongEvaluated then
        //    raise EHCmdQueryCompilationException.Create('Parameter cannot have complex evaluated argument as its value', Result.Children[1].NodePosition);
    except
        Result.Free;
        Result := nil;

        raise;
    end;
end;

function THCmdQueryCompiler.ReadArgument(const ADisablePostProcessing: Boolean; const AAllowParameters: Boolean): THCmdQueryCompilerNode;
var C: UnicodeChar;
    TempPos: THCmdQueryPosition;
begin
    Result := nil;

    FStringStream.IgnoreSpace;
    if FStringStream.EOF then
        raise EHCmdQueryCompilationException.Create('Expected argument, but <EOF> (end-of-file) found', Position);

    C := FStringStream.PeekChar;

    case C of
        ']', ')', '}', ';':
            begin
                raise EHCmdQueryCompilationException.Create('Empty arguments are not allowed', Position);
            end;
        '-':
            begin
                { Canonical way of writing HCmdQuery code requires interpreter to support `->` as continuty operator
                }
                if FStringStream.PeekNextOrDefault(1) = '>' then begin
                    {#! Compile continuity }
                    FStringStream.ReadChar;

                    Result := ReadLastEvaluatedArgument;
                    Exit;
                end;

                // Else - it is going to be a number
                Result := ReadNumber;
            end;
        '+', '0'..'9':
            begin
                // It is probably a number
                Result := ReadNumber;
            end;
        '$':
            begin
                // It is a variable
                Result := ReadVariable;
            end;
        '''', '"':
            begin
                // It is a string
                Result := ReadString;
            end;
        '<':
            begin
                if (FStringStream.PeekNextOrDefault(1) = '<') and (FStringStream.PeekNextOrDefault(2) = '<') then
                    Result := ReadBigString
                else
                    Result := ReadUnquotedString;
            end;
        '[':
            begin
                Result := ReadEvaluatedArgument;
            end;
        '(':
            begin
                Result := ReadLongEvaluatedArgument;
                if (Result.NodeType = THCmdQueryCompilerNodeType.LongEvaluated) and not AAllowParameters then begin
                    TempPos := Result.NodePosition;
                    Result.Free;
                    Result := nil;

                    raise EHCmdQueryCompilationException.Create('Evaluated argument (complex) is not applicable there', TempPos);
                end;
            end;
        '{':
            begin
                Result := ReadBody;
            end;
        ':':
            begin
                Result := ReadLastEvaluatedArgument;
                Exit;
            end;
    else
        Result := ReadUnquotedString;

        if FStringStream.PeekNextOrDefault(0) = '(' then begin
            // Syntax extension
            Result.NodeType := THCmdQueryCompilerNodeType.Evaluated;

            FStringStream.ReadChar;
            ReadArguments(Result);

            C := FStringStream.ReadChar;

            if not (C = ')') then
                raise EHCmdQueryCompilationException.Create('Function call should end with `)`, but it ended with `%s`', [ C ], FStringStream.Position);

            //Exit;
        end;
    end;

    // FStringStream.IgnoreSpace;

    if ADisablePostProcessing then
        Exit;

    while CharInSet(FStringStream.PeekNextOrDefault(0), [ '[', '.' ]) do begin
        C := FStringStream.ReadChar;
        // FStringStream.IgnoreSpace;

        if C = '[' then
            Result := ReadArgumentIndexing(Result)
        else
            Result := ReadArgumentFieldIndexing(Result);
    end;

    if (Result.NodeType = THCmdQueryCompilerNodeType.FieldIndexing) and (FStringStream.PeekNextOrDefault(0) = '!') and (FStringStream.PeekNextOrDefault(1) = '(') then begin
        Result.NodeType := THCmdQueryCompilerNodeType.MethodCall;

        FStringStream.ReadChar;
        FStringStream.ReadChar;
        ReadArguments(Result);

        C := FStringStream.ReadChar;

        if not (C = ')') then
            raise EHCmdQueryCompilationException.Create('Method call should end with `)`, but it ended with `%s`', [ C ], FStringStream.Position);

        Exit;
    end;

    if not AAllowParameters or (Result.NodeType = THCmdQueryCompilerNodeType.LongEvaluated) then
        Exit;

    if FStringStream.PeekNextOrDefault(0) = '=' then
        // It is parameter
        Result := ReadParameter(Result);
end;

function THCmdQueryCompiler.ReadNumber: THCmdQueryCompilerNode;
var NumberString: UnicodeString;
    Start: THCmdQueryPosition;
    OutInt64: Int64;
    OutDouble: Double;
begin
    Result := nil;

    Start := Position;
    NumberString := FStringStream.ReadChar;

    while not FStringStream.EOF and CharInSet(FStringStream.PeekChar, ['-', '+', '.', '0'..'9', 'e', 'E']) do
        NumberString := NumberString + FStringStream.ReadChar;

    if NumberString.TryToInt64(OutInt64) then begin
        Result := THCmdQueryCompilerNode.CreateInt64(OutInt64, Start);
        Exit;
    end;

    if NumberString.TryToDouble(OutDouble) then begin
        Result := THCmdQueryCompilerNode.CreateDouble(OutDouble, Start);
        Exit;
    end;

    raise EHCmdQueryCompilationException.Create('Malformed number `%s` (cannot be understood by HCmdQuery source code compiler)', [ NumberString ], Start);
end;

function THCmdQueryCompiler.ReadVariable: THCmdQueryCompilerNode;
var VarString: UnicodeString;
    Start: THCmdQueryPosition;
    C: UnicodeChar;
begin
    // Assuming the call was made from `$` character
    Start := Position;
    FStringStream.ReadChar;

    VarString := '';
    // Using PeekNextOrDefault, because we actually can have variable name placed in the end of text and without the variable name itself
    C := FStringStream.PeekNextOrDefault(0);

    while C.IsLetterOrDigit or (C = '_') do begin
        FStringStream.ReadChar;

        VarString := VarString + C;

        C := FStringStream.PeekNextOrDefault(0);
    end;

    Result := THCmdQueryCompilerNode.CreateVariable(VarString, Start);
end;

function THCmdQueryCompiler.ReadUnquotedString: THCmdQueryCompilerNode;
var Start: THCmdQueryPosition;
begin
    Start := Position;
    Result := THCmdQueryCompilerNode.CreateString(ReadConstantString, Start);
end;

function THCmdQueryCompiler.ReadString: THCmdQueryCompilerNode;
var QuoteChar, C: UnicodeChar;
    Start: THCmdQueryPosition;
    ValueString: UnicodeString;
begin
    Start := Position;
    QuoteChar := FStringStream.ReadChar;

    ValueString := '';

    while not FStringStream.EOF and not (FStringStream.StringStream.PeekChar = QuoteChar) do begin
        C := FStringStream.StringStream.ReadChar;

        if not (C = '\') then begin
            ValueString := ValueString + C;
            Continue;
        end;

        if FStringStream.EOF then
            Break;

        C := DecodeEscapeChar(FStringStream.StringStream.ReadChar);
        ValueString := ValueString + C;
    end;

    if FStringStream.EOF then
        raise EHCmdQueryCompilationException.Create('String was not closed', Start);

    // Skip closing quote
    // Not FStringStream.StringStream.ReadChar, because we want to skip spaces and other things at the end of argument
    FStringStream.ReadChar;

    Result := THCmdQueryCompilerNode.CreateString(ValueString, Start);
end;

function THCmdQueryCompiler.ReadBigString: THCmdQueryCompilerNode;
var C: UnicodeChar;
    Start: THCmdQueryPosition;
    TempString, ValueString: UnicodeString;
    CanBeSeparated: Boolean;
begin
    TempString := '';
    ValueString := '';

    Start := Position;

    // Skip the beginning
    FStringStream.StringStream.ReadChar;
    FStringStream.StringStream.ReadChar;
    FStringStream.StringStream.ReadChar;

    if FStringStream.StringStream.PeekNextOrDefault(0) = #13 then
        FStringStream.StringStream.ReadChar;

    CanBeSeparated := True;

    while not FStringStream.EOF and not ((FStringStream.PeekNextOrDefault(0) = '>') and (FStringStream.PeekNextOrDefault(1) = '>') and (FStringStream.PeekNextOrDefault(2) = '>')) do begin
        C := FStringStream.StringStream.ReadChar;

        if C = #13 then begin
            CanBeSeparated := True;

            ValueString := ValueString + TempString;
            TempString := #13;

            Continue;
        end;

        if (C = '*') and CanBeSeparated then begin
            CanBeSeparated := False;

            if FStringStream.PeekNextOrDefault(0) = ' ' then
                FStringStream.StringStream.ReadChar;

            if (TempString.Length > 0) and (TempString[1] = #13) then
                TempString := #13
            else
                TempString := '';

            Continue;
        end;

        if C > ' ' then
            CanBeSeparated := False;

        if not (C = '\') then begin
            TempString := TempString + C;
            Continue;
        end;

        if FStringStream.EOF then
            Break;

        C := DecodeEscapeChar(FStringStream.StringStream.ReadChar);
        TempString := TempString + C;
    end;

    if FStringStream.EOF then
        raise EHCmdQueryCompilationException.Create('Big (multiline) string was not closed', Start);

    if not CanBeSeparated then
        ValueString := ValueString + TempString;

    FStringStream.StringStream.ReadChar;
    FStringStream.StringStream.ReadChar;
    FStringStream.ReadChar;

    Result := THCmdQueryCompilerNode.CreateString(ValueString, Start);
end;

function THCmdQueryCompiler.ReadEvaluatedArgument: THCmdQueryCompilerNode;
var Start: THCmdQueryPosition;
    C: UnicodeChar;
begin
    Start := Position;
    FStringStream.ReadChar;

    Result := ReadSentence;

    if FStringStream.EOF then begin
        Result.Free;
        Result := nil;

        raise EHCmdQueryCompilationException.Create('Evaluated argument is not closed', Start);
    end;

    FStringStream.IgnoreSpace;
    C := FStringStream.ReadChar;
    if not (C = ']') then
        raise EHCmdQueryCompilationException.Create('Expected `]` to close an evaluated argument, however `%s` was found', [ C ], Start);
end;

function THCmdQueryCompiler.ReadLastEvaluatedArgument: THCmdQueryCompilerNode;
var Start: THCmdQueryPosition;
begin
    FStringStream.ReadChar;

    Start := Position;

    Result := ReadSentence;
end;

function THCmdQueryCompiler.ReadLongEvaluatedArgument: THCmdQueryCompilerNode;
var Start: THCmdQueryPosition;
    C: UnicodeChar;
    TempNode: THCmdQueryCompilerNode;
begin
    Start := Position;
    Result := THCmdQueryCompilerNode.Create(THCmdQueryCompilerNodeType.LongEvaluated, Start);

    FStringStream.ReadChar;

    try
        C := #0;

        while not FStringStream.EOF do begin
            TempNode := ReadSentence;
            Result.Children.Add(TempNode);

            if FStringStream.EOF then
                Break;

            FStringStream.IgnoreSpace;
            C := FStringStream.ReadChar;

            if C = ';' then
                Continue;

            Break;
        end;

        if FStringStream.EOF and not (C = ')') then
            raise EHCmdQueryCompilationException.Create('Evaluated argument (complex) is not closed', Start);
        if not (C = ')') then
            raise EHCmdQueryCompilationException.Create('Expected `)` to close an evaluated argument (complex), however `%s` was found', [ C ], Start);

        // Just to bring it to normal form
        if Result.Children.Count = 1 then begin
            TempNode := Result.Children.Items[0];
            Result.Children.Remove;
            Result.Free;

            Result := TempNode;
        end;
    except
        Result.Free;
        Result := nil;

        raise;
    end;
end;

function THCmdQueryCompiler.ReadBody: THCmdQueryCompilerNode;
var Start: THCmdQueryPosition;
    C: UnicodeChar;
    TempNode: THCmdQueryCompilerNode;
begin
    Start := Position;
    Result := THCmdQueryCompilerNode.Create(THCmdQueryCompilerNodeType.Body, Start);

    FStringStream.ReadChar;

    try
        C := #0;

        while not FStringStream.EOF do begin
            FStringStream.IgnoreSpace;
            if FStringStream.PeekChar = '}' then begin
                C := FStringStream.ReadChar;
                Break;
            end;

            TempNode := ReadSentence;
            Result.Children.Add(TempNode);

            if FStringStream.EOF then
                Break;

            FStringStream.IgnoreSpace;
            C := FStringStream.ReadChar;

            if C = ';' then
                Continue;

            Break;
        end;

        if FStringStream.EOF and not (C = '}') then
            raise EHCmdQueryCompilationException.Create('Body argument is not closed', Start);
        if not (C = '}') then
            raise EHCmdQueryCompilationException.Create('Expected `}` to close an evaluated argument (complex), however `%s` was found', [ C ], Start);
    except
        Result.Free;
        Result := nil;

        raise;
    end;
end;

procedure THCmdQueryCompiler.ReadArguments(var ATo: THCmdQueryCompilerNode);
var TempNode: THCmdQueryCompilerNode;
    i: Integer;
begin
    FStringStream.IgnoreSpace;

    while not FStringStream.EOF and not CharInSet(FStringStream.PeekChar, [ ';', ')', ']', '}' ]) do begin
        try
            TempNode := ReadArgument(False, True);
            FStringStream.IgnoreSpace;

            if TempNode.NodeType = THCmdQueryCompilerNodeType.LongEvaluated then begin
                for i := 0 to TempNode.Children.Count - 1 do
                    ATo.Children.Add(TempNode.Children.Items[i]);
                TempNode.Children.Clear;
                TempNode.Free;
                TempNode := nil;
            end
            else
                ATo.Children.Add(TempNode);
        except
            ATo.Free;
            ATo := nil;

            raise;
        end;
    end;
end;

function THCmdQueryCompiler.ReadSentence: THCmdQueryCompilerNode;
var C: UnicodeChar;
    i: Integer;
    TempNode: THCmdQueryCompilerNode;
begin
    FStringStream.IgnoreSpace;

    Result := nil;
    if FStringStream.EOF then
        raise EHCmdQueryCompilationException.Create('Expression cannot be empty', Position);

    C := FStringStream.PeekChar;

    if CharInSet(C, [ '}', ']', ')', ';' ]) then
        raise EHCmdQueryCompilationException.Create('Expression cannot be empty', Position);

    Result := THCmdQueryCompilerNode.Create(THCmdQueryCompilerNodeType.Evaluated, Position);

    if CharInSet(C, [ '{', '(', ']' ]) or CharInSet(C, ['+', '0'..'9']) or (C = '$') or (C = '''') or (C = '"') then begin
        // It is probably the argument
        try
            TempNode := ReadArgument(False, True);
        except
            Result.Free;
            Result := nil;

            raise;
        end;

        if (TempNode.NodeType = THCmdQueryCompilerNodeType.FieldIndexing) and (FStringStream.PeekNextOrDefault(0) = '!') then begin
            // It is a method call
            FStringStream.ReadChar;

            Result.Free;

            Result := TempNode;
            Result.NodeType := THCmdQueryCompilerNodeType.MethodCall;
        end
        else if TempNode.NodeType = THCmdQueryCompilerNodeType.LongEvaluated then begin
            // Need to unbox the node
            for i := 0 to TempNode.Children.Count - 1 do
                Result.Children.Add(TempNode.Children.Items[i]);

            TempNode.Free;
        end
        else
            Result.Children.Add(TempNode);

        FStringStream.IgnoreSpace;
    end;

    if Result.NodeType = THCmdQueryCompilerNodeType.Evaluated then begin
        Result.DataString := ReadConstantString;

        if Result.DataString.IsEmpty and (Result.Children.Count > 0) then begin
            Result.Free;
            Result := nil;

            raise EHCmdQueryCompilationException.Create('Infix expression notation requires function after a first argument (however, it was not found)', Position);
        end;
    end;

    ReadArguments(Result);
end;

function THCmdQueryCompiler.ReadText: THCmdQueryCompilerNode;
begin
    Result := THCmdQueryCompilerNode.Create(THCmdQueryCompilerNodeType.Body, Position);

    while not FStringStream.EOF do begin
        try
            Result.Children.Add(ReadSentence);
            if not FStringStream.EOF and not (FStringStream.PeekChar = ';') then
                raise EHCmdQueryCompilationException.Create('Expected `;` to end the sentence, however `%s` was found', [ FStringStream.PeekChar ], Position);

            if not FStringStream.EOF then
                FStringStream.ReadChar;
        except
            Result.Free;
            Result := nil;

            raise;
        end;
    end;
end;

function THCmdQueryCompiler.CompileText(const ASourceCode: UnicodeString; const AFileName: UnicodeString): THCmdQueryCompilerNode;
begin
    FStringStream := THCmdQueryCompilerStringStream.Create(ASourceCode);
    FStringStream.StringStream.Position.FileName := AFileName;

    Result := ReadText;
end;

constructor THCmdQueryCompiler.Create;
begin
    inherited Create;
end;

end.

