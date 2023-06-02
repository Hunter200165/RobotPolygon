unit HCmdQuery.Kernel.InterpreterBase;

{$I HCmdQuery.inc}

{#! [1] Getting variable by index may result in undefined behavior, if index passed as argument is outside the variable stack bounds (for example less than zero or greater or equals than count of variables in stack).
    This is not an error, however, there might be a safe-way-to-do-it function, for example GetModuleVariablePointerSafe or something like this, which should return nil, if index is outside of array bounds.
    Also, this allows call to be inlined, which is good thing, probably.
}
{#! [2] Create*Variable functions DO NOT check if variables do actually already exists, therefore be careful using those methods! You probably should check for variable existance before creating one.
    This is not an error, however, there might be a safe-way-to-do-it function, for example CreateModuleVariableSafe or somethinf like thise, which should return a pointer to existing var recode, if it already exists.
    Also, this allow call to be inlined.
}

interface

uses
    SysUtils,
    HCL.Core.Unused,
    HCL.Core.GenericList,
    HCmdQuery.Types,
    HCmdQuery.SafeVariant,
    HCmdQuery.Compiler,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.ResourceManager,
    HCmdQuery.Kernel.CallBoundary;

type

    { THCmdQueryInterpreterBase }

    THCmdQueryInterpreterBase = class(THCmdQueryObject)
    public const
        TypeID = 1683914377947;
    private var
        FResourceManager: THCmdQueryResourceManager;
        _Interpreter: IHCmdQueryInterpreter;
        _Nullable: IHCmdQueryNullable;
    public var
        CallBoundaries: THCmdQueryCallBoundaryFrames;
        CurrentCallBoundary: PHCmdQueryCallBoundaryFrame;
        GlobalFunctions: THCmdQueryFunctions;
        GlobalVariables: THCmdQueryLocalStack;
        SelfObject: PSafeObject;
    public
        ShadowObjects: array [HCmdQueryVarType.None..Pred(HCmdQueryVarType.SafeObject)] of SafeObject;
    public
        property ResourceManager: THCmdQueryResourceManager read FResourceManager;
    protected
        function ConvertCompilerNodeToExecutable(const ACompilerNode: THCmdQueryCompilerNode; var AModule: SafeVariant): SafeVariant;
    public
        procedure _Nullify(const ASelf: PSafeObject); cdecl;
    public
        function _GetCurrentCallBoundary: Pointer; cdecl;
        procedure _SetCurrentCallBoundary(const ACallBoundary: Pointer); cdecl;
        function _SetCurrentCallBoundaryLevelDown: Pointer; cdecl;
    public
        function _AllocateCallBoundaryFrame: Pointer; cdecl;
    public
        function _AllocateString(const AValue: UnicodeString): PSafeString; cdecl;
        function _AllocateObject(const AValue: Pointer; const ATypeID: UInt64): PSafeObject; cdecl;
    public
        function _GetSimpleTypeShadowObject(const ATypeID: HCmdQueryVarType): PSafeObject; cdecl;
    public
        procedure _CallNode(const ANode: PSafeVariant; const AArguments: PSafeVariant; const AArgumentsCount: Integer; const AResult: PSafeVariant); cdecl;
        procedure _CallNodeFull(const ANode: PSafeVariant; const AArguments: PSafeVariant; const AArgumentsCount: Integer; const AParameters: Pointer; const AParametersCount: Integer; const AResult: PSafeVariant); cdecl;
    public
        function AllocateModule(const AFullPath, AShortName: UnicodeString): SafeVariant;
        function ConvertNodes(const ACompilerNode: THCmdQueryCompilerNode; const AFullModulePath, AShortModuleName: UnicodeString): SafeVariant;
    public
        function FindGlobalFunction(const AName: UnicodeString): Integer;
        function FindGlobalVariable(const AName: UnicodeString): Integer;
    public
        function RegisterGlobalFunction(const AName: UnicodeString; const ANativeFunction: THCmdQueryNativeFunction): Boolean;
        procedure RegisterTypeVariable(const AName: UnicodeString; const AObject: Pointer; const ATypeID: UInt64);
    public
        function AllocateCallBoundaryFrame: PHCmdQueryCallBoundaryFrame;
        procedure DeallocateCallBoundaryFrame; cdecl;
    public
        function CallNode(const ANode: PSafeVariant; const AArguments: PSafeVariant; const AArgumentsCount: Integer; const AParameters: PHCmdQueryParameter; const AParametersCount: Integer): SafeVariant;
        //function CallNodePreviousCallBoundary(const ANode: PSafeObject; const AArguments: PSafeVariant; const AArgumentsCount: Integer; const AParameters: PHCmdQueryParameter; const AParametersCount: Integer): SafeVariant;
    public
        constructor Create;
        destructor Destroy; override;
    end;

implementation

uses
    HCmdQuery.Kernel.Context,
    HCmdQuery.Kernel.Node;

{ THCmdQueryInterpreterBase }

function THCmdQueryInterpreterBase.ConvertCompilerNodeToExecutable(const ACompilerNode: THCmdQueryCompilerNode; var AModule: SafeVariant): SafeVariant;
var Node: THCmdQueryNode;
    i: Integer;
begin
    case ACompilerNode.NodeType of
        THCmdQueryCompilerNodeType.Integer:
            begin
                Result := ResourceManager.AllocateObject(THCmdQueryNodeInteger.Create(ACompilerNode.NodePosition), THCmdQueryNode.TypeID);

                Result.AsObject.TreatAs<THCmdQueryNodeInteger>.Data := ACompilerNode.DataInt64;
            end;
        THCmdQueryCompilerNodeType.Double:
            begin
                Result := ResourceManager.AllocateObject(THCmdQueryNodeDouble.Create(ACompilerNode.NodePosition), THCmdQueryNode.TypeID);
                Result.AsObject.TreatAs<THCmdQueryNodeDouble>.Data := ACompilerNode.DataDouble;
            end;
        THCmdQueryCompilerNodeType.UnicodeString:
            begin
                Result := ResourceManager.AllocateObject(THCmdQueryNodeString.Create(ACompilerNode.NodePosition), THCmdQueryNode.TypeID);
                Result.AsObject.TreatAs<THCmdQueryNodeString>.Data := ACompilerNode.DataString;
            end;
        THCmdQueryCompilerNodeType.Variable:
            begin
                Result := ResourceManager.AllocateObject(THCmdQueryNodeVariable.Create(ACompilerNode.NodePosition), THCmdQueryNode.TypeID);
                Result.AsObject.TreatAs<THCmdQueryNodeVariable>.VariableName := ACompilerNode.DataString;
            end;
        THCmdQueryCompilerNodeType.Body:
            begin
                Result := ResourceManager.AllocateObject(THCmdQueryNodeBody.Create(ACompilerNode.NodePosition), THCmdQueryNode.TypeID);
                Node := Result.AsObject.TreatAs<THCmdQueryNode>;

                for i := 0 to ACompilerNode.Children.Count - 1 do
                    Node.Arguments.Add(ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[i], AModule));
            end;
        THCmdQueryCompilerNodeType.Evaluated:
            begin
                Result := ResourceManager.AllocateObject(THCmdQueryNodeCallFunction.Create(ACompilerNode.NodePosition), THCmdQueryNode.TypeID);
                Node := Result.AsObject.TreatAs<THCmdQueryNodeCallFunction>;
                THCmdQueryNodeCallFunction(Node).FunctionName := ACompilerNode.DataString;

                for i := 0 to ACompilerNode.Children.Count - 1 do begin
                    if ACompilerNode.Children.Items[i].NodeType = THCmdQueryCompilerNodeType.Parameter then begin
                        with THCmdQueryNodeCallFunction(Node).Parameters.AddReferenced^ do begin
                            Name := ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[i].Children.Items[0], AModule);
                            Value := ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[i].Children.Items[1], AModule);
                        end;

                        Continue;
                    end;

                    THCmdQueryNodeCallFunction(Node).Arguments.Add(ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[i], AModule));
                end;
            end;
        THCmdQueryCompilerNodeType.MethodCall:
            begin
                Result := ResourceManager.AllocateObject(THCmdQueryNodeMethodCall.Create(ACompilerNode.NodePosition), THCmdQueryNode.TypeID);
                Node := Result.AsObject.TreatAs<THCmdQueryNode>;

                THCmdQueryNodeMethodCall(Node).IndexableNode := ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[0], AModule);
                THCmdQueryNodeMethodCall(Node).MethodNameNode := ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[1], AModule);

                for i := 2 to ACompilerNode.Children.Count - 1 do begin
                    if ACompilerNode.Children.Items[i].NodeType = THCmdQueryCompilerNodeType.Parameter then begin
                        with THCmdQueryNodeMethodCall(Node).Parameters.AddReferenced^ do begin
                            Name := ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[i].Children.Items[0], AModule);
                            Value := ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[i].Children.Items[1], AModule);
                        end;

                        Continue;
                    end;

                    THCmdQueryNodeMethodCall(Node).Arguments.Add(ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[i], AModule));
                end;
            end;
        THCmdQueryCompilerNodeType.Indexing,
        THCmdQueryCompilerNodeType.FieldIndexing:
            begin
                Result := ResourceManager.AllocateObject(THCmdQueryNodeIndex.Create(ACompilerNode.NodePosition), THCmdQueryNode.TypeID);
                Node := Result.AsObject.TreatAs<THCmdQueryNodeIndex>;
                THCmdQueryNodeIndex(Node).IndexableNode := ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[0], AModule);
                THCmdQueryNodeIndex(Node).IndexNode := ConvertCompilerNodeToExecutable(ACompilerNode.Children.Items[1], AModule);
            end;
    else
        raise ENotImplemented.Create('Not implemented yet');
    end;

    Result.AsObject.TreatAs<THCmdQueryNode>.ParentContext := AModule;
    //WriteLn('NODE ', TObject(Result.AsObject.Value).ClassName, ' REFCOUNT = ', Result.AsObject.RefCount);
    // WriteLn('MODULE REFCOUNT = ', AModule.AsObject.RefCount);
end;

procedure THCmdQueryInterpreterBase._Nullify(const ASelf: PSafeObject); cdecl;
var i: Integer;
begin
    for i := 0 to GlobalVariables.Count - 1 do
        GlobalVariables.Items[i].Value := None;

    for i := 0 to GlobalFunctions.Count - 1 do
        GlobalFunctions.Items[i].Value := None;

    GlobalVariables.Clear;
    GlobalFunctions.Clear;
end;

function THCmdQueryInterpreterBase._GetCurrentCallBoundary: Pointer; cdecl;
begin
    Result := CurrentCallBoundary;
end;

procedure THCmdQueryInterpreterBase._SetCurrentCallBoundary(const ACallBoundary: Pointer); cdecl;
begin
    CurrentCallBoundary := ACallBoundary;
end;

function THCmdQueryInterpreterBase._SetCurrentCallBoundaryLevelDown: Pointer; cdecl;
begin
    Result := CurrentCallBoundary;
    CurrentCallBoundary := CurrentCallBoundary.Previous;
end;

function THCmdQueryInterpreterBase._AllocateCallBoundaryFrame: Pointer; cdecl;
begin
    Result := AllocateCallBoundaryFrame;

    if Assigned(CurrentCallBoundary.Previous) then begin
        CurrentCallBoundary.Module := CurrentCallBoundary.Previous.Module;
        CurrentCallBoundary.Position := CurrentCallBoundary.Previous.Position;
    end;
end;

function THCmdQueryInterpreterBase._AllocateString(const AValue: UnicodeString): PSafeString; cdecl;
begin
    Result := ResourceManager.AllocateString(AValue);
end;

function THCmdQueryInterpreterBase._AllocateObject(const AValue: Pointer; const ATypeID: UInt64): PSafeObject; cdecl;
begin
    Result := ResourceManager.AllocateObject(AValue, ATypeID);
end;

function THCmdQueryInterpreterBase._GetSimpleTypeShadowObject(const ATypeID: HCmdQueryVarType): PSafeObject; cdecl;
begin
    if (ATypeID < HCmdQueryVarType.None) or (ATypeID >= HCmdQueryVarType.SafeObject) then begin
        Result := nil;
        Exit;
    end;

    Result := @ShadowObjects[ATypeID];
end;

procedure THCmdQueryInterpreterBase._CallNode(const ANode: PSafeVariant; const AArguments: PSafeVariant; const AArgumentsCount: Integer; const AResult: PSafeVariant); cdecl;
begin
    AResult^ := CallNode(ANode, AArguments, AArgumentsCount, nil, 0);
end;

procedure THCmdQueryInterpreterBase._CallNodeFull(const ANode: PSafeVariant; const AArguments: PSafeVariant; const AArgumentsCount: Integer; const AParameters: Pointer; const AParametersCount: Integer; const AResult: PSafeVariant); cdecl;
begin
    AResult^ := CallNode(ANode, AArguments, AArgumentsCount, AParameters, AParametersCount);
end;

function THCmdQueryInterpreterBase.AllocateModule(const AFullPath, AShortName: UnicodeString): SafeVariant;
begin
    Result := ResourceManager.AllocateObject(THCmdQueryContext.Create, THCmdQueryContext.TypeID);
end;

function THCmdQueryInterpreterBase.ConvertNodes(const ACompilerNode: THCmdQueryCompilerNode; const AFullModulePath, AShortModuleName: UnicodeString): SafeVariant;
var Module: SafeVariant;
begin
    Module := AllocateModule(AFullModulePath, AShortModuleName);

    Result := ConvertCompilerNodeToExecutable(ACompilerNode, Module);
end;

function THCmdQueryInterpreterBase.FindGlobalFunction(const AName: UnicodeString): Integer;
var i: Integer;
begin
    Result := -1;

    for i := GlobalFunctions.Count - 1 downto 0 do
        if GlobalFunctions.Items[i].Name = AName then begin
            Result := i;
            Break;
        end;
end;

function THCmdQueryInterpreterBase.FindGlobalVariable(const AName: UnicodeString): Integer;
var i: Integer;
begin
    Result := -1;

    for i := 0 to GlobalVariables.Count - 1 do
        if GlobalVariables.Items[i].Name = AName then begin
            Result := i;
            Break;
        end;
end;

function THCmdQueryInterpreterBase.RegisterGlobalFunction(const AName: UnicodeString; const ANativeFunction: THCmdQueryNativeFunction): Boolean;
begin
    Result := False;

    if FindGlobalFunction(AName) >= 0 then
        Exit;

    with GlobalFunctions.AddReferenced^ do begin
        Name := AName;
        Value.VarType := HCmdQueryVarType.NativeFunction;
        Value.AsNativeFunction := THCmdQueryNativeFunction(ANativeFunction);
    end;
end;

procedure THCmdQueryInterpreterBase.RegisterTypeVariable(const AName: UnicodeString; const AObject: Pointer; const ATypeID: UInt64);
begin
    with GlobalVariables.AddReferenced^ do begin
        Name := AName;
        Value := ResourceManager.AllocateObject(AObject, ATypeID);
    end;
end;

function THCmdQueryInterpreterBase.AllocateCallBoundaryFrame: PHCmdQueryCallBoundaryFrame;
var APtr: ^PHCmdQueryCallBoundaryFrame;
begin
    APtr := CallBoundaries.AddReferenced;
    Result := APtr^;

    if not Assigned(Result) then begin
        New(Result);
        Result^ := Default(THCmdQueryCallBoundaryFrame);

        APtr^ := Result;
    end;


    // Result^ := Default(THCmdQueryCallBoundaryFrame);

    if Assigned(CurrentCallBoundary) then begin
        if Assigned(CurrentCallBoundary.Next) then begin
            CurrentCallBoundary.Next.Right := Result;
            Result.Left := CurrentCallBoundary.Next;
            Result.SelfArgumentIndex := CurrentCallBoundary.Next.ArgumentRequestIndex;

            Result.Position := CurrentCallBoundary.Position;
        end
        else
            Result.SelfArgumentIndex := CurrentCallBoundary.ArgumentRequestIndex;

        CurrentCallBoundary.Next := Result;
    end;
    Result.Previous := CurrentCallBoundary;

    Result.Next := nil;
    Result.Interpreter := SelfObject;

    CurrentCallBoundary := Result;
end;

procedure THCmdQueryInterpreterBase.DeallocateCallBoundaryFrame; cdecl;
var Prev: PHCmdQueryCallBoundaryFrame;
begin
    Prev := CurrentCallBoundary.Previous;
    if Assigned(CurrentCallBoundary.Left) then begin
        CurrentCallBoundary.Left.Right := nil;

        if Assigned(Prev) then
            Prev.Next := CurrentCallBoundary.Left;
    end
    else if Assigned(Prev) then
        Prev.Next := nil;

    CurrentCallBoundary.Clear;

    //if Assigned(Prev) and (Prev.Next = CurrentCallBoundary) then
    //    Prev.Next := nil;
    CurrentCallBoundary := Prev;

    CallBoundaries.Remove;
end;

function THCmdQueryInterpreterBase.CallNode(const ANode: PSafeVariant; const AArguments: PSafeVariant; const AArgumentsCount: Integer; const AParameters: PHCmdQueryParameter; const AParametersCount: Integer): SafeVariant;
var CurrentCBF: PHCmdQueryCallBoundaryFrame;
    Params: array of THCmdQueryParameter;
    i: Integer;
begin
    Result := None;
    CurrentCBF := CurrentCallBoundary;

    //for i := 0 to AArgumentsCount - 1 do
        //CurrentCBF.ArgumentStack.Add(AArguments[i]);

    if AArgumentsCount > 0 then begin
        CurrentCBF.ArgumentStack := AArguments;
        CurrentCBF.ArgumentStackCount := AArgumentsCount;
    end;

    //for i := 0 to AParametersCount - 1 do
        //CurrentCBF.ParameterStack.Add(AParameters[i]);

    Params := nil;

    if AParametersCount > 0 then begin
        SetLength(Params, AParametersCount);

        CurrentCallBoundary := CurrentCallBoundary.Previous;
        try
            for i := 0 to AParametersCount - 1 do begin
                if AParameters[i].Name.IsObject and Assigned(AParameters[i].Name.AsObject.Interfaces) and Assigned(AParameters[i].Name.AsObject.Interfaces.Evaluatable) then
                    AParameters[i].Name.AsObject.Interfaces.Evaluatable.Evaluate(SelfObject, AParameters[i].Name.AsObject, @Params[i].Name)
                else
                    Params[i].Name := AParameters[i].Name;

                Params[i].Value := AParameters[i].Value;
            end;
        finally
            CurrentCallBoundary := CurrentCBF;
        end;

        CurrentCBF.ParameterStack := @Params[0];
        CurrentCBF.ParameterStackCount := AParametersCount;
    end;

    if ANode.VarType = HCmdQueryVarType.NativeFunction then begin
        Result := None;
        // CurrentCBF.Position := CurrentCBF.Previous.Position;
        ANode.AsNativeFunction(SelfObject, @Result)
    end
    else if ANode.IsObject and Assigned(ANode.AsObject.Interfaces) and Assigned(ANode.AsObject.Interfaces.Evaluatable) then
        // Result := ANode.AsObject.Interfaces.Evaluatable.Evaluate(SelfObject, ANode.AsObject);
        ANode.AsObject.Interfaces.Evaluatable.Evaluate(SelfObject, ANode.AsObject, @Result)
    else
        Result := ANode^;
end;

constructor THCmdQueryInterpreterBase.Create;
var i: HCmdQueryVarType;
begin
    inherited Create;

    for i := Low(ShadowObjects) to High(ShadowObjects) do begin
        ShadowObjects[i] := Default(SafeObject);
        ShadowObjects[i].Value := nil;
        ShadowObjects[i].ResourceManager := nil;
        ShadowObjects[i].RefCount := 1;
        ShadowObjects[i].Address := -1;

        ShadowObjects[i].AllocateStandaloneInterfacesTable;

        New(ShadowObjects[i].Interfaces.Addable);
        New(ShadowObjects[i].Interfaces.Subtractable);
        New(ShadowObjects[i].Interfaces.Multiplyable);
        New(ShadowObjects[i].Interfaces.Divisible);
    end;

    _Interpreter.GetCurrentCallBoundary := _GetCurrentCallBoundary;
    _Interpreter.SetCurrentCallBoundary := _SetCurrentCallBoundary;
    _Interpreter.SetCurrentCallBoundaryLevelDown := _SetCurrentCallBoundaryLevelDown;

    _Interpreter.AllocateCallBoundaryFrame := _AllocateCallBoundaryFrame;
    _Interpreter.DeallocateCallBoundaryFrame := DeallocateCallBoundaryFrame;

    _Interpreter.GetSimpleTypeShadowObject := _GetSimpleTypeShadowObject;

    _Interpreter.CallNode := _CallNode;
    _Interpreter.CallNodeFull := _CallNodeFull;

    _Interpreter.AllocateString := _AllocateString;
    _Interpreter.AllocateObject := _AllocateObject;

    _Nullable.Nullify := _Nullify;

    FResourceManager := THCmdQueryResourceManager.Create;

    // It should stay here for eternity
    SelfObject := FResourceManager.AllocateObject(Self, Self.TypeID);
    SelfObject.RefCount := MaxLongint div 2;

    SelfObject.AllocateStandaloneInterfacesTable;
    SelfObject.Interfaces.Interpreter := @_Interpreter;
    SelfObject.Interfaces.Nullable := @_Nullable;

    CurrentCallBoundary := nil;
end;

destructor THCmdQueryInterpreterBase.Destroy;
var i: HCmdQueryVarType;
    k: Integer;
begin
    for i := Low(ShadowObjects) to High(ShadowObjects) do begin
        Dispose(ShadowObjects[i].Interfaces.Addable);
        Dispose(ShadowObjects[i].Interfaces.Subtractable);
        Dispose(ShadowObjects[i].Interfaces.Multiplyable);
        Dispose(ShadowObjects[i].Interfaces.Divisible);

        ShadowObjects[i].Destroy;

        ShadowObjects[i] := Default(SafeObject);
    end;

    FResourceManager.Free;

    for k := 0 to CallBoundaries.Size - 1 do begin
        if Assigned(CallBoundaries.Items[k]) then
            Dispose(CallBoundaries.Items[k]);
        CallBoundaries.Items[k] := nil;
    end;

    inherited Destroy;
end;

end.

