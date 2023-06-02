unit HCmdQuery.RTL.ControlFlow;

{$I HCmdQuery.inc}

interface

uses
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary;

procedure HCmdQuery_ControlFlow_If(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_ControlFlow_While(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_ControlFlow_ForSequential(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_ControlFlow_ForIn(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_ControlFlow_For(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_ControlFlow_Break(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_ControlFlow_Continue(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_ControlFlow_Return(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_ControlFlow_Previous(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_ControlFlow_Next(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_ControlFlow_SetArgument(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_ControlFlow_GetSelfArgumentIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_ControlFlow_ExpandArguments(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_ControlFlow_GetPosition(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_ControlFlow_SetNewFunctionName(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

implementation

procedure HCmdQuery_ControlFlow_If(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    HasElsePart: Boolean;
    TruePart, FalsePart: PSafeVariant;
begin
    //CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary;
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(4);

    TruePart := CBF.ExpectNode(1, 'if[1]: Expected true branch for condition');
    FalsePart := nil;

    HasElsePart := CBF.ArgumentStackCount > 2;
    if HasElsePart then begin
        CBF.ExpectKeyword(2, 'else', 'if[2]: Expected `else` keyword');
        FalsePart := CBF.ExpectNode(3, 'if[3]: Expected false branch for condition');
    end;

    if CBF.ExpectValue(0, 'if[0]: Expected condition').GetBooleanValue then
        AResult^ := CBF.CallNodeWithPreviousFrame(TruePart)
    else if HasElsePart then
        AResult^ := CBF.CallNodeWithPreviousFrame(FalsePart)
    else
        AResult^ := 0;
end;

procedure HCmdQuery_ControlFlow_While(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Condition, Body: PSafeVariant;
begin
    //CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary;
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);

    Condition := CBF.ExpectNode(0, 'while[0]: Expected condition');
    Body := CBF.ExpectNode(1, 'while[1]: Expected body');

    AResult^ := 0;
    while CBF.CallNodeWithPreviousFrame(Condition).GetBooleanValue do begin
        AResult^ := CBF.CallNodeWithPreviousFrame(Body);

        case CBF.Previous.ControlFlowFlag of
            THCmdQueryControlFlowFlag.None: ;
            THCmdQueryControlFlowFlag.Break:
                begin
                    CBF.Previous.ControlFlowFlag := THCmdQueryControlFlowFlag.None;
                    Break;
                end;
            THCmdQueryControlFlowFlag.Continue:
                begin
                    CBF.Previous.ControlFlowFlag := THCmdQueryControlFlowFlag.None;
                    Continue;
                end;
            THCmdQueryControlFlowFlag.Return:
                Break;
        end;
    end;
end;

procedure HCmdQuery_ControlFlow_ForSequential(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF, PreviousCBF: PHCmdQueryCallBoundaryFrame;
    VarName: UnicodeString;
    VarPtr: PHCmdQueryVariable;
    FromValue, ToValue, Current, Step: Int64;
    Base: Integer;
    Body: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(4);

    VarName := CBF.ExpectVariable(0, 'for[0]: Expected counter varible');
    FromValue := CBF.ExpectInteger(1, 'for[1]: Expected integer lower boundary');
    ToValue := CBF.ExpectInteger(2, 'for[2]: Expected integer higher boundary');
    Body := CBF.ExpectNode(3, 'for[3]: Expected body');

    Step := CBF.ExpectParameterIntegerDefault('step', 1);
    if Step = 0 then
        raise EHCmdQueryArgumentException.Create(
            'for[step]: Step parameter cannot be zero',
            CBF.Position^
        );

    AResult^ := None;

    AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundaryLevelDown();
    try
        PreviousCBF := CBF.Previous;
        Base := PreviousCBF.SetLocalVariablesStackBase;
        try
            VarPtr := PreviousCBF.CreateLocalVariable(VarName);
            VarPtr.Value := FromValue;
            Current := FromValue;

            if Step > 0 then begin
                while Current <= ToValue do begin
                    AInterpreter.Interfaces.Interpreter.CallNode(Body, nil, 0, AResult);
                    //Body.AsObject.Interfaces.Evaluatable.Evaluate(AInterpreter, Body.AsObject, AResult);
                    Current := Current + Step;
                    VarPtr.Value := Current;

                    case PreviousCBF.ControlFlowFlag of
                        THCmdQueryControlFlowFlag.None: ;
                        THCmdQueryControlFlowFlag.Break:
                            begin
                                PreviousCBF.ControlFlowFlag := THCmdQueryControlFlowFlag.None;
                                Break;
                            end;
                        THCmdQueryControlFlowFlag.Continue:
                            begin
                                PreviousCBF.ControlFlowFlag := THCmdQueryControlFlowFlag.None;
                                Continue;
                            end;
                        THCmdQueryControlFlowFlag.Return:
                            Break;
                    end;
                end;
            end
            else begin
                while Current >= ToValue do begin
                    AInterpreter.Interfaces.Interpreter.CallNode(Body, nil, 0, AResult);
                    //Body.AsObject.Interfaces.Evaluatable.Evaluate(AInterpreter, Body.AsObject, AResult);
                    Current := Current + Step;
                    VarPtr.Value := Current;

                    case PreviousCBF.ControlFlowFlag of
                        THCmdQueryControlFlowFlag.None: ;
                        THCmdQueryControlFlowFlag.Break:
                            begin
                                PreviousCBF.ControlFlowFlag := THCmdQueryControlFlowFlag.None;
                                Break;
                            end;
                        THCmdQueryControlFlowFlag.Continue:
                            begin
                                PreviousCBF.ControlFlowFlag := THCmdQueryControlFlowFlag.None;
                                Continue;
                            end;
                        THCmdQueryControlFlowFlag.Return:
                            Break;
                    end;
                end;
            end;
        finally
            PreviousCBF.RestoreLocalVariablesStackBase(Base);
        end;
    finally
        AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF);
    end;
end;

procedure HCmdQuery_ControlFlow_ForIn(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin

end;

procedure HCmdQuery_ControlFlow_For(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    i: Integer;
    VarName: UnicodeString;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    i := 0;
    while (i < CBF.ArgumentStackCount) and CBF.TryExpectVariable(i, VarName) do
        i := i + 1;

    if (i < CBF.ArgumentStackCount) and CBF.TryExpectKeyword(i, 'in') then
        raise EHCmdQueryNoSuchOverload.Create(
            'for-in function is not implemented yet',
            CBF.Position^
        );

    CBF.ChangeFunctionName := True;
    CBF.NewFunctionName := 'for-sequential';

    HCmdQuery_ControlFlow_ForSequential(AInterpreter, AResult);
end;

procedure HCmdQuery_ControlFlow_Break(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := None;
    CBF.Previous.ControlFlowFlag := THCmdQueryControlFlowFlag.Break;
end;

procedure HCmdQuery_ControlFlow_Continue(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := None;
    CBF.Previous.ControlFlowFlag := THCmdQueryControlFlowFlag.Continue;
end;

procedure HCmdQuery_ControlFlow_Return(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := CBF.ExpectValue(0, 'return[0]: Expected value to return');
    CBF.Previous.ControlFlowFlag := THCmdQueryControlFlowFlag.Return;
end;

procedure HCmdQuery_ControlFlow_Previous(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Node: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    Node := CBF.ExpectNode(0, 'previous[0]: Expected node to execute in previous context');

    if Assigned(CBF.Previous.Left) then begin
        AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF.Previous.Left);
        try
            //AResult^ := CBF.Previous.Left.CallNodeWithPreviousFrame(Node);
            AInterpreter.Interfaces.Interpreter.CallNode(Node, nil, 0, AResult);
        finally
            AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF);
        end;
        Exit;
    end;

    if Assigned(CBF.Previous.Previous) then begin
        AResult^ := CBF.Previous.CallNodeWithPreviousFrame(Node);
        Exit;
    end;

    raise EHCmdQueryRuntimeException.Create('previous[]: No frame after %s frame found', [ CBF.Previous.Position.ToString ], CBF.Position^);
end;

procedure HCmdQuery_ControlFlow_Next(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Node: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    Node := CBF.ExpectNode(0, 'next[0]: Expected node to execute in next context');

    if Assigned(CBF.Previous.Right) then begin
        AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF.Previous.Right);
        try
            AInterpreter.Interfaces.Interpreter.CallNode(Node, nil, 0, AResult);
        finally
            AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF);
        end;
        Exit;
    end;

    {#! This should point to the next itself, making this function useless }
    AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF.Previous.Next);
    try
        AInterpreter.Interfaces.Interpreter.CallNode(Node, nil, 0, AResult);
    finally
        AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF);
    end;
end;

procedure HCmdQuery_ControlFlow_SetArgument(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Index: Integer;
    Value: SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(2);

    Index := CBF.ExpectInteger(0, 'setArgument[0]: Expected index of argument');
    if (Index < 0) or (Index >= CBF.Previous.ArgumentStackCount) then
        raise EHCmdQueryArgumentOutOfBounds.Create('setArgument[0]: Index is out of bound (%d, out of %d arguments overall)', [ Index, CBF.Previous.ArgumentStackCount ], CBF.Position^);

    Value := CBF.ExpectValue(1, 'setArgument[1]: Expected value to exchange argument for');
    CBF.Previous.ArgumentStack[Index] := Value;

    AResult^ := Value;
end;

procedure HCmdQuery_ControlFlow_GetSelfArgumentIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := CBF.Previous.SelfArgumentIndex;
end;

procedure HCmdQuery_ControlFlow_ExpandArguments(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Arguments: array of SafeVariant;
    PrevArgs: PSafeVariant;
    Count, PrevArgsCount: Integer;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(2);

    Count := CBF.ExpectInteger(0, 'expandArguments[0]: Expected number of arguments to be created');

    if Count < 0 then
        raise EHCmdQueryArgumentOutOfBounds.Create('expandArguments[0]: Count of argument cannot be less than zero (%d)', [ Count ], CBF.Position^);

    Arguments := nil;
    SetLength(Arguments, Count);
    PrevArgs := CBF.Previous.ArgumentStack;
    PrevArgsCount := CBF.Previous.ArgumentStackCount;

    if Count > 0 then
        CBF.Previous.ArgumentStack := @Arguments[0]
    else
        CBF.Previous.ArgumentStack := nil;
    CBF.Previous.ArgumentStackCount := Count;

    try
        AResult^ := CBF.ExpectValue(1, 'expandArguments[1]: Expected node to execute with modified arguments');
    finally
        CBF.Previous.ArgumentStack := PrevArgs;
        CBF.Previous.ArgumentStackCount := PrevArgsCount;
    end;
end;

procedure HCmdQuery_ControlFlow_GetPosition(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := CBF.AllocateString(CBF.Previous.Position^.ToString);
end;

procedure HCmdQuery_ControlFlow_SetNewFunctionName(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    CBF.Previous.NewFunctionName := CBF.ExpectString(0, 'setNewFunctionName[0]: Expected string name of new function');
    CBF.Previous.ChangeFunctionName := True;
end;

end.

