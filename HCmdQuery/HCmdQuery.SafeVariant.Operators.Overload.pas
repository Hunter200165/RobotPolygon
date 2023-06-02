unit HCmdQuery.SafeVariant.Operators.Overload;

{$I HCmdQuery.inc}

interface

uses
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.CallBoundary;

function HCmdQuery_Operators_CallBinaryOverload(const AInterpreter: PSafeObject; const AOperatorOffset: HCmdQueryBinaryOperatorInterfaceOffset; const AValues: PSafeVariant; const AResult: PSafeVariant): Boolean;
function HCmdQuery_Operators_CallUnaryOverload(const AInterpreter: PSafeObject; const AOperatorOffset: HCmdQueryUnaryOperatorInterfaceOffset; const AValue: PSafeVariant; const AResult: PSafeVariant): Boolean;

implementation

function HCmdQuery_Operators_CallBinaryOverload(const AInterpreter: PSafeObject; const AOperatorOffset: HCmdQueryBinaryOperatorInterfaceOffset; const AValues: PSafeVariant; const AResult: PSafeVariant): Boolean;
var T1, T2: HCmdQueryVarType;
    Obj1, Obj2: PSafeObject;
    Overload1, Overload2: PIHCmdQueryBinaryOperatorOverloadable;
    NewCBF: PHCmdQueryCallBoundaryFrame;
{ Aux }
    function TryLeftOverload: Boolean;
    begin
        Result := False;

        if T1 = HCmdQueryVarType.SafeObject then
            Obj1 := AValues[0].AsObject
        else
            Obj1 := AInterpreter.Interfaces.Interpreter.GetSimpleTypeShadowObject(T1);

        if not Assigned(Obj1.Interfaces) then
            Exit;

        Overload1 := (@Obj1.Interfaces.Addable)[Integer(AOperatorOffset)];
        if not Assigned(Overload1) then
            Exit;
        if not (Overload1.LeftOverload.VarType in [ HCmdQueryVarType.NativeFunction, HCmdQueryVarType.SafeObject ]) then
            Exit;

        NewCBF := AInterpreter.Interfaces.Interpreter.AllocateCallBoundaryFrame;
        try
            //AResult^ := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CallNode(@Overload1.LeftOverload, AValues, 2, nil, 0);
            NewCBF.CreateLocalVariable('self').Value := AValues[0];
            AInterpreter.Interfaces.Interpreter.CallNode(@Overload1.LeftOverload, AValues, 2, AResult);
        finally
            AInterpreter.Interfaces.Interpreter.DeallocateCallBoundaryFrame;
        end;

        Result := not (AResult.VarType = HCmdQueryVarType.SkipObject);
    end;
    function TryRightOverload: Boolean;
    begin
        Result := False;

        if T2 = HCmdQueryVarType.SafeObject then
            Obj2 := AValues[1].AsObject
        else
            Obj2 := AInterpreter.Interfaces.Interpreter.GetSimpleTypeShadowObject(T2);

        if not Assigned(Obj2.Interfaces) then
            Exit;

        Overload2 := (@Obj2.Interfaces.Addable)[Integer(AOperatorOffset)];
        if not Assigned(Overload2) then
            Exit;
        if not (Overload2.RightOverload.VarType in [ HCmdQueryVarType.NativeFunction, HCmdQueryVarType.SafeObject ]) then
            Exit;

        NewCBF := AInterpreter.Interfaces.Interpreter.AllocateCallBoundaryFrame;
        try
            NewCBF.CreateLocalVariable('self').Value := AValues[1];
            AInterpreter.Interfaces.Interpreter.CallNode(@Overload2.RightOverload, AValues, 2, AResult);
        finally
            AInterpreter.Interfaces.Interpreter.DeallocateCallBoundaryFrame;
        end;

        Result := not (AResult.VarType = HCmdQueryVarType.SkipObject);
    end;
{ Main routine }
begin
    T1 := AValues[0].VarType;
    T2 := AValues[1].VarType;

    Result := True;

    if TryLeftOverload then
        Exit;

    if TryRightOverload then
        Exit;

    Result := False;
end;

function HCmdQuery_Operators_CallUnaryOverload(const AInterpreter: PSafeObject; const AOperatorOffset: HCmdQueryUnaryOperatorInterfaceOffset; const AValue: PSafeVariant; const AResult: PSafeVariant): Boolean;
var T1: HCmdQueryVarType;
    Obj1: PSafeObject;
    Overload1: PIHCmdQueryUnaryOperatorOverloadable;
    NewCBF: PHCmdQueryCallBoundaryFrame;
{ Aux }
    function TryOverload: Boolean;
    begin
        Result := False;

        if T1 = HCmdQueryVarType.SafeObject then
            Obj1 := AValue.AsObject
        else
            Obj1 := AInterpreter.Interfaces.Interpreter.GetSimpleTypeShadowObject(T1);

        if not Assigned(Obj1.Interfaces) then
            Exit;

        Overload1 := (@Obj1.Interfaces.Negatable)[Integer(AOperatorOffset)];
        if not Assigned(Overload1) then
            Exit;
        if not (Overload1.Overload.VarType in [ HCmdQueryVarType.NativeFunction, HCmdQueryVarType.SafeObject ]) then
            Exit;

        NewCBF := AInterpreter.Interfaces.Interpreter.AllocateCallBoundaryFrame;
        try
            NewCBF.CreateLocalVariable('self').Value := AValue^;
            AInterpreter.Interfaces.Interpreter.CallNode(@Overload1.Overload, AValue, 1, AResult);
        finally
            AInterpreter.Interfaces.Interpreter.DeallocateCallBoundaryFrame;
        end;

        Result := not (AResult.VarType = HCmdQueryVarType.SkipObject);
    end;
{ Main routine }
begin
    T1 := AValue.VarType;

    Result := True;
    if TryOverload then
        Exit;

    Result := False;
end;

end.

