unit HCmdQuery.RTL.Format;

{$I HCmdQuery.inc}

interface

uses
    SysUtils,
    HCmdQuery.SafeVariant,
    HCmdQuery.Format,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary;

procedure HCmdQuery_Format_Sprintf(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

implementation

procedure HCmdQuery_Format_Sprintf(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
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
end;

end.

