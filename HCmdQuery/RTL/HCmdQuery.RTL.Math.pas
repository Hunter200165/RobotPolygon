unit HCmdQuery.RTL.Math;

{$I HCmdQuery.inc}

interface

uses
    Math,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.CallBoundary;

procedure HCmdQuery_Math_Pi(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Math_Abs(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Round(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Floor(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Ceil(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Math_Frac(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Trunc(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Int(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Math_Exp(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Ln(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Math_Sqrt(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Sqr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Math_Sin(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Cos(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Tan(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_Cotan(const AInterpreter: PSafeObject; const AResult: PsafeVariant); cdecl;

procedure HCmdQuery_Math_ArcSin(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_ArcCos(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_ArcTan(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_ArcCotan(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Math_Randomize(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_RandomInteger(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Math_RandomFloat(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

implementation

uses
    SysUtils;

procedure HCmdQuery_Math_Pi(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := Pi;
end;

procedure HCmdQuery_Math_Abs(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Abs(CBF.ExpectNumber(0, 'math::abs[0]: Expected number to get absolute value of'));
end;

procedure HCmdQuery_Math_Round(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Round(CBF.ExpectNumber(0, 'math::round[0]: Expected number to round'));
end;

procedure HCmdQuery_Math_Floor(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Floor(CBF.ExpectNumber(0, 'math::floor[0]: Expected number to floor-round'));
end;

procedure HCmdQuery_Math_Ceil(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Ceil(CBF.ExpectNumber(0, 'math::ceil[0]: Expected number to ceil-round'));
end;

procedure HCmdQuery_Math_Frac(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Frac(CBF.ExpectNumber(0, 'math::frac[0]: Expected number to get fractional part of'));
end;

procedure HCmdQuery_Math_Trunc(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Trunc(CBF.ExpectNumber(0, 'math::trunc[0]: Expected number to truncate'));
end;

procedure HCmdQuery_Math_Int(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Int(CBF.ExpectNumber(0, 'math::int[0]: Expected number to get integer part of'));
end;

procedure HCmdQuery_Math_Exp(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Exp(CBF.ExpectNumber(0, 'math::exp[0]: Expected number as power to raise exponent to'));
end;

procedure HCmdQuery_Math_Ln(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Ln(CBF.ExpectNumber(0, 'math::ln[0]: Expected number to get natural logarithm of'));
end;

procedure HCmdQuery_Math_Sqrt(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Sqrt(CBF.ExpectNumber(0, 'math::sqrt[0]: Expected number to get square root from'));
end;

procedure HCmdQuery_Math_Sqr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Sqr(CBF.ExpectNumber(0, 'math::sqr[0]: Expected number to get square of'));
end;

procedure HCmdQuery_Math_Sin(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Sin(CBF.ExpectNumber(0, 'math::sin[0]: Expected number to get sine of'));
end;

procedure HCmdQuery_Math_Cos(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Cos(CBF.ExpectNumber(0, 'math::cos[0]: Expected number to get cosine of'));
end;

procedure HCmdQuery_Math_Tan(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Tan(CBF.ExpectNumber(0, 'math::tan[0]: Expected number to get tangent of'));
end;

procedure HCmdQuery_Math_Cotan(const AInterpreter: PSafeObject; const AResult: PsafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := Cotan(CBF.ExpectNumber(0, 'math::cotan[0]: Expected number to get cotangent of'));
end;

procedure HCmdQuery_Math_ArcSin(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := ArcSin(CBF.ExpectNumber(0, 'math::arcsin[0]: Expected number to get arcsine of'));
end;

procedure HCmdQuery_Math_ArcCos(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := ArcCos(CBF.ExpectNumber(0, 'math::arccos[0]: Expected number to get arccosine of'));
end;

procedure HCmdQuery_Math_ArcTan(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := ArcTan(CBF.ExpectNumber(0, 'math::arctan[0]: Expected number to get arctangent of'));
end;

procedure HCmdQuery_Math_ArcCotan(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := ArcCot(CBF.ExpectNumber(0, 'math::arccot[0]: Expected number to get arccotangent of'));
end;

var PRNGSeed: Cardinal;

procedure HCmdQuery_Math_Randomize(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    if CBF.ArgumentStackCount > 0 then
        PRNGSeed := CBF.ExpectInteger(0, 'math::randomize[0]: Expected integer seed for PRNG')
    else
        PRNGSeed := GetTickCount64;

    AResult^ := PRNGSeed;
end;

procedure HCmdQuery_Math_RandomInteger(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Min, Max: Int64;
    Res: UInt64;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(2);

    Min := 0;
    if CBF.ArgumentStackCount = 2 then begin
        Min := CBF.ExpectInteger(0, 'math::randint[0]: Expected integer lower bound of range');
        Max := CBF.ExpectInteger(1, 'math::randint[1]: Expected integer higher bound of range');
    end
    else
        Max := CBF.ExpectInteger(0, 'math::randint[0]: Expected integer higher bound of range');

    PRNGSeed := Cardinal(Int64(PRNGSeed) * 1103515245 + 12345);
    Res := PRNGSeed;
    PRNGSeed := Cardinal(Int64(PRNGSeed) * 1103515245 + 12345);
    Res := (Res shl 32) or PRNGSeed;

    Res := Res mod UInt64(Abs(Max - Min));
    Res := Res + Min;

    AResult^ := Res;
end;

procedure HCmdQuery_Math_RandomFloat(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := Random;
end;

end.

