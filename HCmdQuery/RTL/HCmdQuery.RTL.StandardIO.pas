unit HCmdQuery.RTL.StandardIO;

{$I HCmdQuery.inc}

interface

uses
    SysUtils,
    HCmdQuery.SafeVariant,
    HCmdQuery.Format,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary;

procedure HCmdQuery_StandardIO_Write(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_StandardIO_Print(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_StandardIO_PrintF(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

implementation

procedure HCmdQuery_StandardIO_Write(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    i: Integer;
    Res: UnicodeString;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    Res := '';
    for i := 0 to CBF.ArgumentStackCount - 1 do begin
        if i > 0 then
            Res := Res + #9;
        Res := Res + CBF.ExpectValue(i).GetSimpleString;
    end;

    if @AInterpreter.Interfaces.Interpreter.WriteToStdOut = nil then
        raise EHCmdQueryRuntimeException.Create('write[]: Writing to standard input is not supported', CBF.Position^);
    AInterpreter.Interfaces.Interpreter.WriteToStdOut(Res);

    AResult^ := CBF.AllocateString(Res);
end;

procedure HCmdQuery_StandardIO_Print(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    i: Integer;
    Res: UnicodeString;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    Res := '';
    for i := 0 to CBF.ArgumentStackCount - 1 do begin
        if i > 0 then
            Res := Res + #9;
        Res := Res + CBF.ExpectValue(i).GetSimpleString;
    end;

    if @AInterpreter.Interfaces.Interpreter.WriteToStdOut = nil then
        raise EHCmdQueryRuntimeException.Create('print[]: Writing to standard input is not supported', CBF.Position^);

    AInterpreter.Interfaces.Interpreter.WriteToStdOut(Res + LineEnding);

    AResult^ := CBF.AllocateString(Res);
end;

procedure HCmdQuery_StandardIO_PrintF(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Args: array of SafeVariant;
    FmtString: UnicodeString;
    i: Integer;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    FmtString := CBF.ExpectString(0, 'sprintf[0]: Expected format string');

    Args := nil;
    SetLength(Args, CBF.ArgumentStackCount - 1);

    for i := 0 to Length(Args) - 1 do
        Args[i] := CBF.ExpectValue(i + 1);

    try
        AResult^ := CBF.AllocateString(HCmdQuery_Format(FmtString, Args));
    except
        on E: EFormatError do begin
            raise EHCmdQueryRuntimeException.Create('sprintf[]: ' + UnicodeString(E.Message), CBF.Position^);
        end;
    end;

    if @AInterpreter.Interfaces.Interpreter.WriteToStdOut = nil then
        raise EHCmdQueryRuntimeException.Create('printf[]: Writing to standard input is not supported', CBF.Position^);

    AInterpreter.Interfaces.Interpreter.WriteToStdOut(AResult.AsString.Value);
end;

end.

