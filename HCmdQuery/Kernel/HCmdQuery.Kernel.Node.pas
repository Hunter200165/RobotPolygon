unit HCmdQuery.Kernel.Node;

{$I HCmdQuery.inc}

interface

uses
    SysUtils,
    HCL.Core.GenericList,
    HCL.Core.Unused,
    HCmdQuery.Types,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary;

type
    (* THCmdQueryNode
    *)
    THCmdQueryNode = class(THCmdQueryObject)
    public const
        TypeID = 1683914170003;
    public
        procedure _DisposeObject(const AObject: PSafeObject); override;
    protected var
        _Evaluatable: IHCmdQueryEvaluatable;
    public var
        Arguments: HList<SafeVariant>;
        Parameters: HList<THCmdQueryParameter>;
        Position: THCmdQueryPosition;
        ParentContext: SafeVariant;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        function GetOpCode(const AInterpreter: PSafeObject; const ANode: PSafeObject): Integer; cdecl;
        procedure GetArgument(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AIndex: Integer; out AResult: PSafeVariant); cdecl;
    public
        function GetArgumentsPointer: PSafeVariant;
        function GetParametersPointer: PHCmdQueryParameter;
    public
        constructor Create(const APosition: THCmdQueryPosition);
        destructor Destroy; override;
    end;

    { THCmdQueryNodeInteger }

    THCmdQueryNodeInteger = class(THCmdQueryNode)
    public var
        Data: Int64;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
    end;

    { THCmdQueryNodeDouble }

    THCmdQueryNodeDouble = class(THCmdQueryNode)
    public var
        Data: Double;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
    end;

    { THCmdQueryNodeString }

    THCmdQueryNodeString = class(THCmdQueryNode)
    public var
        Data: UnicodeString;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
    end;

    { THCmdQueryNodeIndex }

    THCmdQueryNodeIndex = class(THCmdQueryNode)
    protected var
        _Assignable: IHCmdQueryAssignable;
    public var
        IndexableNode: SafeVariant;
        IndexNode: SafeVariant;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure GetArgument(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AIndex: Integer; out AResult: PSafeVariant); cdecl;
    public
        procedure AssignIndex(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
    public
        procedure Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
    end;

    { THCmdQueryNodeMethodCall }

    THCmdQueryNodeMethodCall = class(THCmdQueryNode)
    public var
        IndexableNode: SafeVariant;
        MethodNameNode: SafeVariant;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure GetArgument(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AIndex: Integer; out AResult: PSafeVariant); cdecl;
    public
        procedure Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
    end;

    { THCmdQueryNodeVariable }

    THCmdQueryNodeVariable = class(THCmdQueryNode)
    protected var
        _Assignable: IHCmdQueryAssignable;
    public var
        VariableName: UnicodeString;
        VariableLocation: THCmdQueryScopeLocation;
        VariableIndex: Integer;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure InitializeVariableLocation(const AInterpreter: PSafeObject);
    public
        procedure AssignLocal(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
        procedure AssignModuleLocal(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
        procedure AssignModuleGlobal(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
        procedure AssignGlobal(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
        procedure Assign(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
    public
        procedure EvaluateGetLocal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
        procedure EvaluateGetModuleLocal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
        procedure EvaluateGetModuleGlobal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
        procedure EvaluateGetGlobal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
        procedure Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
    end;

    { THCmdQueryNodeBody }

    THCmdQueryNodeBody = class(THCmdQueryNode)
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
    end;

    { THCmdQueryNodeCallFunction }

    THCmdQueryNodeCallFunction = class(THCmdQueryNode)
    public var
        FunctionName: UnicodeString;
        FunctionLocation: THCmdQueryScopeLocation;
        FunctionIndex: Integer;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure EvaluateCallLocal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
        procedure EvaluateCallModule(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
        procedure EvaluateCallGlobal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
        procedure Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
    end;

implementation

uses
    HCmdQuery.Kernel.Context,
    HCmdQuery.Kernel.InterpreterBase;

{ THCmdQueryNodeMethodCall }

procedure THCmdQueryNodeMethodCall._CreateObject(const AObject: PSafeObject);
begin
    inherited _CreateObject(AObject);

    _Evaluatable.Evaluate := Evaluate;
    _Evaluatable.GetArgument := GetArgument;
end;

procedure THCmdQueryNodeMethodCall.GetArgument(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AIndex: Integer; out AResult: PSafeVariant); cdecl;
begin
    AResult := nil;
    case AIndex of
        0: AResult := @IndexableNode;
        1: AResult := @MethodNameNode;
    end;
end;

procedure THCmdQueryNodeMethodCall.Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
var PreRes: SafeVariant;
    IndexingObj: PSafeObject;
    Operands: array of SafeVariant;
    CBF: PHCmdQueryCallBoundaryFrame;
    Infs: PSafeObjectInterfaces;
    i: Integer;
begin
    PreRes := None;

    IndexableNode.AsObject.Interfaces.Evaluatable.Evaluate(AInterpreter, IndexableNode.AsObject, @PreRes);

    IndexingObj := nil;
    if PreRes.IsObject then
        IndexingObj := PreRes.AsObject
    else
        IndexingObj := AInterpreter.Interfaces.Interpreter.GetSimpleTypeShadowObject(PreRes.VarType);

    if IndexingObj = nil then
        raise EHCmdQueryNotAnObject.Create(
            '%s does not support method calling',
            [ PreRes.GetTypeString ],
            Position
        );

    Infs := IndexingObj.Interfaces;

    while Assigned(Infs) and (not Assigned(Infs.MethodSupportable) or not Assigned(@Infs.MethodSupportable.CallMethod)) do
        Infs := Infs.ShadowInterfaces;

    if Infs = nil then
        raise EHCmdQueryObjectDoesNotSupportInterface.Create(
            '%s (or its shadow object) does not support method calling',
            [ PreRes.GetTypeString ],
            Position
        );

    Operands := nil;
    SetLength(Operands, Arguments.Count + 2);

    for i := 0 to Arguments.Count - 1 do
        Operands[i + 2] := Arguments.Items[i];

    Operands[1] := None;

    MethodNameNode.AsObject.Interfaces.Evaluatable.Evaluate(AInterpreter, MethodNameNode.AsObject, @Operands[1]);

    Operands[0] := None;
    Operands[0] := IndexingObj;
    // Assigning SafeVariant can leave refcount unincremented
    IndexingObj.AddRef;

    while not False do begin

        //CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary();
        CBF := AInterpreter.Interfaces.Interpreter.AllocateCallBoundaryFrame();
        CBF.Position := @Position;
        try
            with CBF.LocalVariableStack.AddReferenced^ do begin
                Name := 'self';
                Value := PreRes;
            end;
            //#! Maybe self should contain IndexingObj and selfValue variable should contain PreRes?

            AInterpreter.Interfaces.Interpreter.CallNodeFull(@Infs.MethodSupportable.CallMethod, @Operands[0], Length(Operands), GetParametersPointer, Parameters.Count, AResult);
        finally
            AInterpreter.Interfaces.Interpreter.DeallocateCallBoundaryFrame;
        end;

        if AResult.VarType = HCmdQueryVarType.SkipObject then begin
            //while Assigned(IndexingObj.Interfaces.ShadowInterfaces) and ;

            Infs := Infs.ShadowInterfaces;
            while Assigned(Infs) and (not Assigned(Infs.MethodSupportable) or not Assigned(@Infs.MethodSupportable.CallMethod)) do
                Infs := Infs.ShadowInterfaces;

            if Infs = nil then
                raise EHCmdQueryNoSuchOverload.Create(
                    '%s does not support method call with %s type or with %s value',
                    [ PreRes.GetTypeString, Operands[1].GetTypeString, Operands[1].GetSimpleString ],
                    PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
                );
        end
        else
            Break;
    end;
end;

{ THCmdQueryNodeIndex }

procedure THCmdQueryNodeIndex._CreateObject(const AObject: PSafeObject);
begin
    inherited _CreateObject(AObject);

    _Evaluatable.Evaluate := Evaluate;
    _Evaluatable.GetArgument := GetArgument;

    AObject.Interfaces.Assignable := @_Assignable;
    _Assignable.Assign := AssignIndex;
end;

procedure THCmdQueryNodeIndex.GetArgument(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AIndex: Integer; out AResult: PSafeVariant); cdecl;
begin
    AResult := nil;
    case AIndex of
        0: AResult := @IndexableNode;
        1: AResult := @IndexNode;
    end;
end;

procedure THCmdQueryNodeIndex.AssignIndex(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
var PreRes, Res: SafeVariant;
    IndexingObj: PSafeObject;
    Operands: array [0..2] of SafeVariant;
    CBF: PHCmdQueryCallBoundaryFrame;
    Infs: PSafeObjectInterfaces;
begin
    PreRes := None;

    IndexableNode.AsObject.Interfaces.Evaluatable.Evaluate(AInterpreter, IndexableNode.AsObject, @PreRes);

    IndexingObj := nil;
    if PreRes.IsObject then
        IndexingObj := PreRes.AsObject
    else
        IndexingObj := AInterpreter.Interfaces.Interpreter.GetSimpleTypeShadowObject(PreRes.VarType);

    if IndexingObj = nil then
        raise EHCmdQueryNotAnObject.Create(
            '%s does not support indexing',
            [ PreRes.GetTypeString ],
            PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
        );

    Infs := IndexingObj.Interfaces;

    while Assigned(Infs) and (not Assigned(Infs.Indexable) or not Assigned(@Infs.Indexable.SetToIndex)) do
        Infs := Infs.ShadowInterfaces;

    if Infs = nil then
        raise EHCmdQueryObjectDoesNotSupportInterface.Create(
            '%s (or its shadow object) does not support indexing',
            [ PreRes.GetTypeString ],
            Position
            //PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
        );

    //if IndexingObj.Interfaces = nil then
    //    raise EHCmdQueryObjectDoesNotSupportInterfaces.Create(
    //        'Type %s (or its shadow object) does not support indexing',
    //        [ PreRes.GetTypeString ],
    //        PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
    //    );
    //
    //if (IndexingObj.Interfaces.Indexable = nil) or (IndexingObj.Interfaces.Indexable.GetFromIndex = None) then
    //    raise EHCmdQueryObjectDoesNotSupportInterface.Create(
    //        'Type %s (or its shadow object) does not support indexing',
    //        [ PreRes.GetTypeString ],
    //        PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
    //    );

    Operands[1] := None;
    Operands[2] := None;


    IndexNode.AsObject.Interfaces.Evaluatable.Evaluate(AInterpreter, IndexNode.AsObject, @Operands[1]);

    Operands[0] := None;
    Operands[0] := IndexingObj;
    Operands[2] := ANewValue;
    // Assigning SafeVariant can leave refcount unincremented
    IndexingObj.AddRef;

    while not False do begin

        //CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary();
        CBF := AInterpreter.Interfaces.Interpreter.AllocateCallBoundaryFrame();
        CBF.Position := @Position;
        try
            with CBF.LocalVariableStack.AddReferenced^ do begin
                Name := 'self';
                Value := PreRes;
            end;

            Res := None;
            AInterpreter.Interfaces.Interpreter.CallNode(@Infs.Indexable.SetToIndex, @Operands[0], 3, @Res);
        finally
            AInterpreter.Interfaces.Interpreter.DeallocateCallBoundaryFrame;
        end;

        if Res.VarType = HCmdQueryVarType.SkipObject then begin
            //while Assigned(IndexingObj.Interfaces.ShadowInterfaces) and ;

            Infs := Infs.ShadowInterfaces;
            while Assigned(Infs) and (not Assigned(Infs.Indexable) or not Assigned(@Infs.Indexable.SetToIndex)) do
                Infs := Infs.ShadowInterfaces;

            if Infs = nil then
                raise EHCmdQueryNoSuchOverload.Create(
                    '%s does not support write indexing either with %s type or with %s value',
                    [ PreRes.GetTypeString, Operands[1].GetTypeString, Operands[1].GetSimpleString ],
                    Position
                    //PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
                );
        end
        else
            Break;
    end;
end;

procedure THCmdQueryNodeIndex.Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
var PreRes: SafeVariant;
    IndexingObj: PSafeObject;
    Operands: array [0..1] of SafeVariant;
    CBF: PHCmdQueryCallBoundaryFrame;
    Infs: PSafeObjectInterfaces;
begin
    PreRes := None;

    IndexableNode.AsObject.Interfaces.Evaluatable.Evaluate(AInterpreter, IndexableNode.AsObject, @PreRes);

    IndexingObj := nil;
    if PreRes.IsObject then
        IndexingObj := PreRes.AsObject
    else
        IndexingObj := AInterpreter.Interfaces.Interpreter.GetSimpleTypeShadowObject(PreRes.VarType);

    if IndexingObj = nil then
        raise EHCmdQueryNotAnObject.Create(
            '%s does not support indexing',
            [ PreRes.GetTypeString ],
            PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
        );

    Infs := IndexingObj.Interfaces;

    while Assigned(Infs) and (not Assigned(Infs.Indexable) or not Assigned(@Infs.Indexable.GetFromIndex)) do
        Infs := Infs.ShadowInterfaces;

    if Infs = nil then
        raise EHCmdQueryObjectDoesNotSupportInterface.Create(
            '%s (or its shadow object) does not support indexing',
            [ PreRes.GetTypeString ],
            //PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
            Position
        );

    //if IndexingObj.Interfaces = nil then
    //    raise EHCmdQueryObjectDoesNotSupportInterfaces.Create(
    //        'Type %s (or its shadow object) does not support indexing',
    //        [ PreRes.GetTypeString ],
    //        PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
    //    );
    //
    //if (IndexingObj.Interfaces.Indexable = nil) or (IndexingObj.Interfaces.Indexable.GetFromIndex = None) then
    //    raise EHCmdQueryObjectDoesNotSupportInterface.Create(
    //        'Type %s (or its shadow object) does not support indexing',
    //        [ PreRes.GetTypeString ],
    //        PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
    //    );

    Operands[1] := None;

    IndexNode.AsObject.Interfaces.Evaluatable.Evaluate(AInterpreter, IndexNode.AsObject, @Operands[1]);

    Operands[0] := None;
    Operands[0] := IndexingObj;
    // Assigning SafeVariant can leave refcount unincremented
    IndexingObj.AddRef;

    while not False do begin

        //CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary();
        CBF := AInterpreter.Interfaces.Interpreter.AllocateCallBoundaryFrame();
        CBF.Position := @Position;
        try
            with CBF.LocalVariableStack.AddReferenced^ do begin
                Name := 'self';
                Value := PreRes;
            end;

            AInterpreter.Interfaces.Interpreter.CallNode(@Infs.Indexable.GetFromIndex, @Operands[0], 3, AResult);
        finally
            AInterpreter.Interfaces.Interpreter.DeallocateCallBoundaryFrame;
        end;

        if AResult.VarType = HCmdQueryVarType.SkipObject then begin
            //while Assigned(IndexingObj.Interfaces.ShadowInterfaces) and ;

            Infs := Infs.ShadowInterfaces;
            while Assigned(Infs) and (not Assigned(Infs.Indexable) or not Assigned(@Infs.Indexable.GetFromIndex)) do
                Infs := Infs.ShadowInterfaces;

            if Infs = nil then
                raise EHCmdQueryNoSuchOverload.Create(
                    '%s does not support read indexing either with %s type or with %s value',
                    [ PreRes.GetTypeString, Operands[1].GetTypeString, Operands[1].GetSimpleString ],
                    PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).Position^
                );
        end
        else
            Break;
    end;

end;

{ THCmdQueryNode }

procedure THCmdQueryNode._DisposeObject(const AObject: PSafeObject);
begin
    inherited;
end;

procedure THCmdQueryNode._CreateObject(const AObject: PSafeObject);
begin
    AObject.AllocateStandaloneInterfacesTable;
    AObject.Interfaces.Evaluatable := @_Evaluatable;
    AObject.Interfaces.Evaluatable.GetOpCode := GetOpCode;
    AObject.Interfaces.Evaluatable.GetArgument := GetArgument;
end;

function THCmdQueryNode.GetOpCode(const AInterpreter: PSafeObject; const ANode: PSafeObject): Integer; cdecl;
begin
    Result := -1;

    if Self is THCmdQueryNodeBody then
        Result := Ord(THCmdQueryNodeType.Body)
    else if Self is THCmdQueryNodeCallFunction then
        Result := Ord(THCmdQueryNodeType.Evaluated)
    else if Self is THCmdQueryNodeDouble then
        Result := Ord(THCmdQueryNodeType.Double)
    else if Self is THCmdQueryNodeIndex then
        Result := Ord(THCmdQueryNodeType.Indexing)
    else if Self is THCmdQueryNodeInteger then
        Result := Ord(THCmdQueryNodeType.Integer)
    else if Self is THCmdQueryNodeMethodCall then
        Result := Ord(THCmdQueryNodeType.MethodCall)
    else if Self is THCmdQueryNodeString then
        Result := Ord(THCmdQueryNodeType.UnicodeString)
    else if Self is THCmdQueryNodeVariable then
        Result := Ord(THCmdQueryNodeType.Variable);
end;

procedure THCmdQueryNode.GetArgument(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AIndex: Integer; out AResult: PSafeVariant); cdecl;
begin
    AResult := @Arguments.Items[AIndex];
end;

function THCmdQueryNode.GetArgumentsPointer: PSafeVariant;
begin
    if Arguments.Count > 0 then
        Result := @Arguments.Items[0]
    else
        Result := nil;
end;

function THCmdQueryNode.GetParametersPointer: PHCmdQueryParameter;
begin
    if Parameters.Count > 0 then
        Result := @Parameters.Items[0]
    else
        Result := nil;
end;

constructor THCmdQueryNode.Create(const APosition: THCmdQueryPosition);
begin
    inherited Create;

    Arguments.Nullify;
    Parameters.Nullify;

    Position := APosition;
end;

destructor THCmdQueryNode.Destroy;
var i: Integer;
begin
    for i := 0 to Arguments.Count - 1 do
        Arguments.Items[i] := None;

    for i := 0 to Parameters.Count - 1 do begin
        Parameters.Items[i].Name := None;
        Parameters.Items[i].Value := None;
    end;

    Arguments.Nullify;
    Parameters.Nullify;

    ParentContext := None;

    //WriteLn('[nodedisposal] CONTEXT REFCOUNT = ', ParentContext.AsObject.RefCount);

    inherited Destroy;
end;

{ THCmdQueryNodeInteger }

procedure THCmdQueryNodeInteger._CreateObject(const AObject: PSafeObject);
begin
    inherited;

    AObject.Interfaces.Evaluatable.Evaluate := Evaluate;
end;

procedure THCmdQueryNodeInteger.Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    Unused<Pointer>(AInterpreter);
    Unused<Pointer>(ANode);

    AResult^ := Data;
end;

{ THCmdQueryNodeDouble }

procedure THCmdQueryNodeDouble._CreateObject(const AObject: PSafeObject);
begin
    inherited;

    AObject.Interfaces.Evaluatable.Evaluate := Evaluate;
end;

procedure THCmdQueryNodeDouble.Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    Unused<Pointer>(AInterpreter);
    Unused<Pointer>(ANode);

    AResult^ := Data;
end;

{ THCmdQueryNodeString }

procedure THCmdQueryNodeString._CreateObject(const AObject: PSafeObject);
begin
    inherited;

    AObject.Interfaces.Evaluatable.Evaluate := Evaluate;
end;

procedure THCmdQueryNodeString.Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    Unused<Pointer>(ANode);

    AResult^ := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.ResourceManager.AllocateString(Data);
end;

{ THCmdQueryNodeVariable }

procedure THCmdQueryNodeVariable._CreateObject(const AObject: PSafeObject);
begin
    inherited;
    AObject.Interfaces.Assignable := @_Assignable;

    _Evaluatable.Evaluate := Evaluate;
    _Assignable.Assign := Assign;
end;

procedure THCmdQueryNodeVariable.InitializeVariableLocation(const AInterpreter: PSafeObject);
var Interpreter: THCmdQueryInterpreterBase;
    CBF: PHCmdQueryCallBoundaryFrame;
    Index: Integer;
begin
    Interpreter := AInterpreter.TreatAs<THCmdQueryInterpreterBase>;
    CBF := Interpreter.CurrentCallBoundary;

    Index := CBF.FindLocalVariable(VariableName);
    if Index >= 0 then begin
        VariableLocation := THCmdQueryScopeLocation.Local;
        VariableIndex := Index;

        Exit;
    end;

    Index := CBF.FindModuleLocalVariable(VariableName);
    if Index >= 0 then begin
        VariableLocation := THCmdQueryScopeLocation.ModuleLocal;
        VariableIndex := Index;

        Exit;
    end;

    Index := CBF.FindModuleGlobalVariable(VariableName);
    if Index >= 0 then begin
        VariableLocation := THCmdQueryScopeLocation.ModuleGlobal;
        VariableIndex := Index;

        Exit;
    end;

    Index := Interpreter.FindGlobalVariable(VariableName);
    if Index >= 0 then begin
        VariableLocation := THCmdQueryScopeLocation.Global;
        VariableIndex := Index;

        Exit;
    end;

    raise EHCmdQueryNoSuchVariableException.Create('Variable with name `%s` is undefined', [ VariableName ], Position);
end;

procedure THCmdQueryNodeVariable.AssignLocal(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
begin
    AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary.LocalVariableStack.Items[VariableIndex].Value := ANewValue;
end;

procedure THCmdQueryNodeVariable.AssignModuleLocal(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
begin
    ParentContext.AsObject.TreatAs<THCmdQueryContext>.ModuleLocalVariables.Items[VariableIndex].Value := ANewValue;
end;

procedure THCmdQueryNodeVariable.AssignModuleGlobal(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
begin
    ParentContext.AsObject.TreatAs<THCmdQueryContext>.ModuleGlobalVariables.Items[VariableIndex].Value := ANewValue;
end;

procedure THCmdQueryNodeVariable.AssignGlobal(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
begin
    AInterpreter.TreatAs<THCmdQueryInterpreterBase>.GlobalVariables.Items[VariableIndex].Value := ANewValue;
end;

procedure THCmdQueryNodeVariable.Assign(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
begin
    if VariableLocation = THCmdQueryScopeLocation.NotKnown then
        InitializeVariableLocation(AInterpreter);

    case VariableLocation of
        THCmdQueryScopeLocation.Local : _Assignable.Assign := AssignLocal;
        THCmdQueryScopeLocation.ModuleLocal: _Assignable.Assign := AssignModuleLocal;
        THCmdQueryScopeLocation.ModuleGlobal: _Assignable.Assign := AssignModuleGlobal;
        THCmdQueryScopeLocation.Global: _Assignable.Assign := AssignGlobal;
    else
        // Impossible state
        {#! [1] Maybe raise an exception? }
        Exit;
    end;

    _Assignable.Assign(AInterpreter, ASelf, ANewValue);
end;

procedure THCmdQueryNodeVariable.EvaluateGetLocal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    AResult^ := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary.LocalVariableStack.Items[VariableIndex].Value;
end;

procedure THCmdQueryNodeVariable.EvaluateGetModuleLocal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    AResult^ := ParentContext.AsObject.TreatAs<THCmdQueryContext>.ModuleLocalVariables.Items[VariableIndex].Value;
end;

procedure THCmdQueryNodeVariable.EvaluateGetModuleGlobal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    AResult^ := ParentContext.AsObject.TreatAs<THCmdQueryContext>.ModuleGlobalVariables.Items[VariableIndex].Value;
end;

procedure THCmdQueryNodeVariable.EvaluateGetGlobal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    AResult^ := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.GlobalVariables.Items[VariableIndex].Value;
end;

procedure THCmdQueryNodeVariable.Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    if VariableLocation = THCmdQueryScopeLocation.NotKnown then
        InitializeVariableLocation(AInterpreter);

    case VariableLocation of
        THCmdQueryScopeLocation.Local : _Evaluatable.Evaluate := EvaluateGetLocal;
        THCmdQueryScopeLocation.ModuleLocal: _Evaluatable.Evaluate := EvaluateGetModuleLocal;
        THCmdQueryScopeLocation.ModuleGlobal: _Evaluatable.Evaluate := EvaluateGetModuleGlobal;
        THCmdQueryScopeLocation.Global: _Evaluatable.Evaluate := EvaluateGetGlobal;
    else
        // It is not possible to be here
        {#! [1] }
        AResult^ := None;
        Exit;
    end;

    _Evaluatable.Evaluate(AInterpreter, ANode, AResult);
end;

{ THCmdQueryNodeBody }

procedure THCmdQueryNodeBody._CreateObject(const AObject: PSafeObject);
begin
    inherited;

    AObject.Interfaces.Evaluatable.Evaluate := Evaluate;
end;

procedure THCmdQueryNodeBody.Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
var i, PrevBase: Integer;
    CBF: PHCmdQueryCallBoundaryFrame;
begin
    Unused<Pointer>(ANode);

    CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CurrentCallBoundary;

    AResult^ := 0;

    PrevBase := CBF.SetLocalVariablesStackBase;
    try
        for i := 0 to Arguments.Count - 1 do begin
            if not (CBF.ControlFlowFlag = THCmdQueryControlFlowFlag.None) then
                Break;

            AResult^ := None;

            //CBF.ArgumentRequestIndex := i;
            AInterpreter.Interfaces.Interpreter.CallNode(@Arguments.Items[i], nil, 0, AResult);
            //Arguments.Items[i].AsObject.Interfaces.Evaluatable.Evaluate(AInterpreter, Arguments.Items[i].AsObject, AResult);
        end;
    finally
        CBF.RestoreLocalVariablesStackBase(PrevBase);
    end;
end;

{ THCmdQueryNodeCallFunction }

procedure THCmdQueryNodeCallFunction._CreateObject(const AObject: PSafeObject);
begin
    inherited;

    AObject.Interfaces.Evaluatable.Evaluate := Evaluate;
end;

procedure THCmdQueryNodeCallFunction.EvaluateCallLocal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    NodeToCall: PSafeVariant;
    Module: THCmdQueryContext;
begin
    Unused<Pointer>(ANode);

    Module := ParentContext.AsObject.TreatAs<THCmdQueryContext>;
    CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.AllocateCallBoundaryFrame;
    try
        NodeToCall := @Module.LocalFunctions.Items[FunctionIndex].Value;
        CBF.Position := @Position;

        // Node could be native function, therefore we must handle this particular case
        if NodeToCall.VarType = HCmdQueryVarType.SafeObject then
            CBF.Module := NodeToCall.AsObject.TreatAs<THCmdQueryNode>.ParentContext.AsObject
        else
            CBF.Module := ParentContext.AsObject;

        try
            //Result := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.CallNode(NodeToCall, GetArgumentsPointer, Arguments.Count, GetParametersPointer, Parameters.Count);
            AInterpreter.Interfaces.Interpreter.CallNodeFull(NodeToCall, GetArgumentsPointer, Arguments.Count, GetParametersPointer, Parameters.Count, AResult);

            if CBF.ChangeFunctionName then begin
                FunctionName := CBF.NewFunctionName;
                FunctionIndex := -1;

                _Evaluatable.Evaluate := Evaluate;
            end;
        except
            on E: EHCmdQueryRuntimeException do begin
                HCmdQueryProcessException(E, 'in local function `' + FunctionName + '`', Position);
                raise;
            end;
            on E: Exception do begin
                E := HCmdQueryProcessException(E, 'in local function `' + FunctionName + '`', Position);
                raise E;
            end;
        end;
    finally
        AInterpreter.TreatAs<THCmdQueryInterpreterBase>.DeallocateCallBoundaryFrame;
    end;
end;

procedure THCmdQueryNodeCallFunction.EvaluateCallModule(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    NodeToCall: PSafeVariant;
    Module: THCmdQueryContext;
begin
    Unused<Pointer>(ANode);

    //Interpreter := AInterpreter.TreatAs<THCmdQueryInterpreterBase>;
    Module := ParentContext.AsObject.TreatAs<THCmdQueryContext>;
    CBF := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.AllocateCallBoundaryFrame;
    try
        NodeToCall := @Module.ModuleFunctions.Items[FunctionIndex].Value;
        CBF.Position := @Position;

        if NodeToCall.VarType = HCmdQueryVarType.SafeObject then
            CBF.Module := NodeToCall.AsObject.TreatAs<THCmdQueryNode>.ParentContext.AsObject
        else
            CBF.Module := ParentContext.AsObject;

        try
            //Result := Interpreter.CallNode(NodeToCall, GetArgumentsPointer, Arguments.Count, GetParametersPointer, Parameters.Count);
            AInterpreter.Interfaces.Interpreter.CallNodeFull(NodeToCall, GetArgumentsPointer, Arguments.Count, GetParametersPointer, Parameters.Count, AResult);

            if CBF.ChangeFunctionName then begin
                FunctionName := CBF.NewFunctionName;
                FunctionIndex := -1;

                _Evaluatable.Evaluate := Evaluate;
            end;
        except
            on E: EHCmdQueryRuntimeException do begin
                HCmdQueryProcessException(E, 'in module function `' + FunctionName + '`', Position);
                raise;
            end;
            on E: Exception do begin
                E := HCmdQueryProcessException(E, 'in module function `' + FunctionName + '`', Position);
                raise E;
            end;
        end;
    finally
        AInterpreter.TreatAs<THCmdQueryInterpreterBase>.DeallocateCallBoundaryFrame;
    end;
end;

procedure THCmdQueryNodeCallFunction.EvaluateCallGlobal(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    NodeToCall: PSafeVariant;
    Interpreter: THCmdQueryInterpreterBase;
begin
    Unused<Pointer>(ANode);

    Interpreter := AInterpreter.TreatAs<THCmdQueryInterpreterBase>;
    CBF := Interpreter.AllocateCallBoundaryFrame;
    try
        NodeToCall := @Interpreter.GlobalFunctions.Items[FunctionIndex].Value;
        CBF.Position := @Position;

        if NodeToCall.VarType = HCmdQueryVarType.SafeObject then
            CBF.Module := NodeToCall.AsObject.TreatAs<THCmdQueryNode>.ParentContext.AsObject
        else
            CBF.Module := ParentContext.AsObject;

        try
            //Result := Interpreter.CallNode(NodeToCall, GetArgumentsPointer, Arguments.Count, GetParametersPointer, Parameters.Count);
            AInterpreter.Interfaces.Interpreter.CallNodeFull(NodeToCall, GetArgumentsPointer, Arguments.Count, GetParametersPointer, Parameters.Count, AResult);

            if CBF.ChangeFunctionName then begin
                FunctionName := CBF.NewFunctionName;
                FunctionIndex := -1;

                _Evaluatable.Evaluate := Evaluate;
            end;
        except
            on E: EHCmdQueryRuntimeException do begin
                HCmdQueryProcessException(E, 'in global function `' + FunctionName + '`', Position);
                raise;
            end;
            on E: Exception do begin
                E := HCmdQueryProcessException(E, 'in global function `' + FunctionName + '`', Position);
                raise E;
            end;
        end;
    finally
        Interpreter.DeallocateCallBoundaryFrame;
    end;
end;

procedure THCmdQueryNodeCallFunction.Evaluate(const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant); cdecl;
var Module: THCmdQueryContext;
    Index: Integer;
begin
    Module := ParentContext.AsObject.TreatAs<THCmdQueryContext>;
    Index := Module.FindLocalFunction(FunctionName);

    if Index >= 0 then begin
        FunctionLocation := THCmdQueryScopeLocation.Local;
        FunctionIndex := Index;

        _Evaluatable.Evaluate := EvaluateCallLocal;
        _Evaluatable.Evaluate(AInterpreter, ANode, AResult);

        Exit;
    end;

    Index := Module.FindModuleFunction(FunctionName);
    if Index >= 0 then begin
        FunctionLocation := THCmdQueryScopeLocation.ModuleGlobal;
        FunctionIndex := Index;

        _Evaluatable.Evaluate := EvaluateCallModule;
        _Evaluatable.Evaluate(AInterpreter, ANode, AResult);

        Exit;
    end;

    Index := AInterpreter.TreatAs<THCmdQueryInterpreterBase>.FindGlobalFunction(FunctionName);

    if Index >= 0 then begin
        FunctionLocation := THCmdQueryScopeLocation.Global;
        FunctionIndex := Index;

        _Evaluatable.Evaluate := EvaluateCallGlobal;
        _Evaluatable.Evaluate(AInterpreter, ANode, AResult);

        Exit;
    end;

    raise EHCmdQueryNoSuchFunctionException.Create('No function with name `%s` is defined', [ FunctionName ], Position);
end;

end.

