unit HCmdQuery.RTL.Functions;

{$I HCmdQuery.inc}

interface

uses
    SysUtils,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary;

procedure HCmdQuery_Functions_CreateLocalFunction(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_CreateModuleFunction(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_CreateGlobalFunction(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Functions_ArgsCount(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_ParamsCount(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Functions_Arg(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_Callback(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_ArgRaw(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_ArgRef(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_DefaultArg(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_NodeArg(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

function HCmdQuery_Functions_ExpectTypedArgument(const CBF: PHCmdQueryCallBoundaryFrame; const AResult: PSafeVariant; const AFunctionName: UnicodeString; const ATypes: THCmdQueryVarTypes; const ARaiseException: Boolean = True): Boolean;

procedure HCmdQuery_Functions_ArgInt(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_ArgNumber(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_ArgString(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Functions_DefaultArgInt(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_DefaultArgNumber(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Functions_DefaultArgString(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_Functions_EndExp(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

implementation

var _ReferenceInterfaceTable: TSafeObjectInterfaces;
    _ReferenceAssignable: IHCmdQueryAssignable;
    _ReferenceEvaluatable: IHCmdQueryEvaluatable;

type

    { THCmdQueryReference }

    THCmdQueryReference = class(THCmdQueryObject)
    public const
        TypeID = 1683915021849;
    public var
        SavedCBF: PHCmdQueryCallBoundaryFrame;
        AssignableObject: PSafeObject;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure Assign(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
    public
        destructor Destroy; override;
    end;

procedure HCmdQuery_Functions_CreateLocalFunction(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Name: UnicodeString;
    Index: Integer;
    Assignable: PSafeObject;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);

    Assignable := nil;
    if CBF.ExpectParameterBooleanDefault('rawname', False) then
        Name := CBF.ExpectString(0, 'function[0]: Expected raw string name of function')
    else if not CBF.TryExpectVariable(0, Name) and not CBF.TryExpectAssignable(0, Assignable) then
        raise EHCmdQueryArgumentException.Create('function[0]: Expected variable (name of function) or assignable', CBF.Position^);

    AResult^ := CBF.ExpectNode(1, 'function[1]: Expected body of function')^;

    if Assigned(Assignable) then begin
        AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundaryLevelDown;
        try
            Assignable.Interfaces.Assignable.Assign(AInterpreter, Assignable, AResult^);
        finally
            AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF);
        end;

        Exit;
    end;

    Index := CBF.FindLocalFunction(Name);
    if Index >= 0 then
        CBF.GetLocalFunctionPointer(Index).Value := AResult^
    else
        CBF.CreateLocalFunction(Name).Value := AResult^;

    // WriteLn('FUNCTION REFCOUNT = ', AResult^.AsObject.RefCount);
end;

procedure HCmdQuery_Functions_CreateModuleFunction(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Name: UnicodeString;
    Index: Integer;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(2);

    Name := CBF.ExpectVariable(0, 'method[0]: Expected variable (name of method)');
    AResult^ := CBF.ExpectNode(1, 'method[1]: Expected body of method')^;

    Index := CBF.FindModuleFunction(Name);
    if Index >= 0 then
        CBF.GetModuleFunctionPointer(Index).Value := AResult^
    else
        CBF.CreateModuleFunction(Name).Value := AResult^;
end;

procedure HCmdQuery_Functions_CreateGlobalFunction(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Name: UnicodeString;
    Index: Integer;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(3);

    Name := CBF.ExpectVariable(1, 'global-function[0]: Expected variable (name of function)');
    AResult^ := CBF.ExpectNode(2, 'global-function[1]: Expected body of function')^;

    Index := CBF.FindGlobalFunction(Name);
    if Index >= 0 then
        CBF.GetGlobalFunctionPointer(Index).Value := AResult^
    else
        CBF.CreateGlobalFunction(Name).Value := AResult^;
end;

procedure HCmdQuery_Functions_ArgsCount(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := CBF.Previous.ArgumentStackCount;
end;

procedure HCmdQuery_Functions_ParamsCount(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := CBF.Previous.ParameterStackCount;
end;

procedure HCmdQuery_Functions_Arg(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Index: Integer;
    Message: UnicodeString;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(1);
    Index := CBF.ExpectInteger(0, 'arg[0]: Expected integer index of argument');

    if CBF.Previous.TryExpectValue(Index, AResult^) then
        Exit;

    if not CBF.TryExpectParameterString('message', Message) then
        Message := UnicodeFormat('Argument #%d is required (there are %d arguments overall)', [ Index, CBF.Previous.ArgumentStackCount ]);

    raise EHCmdQueryArgumentException.Create(Message, CBF.Position^);
end;

procedure HCmdQuery_Functions_Callback(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF, Current, Prev: PHCmdQueryCallBoundaryFrame;
    Index, PrevCount: Integer;
    PrevArgs: PSafeVariant;
    NodeToCall: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    Index := CBF.ExpectInteger(0, 'callback[0]: Expected integer index of argument');
    NodeToCall := CBF.Previous.ExpectNode(Index, 'callback[]: Expected argument');

    PrevArgs := CBF.Previous.Previous.ArgumentStack;
    PrevCount := CBF.Previous.Previous.ArgumentStackCount;
    AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF.Previous.Previous);
    Prev := CBF.Previous.Previous.Previous;
    CBF.Previous.Previous.Previous := CBF.Previous;
    //AInterpreter.Interfaces.Interpreter.AllocateCallBoundaryFrame;
    try
        if CBF.ArgumentStackCount > 1 then
            CBF.Previous.Previous.ArgumentStack := CBF.ArgumentStack + 1
            //AInterpreter.Interfaces.Interpreter.CallNode(NodeToCall, CBF.ArgumentStack + 1, CBF.ArgumentStackCount - 1, AResult)
        else
            CBF.Previous.Previous.ArgumentStack := nil;
            //AInterpreter.Interfaces.Interpreter.CallNode(NodeToCall, nil, 0, AResult);
        CBF.Previous.Previous.ArgumentStackCount := CBF.ArgumentStackCount - 1;

        AInterpreter.Interfaces.Interpreter.CallNode(NodeToCall, nil, 0, AResult);
        CBF.Previous.Previous.ControlFlowFlag := THCmdQueryControlFlowFlag.None;
    finally
        CBF.Previous.Previous.ArgumentStack := PrevArgs;
        CBF.Previous.Previous.ArgumentStackCount := PrevCount;
        CBF.Previous.Previous.Previous := Prev;
        // AInterpreter.Interfaces.Interpreter.DeallocateCallBoundaryFrame;
        AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF);
    end;
end;

procedure HCmdQuery_Functions_ArgRaw(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Temp: PSafeVariant;
    Index: Integer;
    Message: UnicodeString;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    Index := CBF.ExpectInteger(0, 'arg::raw[0]: Expected integer index of argument');

    if CBF.Previous.TryExpectNode(Index, Temp) then begin
        AResult^ := Temp^;
        Exit;
    end;

    if not CBF.TryExpectParameterString('message', Message) then
        Message := UnicodeFormat('Argument #%d is required (there are %d arguments overall)', [ Index, CBF.Previous.ArgumentStackCount ]);

    raise EHCmdQueryArgumentException.Create(Message, CBF.Position^);
end;

procedure HCmdQuery_Functions_ArgRef(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Index: Integer;
    Assignable: PSafeObject;
    Reference: THCmdQueryReference;
    Message: UnicodeString;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    Index := CBF.ExpectInteger(0, 'arg::ref[0]: Expected integer index of argument');

    if CBF.Previous.TryExpectAssignable(Index, Assignable) then begin
        Assignable.AddRef;

        Reference := THCmdQueryReference.Create;
        Reference.SavedCBF := CBF.Previous.Previous;
        Reference.AssignableObject := Assignable;

        AResult^ := CBF.AllocateObject(Reference, Reference.TypeID);
        Exit;
    end;

    if not CBF.TryExpectParameterString('message', Message) then begin
        if CBF.Previous.ArgumentStackCount <= Index then
            Message := UnicodeFormat('Argument #%d is required (there are %d arguments overall)', [ Index, CBF.Previous.ArgumentStackCount ])
        else
            Message := UnicodeFormat('Argument #%d is required to be assignable', [ Index ]);
    end;

    raise EHCmdQueryArgumentException.Create(Message, CBF.Position^);
end;

procedure HCmdQuery_Functions_DefaultArg(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Index: Integer;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(2);
    Index := CBF.ExpectInteger(0, 'defaultarg[0]: Expected integer index of argument');

    if CBF.Previous.TryExpectValue(Index, AResult^) then
        Exit;

    AResult^ := CBF.ExpectValue(1, 'defaultarg[1]: Expected default value');
end;

procedure HCmdQuery_Functions_NodeArg(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Index: Integer;
    Message: UnicodeString;
    Node: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    CBF.EndExpectation(1);
    Index := CBF.ExpectInteger(0, 'node::arg[0]: Expected integer index of argument');

    if CBF.Previous.TryExpectNode(Index, Node) then begin
        // Return actual value of node/some other type
        AResult^ := Node^;
        Exit;
    end;

    if not CBF.TryExpectParameterString('message', Message) then
        Message := UnicodeFormat('Argument #%d is required (there are %d arguments overall)', [ Index, CBF.Previous.ArgumentStackCount ]);

    raise EHCmdQueryArgumentException.Create(Message, CBF.Position^);
end;

function HCmdQuery_Functions_ExpectTypedArgument(const CBF: PHCmdQueryCallBoundaryFrame; const AResult: PSafeVariant; const AFunctionName: UnicodeString; const ATypes: THCmdQueryVarTypes; const ARaiseException: Boolean): Boolean;
var Index: Int64;
    Message: UnicodeString;
begin
    //CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    //
    //CBF.EndExpectation(1);
    //Index := CBF.ExpectInteger(0, 'int::arg[0]: Expected integer index of argument');

    Result := False;

    if not CBF.TryExpectInteger(0, Index) then begin
        if ARaiseException then
            raise EHCmdQueryArgumentException.Create(AFunctionName + '[0]: Expected integer index of argument', CBF.Position^)
        else
            // Silently return false
            Exit;
    end;

    if Index >= CBF.Previous.ArgumentStackCount then begin
        if not ARaiseException then
            Exit;

        if not CBF.TryExpectParameterString('message', Message) then
            Message := UnicodeFormat('Argument #%d (%s) is required (there are %d arguments overall)', [ Index, HCmdQuery_VarSetToString(ATypes), CBF.Previous.ArgumentStackCount ]);

        raise EHCmdQueryArgumentException.Create(Message, CBF.Position^);
    end;

    Result := CBF.Previous.TryExpectValue(Index, AResult^) and (AResult.VarType in ATypes);
    if Result then
        Exit;

    if not CBF.TryExpectParameterString('message', Message) then
        Message := UnicodeFormat('Argument #%d is required to be %s, but given type is %s', [ Index, HCmdQuery_VarSetToString(ATypes), AResult.GetTypeString ]);

    AResult^ := None;

    raise EHCmdQueryArgumentException.Create(Message, CBF.Position^);
end;

procedure HCmdQuery_Functions_ArgInt(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    HCmdQuery_Functions_ExpectTypedArgument(CBF, AResult, 'arg::int', [ HCmdQueryVarType.Int64 ]);
end;

procedure HCmdQuery_Functions_ArgNumber(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    HCmdQuery_Functions_ExpectTypedArgument(CBF, AResult, 'arg::real', [ HCmdQueryVarType.Int64, HCmdQueryVarType.Double ]);
    if AResult.IsInteger then
        AResult^ := Double(AResult.AsInteger);
end;

procedure HCmdQuery_Functions_ArgString(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    HCmdQuery_Functions_ExpectTypedArgument(CBF, AResult, 'arg::string', [ HCmdQueryVarType.SafeString ]);
end;

procedure HCmdQuery_Functions_DefaultArgInt(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    if not HCmdQuery_Functions_ExpectTypedArgument(CBF, AResult, 'defaultarg::int', [ HCmdQueryVarType.Int64 ], False) then
        AResult^ := CBF.ExpectInteger(1, 'defaultarg::int[1]: Expected default integer value');
end;

procedure HCmdQuery_Functions_DefaultArgNumber(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    if not HCmdQuery_Functions_ExpectTypedArgument(CBF, AResult, 'defaultarg::real', [ HCmdQueryVarType.Int64, HCmdQueryVarType.Double ], False) then begin
        AResult^ := CBF.ExpectNumber(1, 'defaultarg::real[1]: Expected default number value');
        Exit;
    end;

    if AResult.IsInteger then
        AResult^ := Double(AResult^.AsInteger);
end;

procedure HCmdQuery_Functions_DefaultArgString(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    if not HCmdQuery_Functions_ExpectTypedArgument(CBF, AResult, 'defaultarg::string', [ HCmdQueryVarType.SafeString ], False) then
        AResult^ := CBF.AllocateString(CBF.ExpectString(1, 'defaultarg::string[1]: Expected default string value'));
end;

procedure HCmdQuery_Functions_EndExp(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Index: Integer;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    Index := CBF.ExpectInteger(0, 'endexp[0]: Expected integer index');

    CBF.Previous.EndExpectation(Index);
    AResult^ := True;
end;

{ THCmdQueryReference }

procedure THCmdQueryReference._CreateObject(const AObject: PSafeObject);
begin
    inherited _CreateObject(AObject);
    _ReferenceInterfaceTable.AddRef;
    AObject.Interfaces := @_ReferenceInterfaceTable;
end;

procedure THCmdQueryReference.Assign(const AInterpreter: PSafeObject; const ASelf: PSafeObject; const ANewValue: SafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    Self := TObject(ASelf.Value) as THCmdQueryReference;

    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary();
    AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(SavedCBF);
    try
        AssignableObject.Interfaces.Assignable.Assign(AInterpreter, AssignableObject, ANewValue);
    finally
        AInterpreter.Interfaces.Interpreter.SetCurrentCallBoundary(CBF);
    end;
end;

destructor THCmdQueryReference.Destroy;
begin
    if Assigned(AssignableObject) then begin
        AssignableObject.ReleaseRef;
        AssignableObject := nil;
    end;

    inherited Destroy;
end;

initialization begin
    _ReferenceAssignable.Assign := THCmdQueryReference(nil).Assign;

    _ReferenceInterfaceTable.Assignable := @_ReferenceAssignable;
    _ReferenceInterfaceTable.RefCount := 1;
end;

end.

