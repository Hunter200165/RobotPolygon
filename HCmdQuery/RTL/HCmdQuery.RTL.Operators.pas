unit HCmdQuery.RTL.Operators;

{$I HCmdQuery.inc}

interface

uses
    HCmdQuery.SafeVariant,
    HCmdQuery.SafeVariant.Operators,
    HCmdQuery.Kernel.CallBoundary;

procedure HCmdQuery_Operators_Add(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_Subtract(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_Negate(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_Minus(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_Multiply(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_Divide(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_IntDivide(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_Modulo(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Operators_BinaryNot(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_BinaryAnd(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_BinaryOr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_BinaryXor(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_BinaryShl(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_BinaryShr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Operators_LogicalNot(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_LogicalAnd(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_LogicalOr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Operators_Equals(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_NotEquals(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_Less(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_LessEquals(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_Greater(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Operators_GreaterEquals(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

implementation

procedure HCmdQuery_Operators_Add(const AInterpreter: PSafeObject; const AResult: PSafeVariant);
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    //CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary;
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '+[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '+[1]: Expected second operand');

    HCmdQuery_SafeVariant_Add(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_Subtract(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '-[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '-[1]: Expected second operand');

    HCmdQuery_SafeVariant_Subtract(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_Negate(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operand: SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(1);
    Operand := CBF.ExpectValue(0, '-[0]: Expected first operand');

    HCmdQuery_SafeVariant_Negate(AInterpreter, @Operand, AResult);
end;

procedure HCmdQuery_Operators_Minus(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    if CBF.ArgumentStackCount < 2 then begin
        CBF.ChangeFunctionName := True;
        CBF.NewFunctionName := 'negate';

        HCmdQuery_Operators_Negate(AInterpreter, AResult);
    end
    else begin
        CBF.ChangeFunctionName := True;
        CBF.NewFunctionName := 'subtract';

        HCmdQuery_Operators_Subtract(AInterpreter, AResult);
    end;
end;

procedure HCmdQuery_Operators_Multiply(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '*[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '*[1]: Expected second operand');

    HCmdQuery_SafeVariant_Multiply(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_Divide(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '/[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '/[1]: Expected second operand');

    HCmdQuery_SafeVariant_Divide(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_IntDivide(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, 'div[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, 'div[1]: Expected second operand');


    HCmdQuery_SafeVariant_IntDivide(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_Modulo(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, 'mod[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, 'mod[1]: Expected second operand');

    HCmdQuery_SafeVariant_Modulo(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_BinaryNot(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operand: SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(1);
    Operand := CBF.ExpectValue(0, '~[0]: Expected first operand');

    HCmdQuery_SafeVariant_BinaryNot(AInterpreter, @Operand, AResult);
end;

procedure HCmdQuery_Operators_BinaryAnd(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '&[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '&[1]: Expected second operand');

    HCmdQuery_SafeVariant_BinaryAnd(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_BinaryOr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '|[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '|[1]: Expected second operand');

    HCmdQuery_SafeVariant_BinaryOr(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_BinaryXor(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '^[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '^[1]: Expected second operand');

    HCmdQuery_SafeVariant_BinaryXor(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_BinaryShl(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '<<[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '<<[1]: Expected second operand');

    HCmdQuery_SafeVariant_BinaryShl(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_BinaryShr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '>>[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '>>[1]: Expected second operand');

    HCmdQuery_SafeVariant_BinaryShr(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_LogicalNot(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operand: SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(1);
    Operand := CBF.ExpectValue(0, 'not[0]: Expected first operand');

    AResult^ := not Operand.GetBooleanValue;
end;

procedure HCmdQuery_Operators_LogicalAnd(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    if not CBF.ExpectValue(0, 'and[0]: Expected first operand').GetBooleanValue then begin
        AResult^ := False;
        Exit;
    end;

    AResult^ := CBF.ExpectValue(1, 'and[1]: Expected second operand').GetBooleanValue;
end;

procedure HCmdQuery_Operators_LogicalOr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    if CBF.ExpectValue(0, 'or[0]: Expected first operand').GetBooleanValue then begin
        AResult^ := True;
        Exit;
    end;

    AResult^ := CBF.ExpectValue(1, 'or[1]: Expected second operand');

    //AResult^ := Operands[0].GetBooleanValue or Operands[1].GetBooleanValue;
end;

procedure HCmdQuery_Operators_Equals(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '==[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '==[1]: Expected second operand');

    HCmdQuery_SafeVariant_Equals(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_NotEquals(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '!=[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '!=[1]: Expected second operand');

    HCmdQuery_SafeVariant_NotEquals(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_Less(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '<[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '<[1]: Expected second operand');

    HCmdQuery_SafeVariant_Less(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_LessEquals(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '<=[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '<=[1]: Expected second operand');

    HCmdQuery_SafeVariant_LessEquals(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_Greater(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '>[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '>[1]: Expected second operand');

    HCmdQuery_SafeVariant_Greater(AInterpreter, @Operands[0], AResult);
end;

procedure HCmdQuery_Operators_GreaterEquals(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Operands[0] := CBF.ExpectValue(0, '>=[0]: Expected first operand');
    Operands[1] := CBF.ExpectValue(1, '>=[1]: Expected second operand');

    HCmdQuery_SafeVariant_GreaterEquals(AInterpreter, @Operands[0], AResult);
end;

end.

