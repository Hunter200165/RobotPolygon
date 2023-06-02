unit HCmdQuery.Format;

{$I HCmdQuery.inc}

interface

uses
    SysUtils,
    HCL.Core.Commons,
    HCL.Core.StringUtils,
    HCmdQuery.SafeVariant;

function HCmdQuery_Format(const AFmt: UnicodeString; const AArgs: array of SafeVariant): UnicodeString;

implementation

type
    TFormatAnchorType = (
        Integer,
        Real,
        UnicodeString
    );

    { TFormatAnchor }

    TFormatAnchor = record
    public const
        FormatAnchors: array [TFormatAnchorType] of Char = ('d', 'f', 's');
    public var
        AnchorType: TFormatAnchorType;
        Precision: Integer;
        Width: Integer;
        LeftAlign: Boolean;
        ReadIndex: Integer;
        FormatAnchorIndex: Integer;
    public
        function FormatArgument(const AArguments: PSafeVariant; const AArgsCount: Integer; var ACurrentIndex: Integer): UnicodeString;
    public
        function ToString: UnicodeString;
        procedure Nullify;
    end;

function HCmdQuery_Format(const AFmt: UnicodeString; const AArgs: array of SafeVariant): UnicodeString;
var i, AnchorIndex, ArgIndex: Integer;
    FmtString: UnicodeString;
    GlobalResult: UnicodeString absolute Result;
    FmtAnchor: TFormatAnchor;
{ Aux }
    function ReadNumber: Integer;
    begin
        Result := 0;
        if (i <= AFmt.Length) and (AFmt[i] = '*') then begin
            FmtString := FmtString + AFmt[i];
            i := i + 1;
            Result := -1;
            Exit;
        end;

        while (i <= AFmt.Length) and AFmt[i].IsDigit do begin
            Result := Result * 10 + (Ord(AFmt[i]) - Ord('0'));
            if Result > 200000000 then begin
                Result := -2;
                Exit;
            end;
            FmtString := FmtString + AFmt[i];
            i := i + 1;
        end;
    end;

    function IsInvalid(const APredicate: Boolean): Boolean;
    begin
        Result := APredicate;
        if APredicate then
            GlobalResult := GlobalResult + FmtString;
    end;

    function ReadAnchorType: Boolean;
    begin
        FmtString := FmtString + AFmt[i];

        Result := True;
        case AFmt[i] of
            'd': FmtAnchor.AnchorType := TFormatAnchorType.Integer;
            'f': FmtAnchor.AnchorType := TFormatAnchorType.Real;
            's': FmtAnchor.AnchorType := TFormatAnchorType.UnicodeString;
        else
            GlobalResult := GlobalResult + FmtString;
            i := i + 1;
            Result := False;
        end;
    end;
{ Main }
begin
    i := 1;

    AnchorIndex := 0;
    ArgIndex := 0;

    Result := '';
    while i < AFmt.Length do begin
        if not (AFmt[i] = '%') then begin
            Result := Result + AFmt[i];
            i := i + 1;
            Continue;
        end;

        // Control character
        i := i + 1;

        FmtAnchor.Nullify;
        FmtString := '%';
        //AnchorIndex := AnchorIndex + 1;
        case AFmt[i] of
            'd': FmtAnchor.AnchorType := TFormatAnchorType.Integer;
            'f': FmtAnchor.AnchorType := TFormatAnchorType.Real;
            's': FmtAnchor.AnchorType := TFormatAnchorType.UnicodeString;

            '0'..'9':
                begin
                    // It is either index or width
                    //FmtString := '%';
                    FmtAnchor.ReadIndex := ReadNumber;
                    if IsInvalid(FmtAnchor.ReadIndex = -2) or IsInvalid(i > AFmt.Length) then
                        Continue;
                    if not (AFmt[i] = ':') then begin
                        // It was width
                        FmtAnchor.Width := FmtAnchor.ReadIndex;
                        FmtAnchor.ReadIndex := -1;
                    end
                    else begin
                        // Width should follow
                        FmtString := FmtString + ':';
                        i := i + 1;
                        if IsInvalid(i > AFmt.Length) then
                            Continue;
                        if AFmt[i] = '-' then begin
                            FmtString := FmtString + '-';
                            i := i + 1;
                            FmtAnchor.LeftAlign := True;

                            if IsInvalid(i > AFmt.Length) then
                                Continue;
                        end;

                        FmtAnchor.Width := ReadNumber;
                        if IsInvalid(FmtAnchor.Width = -2) or IsInvalid(i > AFmt.Length) then
                            Continue;
                    end;

                    // Precision
                    if AFmt[i] = '.' then begin
                        FmtString := FmtString + '.';
                        i := i + 1;
                        if IsInvalid(i > AFmt.Length) then
                            Continue;

                        FmtAnchor.Precision := ReadNumber;
                        if IsInvalid(FmtAnchor.Precision = -2) or IsInvalid(i > AFmt.Length) then
                            Continue;
                    end;

                    if not ReadAnchorType then
                        Continue;
                end;
            ':':
                begin
                    FmtString := FmtString + ':';
                    FmtAnchor.ReadIndex := 0;
                    i := i + 1;

                    if IsInvalid(i > AFmt.Length) then
                        Continue;

                    if AFmt[i] = '-' then begin
                        FmtString := FmtString + '-';
                        i := i + 1;

                        FmtAnchor.LeftAlign := True;
                        if IsInvalid(i > AFmt.Length) then
                            Continue;
                    end;

                    FmtAnchor.Width := ReadNumber;
                    if IsInvalid(FmtAnchor.Width = -2) or (i > AFmt.Length) then
                        Continue;

                    if AFmt[i] = '.' then begin
                        FmtString := FmtString + '.';
                        i := i + 1;

                        if IsInvalid(i > AFmt.Length) then
                            Continue;

                        FmtAnchor.Precision := ReadNumber;
                        if IsInvalid(FmtAnchor.Precision = -2) or IsInvalid(i > AFmt.Length) then
                            Continue;
                    end;

                    if not ReadAnchorType then
                        Continue;
                end;
            '-':
                begin
                    FmtString := FmtString + '-';
                    i := i + 1;

                    FmtAnchor.LeftAlign := True;
                    if IsInvalid(i > AFmt.Length) then
                        Continue;

                    FmtAnchor.Width := ReadNumber;
                    if IsInvalid(FmtAnchor.Width = -2) or (i > AFmt.Length) then
                        Continue;

                    if AFmt[i] = '.' then begin
                        FmtString := FmtString + '.';
                        i := i + 1;

                        if IsInvalid(i > AFmt.Length) then
                            Continue;

                        FmtAnchor.Precision := ReadNumber;
                        if IsInvalid(FmtAnchor.Precision = -2) or IsInvalid(i > AFmt.Length) then
                            Continue;
                    end;

                    if not ReadAnchorType then
                        Continue;
                end;
            '*':
                begin
                    FmtString := FmtString + '*';
                    FmtAnchor.Width := -1;
                    i := i + 1;

                    if IsInvalid(i > AFmt.Length) then
                        Continue;

                    if AFmt[i] = '.' then begin
                        FmtString := FmtString + '.';
                        i := i + 1;

                        if IsInvalid(i > AFmt.Length) then
                            Continue;

                        FmtAnchor.Precision := ReadNumber;
                        if IsInvalid(FmtAnchor.Precision = -2) or IsInvalid(i > AFmt.Length) then
                            Continue;
                    end;

                    if not ReadAnchorType then
                        Continue;
                end;
            '.':
                begin
                    FmtString := FmtString + '.';
                    i := i + 1;

                    if IsInvalid(i > AFmt.Length) then
                        Continue;

                    FmtAnchor.Precision := ReadNumber;
                    if IsInvalid(FmtAnchor.Precision = -2) or IsInvalid(i > AFmt.Length) then
                        Continue;

                    if not ReadAnchorType then
                        Continue;
                end;
        else
            Result := Result + AFmt[i];
            //AnchorIndex := AnchorIndex - 1;
            i := i + 1;
            Continue;
        end;
        FmtAnchor.FormatAnchorIndex := AnchorIndex;
        AnchorIndex := AnchorIndex + 1;

        if Length(AArgs) > 0 then
            Result := Result + FmtAnchor.FormatArgument(@AArgs[0], Length(AArgs), ArgIndex)
        else
            Result := Result + FmtAnchor.FormatArgument(nil, 0, ArgIndex);

        i := i + 1;
    end;

    if i = AFmt.Length then
        Result := Result + AFmt[AFmt.Length];
end;

{ TFormatAnchor }

function TFormatAnchor.FormatArgument(const AArguments: PSafeVariant; const AArgsCount: Integer; var ACurrentIndex: Integer): UnicodeString;
var CurrentWidth, CurrentPrecision, i: Integer;
    Arg: PSafeVariant;
{ Aux }
    function RequireArgument(const ATypes: THCmdQueryVarTypes): PSafeVariant;
    begin
        if ACurrentIndex >= AArgsCount then begin
            raise EFormatError.CreateFmt('Format anchor #%d (%s) requires argument at index %d, however there is %d arguments overall', [ FormatAnchorIndex, ToString, ACurrentIndex, AArgsCount ]);
        end;

        if not (AArguments[ACurrentIndex].VarType in ATypes) then
            raise EFormatError.CreateFmt('Format anchor #%d (%s) requires argument at index %d to be %s, however argument was %s', [ FormatAnchorIndex, ToString, ACurrentIndex, HCmdQuery_VarSetToString(ATypes), AArguments[ACurrentIndex].GetTypeString ]);

        Result := AArguments + ACurrentIndex;
        ACurrentIndex := ACurrentIndex + 1;
    end;
{ Main }
begin
    if ReadIndex >= 0 then
        ACurrentIndex := ReadIndex;

    if Width = -1 then
        CurrentWidth := RequireArgument([ HCmdQueryVarType.Int64 ]).AsInteger
    else
        CurrentWidth := Width;

    if Precision = -1 then
        CurrentPrecision := RequireArgument([ HCmdQueryVarType.Int64 ]).AsInteger
    else
        CurrentPrecision := Precision;

    case AnchorType of
        TFormatAnchorType.Integer:
            Result := IntToStr(RequireArgument([ HCmdQueryVarType.Int64 ]).AsInteger);
        TFormatAnchorType.Real:
            begin
                if CurrentPrecision < 0 then
                    CurrentPrecision := 6;
                Arg := RequireArgument([ HCmdQueryVarType.Int64, HCmdQueryVarType.Double ]);
                if Arg.VarType = HCmdQueryVarType.Int64 then begin
                    if CurrentPrecision = 0 then
                        Result := IntToStr(Arg.AsInteger)
                    else
                        Result := FloatToStr(Arg.AsInteger, CurrentPrecision);
                end
                else if CurrentPrecision = 0 then
                    Result := FloatToStr(Arg.AsDouble, 6)
                else
                    Result := FloatToStr(Arg.AsDouble, CurrentPrecision);

                if Result.Contains('.') then begin
                    i := Result.Length;
                    while (i > 1) and not (Result[i - 1] = '.') and (Result[i] = '0') do
                        i := i - 1;
                    SetLength(Result, i);
                end;
            end;
        TFormatAnchorType.UnicodeString:
            Result := RequireArgument([ HCmdQueryVarType.SafeString ]).AsString.Value;
    end;

    if CurrentWidth > Result.Length then begin
        if LeftAlign then
            Result := Result.PadRight(' ', CurrentWidth)
        else
            Result := Result.PadLeft(' ', CurrentWidth);
    end;
end;

function TFormatAnchor.ToString: UnicodeString;
begin
    Result := '%';
    if not (ReadIndex = -1) then begin
        if ReadIndex > 0 then
            Result := Result + IntToStr(ReadIndex);
        Result := Result + ':';
    end;

    if LeftAlign then
        Result := Result + '-';

    if Width = -1 then
        Result := Result + '*'
    else if Width > 0 then
        Result := Result + IntToStr(Width);

    if Precision = -1 then
        Result := Result + '.*'
    else if Precision > 0 then
        Result := Result + '.' + IntToStr(Precision);

    Result := Result + Self.FormatAnchors[AnchorType];
end;

procedure TFormatAnchor.Nullify;
begin
    AnchorType := TFormatAnchorType.Integer;
    Precision := 0;
    Width := 0;
    LeftAlign := False;
    ReadIndex := -1;
end;

end.

