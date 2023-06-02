unit HCmdQuery.Kernel.CallBoundary;

{$I HCmdQuery.inc}

interface

uses
    SysUtils,
    HCL.Core.Unused,
    HCL.Core.GenericList,
    HCmdQuery.Types,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.ResourceManager;

type
    PHCmdQueryCallBoundaryFrame = ^THCmdQueryCallBoundaryFrame;

    { THCmdQueryCallBoundaryFrame }

    THCmdQueryCallBoundaryFrame = packed record
        LocalVariablesStackBase: Integer;

        Action: THCmdQueryNodeType;
        Position: PHCmdQueryPosition;

        Next, Previous, Left, Right: PHCmdQueryCallBoundaryFrame;
        Module: PSafeObject;
        Interpreter: PSafeObject;

        LocalVariableStack: THCmdQueryLocalStack;
        //ArgumentStack: THCmdQueryArgumentStack;
        //ParameterStack: THCmdQueryParameterStack;
        ArgumentStack: PSafeVariant;
        ArgumentStackCount: Integer;
        ParameterStack: PHCmdQueryParameter;
        ParameterStackCount: Integer;

        ArgumentRequestIndex: Integer;
        SelfArgumentIndex: Integer;

        ControlFlowFlag: THCmdQueryControlFlowFlag;
    public
        { Some flags to control morph of the bytecode }
        { If this flag is set, then node should change it's name to provided in NewFunctionName field
        }
        ChangeFunctionName: Boolean;
        NewFunctionName: UnicodeString;
    public
        function FindLocalVariable(const AName: UnicodeString): Integer;
        function FindLocalVariableToStackBase(const AName: UnicodeString): Integer;
        function FindModuleLocalVariable(const AName: UnicodeString): Integer;
        function FindModuleGlobalVariable(const AName: UnicodeString): Integer;
        function FindGlobalVariable(const AName: UnicodeString): Integer;
        function FindLocalFunction(const AName: UnicodeString): Integer;
        function FindModuleFunction(const AName: UnicodeString): Integer;
        function FindGlobalFunction(const AName: UnicodeString): Integer;
    public
        function CreateLocalVariable(const AName: UnicodeString): PHCmdQueryVariable;
        function CreateModuleLocalVariable(const AName: UnicodeString): PHCmdQueryVariable; {$IfDef HCmdQuery_CallBoundary_InlineCreateVariable}inline;{$EndIf}
        function CreateModuleGlobalVariable(const AName: UnicodeString): PHCmdQueryVariable;
        function CreateGlobalVariable(const AName: UnicodeString): PHCmdQueryVariable; {$IfDef HCmdQuery_CallBoundary_InlineCreateVariable}inline;{$EndIf}
    public
        function CreateLocalFunction(const AName: UnicodeString): PHCmdQueryFunction;
        function CreateModuleFunction(const AName: UnicodeString): PHCmdQueryFunction;
        function CreateGlobalFunction(const AName: UnicodeString): PHCmdQueryFunction;
    public
        function GetModuleLocalVariablePointer(const AIndex: Integer): PHCmdQueryVariable; {$IfDef HCmdQuery_CallBoundary_InlineGetVariable}inline;{$EndIf}
        function GetModuleGlobalVariablePointer(const AIndex: Integer): PHCmdQueryVariable;
        function GetGlobalVariablePointer(const AIndex: Integer): PHCmdQueryVariable; {$IfDef HCmdQuery_CallBoundary_InlineGetVariable}inline;{$EndIf}
    public
        function GetLocalFunctionPointer(const AIndex: Integer): PHCmdQueryFunction;
        function GetModuleFunctionPointer(const AIndex: Integer): PHCmdQueryFunction;
        function GetGlobalFunctionPointer(const AIndex: Integer): PHCmdQueryFunction;
    public
        function SetLocalVariablesStackBase: Integer;
        procedure RestoreLocalVariablesStackBase(const ABase: Integer);
    public
        function CallNodeWithPreviousFrame(const ANode: PSafeVariant): SafeVariant;
    public
        function AllocateString(const AValue: UnicodeString): PSafeString;
        function AllocateObject(const AValue: Pointer; const ATypeID: UInt64): PSafeObject;
    public
        function TryExpectNode(const AIndex: Integer; out ANode: PSafeVariant): Boolean;
        function TryExpectKeyword(const AIndex: Integer; const AKeyword: UnicodeString): Boolean;
        function TryExpectKeywords(const AIndex: Integer; const AKeywords: array of UnicodeString): Integer;
        function TryExpectVariable(const AIndex: Integer; out AVariableName: UnicodeString): Boolean;
        function TryExpectAssignable(const AIndex: Integer; out AAssignable: PSafeObject): Boolean;
        function TryExpectValue(const AIndex: Integer; out AResult: SafeVariant): Boolean;
        function TryExpectString(const AIndex: Integer; out AResult: UnicodeString): Boolean;
        function TryExpectInteger(const AIndex: Integer; out AResult: Int64): Boolean;
        function TryExpectNumber(const AIndex: Integer; out AResult: Double): Boolean;
    public
        function FindParameter(const AName: UnicodeString): Integer;
    public
        function TryExpectParameterNode(const AName: UnicodeString; out ANode: PSafeVariant): Boolean;
        function TryExpectParameterValue(const AName: UnicodeString; out AResult: SafeVariant): Boolean;
        function TryExpectParameterString(const AName: UnicodeString; out AResult: UnicodeString): Boolean;
        function TryExpectParameterInteger(const AName: UnicodeString; out AResult: Int64): Boolean;
        function TryExpectParameterNumber(const AName: UnicodeString; out AResult: Double): Boolean;
        function TryExpectParameterBoolean(const AName: UnicodeString; out AResult: Boolean): Boolean;
    public
        function ExpectNode(const AIndex: Integer; const AMessage: UnicodeString = 'Message is not assigned'): PSafeVariant;
        procedure ExpectKeyword(const AIndex: Integer; const AKeyword: UnicodeString; const AMessage: UnicodeString = 'Message is not assigned');
        function ExpectKeywords(const AIndex: Integer; const AKeywords: array of UnicodeString; const AMessage: UnicodeString = 'Message is not assigned'): Integer;
        function ExpectVariable(const AIndex: Integer; const AMessage: UnicodeString = 'Message is not assigned'): UnicodeString;
        function ExpectAssignable(const AIndex: Integer; const AMessage: UnicodeString = 'Message is not assigned'): PSafeObject;
        function ExpectValue(const AIndex: Integer; const AMessage: UnicodeString = 'Message is not assigned'): SafeVariant;
        function ExpectString(const AIndex: Integer; const AMessage: UnicodeString = 'Message is not assigned'): UnicodeString;
        function ExpectInteger(const AIndex: Integer; const AMessage: UnicodeString = 'Message is not assigned'): Int64;
        function ExpectNumber(const AIndex: Integer; const AMessage: UnicodeString = 'Message is not assigned'): Double;
    public
        function ExpectIntegerDefault(const AIndex: Integer; const ADefaultValue: Int64): Int64;
        function ExpectNumberDefault(const AIndex: Integer; const ADefaultValue: Double): Double;
        function ExpectStringDefault(const AIndex: Integer; const ADefaultValue: UnicodeString): UnicodeString;
    public
        function ExpectParameterNode(const AName: UnicodeString; const AMessage: UnicodeString = 'Message is not assigned'): PSafeVariant;
        function ExpectParameterValue(const AName: UnicodeString; const AMessage: UnicodeString = 'Message is not assigned'): SafeVariant;
        function ExpectParameterString(const AName: UnicodeString; const AMessage: UnicodeString = 'Message is not assigned'): UnicodeString;
        function ExpectParameterInteger(const AName: UnicodeString; const AMessage: UnicodeString = 'Message is not assigned'): Int64;
        function ExpectParameterNumber(const AName: UnicodeString; const AMessage: UnicodeString = 'Message is not assigned'): Double;
    public
        function ExpectParameterValueDefault(const AName: UnicodeString; const ADefault: SafeVariant): SafeVariant;
        function ExpectParameterStringDefault(const AName: UnicodeString; const ADefault: UnicodeString): UnicodeString;
        function ExpectParameterIntegerDefault(const AName: UnicodeString; const ADefault: Int64): Int64;
        function ExpectParameterNumberDefault(const AName: UnicodeString; const ADefault: Double): Double;
        function ExpectParameterBooleanDefault(const AName: UnicodeString; const ADefault: Boolean): Boolean;
    public
        procedure EndExpectation(const AIndex: Integer);
    public
        procedure Clear;
    end;

    THCmdQueryCallBoundaryFrames = HList<PHCmdQueryCallBoundaryFrame>;

implementation

uses
    HCmdQuery.Kernel.Node,
    HCmdQuery.Kernel.Context,
    HCmdQuery.Kernel.InterpreterBase;

{ THCmdQueryCallBoundaryFrame }

function THCmdQueryCallBoundaryFrame.FindLocalVariable(const AName: UnicodeString): Integer;
var i: Integer;
begin
    Result := -1;

    for i := LocalVariableStack.Count - 1 downto 0 do
        if LocalVariableStack.Items[i].Name = AName then begin
            Result := i;
            Break;
        end;
end;

function THCmdQueryCallBoundaryFrame.FindLocalVariableToStackBase(const AName: UnicodeString): Integer;
var i: Integer;
begin
    Result := -1;

    for i := LocalVariableStack.Count - 1 downto LocalVariablesStackBase do
        if LocalVariableStack.Items[i].Name = AName then begin
            Result := i;
            Break;
        end;
end;

function THCmdQueryCallBoundaryFrame.FindModuleLocalVariable(const AName: UnicodeString): Integer;
begin
    Result := Module.TreatAs<THCmdQueryContext>.FindModuleLocalVariable(AName);
end;

function THCmdQueryCallBoundaryFrame.FindModuleGlobalVariable(const AName: UnicodeString): Integer;
begin
    Result := Module.TreatAs<THCmdQueryContext>.FindModuleGlobalVariable(AName);
end;

function THCmdQueryCallBoundaryFrame.FindGlobalVariable(const AName: UnicodeString): Integer;
begin
    Result := Interpreter.TreatAs<THCmdQueryInterpreterBase>.FindGlobalVariable(AName);
end;

function THCmdQueryCallBoundaryFrame.FindLocalFunction(const AName: UnicodeString): Integer;
begin
    Result := Module.TreatAs<THCmdQueryContext>.FindLocalFunction(AName);
end;

function THCmdQueryCallBoundaryFrame.FindModuleFunction(const AName: UnicodeString): Integer;
begin
    Result := Module.TreatAs<THCmdQueryContext>.FindModuleFunction(AName);
end;

function THCmdQueryCallBoundaryFrame.FindGlobalFunction(const AName: UnicodeString): Integer;
begin
    Result := Interpreter.TreatAs<THCmdQueryInterpreterBase>.FindGlobalFunction(AName);
end;

function THCmdQueryCallBoundaryFrame.CreateLocalVariable(const AName: UnicodeString): PHCmdQueryVariable;
begin
    Result := LocalVariableStack.AddReferenced;
    Result.Name := AName;
end;

function THCmdQueryCallBoundaryFrame.CreateModuleLocalVariable(const AName: UnicodeString): PHCmdQueryVariable;
begin
    {#! [2] }
    Result := Module.TreatAs<THCmdQueryContext>.ModuleLocalVariables.AddReferenced;
    Result.Name := AName;
end;

function THCmdQueryCallBoundaryFrame.CreateModuleGlobalVariable(const AName: UnicodeString): PHCmdQueryVariable;
begin
    Result := Module.TreatAs<THCmdQueryContext>.ModuleGlobalVariables.AddReferenced;
    Result.Name := AName;
end;

function THCmdQueryCallBoundaryFrame.CreateGlobalVariable(const AName: UnicodeString): PHCmdQueryVariable;
begin
    {#! [2] }
    Result := Interpreter.TreatAs<THCmdQueryInterpreterBase>.GlobalVariables.AddReferenced;
    Result.Name := AName;
end;

function THCmdQueryCallBoundaryFrame.CreateLocalFunction(const AName: UnicodeString): PHCmdQueryFunction;
begin
    Result := Module.TreatAs<THCmdQueryContext>.LocalFunctions.AddReferenced;
    Result.Name := AName;
end;

function THCmdQueryCallBoundaryFrame.CreateModuleFunction(const AName: UnicodeString): PHCmdQueryFunction;
begin
    Result := Module.TreatAs<THCmdQueryContext>.ModuleFunctions.AddReferenced;
    Result.Name := AName;
end;

function THCmdQueryCallBoundaryFrame.CreateGlobalFunction(const AName: UnicodeString): PHCmdQueryFunction;
begin
    Result := Interpreter.TreatAs<THCmdQueryInterpreterBase>.GlobalFunctions.AddReferenced;
    Result.Name := AName;
end;

function THCmdQueryCallBoundaryFrame.GetModuleLocalVariablePointer(const AIndex: Integer): PHCmdQueryVariable;
begin
    {#! [1] }
    Result := @(Module.TreatAs<THCmdQueryContext>.ModuleLocalVariables.Items[AIndex]);
end;

function THCmdQueryCallBoundaryFrame.GetModuleGlobalVariablePointer(const AIndex: Integer): PHCmdQueryVariable;
begin
    Result := @(Module.TreatAs<THCmdQueryContext>.ModuleGlobalVariables.Items[AIndex]);
end;

function THCmdQueryCallBoundaryFrame.GetGlobalVariablePointer(const AIndex: Integer): PHCmdQueryVariable;
begin
    {#! [1] }
    Result := @(Interpreter.TreatAs<THCmdQueryInterpreterBase>.GlobalVariables.Items[AIndex]);
end;

function THCmdQueryCallBoundaryFrame.GetLocalFunctionPointer(const AIndex: Integer): PHCmdQueryFunction;
begin
    {#! [1] }
    Result := @(Module.TreatAs<THCmdQueryContext>.LocalFunctions.Items[AIndex]);
end;

function THCmdQueryCallBoundaryFrame.GetModuleFunctionPointer(const AIndex: Integer): PHCmdQueryFunction;
begin
    {#! [1] }
    Result := @(Module.TreatAs<THCmdQueryContext>.ModuleFunctions.Items[AIndex]);
end;

function THCmdQueryCallBoundaryFrame.GetGlobalFunctionPointer(const AIndex: Integer): PHCmdQueryFunction;
begin
    {#! [1] }
    Result := @(Interpreter.TreatAs<THCmdQueryInterpreterBase>.GlobalFunctions.Items[AIndex]);
end;

function THCmdQueryCallBoundaryFrame.SetLocalVariablesStackBase: Integer;
begin
    Result := LocalVariablesStackBase;
    LocalVariablesStackBase := LocalVariableStack.Count;
end;

procedure THCmdQueryCallBoundaryFrame.RestoreLocalVariablesStackBase(const ABase: Integer);
var i: Integer;
begin
    //WriteLn('Restoring stack base to ', ABase);
    for i := LocalVariableStack.Count - 1 downto LocalVariablesStackBase do begin
        LocalVariableStack.Items[i].Value := None;
        LocalVariableStack.Remove;
    end;
    LocalVariablesStackBase := ABase;
end;

function THCmdQueryCallBoundaryFrame.CallNodeWithPreviousFrame(const ANode: PSafeVariant): SafeVariant;
var PrevCBF: PHCmdQueryCallBoundaryFrame;
begin
    PrevCBF := Interpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary;
    try
        //Interpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary := PrevCBF.Previous;

        // Call with previous from SELF boundary!
        Interpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary := Previous;
        Result := Interpreter.TreatAs<THCmdQueryInterpreterBase>.CallNode(ANode, nil, 0, nil, 0);
    finally
        Interpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary := PrevCBF;
    end;
end;

function THCmdQueryCallBoundaryFrame.AllocateString(const AValue: UnicodeString): PSafeString;
begin
    Result := Interpreter.TreatAs<THCmdQueryInterpreterBase>.ResourceManager.AllocateString(AValue);
end;

function THCmdQueryCallBoundaryFrame.AllocateObject(const AValue: Pointer; const ATypeID: UInt64): PSafeObject;
begin
    Result := Interpreter.TreatAs<THCmdQueryInterpreterBase>.ResourceManager.AllocateObject(AValue, ATypeID);
end;

function THCmdQueryCallBoundaryFrame.TryExpectNode(const AIndex: Integer; out ANode: PSafeVariant): Boolean;
begin
    Result := False;
    if (AIndex < 0) or (AIndex >= ArgumentStackCount) then
        Exit;

    //ANode := @ArgumentStack.Items[AIndex];
    ANode := ArgumentStack + AIndex;
    Result := True;
end;

function THCmdQueryCallBoundaryFrame.TryExpectKeyword(const AIndex: Integer; const AKeyword: UnicodeString): Boolean;
var TempNode: PSafeVariant;
begin
    Result := TryExpectNode(AIndex, TempNode);
    if not Result then
        Exit;

    Result := False;
    if not TempNode.IsObject or not Assigned(TempNode.AsObject.Interfaces) or not Assigned(TempNode.AsObject.Interfaces.Evaluatable) or not (TObject(TempNode.AsObject.Value) is THCmdQueryNodeString) then
        Exit;

    Result := TempNode.AsObject.TreatAs<THCmdQueryNodeString>.Data = AKeyword;
end;

function THCmdQueryCallBoundaryFrame.TryExpectKeywords(const AIndex: Integer; const AKeywords: array of UnicodeString): Integer;
var TempNode: PSafeVariant;
    Current: UnicodeString;
    i: Integer;
begin
    Result := -1;
    if not TryExpectNode(AIndex, TempNode) then
        Exit;

    if not TempNode.IsObject or not Assigned(TempNode.AsObject.Interfaces) or not Assigned(TempNode.AsObject.Interfaces.Evaluatable) or not (TObject(TempNode.AsObject.Value) is THCmdQueryNodeString) then
        Exit;

    Current := TempNode.AsObject.TreatAs<THCmdQueryNodeString>.Data;

    for i := 0 to Length(AKeywords) - 1 do
        if Current = AKeywords[i] then begin
            Result := i;
            Break;
        end;
end;

function THCmdQueryCallBoundaryFrame.TryExpectVariable(const AIndex: Integer; out AVariableName: UnicodeString): Boolean;
var TempNode: PSafeVariant;
begin
    Result := TryExpectNode(AIndex, TempNode);
    if not Result then
        Exit;

    Result := False;
    if not TempNode.IsObject or not Assigned(TempNode.AsObject.Interfaces) or not Assigned(TempNode.AsObject.Interfaces.Evaluatable) or not (TObject(TempNode.AsObject.Value) is THCmdQueryNodeVariable) then
        Exit;

    AVariableName := TempNode.AsObject.TreatAs<THCmdQueryNodeVariable>.VariableName;
    Result := True;
end;

function THCmdQueryCallBoundaryFrame.TryExpectAssignable(const AIndex: Integer; out AAssignable: PSafeObject): Boolean;
var TempNode: PSafeVariant;
    TempRes: SafeVariant;
begin
    Result := TryExpectNode(AIndex, TempNode);
    if not Result then
        Exit;

    Result := False;
    if not TempNode.IsObject then
        Exit;

    if Assigned(TempNode.AsObject.Interfaces) and Assigned(TempNode.AsObject.Interfaces.Assignable) then begin
        Result := True;
        AAssignable := TempNode.AsObject;
        Exit;
    end;

    TempRes := CallNodeWithPreviousFrame(TempNode);
    if TempRes.IsObject and Assigned(TempRes.AsObject.Interfaces) and Assigned(TempRes.AsObject.Interfaces.Assignable) then begin
        Result := True;
        AAssignable := TempRes.AsObject;
        Exit;
    end;
end;

function THCmdQueryCallBoundaryFrame.TryExpectValue(const AIndex: Integer; out AResult: SafeVariant): Boolean;
var TempNode: PSafeVariant;
begin
    Result := TryExpectNode(AIndex, TempNode);
    if not Result then
        Exit;

    ArgumentRequestIndex := AIndex;
    AResult := CallNodeWithPreviousFrame(TempNode);

    Result := True;
end;

function THCmdQueryCallBoundaryFrame.TryExpectString(const AIndex: Integer; out AResult: UnicodeString): Boolean;
var TempValue: SafeVariant;
begin
    Result := TryExpectValue(AIndex, TempValue);
    if not Result then
        Exit;

    Result := TempValue.IsString;
    if not Result then
        Exit;

    AResult := TempValue.AsString.Value;
end;

function THCmdQueryCallBoundaryFrame.TryExpectInteger(const AIndex: Integer; out AResult: Int64): Boolean;
var TempValue: SafeVariant;
begin
    Result := TryExpectValue(AIndex, TempValue);
    if not Result then
        Exit;

    Result := TempValue.IsInteger;
    if not Result then
        Exit;

    AResult := TempValue.AsInteger;
end;

function THCmdQueryCallBoundaryFrame.TryExpectNumber(const AIndex: Integer; out AResult: Double): Boolean;
var TempValue: SafeVariant;
begin
    Result := TryExpectValue(AIndex, TempValue);
    if not Result then
        Exit;

    case TempValue.VarType of
        HCmdQueryVarType.Int64 : AResult := TempValue.AsInteger;
        HCmdQueryVarType.Double: AResult := TempValue.AsDouble;
    else
        Result := False;
    end;
end;

function THCmdQueryCallBoundaryFrame.FindParameter(const AName: UnicodeString): Integer;
var i: Integer;
begin
    Result := -1;
    for i := 0 to ParameterStackCount - 1 do
        if ParameterStack[i].Name.IsString and (ParameterStack[i].Name.AsString.Value = AName) then begin
            Result := i;
            Break;
        end;
end;

function THCmdQueryCallBoundaryFrame.TryExpectParameterNode(const AName: UnicodeString; out ANode: PSafeVariant): Boolean;
var Index: Integer;
begin
    Result := False;
    Index := FindParameter(AName);
    if Index < 0 then
        Exit;

    ANode := @ParameterStack[Index].Value;
    Result := True;
end;

function THCmdQueryCallBoundaryFrame.TryExpectParameterValue(const AName: UnicodeString; out AResult: SafeVariant): Boolean;
var TempNode: PSafeVariant;
begin
    Result := False;
    if not TryExpectParameterNode(AName, TempNode) then
        Exit;

    AResult := CallNodeWithPreviousFrame(TempNode);
    Result := True;
end;

function THCmdQueryCallBoundaryFrame.TryExpectParameterString(const AName: UnicodeString; out AResult: UnicodeString): Boolean;
var Value: SafeVariant;
begin
    Result := False;
    if not TryExpectParameterValue(AName, Value) or not Value.IsString then
        Exit;
    AResult := Value.AsString.Value;
    Result := True;
end;

function THCmdQueryCallBoundaryFrame.TryExpectParameterInteger(const AName: UnicodeString; out AResult: Int64): Boolean;
var Value: SafeVariant;
begin
    Result := False;
    if not TryExpectParameterValue(AName, Value) or not Value.IsInteger then
        Exit;
    AResult := Value.AsInteger;
    Result := True;
end;

function THCmdQueryCallBoundaryFrame.TryExpectParameterNumber(const AName: UnicodeString; out AResult: Double): Boolean;
var Value: SafeVariant;
begin
    Result := False;
    if not TryExpectParameterValue(AName, Value) or not (Value.VarType in [ HCmdQueryVarType.Int64, HCmdQueryVarType.Double ]) then
        Exit;

    case Value.VarType of
        HCmdQueryVarType.Int64: AResult := Value.AsInteger;
        HCmdQueryVarType.Double: AResult := Value.AsDouble;
    else
        { Impossible case }
    end;
    Result := True;
end;

function THCmdQueryCallBoundaryFrame.TryExpectParameterBoolean(const AName: UnicodeString; out AResult: Boolean): Boolean;
var Value: SafeVariant;
begin
    Result := False;
    if not TryExpectParameterValue(AName, Value) then
        Exit;

    Result := True;
    AResult := Value.GetBooleanValue;
end;

function THCmdQueryCallBoundaryFrame.ExpectNode(const AIndex: Integer; const AMessage: UnicodeString): PSafeVariant;
begin
    if not TryExpectNode(AIndex, Result) then
        raise EHCmdQueryArgumentException.Create(AMessage, Position^);
end;

procedure THCmdQueryCallBoundaryFrame.ExpectKeyword(const AIndex: Integer; const AKeyword: UnicodeString; const AMessage: UnicodeString);
begin
    if not TryExpectKeyword(AIndex, AKeyword) then
        raise EHCmdQueryArgumentException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectKeywords(const AIndex: Integer; const AKeywords: array of UnicodeString; const AMessage: UnicodeString): Integer;
begin
    Result := TryExpectKeywords(AIndex, AKeywords);
    if Result < 0 then
        raise EHCmdQueryArgumentException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectVariable(const AIndex: Integer; const AMessage: UnicodeString): UnicodeString;
begin
    if not TryExpectVariable(AIndex, Result) then
        raise EHCmdQueryArgumentException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectAssignable(const AIndex: Integer; const AMessage: UnicodeString): PSafeObject;
begin
    if not TryExpectAssignable(AIndex, Result) then
        raise EHCmdQueryArgumentException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectValue(const AIndex: Integer; const AMessage: UnicodeString): SafeVariant;
begin
    if not TryExpectValue(AIndex, Result) then
        raise EHCmdQueryArgumentException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectString(const AIndex: Integer; const AMessage: UnicodeString): UnicodeString;
begin
    if not TryExpectString(AIndex, Result) then
        raise EHCmdQueryArgumentException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectInteger(const AIndex: Integer; const AMessage: UnicodeString): Int64;
begin
    if not TryExpectInteger(AIndex, Result) then
        raise EHCmdQueryArgumentException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectNumber(const AIndex: Integer; const AMessage: UnicodeString): Double;
begin
    if not TryExpectNumber(AIndex, Result) then
        raise EHCmdQueryArgumentException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectIntegerDefault(const AIndex: Integer; const ADefaultValue: Int64): Int64;
begin
    if not TryExpectInteger(AIndex, Result) then
        Result := ADefaultValue;
end;

function THCmdQueryCallBoundaryFrame.ExpectNumberDefault(const AIndex: Integer; const ADefaultValue: Double): Double;
begin
    if not TryExpectNumber(AIndex, Result) then
        Result := ADefaultValue;
end;

function THCmdQueryCallBoundaryFrame.ExpectStringDefault(const AIndex: Integer; const ADefaultValue: UnicodeString): UnicodeString;
begin
    if not TryExpectString(AIndex, Result) then
        Result := ADefaultValue;
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterNode(const AName: UnicodeString; const AMessage: UnicodeString): PSafeVariant;
begin
    if not TryExpectParameterNode(AName, Result) then
        raise EHCmdQueryParameterException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterValue(const AName: UnicodeString; const AMessage: UnicodeString): SafeVariant;
begin
    if not TryExpectParameterValue(AName, Result) then
        raise EHCmdQueryParameterException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterString(const AName: UnicodeString; const AMessage: UnicodeString): UnicodeString;
begin
    if not TryExpectParameterString(AName, Result) then
        raise EHCmdQueryParameterException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterInteger(const AName: UnicodeString; const AMessage: UnicodeString): Int64;
begin
    if not TryExpectParameterInteger(AName, Result) then
        raise EHCmdQueryParameterException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterNumber(const AName: UnicodeString; const AMessage: UnicodeString): Double;
begin
    if not TryExpectParameterNumber(AName, Result) then
        raise EHCmdQueryParameterException.Create(AMessage, Position^);
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterValueDefault(const AName: UnicodeString; const ADefault: SafeVariant): SafeVariant;
begin
    if not TryExpectParameterValue(AName, Result) then
        Result := ADefault;
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterStringDefault(const AName: UnicodeString; const ADefault: UnicodeString): UnicodeString;
begin
    if not TryExpectParameterString(AName, Result) then
        Result := ADefault;
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterIntegerDefault(const AName: UnicodeString; const ADefault: Int64): Int64;
begin
    if not TryExpectParameterInteger(AName, Result) then
        Result := ADefault;
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterNumberDefault(const AName: UnicodeString; const ADefault: Double): Double;
begin
    if not TryExpectParameterNumber(AName, Result) then
        Result := ADefault;
end;

function THCmdQueryCallBoundaryFrame.ExpectParameterBooleanDefault(const AName: UnicodeString; const ADefault: Boolean): Boolean;
begin
    if not TryExpectParameterBoolean(AName, Result) then
        Result := ADefault;
end;

procedure THCmdQueryCallBoundaryFrame.EndExpectation(const AIndex: Integer);
begin
    if ArgumentStackCount > AIndex then
        raise EHCmdQueryArgumentException.Create('Argument at index %d was not expected (there is %d arguments overall)', [ AIndex, ArgumentStackCount ], Position^);
end;

procedure THCmdQueryCallBoundaryFrame.Clear;
var i: Integer;
begin
    for i := 0 to LocalVariableStack.Count - 1 do
        LocalVariableStack.Items[i].Value := None;
    //for i := 0 to ArgumentStack.Count - 1 do
        //ArgumentStack.Items[i] := None;
    //for i := 0 to ParameterStack.Count - 1 do begin
        //ParameterStack.Items[i].Name := None;
        //ParameterStack.Items[i].Value := None;
    //end;

    //LocalVariableStack.Nullify;
    //ArgumentStack.Nullify;
    //ParameterStack.Nullify;

    LocalVariableStack.Clear;
    //ArgumentStack.Clear;
    //ParameterStack.Clear;

    ArgumentStack := nil;
    ParameterStack := nil;
    ArgumentStackCount := 0;
    ParameterStackCount := 0;

    LocalVariablesStackBase := 0;
    //ArgumentStackBase := 0;
    //ParameterStackBase := 0;

    Next := nil;
    Previous := nil;
    Left := nil;
    Right := nil;

    ChangeFunctionName := False;
    NewFunctionName := '';

    ControlFlowFlag := THCmdQueryControlFlowFlag.None;
end;

end.

