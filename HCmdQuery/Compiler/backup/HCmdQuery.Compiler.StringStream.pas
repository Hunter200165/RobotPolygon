unit HCmdQuery.Compiler.StringStream;

{$I HCmdQuery.inc}

interface

uses
    HCL.Core.StringUtils,
    HCmdQuery.Types,
    HCmdQuery.Kernel.Types;

type

    (* THCmdQueryStringStream
    *)
    THCmdQueryStringStream = record
    private
        WasCR: Boolean;
    public
        StringValue: UnicodeString;
        StringLength: Integer;
    public
        Index: Integer;
        Position: THCmdQueryPosition;
    public
        function EOF: Boolean;
    public
        function PeekChar: UnicodeChar;
        function ReadChar: UnicodeChar;
        function PeekNext(const AOffset: Integer; out AResult: UnicodeChar): Boolean;
        function PeekNextOrDefault(const AOffset: Integer; const ADefault: UnicodeChar = #0): UnicodeChar;
    public
        constructor Create(const AValue: UnicodeString);
    end;

    (* THCmdQueryCompilerStringStream *)

    THCmdQueryCompilerStringStream = record
    private var
        WasSpace: Boolean;
    public
        StringStream: THCmdQueryStringStream;
    public
        property Position: THCmdQueryPosition read StringStream.Position write StringStream.Position;
    private
        procedure SkipSpacesAndComments;
        procedure SkipComment;
    public
        function EOF: Boolean;
        function IgnoreSpace: Boolean;
    public
        function PeekChar: UnicodeChar;
        { Inline, because they are just tail calls }
        function PeekNext(const AOffset: Integer; out AResult: UnicodeChar): Boolean; inline;
        function PeekNextOrDefault(const AOffset: Integer; const ADefault: UnicodeChar = #0): UnicodeChar; inline;
        function ReadChar: UnicodeChar;
    public
        constructor Create(const AValue: UnicodeString);
    end;

implementation

{ THCmdQueryStringStream }

function THCmdQueryStringStream.EOF: Boolean;
begin
    Result := Index > StringLength;
end;

function THCmdQueryStringStream.PeekChar: UnicodeChar;
begin
    if Index > StringLength then
        raise EHCmdQueryCompilationException.Create('Unexpected <EOF> (end of file)', Position);

    Result := StringValue[Index];

    if Result = #13 then
        WasCR := True;

    // We convert any line ending to #13 and just ignore other one, which may or may not appear
    if Result = #10 then
        Result := #13;
end;

function THCmdQueryStringStream.ReadChar: UnicodeChar;
begin
    Result := PeekChar;

    Inc(Index);
    Position.IncChar;

    if WasCR and (Index <= StringLength) then begin
        WasCR := False;
        Inc(Index);
        Position.IncLine;
    end;
end;

function THCmdQueryStringStream.PeekNext(const AOffset: Integer; out AResult: UnicodeChar): Boolean;
begin
    Result := False;
    if (Index + AOffset) > StringLength then
        Exit;

    Result := True;
    AResult := StringValue[Index + AOffset];
end;

function THCmdQueryStringStream.PeekNextOrDefault(const AOffset: Integer; const ADefault: UnicodeChar): UnicodeChar;
begin
    if not PeekNext(AOffset, Result) then
        Result := ADefault;
end;

constructor THCmdQueryStringStream.Create(const AValue: UnicodeString);
begin
    StringValue := AValue;
    StringLength := StringValue.Length;
    Index := 1;
    WasCR := False;
end;

{ THCmdQueryCompilerStringStream }

procedure THCmdQueryCompilerStringStream.SkipSpacesAndComments;
var C: UnicodeChar;
begin
    if StringStream.EOF then
        Exit;

    C := StringStream.PeekChar;

    while (C = '#') or (C = ',') or (C <= ' ') do begin
        WasSpace := True;

        C := StringStream.ReadChar;

        if C = '#' then
            SkipComment;

        if StringStream.EOF then
            Break;

        C := StringStream.PeekChar;
    end;
end;

procedure THCmdQueryCompilerStringStream.SkipComment;
begin
    while not StringStream.EOF and not (StringStream.ReadChar = #13) do
        // Empty body
        ;
end;

function THCmdQueryCompilerStringStream.EOF: Boolean;
begin
    Result := StringStream.Index > StringStream.StringLength;
end;

function THCmdQueryCompilerStringStream.IgnoreSpace: Boolean;
begin
    Result := WasSpace;
    WasSpace := False;
end;

function THCmdQueryCompilerStringStream.PeekChar: UnicodeChar;
begin
    if WasSpace then begin
        Result := ' ';
        Exit;
    end;

    Result := StringStream.PeekChar;
end;

function THCmdQueryCompilerStringStream.PeekNext(const AOffset: Integer; out AResult: UnicodeChar): Boolean;
begin
    if (AOffset = 0) and WasSpace then begin
        AResult := ' ';
        Result := True;
        Exit;
    end;

    Result := StringStream.PeekNext(AOffset, AResult);
end;

function THCmdQueryCompilerStringStream.PeekNextOrDefault(const AOffset: Integer; const ADefault: UnicodeChar): UnicodeChar;
begin
    if (AOffset = 0) and WasSpace then begin
        Result := ' ';
        Exit;
    end;

    Result := StringStream.PeekNextOrDefault(AOffset, ADefault);
end;

function THCmdQueryCompilerStringStream.ReadChar: UnicodeChar;
begin
    if WasSpace then begin
        Result := ' ';
        WasSpace := False;
        Exit;
    end;

    Result := StringStream.ReadChar;

    SkipSpacesAndComments;
end;

constructor THCmdQueryCompilerStringStream.Create(const AValue: UnicodeString);
begin
    WasSpace := False;
    StringStream := THCmdQueryStringStream.Create(AValue);
    SkipSpacesAndComments;
end;

end.

