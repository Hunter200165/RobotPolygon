unit HCmdQuery.RTL.Variables;

{$Include HCmdQuery.inc}

interface

uses
    HCmdQuery.SafeVariant,
    HCmdQuery.SafeVariant.Operators,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary;

procedure HCmdQuery_Variables_CreateLocal(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_CreateModuleField(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_CreateModuleGlobalField(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_CreateGlobalVariable(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Variables_HandleGlobal(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Variables_Assign(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Variables_AssignWithAction(const AInterpreter: PSafeObject; const AResult: PSafeVariant; const AFunctionName: UnicodeString; const AOperator: THCmdQuerySafeVariantOperator);

procedure HCmdQuery_Variables_AssignAdd(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignSub(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignMultiply(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignDivide(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignIntDivide(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignModulo(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignBitwiseAnd(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignBitwiseOr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignBitwiseXor(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignBitwiseShl(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Variables_AssignBitwiseShr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

implementation

uses
    HCmdQuery.RTL.Functions;

procedure HCmdQuery_Variables_CreateLocal(const AInterpreter: PSafeObject; const AResult: PSafeVariant);
var CBF: PHCmdQueryCallBoundaryFrame;
    VarName: UnicodeString;
    Index: Integer;
begin
    //CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary;
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);

    VarName := CBF.ExpectVariable(0, 'local[0]: Expected variable to create');
    AResult^ := CBF.ExpectValue(1, 'local[1]: Expected value to assign to a variable');

    // We must check if another variable with this name already exists
    CBF := CBF.Previous;

    Index := CBF.FindLocalVariableToStackBase(VarName);
    if Index >= 0 then begin
        CBF.LocalVariableStack.Items[Index].Value := AResult^;
        Exit;
    end;

    with CBF.LocalVariableStack.AddReferenced^ do begin
        Name := VarName;
        Value := AResult^;
    end;
end;

procedure HCmdQuery_Variables_CreateModuleField(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    VarName: UnicodeString;
    Index: Integer;
begin
    //CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary;
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);

    VarName := CBF.ExpectVariable(0, 'field[0]: Expected variable to create');
    AResult^ := CBF.ExpectValue(1, 'field[1]: Expected value to assign to a variable');

    // Going back to one stack frame
    CBF := CBF.Previous;
    Index := CBF.FindModuleLocalVariable(VarName);
    if Index >= 0 then begin
        // Module variable already exists, no need to create it, just assign
        CBF.GetModuleLocalVariablePointer(Index).Value := AResult^;
        Exit;
    end;

    CBF.CreateModuleLocalVariable(VarName).Value := AResult^;
end;

procedure HCmdQuery_Variables_CreateModuleGlobalField(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    VarName: UnicodeString;
    Index: Integer;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(3);

    VarName := CBF.ExpectVariable(1, 'global-field[1]: Expected variable to create');
    AResult^ := CBF.ExpectValue(2, 'global-field[2]: Expected value to assign to a variable');

    Index := CBF.FindModuleGlobalVariable(VarName);
    if Index >= 0 then
        CBF.GetModuleLocalVariablePointer(Index).Value := AResult^
    else
        CBF.CreateModuleLocalVariable(VarName).Value := AResult^;
end;

procedure HCmdQuery_Variables_CreateGlobalVariable(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    VarName: UnicodeString;
    Index: Integer;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(2);

    VarName := CBF.ExpectVariable(0, 'global[0]: Expected variable to create');
    AResult^ := CBF.ExpectValue(1, 'global[1]: Expected value to assign to a variable');

    Index := CBF.FindGlobalVariable(VarName);
    if Index >= 0 then
        CBF.GetGlobalVariablePointer(Index).Value := AResult^
    else
        CBF.CreateGlobalVariable(VarName).Value := AResult^;
end;

procedure HCmdQuery_Variables_HandleGlobal(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    //CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary;
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    //CBF.EndExpectation(2);

    case CBF.TryExpectKeywords(0, [ 'field', 'function' ]) of
        0:
            begin
                // This is global field
                CBF.ChangeFunctionName := True;
                CBF.NewFunctionName := 'global-field';

                HCmdQuery_Variables_CreateModuleGlobalField(AInterpreter, AResult);

                Exit;
            end;
        1:
            begin
                // This is global function
                CBF.ChangeFunctionName := True;
                CBF.NewFunctionName := 'global-function';

                HCmdQuery_Functions_CreateGlobalFunction(AInterpreter, AResult);

                Exit;
            end;
    end;

    CBF.ChangeFunctionName := True;
    CBF.NewFunctionName := 'global-var';

    HCmdQuery_Variables_CreateGlobalVariable(AInterpreter, AResult);
end;

procedure HCmdQuery_Variables_Assign(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Assignable: PSafeObject;
begin
    // CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary;
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);

    Assignable := CBF.ExpectAssignable(0, ':=[0]: Expected assignable part');
    AResult^ := CBF.ExpectValue(1, ':=[1]: Expected value to assign to a variable');

    //AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary := CBF.Previous;
    AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundaryLevelDown;
    try
        Assignable.Interfaces.Assignable.Assign(AInterpreter, Assignable, AResult^);
    finally
        AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF);
    end;

end;

procedure HCmdQuery_Variables_AssignWithAction(const AInterpreter: PSafeObject; const AResult: PSafeVariant; const AFunctionName: UnicodeString; const AOperator: THCmdQuerySafeVariantOperator);
var CBF: PHCmdQueryCallBoundaryFrame;
    Assignable: PSafeObject;
    TempNode: PSafeVariant;
    Operands: array [0..1] of SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    if CBF.ArgumentStackCount < 1 then
        raise EHCmdQueryArgumentException.Create(AFunctionName + '[0]: Expected first argument (assignable)', CBF.Position^);
    if CBF.ArgumentStackCount < 2 then
        raise EHCmdQueryArgumentException.Create(AFunctionName + '[1]: Expected argument to apply action', CBF.Position^);

    Assignable := nil;
    TempNode := CBF.ExpectNode(0);
    if TempNode.IsObject and Assigned(TempNode.AsObject.Interfaces) and Assigned(TempNode.AsObject.Interfaces.Assignable) then
        Assignable := TempNode.AsObject;

    Operands[0] := CBF.ExpectValue(0);
    Operands[1] := CBF.ExpectValue(1);

    if not Assigned(Assignable) then begin
        if not (Operands[0].IsObject and Assigned(Operands[0].AsObject.Interfaces) and Assigned(Operands[0].AsObject.Interfaces.Assignable)) then
            raise EHCmdQueryArgumentException.Create(
                AFunctionName + '[0]: Expected assignable argument',
                CBF.Position^
            );

        Assignable := Operands[0].AsObject;
    end;

    AOperator(AInterpreter, @Operands[0], AResult);

    AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundaryLevelDown();
    try
        Assignable.Interfaces.Assignable.Assign(AInterpreter, Assignable, AResult^);
    finally
        AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF);
    end;
end;

procedure HCmdQuery_Variables_AssignAdd(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '+=', HCmdQuery_SafeVariant_Add);
end;

procedure HCmdQuery_Variables_AssignSub(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '-=', HCmdQuery_SafeVariant_Subtract);
end;

procedure HCmdQuery_Variables_AssignMultiply(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '*=', HCmdQuery_SafeVariant_Multiply);
end;

procedure HCmdQuery_Variables_AssignDivide(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '/=', HCmdQuery_SafeVariant_Divide);
end;

procedure HCmdQuery_Variables_AssignIntDivide(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '//=', HCmdQuery_SafeVariant_IntDivide);
end;

procedure HCmdQuery_Variables_AssignModulo(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '%=', HCmdQuery_SafeVariant_Modulo);
end;

procedure HCmdQuery_Variables_AssignBitwiseAnd(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '&=', HCmdQuery_SafeVariant_BinaryAnd);
end;

procedure HCmdQuery_Variables_AssignBitwiseOr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '|=', HCmdQuery_SafeVariant_BinaryOr);
end;

procedure HCmdQuery_Variables_AssignBitwiseXor(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '^=', HCmdQuery_SafeVariant_BinaryXor);
end;

procedure HCmdQuery_Variables_AssignBitwiseShl(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '>>=', HCmdQuery_SafeVariant_BinaryShl);
end;

procedure HCmdQuery_Variables_AssignBitwiseShr(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Variables_AssignWithAction(AInterpreter, AResult, '<<=', HCmdQuery_SafeVariant_BinaryShr);
end;

end.

