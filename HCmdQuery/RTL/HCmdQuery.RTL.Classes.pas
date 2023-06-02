unit HCmdQuery.RTL.Classes;

{$I HCmdQuery.inc}

{#! Should be ensured to be an object first! }

interface

uses
    HCL.Core.Unused,
    HCL.Core.GenericList,
    HCL.Core.HashTable,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary,
    HCmdQuery.RTL.NativeObjects;

type
    THCmdQueryClassVirtualTable = class;
    THCmdQueryClassInstance = class;

    THCmdQueryClassVisibility = (
        Public,
        Protected,
        Private
    );

    THCmdQueryClassMethodMode = (
        // Can be called without construction of object
        Static,
        // Called from current vmtable and upper (current ---> root)
        Normal,
        // Called from top vmtable and upper (top ---> current ---> root)
        Dynamic,
        // Raises abstract exception upon being called
        Abstract
    );

    THCmdQueryClassMethod = packed record
    public var
        VMTable: THCmdQueryClassVirtualTable;
        MethodMode: THCmdQueryClassMethodMode;
        Visibility: THCmdQueryClassVisibility;
        MethodNode: SafeVariant;
    end;
    PHCmdQueryClassMethod = ^THCmdQueryClassMethod;
    THCmdQueryClassMethods = THCLHashTable<SafeVariant, THCmdQueryClassMethod>;

    THCmdQueryClassPropertyAccessMode = (
        None,
        Field,
        Getter,
        Inline
    );

    THCmdQueryClassPropertyAccessor = packed record
    public var
        Mode: THCmdQueryClassPropertyAccessMode;
        //#! Visibility of property accessor?
        //Visibility: THCmdQueryClassVisibility;
        // Depends on mode:
        // * None - should be None
        // * Field - should be String with name of field to get from
        // * Getter - should be String with method name to call
        // * Inline - should be raw node to call
        Accessor: SafeVariant;
    end;
    PHCmdQueryClassPropertyAccessor = ^THCmdQueryClassPropertyAccessor;

    THCmdQueryClassProperty = packed record
    public var
        VMTable: THCmdQueryClassVirtualTable;
        Visibility: THCmdQueryClassVisibility;
        Reader: THCmdQueryClassPropertyAccessor;
        Writer: THCmdQueryClassPropertyAccessor;
    end;
    PHCmdQueryClassProperty = ^THCmdQueryClassProperty;
    THCmdQueryClassProperties = THCLHashTable<SafeVariant, THCmdQueryClassProperty>;

    { THCmdQueryClassVirtualTable }

    THCmdQueryClassVirtualTable = class(THCmdQueryObject)
    public const
        TypeID = 1683915166632;
    protected var
        FParentVMTable: THCmdQueryClassVirtualTable;
        FParentVMTableIntf: SafeVariant;
        FVMTableClassName: UnicodeString;
        FSelfObject: PSafeObject;
    public var
        Methods: THCmdQueryClassMethods;
        Properties: THCmdQueryClassProperties;
    protected
        procedure _CreateObject(const AObject: PSafeObject); override;
    public
        procedure InheritFrom(const AFrom: THCmdQueryClassVirtualTable);
    public
        property ParentVMTable: THCmdQueryClassVirtualTable read FParentVMTable;
        property ParentVMTableIntf: SafeVariant read FParentVMTableIntf;
        property VMTableClassName: UnicodeString read FVMTableClassName write FVMTableClassName;
        property SelfObject: PSafeObject read FSelfObject;
    public
        constructor Create;
        destructor Destroy; override;
    end;

    { THCmdQueryClass }

    THCmdQueryClass = class(THCmdQueryObject)
    public const
        TypeID = 1683915224585;
    protected var
        FVMTable: THCmdQueryClassVirtualTable;
        FVMTableIntf: SafeVariant;
        FParentClass: THCmdQueryClass;
        FParentClassIntf: SafeVariant;
        FSelfObject: PSafeObject;
    protected
        _ClassInterfaceTable: TSafeObjectInterfaces;
        _ClassIndexable: IHCmdQueryIndexable;
        _ClassMethodSupportable: IHCmdQueryMethodSupportable;
        _ClassSimpleStringable: IHCmdQuerySimpleStringable;

        _ObjectInterfaceTable: TSafeObjectInterfaces;
        _ObjectIndexable: IHCmdQueryIndexable;
        _ObjectMethodSupportable: IHCmdQueryMethodSupportable;
        _ObjectSimpleStringable: IHCmdQuerySimpleStringable;
    public var
        StaticFields: THCLHashTable<SafeVariant, SafeVariant>;
    protected
        procedure _CreateObject(const AObject: PSafeObject); override;
        procedure _DisposeObject(const AObject: PSafeObject); override;
    protected
        function _ToStringSimpleClass(const AObject: PSafeObject): UnicodeString; cdecl;
        function _ToStringSimpleObject(const AObject: PSafeObject): UnicodeString; cdecl;
    public
        property VMTable: THCmdQueryClassVirtualTable read FVMTable;
        property VMTableIntf: SafeVariant read FVMTableIntf;
        property ParentClass: THCmdQueryClass read FParentClass;
        property ParentClassIntf: SafeVariant read FParentClassIntf;
        property SelfObject: PSafeObject read FSelfObject;
    public
        procedure CreateInstance(const ACBF: PHCmdQueryCallBoundaryFrame; const AResult: PSafeVariant);
    public
        procedure GetValueFromIndex(const ACBF: PHCmdQueryCallBoundaryFrame; const AIndex: PSafeVariant; const AResult: PSafeVariant);
        procedure SetValueToIndex(const ACBF: PHCmdQueryCallBoundaryFrame; const AIndex: PSafeVariant; const AValue: PSafeVariant; const AResult: PSafeVariant);
        procedure CallArbitraryMethod(const ACBF: PHCmdQueryCallBoundaryFrame; const AMethodName: PSafeVariant; const AResult: PSafeVariant);
    public
        constructor Create;
        destructor Destroy; override;
    end;

    { THCmdQueryClassInstance }

    THCmdQueryClassInstance = class(THCmdQueryObject)
    public const
        TypeID = 1683915273659;
    protected var
        FPrototypeClass: THCmdQueryClass;
        FPrototypeClassIntf: SafeVariant;
        FSelfObject: PSafeObject;
    public var
        Fields: THCLHashTable<SafeVariant, SafeVariant>;
    public
        property PrototypeClass: THCmdQueryClass read FPrototypeClass;
        property PrototypeClassIntf: SafeVariant read FPrototypeClassIntf;
        property SelfObject: PSafeObject read FSelfObject;
    protected
        procedure _CreateObject(const AObject: PSafeObject); override;
        procedure _DisposeObject(const AObject: PSafeObject); override;
    public
        procedure GetValueFromIndex(const ACBF: PHCmdQueryCallBoundaryFrame; const AIndex: PSafeVariant; const AResult: PSafeVariant);
        procedure SetValueToIndex(const ACBF: PHCmdQueryCallBoundaryFrame; const AIndex: PSafeVariant; const AValue: PSafeVariant; const AResult: PSafeVariant);
    public
        procedure CallArbitraryNode(const ACBF: PHCmdQueryCallBoundaryFrame; const AMethodNode: PSafeVariant; const ACurrentVMT, ATopVMT: PSafeObject; const AResult: PSafeVariant);
        procedure CallArbitraryMethod(const ACBF: PHCmdQueryCallBoundaryFrame; const AMethodName: PSafeVariant; const AVisibility: THCmdQueryClassVisibility; ACurrentVMT, ATopVMT: THCmdQueryClassVirtualTable; const AResult: PSafeVariant; const ACallInherited: Boolean = False); overload;
        procedure CallArbitraryMethod(const ACBF: PHCmdQueryCallBoundaryFrame; const AMethodName: PSafeVariant; const AResult: PSafeVariant); overload;
    public
        constructor Create;
        destructor Destroy; override;
    end;

function HCmdQuery_Classes_ClassVisibilityToString(const AVisibility: THCmdQueryClassVisibility): UnicodeString;

procedure HCmdQuery_Classes_Class(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Classes_Public(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Classes_Protected(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Classes_Private(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_Classes_Inherited(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

implementation

procedure GetVMTablePointersRaw(const ACBF: PHCmdQueryCallBoundaryFrame; const ASelfObj: PSafeVariant; out ACurrentVMTable, ATopVMTable: THCmdQueryClassVirtualTable);
var PrevObj, PrevCurrentVM, PrevTopVM: PHCmdQueryVariable;
    PrevCallBoundary: PHCmdQueryCallBoundaryFrame;
begin
    ACurrentVMTable := nil;
    ATopVMTable := nil;

    PrevCallBoundary := ACBF.Previous;
    if not Assigned(PrevCallBoundary) or (PrevCallBoundary.LocalVariableStack.Count < 3) then
        Exit;

    PrevObj := @PrevCallBoundary.LocalVariableStack.Items[0];
    PrevCurrentVM := @PrevCallBoundary.LocalVariableStack.Items[1];
    PrevTopVM := @PrevCallBoundary.LocalVariableStack.Items[2];

    if not (PrevObj.Name = 'self') or
        not (PrevCurrentVM.Name = '_currentVMT') or
        not (PrevTopVM.Name = '_topVMT') or
        not PrevObj.Value.IsObject or
        not PrevCurrentVM.Value.IsObject or
        not PrevTopVM.Value.IsObject or
        not (ASelfObj.AsInteger = PrevObj.Value.AsInteger) or
        not (TObject(PrevCurrentVM.Value.AsObject.Value) is THCmdQueryClassVirtualTable) or
        not (TObject(PrevTopVM.Value.AsObject.Value) is THCmdQueryClassVirtualTable) then
    begin
        Exit;
    end;

    ACurrentVMTable := PrevCurrentVM.Value.AsObject.Value;
    ATopVMTable := PrevTopVM.Value.AsObject.Value;
end;

procedure GetVMTablePointers(const ACBF: PHCmdQueryCallBoundaryFrame; out ACurrentVMTable, ATopVMTable: THCmdQueryClassVirtualTable);
var SelfObj: PHCmdQueryVariable;
begin
    if ACBF.LocalVariableStack.Count <= 0 then
        Exit;
    SelfObj := @ACBF.LocalVariableStack.Items[0];
    if not (SelfObj.Name = 'self') or not SelfObj.Value.IsObject then
        Exit;

    GetVMTablePointersRaw(ACBF, @SelfObj.Value, ACurrentVMTable, ATopVMTable);
end;

procedure HCmdQuery_Class_GetValueFromIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryClass;
    Index: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryClass;
    Index := CBF.ExpectNode(1);

    CBF.ArgumentStackCount := CBF.ArgumentStackCount - 2;
    CBF.ArgumentStack := CBF.ArgumentStack + 2;

    SelfObj.GetValueFromIndex(CBF, Index, AResult);
end;

procedure HCmdQuery_Class_SetValueToIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryClass;
    Index, NewValue: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryClass;
    Index := CBF.ExpectNode(1);
    NewValue := CBF.ExpectNode(2);

    CBF.ArgumentStackCount := CBF.ArgumentStackCount - 2;
    CBF.ArgumentStack := CBF.ArgumentStack + 2;

    SelfObj.SetValueToIndex(CBF, Index, NewValue, AResult);
end;

procedure HCmdQuery_Class_CallMethod(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryClass;
    MethodName: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryClass;
    MethodName := CBF.ExpectNode(1);

    CBF.ArgumentStackCount := CBF.ArgumentStackCount - 2;
    CBF.ArgumentStack := CBF.ArgumentStack + 2;

    SelfObj.CallArbitraryMethod(CBF, MethodName, AResult);
end;

procedure HCmdQuery_Object_GetValueFromIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryClassInstance;
    Index: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryClassInstance;
    Index := CBF.ExpectNode(1);

    CBF.ArgumentStackCount := CBF.ArgumentStackCount - 2;
    CBF.ArgumentStack := CBF.ArgumentStack + 2;

    SelfObj.GetValueFromIndex(CBF, Index, AResult);
end;

procedure HCmdQuery_Object_SetValueToIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryClassInstance;
    Index, NewValue: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryClassInstance;
    Index := CBF.ExpectNode(1);
    NewValue := CBF.ExpectNode(2);

    CBF.ArgumentStackCount := CBF.ArgumentStackCount - 2;
    CBF.ArgumentStack := CBF.ArgumentStack + 2;

    SelfObj.SetValueToIndex(CBF, Index, NewValue, AResult);
end;

procedure HCmdQuery_Object_CallMethod(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryClassInstance;
    MethodName: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryClassInstance;
    MethodName := CBF.ExpectNode(1);

    CBF.ArgumentStackCount := CBF.ArgumentStackCount - 2;
    CBF.ArgumentStack := CBF.ArgumentStack + 2;

    SelfObj.CallArbitraryMethod(CBF, MethodName, AResult);
end;

function HCmdQuery_Classes_ClassVisibilityToString(const AVisibility: THCmdQueryClassVisibility): UnicodeString;
begin
    case AVisibility of
        THCmdQueryClassVisibility.Public   : Result := 'public';
        THCmdQueryClassVisibility.Protected: Result := 'protected';
        THCmdQueryClassVisibility.Private  : Result := 'private';
    end;
end;

procedure HCmdQuery_Classes_Class(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Pos: Integer;
    ClassName: UnicodeString;
    ClassObj, InheritsObj: THCmdQueryClass;
    Inherits: SafeVariant;
    VMT: THCmdQueryClassVirtualTable;
    Local: Boolean;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    Pos := 0;
    if CBF.TryExpectKeyword(0, 'local') then begin
        Local := True;
        Pos := Pos + 1;
    end;

    ClassName := CBF.ExpectVariable(Pos, 'class[]: Expected name of class (variable)');
    Pos := Pos + 1;

    InheritsObj := nil;
    Inherits := None;
    if CBF.TryExpectKeyword(Pos, 'inherits') then begin
        Pos := Pos + 1;
        Inherits := CBF.ExpectValue(Pos, 'class[]: Expected class to inherit from');

        if not Inherits.IsObject then
            raise EHCmdQueryNotAnObject.Create('class[%d]: Object type required', [ Pos ], CBF.Position^);
        if not (TObject(Inherits.AsObject.Value) is THCmdQueryClass) then
            raise EHCmdQueryArgumentException.Create('class[%d]: Can only inherit from classes', [ Pos ], CBF.Position^);

        InheritsObj := TObject(Inherits.AsObject.Value) as THCmdQueryClass;

        Pos := Pos + 1;
    end;

    VMT := THCmdQueryClassVirtualTable.Create;
    VMT.FVMTableClassName := ClassName;

    if Assigned(InheritsObj) then
        VMT.InheritFrom(InheritsObj.VMTable);

    ClassObj := THCmdQueryClass.Create;

    ClassObj.FVMTable := VMT;
    ClassObj.FVMTableIntf := CBF.AllocateObject(VMT, VMT.TypeID);

    ClassObj.FParentClass := InheritsObj;
    ClassObj.FParentClassIntf := Inherits;

    AResult^ := CBF.AllocateObject(ClassObj, ClassObj.TypeID);

    if Local then
        CBF.CreateModuleLocalVariable(ClassName).Value := AResult^
    else
        CBF.CreateModuleGlobalVariable(ClassName).Value := AResult^;

    CBF.ExpectValue(Pos, 'class[]: Expected class definition');
    CBF.EndExpectation(Pos + 1);
end;

procedure HCmdQuery_Classes_ProcessProperty(const ACBF: PHCmdQueryCallBoundaryFrame; const AVisibility: THCmdQueryClassVisibility; const AClass: THCmdQueryClass; const AName: SafeVariant; const AResult: PSafeVariant);
var Prop: THCmdQueryClassProperty;
    i, Pos: Integer;
    Accessor: PHCmdQueryClassPropertyAccessor;
begin
    Prop.Visibility := AVisibility;
    Prop.VMTable := AClass.VMTable;
    Prop.Reader.Mode := THCmdQueryClassPropertyAccessMode.None;
    Prop.Reader.Accessor := None;
    Prop.Writer.Mode := THCmdQueryClassPropertyAccessMode.None;
    Prop.Writer.Accessor := None;

    Pos := 2;
    for i := 0 to 1 do begin
        Accessor := nil;
        case ACBF.TryExpectKeywords(Pos, [ 'read', 'write' ]) of
            -1: Break;
            0:
                begin
                    // Reader
                    if not (Prop.Reader.Mode = THCmdQueryClassPropertyAccessMode.None) then
                        raise EHCmdQueryArgumentException.Create('%s[%d]: Duplicate property read accessor', [ HCmdQuery_Classes_ClassVisibilityToString(AVisibility), Pos ], ACBF.Position^);
                    Accessor := @Prop.Reader;
                end;
            1:
                begin
                    // Writer
                    if not (Prop.Writer.Mode = THCmdQueryClassPropertyAccessMode.None) then
                        raise EHCmdQueryArgumentException.Create('%s[%d]: Duplicate property write accessor', [ HCmdQuery_Classes_ClassVisibilityToString(AVisibility), Pos ], ACBF.Position^);
                    Accessor := @Prop.Writer;
                end;
        end;

        Pos := Pos + 1;
        case ACBF.ExpectKeywords(Pos, [ 'field', 'method', 'inline' ], 'property[]: Expected field/method/inline attributes after read/write accessor') of
            0:
                begin
                    // Field
                    Accessor.Mode := THCmdQueryClassPropertyAccessMode.Field;
                    Pos := Pos + 1;
                    Accessor.Accessor := ACBF.ExpectValue(Pos, 'property[]: Expected property accessor field name');
                end;
            1:
                begin
                    // Method
                    Accessor.Mode := THCmdQueryClassPropertyAccessMode.Getter;
                    Pos := Pos + 1;
                    Accessor.Accessor := ACBF.ExpectValue(Pos, 'property[]: Expected property accessor method name');
                end;
            2:
                begin
                    // Inline
                    Accessor.Mode := THCmdQueryClassPropertyAccessMode.Inline;
                    Pos := Pos + 1;
                    Accessor.Accessor := ACBF.ExpectNode(Pos, 'property[]: Expected property accessor inline node')^;
                end;
        end;

        Pos := Pos + 1;
    end;

    ACBF.EndExpectation(Pos);
    if (Prop.Reader.Mode = THCmdQueryClassPropertyAccessMode.None) and (Prop.Writer.Mode = THCmdQueryClassPropertyAccessMode.None) then
        raise EHCmdQueryArgumentException.Create('property[]: Neither read nor write accessor was provided for property');

    AClass.VMTable.Properties.AddOrSetElement(AName, Prop);

    AResult^ := True;
end;

procedure HCmdQuery_Classes_ProcessMethod(const ACBF: PHCmdQueryCallBoundaryFrame; const AVisibility: THCmdQueryClassVisibility; const AClass: THCmdQueryClass; const AName: SafeVariant; const AResult: PSafeVariant);
var Method: THCmdQueryClassMethod;
    Pos: Integer;
begin
    Method.MethodMode := THCmdQueryClassMethodMode.Normal;
    Method.Visibility := AVisibility;
    Method.VMTable := AClass.VMTable;

    Pos := 2;
    case ACBF.TryExpectKeywords(Pos, [ 'static', 'virtual', 'override', 'abstract' ]) of
        0:
            begin
                Method.MethodMode := THCmdQueryClassMethodMode.Static;
                Pos := Pos + 1;
            end;
        1, 2:
            begin
                Method.MethodMode := THCmdQueryClassMethodMode.Dynamic;
                Pos := Pos + 1;
            end;
        3:
            begin
                Method.MethodMode := THCmdQueryClassMethodMode.Abstract;
                Pos := Pos + 1;
            end;
    end;

    Method.MethodNode := None;
    if not (Method.MethodMode = THCmdQueryClassMethodMode.Abstract) then begin
        Method.MethodNode := ACBF.ExpectNode(Pos, 'method[]: Expected method node')^;
        Pos := Pos + 1;
    end;

    ACBF.EndExpectation(Pos);

    AClass.VMTable.Methods.AddOrSetElement(AName, Method);

    AResult^ := True;
end;

procedure HCmdQuery_Classes_ProcessOverall(const AInterpreter: PSafeObject; const AVisibility: THCmdQueryClassVisibility; const AResult: PSafeVariant);
var CBF: PHCmdQueryCallBoundaryFrame;
    ClassObj: THCmdQueryClass;
    FieldName, FirstOpRes: SafeVariant;
    Indexing, FirstOp, SecondOp: PSafeVariant;
    KeywordIndex: Integer;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    KeywordIndex := CBF.ExpectKeywords(0, [ 'property', 'method' ], HCmdQuery_Classes_ClassVisibilityToString(AVisibility) + '[0]: Expected method or field to declare');

    Indexing := CBF.ExpectNode(1, HCmdQuery_Classes_ClassVisibilityToString(AVisibility) + '[1]: Expected indexing argument');
    if not Indexing.IsObject or not Assigned(Indexing.AsObject.Interfaces) or (Indexing.AsObject.Interfaces.Evaluatable = nil) or not (Indexing.AsObject.Interfaces.Evaluatable.GetOpCode(AInterpreter, Indexing.AsObject) = Ord(THCmdQueryNodeType.Indexing)) then
        raise EHCmdQueryArgumentException.Create(HCmdQuery_Classes_ClassVisibilityToString(AVisibility) + '[1]: Expected indexing node');

    FirstOp := nil;
    Indexing.AsObject.Interfaces.Evaluatable.GetArgument(AInterpreter, Indexing.AsObject, 0, FirstOp);
    Indexing.AsObject.Interfaces.Evaluatable.GetArgument(AInterpreter, Indexing.AsObject, 1, SecondOp);

    FirstOpRes := CBF.CallNodeWithPreviousFrame(FirstOp);
    if not FirstOpRes.IsObject or not (TObject(FirstOpRes.AsObject.Value) is THCmdQueryClass) then
        raise EHCmdQueryArgumentException.Create(HCmdQuery_Classes_ClassVisibilityToString(AVisibility) + '[1]: Expected class type to be on the left side of indexing');

    ClassObj := TObject(FirstOpRes.AsObject.Value) as THCmdQueryClass;

    FieldName := CBF.CallNodeWithPreviousFrame(SecondOp);

    case KeywordIndex of
        0:
            begin
                // Property
                HCmdQuery_Classes_ProcessProperty(CBF, AVisibility, ClassObj, FieldName, AResult);
            end;
        1:
            begin
                // Method
                HCmdQuery_Classes_ProcessMethod(CBF, AVisibility, ClassObj, FieldName, AResult);
            end;
    end;
end;

procedure HCmdQuery_Classes_Public(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Classes_ProcessOverall(AInterpreter, THCmdQueryClassVisibility.Public, AResult);
end;

procedure HCmdQuery_Classes_Protected(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Classes_ProcessOverall(AInterpreter, THCmdQueryClassVisibility.Protected, AResult);
end;

procedure HCmdQuery_Classes_Private(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    HCmdQuery_Classes_ProcessOverall(AInterpreter, THCmdQueryClassVisibility.Private, AResult);
end;

procedure HCmdQuery_Classes_Inherited(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfVar: PHCmdQueryVariable;
    SelfObj: THCmdQueryClassInstance;
    MethodName: SafeVariant;
    CurrentVMT, TopVMT: THCmdQueryClassVirtualTable;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    MethodName := CBF.ExpectValue(0, 'inherited[0]: Expected inherited method name to call');

    if CBF.Previous.LocalVariableStack.Count <= 0 then
        raise EHCmdQueryArgumentException.Create('inherited[]: Function requires context, that contains `self` variable', CBF.Position^);

    SelfVar := @CBF.Previous.LocalVariableStack.Items[0];
    if not (SelfVar.Name = 'self') then
        raise EHCmdQueryArgumentException.Create('inherited[]: Function requires context, that contains `self` variable', CBF.Position^);

    if not SelfVar.Value.IsObject or not SelfVar.Value.AsObject.IsOfType(THCmdQueryClassInstance.TypeID) then
        raise EHCmdQueryArgumentException.Create('inherited[]: Function requires `self` variable to be a class instance', CBF.Position^);

    GetVMTablePointersRaw(CBF, @SelfVar.Value, CurrentVMT, TopVMT);
    if (CurrentVMT = nil) or (TopVMT = nil) then
        raise EHCmdQueryArgumentException.Create('inherited[]: Function require method-call context', CBF.Position^);

    SelfObj := TObject(SelfVar.Value.AsObject.Value) as THCmdQueryClassInstance;

    if (CurrentVMT.ParentVMTable = nil) then
        raise EHCmdQueryArgumentException.Create('inherited[]: There is no parent methods to call for', CBF.Position^);

    CBF.ArgumentStack := CBF.ArgumentStack + 1;
    CBF.ArgumentStackCount := CBF.ArgumentStackCount - 1;

    SelfObj.CallArbitraryMethod(CBF, @MethodName, THCmdQueryClassVisibility.Private, CurrentVMT, TopVMT, AResult, True);
    if AResult.VarType = HCmdQueryVarType.SkipObject then
        raise EHCmdQueryArgumentException.Create('inherited[]: There is no inherited %s method to call', [ MethodName.GetSimpleString ], CBF.Position^);
end;

{ THCmdQueryClassVirtualTable }

procedure THCmdQueryClassVirtualTable._CreateObject(const AObject: PSafeObject);
begin
    inherited _CreateObject(AObject);

    FSelfObject := AObject;
end;

procedure THCmdQueryClassVirtualTable.InheritFrom(const AFrom: THCmdQueryClassVirtualTable);
var MethodsIterator: THCLHashTable<SafeVariant, THCmdQueryClassMethod>.TKeyValuePair;
    PropertiesIterator: THCLHashTable<SafeVariant, THCmdQueryClassProperty>.TKeyValuePair;
begin
    for MethodsIterator in AFrom.Methods do begin
        Methods.AddOrSetElement(MethodsIterator.Key, MethodsIterator.Value);
    end;

    for PropertiesIterator in AFrom.Properties do begin
        Properties.AddOrSetElement(PropertiesIterator.Key, PropertiesIterator.Value);
    end;

    FParentVMTable := AFrom;

    FParentVMTableIntf.VarType := HCmdQueryVarType.SafeObject;
    FParentVMTableIntf.AsObject := AFrom.SelfObject;
    AFrom.SelfObject.AddRef;
end;

constructor THCmdQueryClassVirtualTable.Create;
begin
    inherited;

    Methods.Nullify(THCmdQueryDictionary.CompareSafeVariants, THCmdQueryDictionary.HashSafeVariant);
    Properties.Nullify(THCmdQueryDictionary.CompareSafeVariants, THCmdQueryDictionary.HashSafeVariant);
end;

destructor THCmdQueryClassVirtualTable.Destroy;
begin
    Properties.Destroy;
    Methods.Destroy;

    inherited Destroy;
end;

{ THCmdQueryClass }

procedure THCmdQueryClass._CreateObject(const AObject: PSafeObject);
begin
    inherited _CreateObject(AObject);

    FSelfObject := AObject;

    // Attach interfaces
    AObject.AttachInterfaces(@_ClassInterfaceTable);
end;

procedure THCmdQueryClass._DisposeObject(const AObject: PSafeObject);
begin
    //WriteLn('Disposing class');

    inherited _DisposeObject(AObject);
end;

function THCmdQueryClass._ToStringSimpleClass(const AObject: PSafeObject): UnicodeString; cdecl;
begin
    Result := 'Class ' + (TObject(AObject.Value) as THCmdQueryClass).VMTable.VMTableClassName;
end;

function THCmdQueryClass._ToStringSimpleObject(const AObject: PSafeObject): UnicodeString; cdecl;
begin
    Result := 'Object ' + (TObject(AObject.Value) as THCmdQueryClassInstance).PrototypeClass.VMTable.VMTableClassName;
end;

procedure THCmdQueryClass.CreateInstance(const ACBF: PHCmdQueryCallBoundaryFrame; const AResult: PSafeVariant);
var Obj: THCmdQueryClassInstance;
    ConstructorName, ConstructorResult: SafeVariant;
    FieldValue: THCLHashTable<SafeVariant, SafeVariant>.TKeyValuePair;
begin
    Obj := THCmdQueryClassInstance.Create;

    AResult^ := ACBF.AllocateObject(Obj, Obj.TypeID);
    AResult.AsObject.AttachInterfaces(@_ObjectInterfaceTable);

    Obj.FPrototypeClass := Self;

    Obj.FPrototypeClassIntf.VarType := HCmdQueryVarType.SafeObject;
    Obj.FPrototypeClassIntf.AsObject := SelfObject;
    SelfObject.AddRef;

    for FieldValue in StaticFields do
        Obj.Fields.AddOrSetElement(FieldValue.Key, FieldValue.Value);

    // Replace self pointer to newly created object to call constructor
    ACBF.LocalVariableStack.Items[0].Value := AResult^;

    ConstructorName := ACBF.AllocateString('Create');

    ConstructorResult := None;
    Obj.CallArbitraryMethod(ACBF, @ConstructorName, THCmdQueryClassVisibility.Private, Self.VMTable, Self.VMTable, @ConstructorResult);

    //#! Maybe return null, if constructor returns SkipObject?
end;

procedure THCmdQueryClass.GetValueFromIndex(const ACBF: PHCmdQueryCallBoundaryFrame; const AIndex: PSafeVariant; const AResult: PSafeVariant);
var Value: PSafeVariant;
begin
    AResult.VarType := HCmdQueryVarType.SkipObject;

    Value := StaticFields.ValuePtr[AIndex^];
    if Assigned(Value) then
        AResult^ := Value^;
end;

procedure THCmdQueryClass.SetValueToIndex(const ACBF: PHCmdQueryCallBoundaryFrame; const AIndex: PSafeVariant; const AValue: PSafeVariant; const AResult: PSafeVariant);
begin
    AResult^ := 0;

    StaticFields.AddOrSetElement(AIndex^, AValue^);
end;

procedure THCmdQueryClass.CallArbitraryMethod(const ACBF: PHCmdQueryCallBoundaryFrame; const AMethodName: PSafeVariant; const AResult: PSafeVariant);
var Method: PHCmdQueryClassMethod;
begin
    AResult.VarType := HCmdQueryVarType.SkipObject;

    if AMethodName.IsString and (AMethodName.AsString.Value = 'Create') then begin
        // Create an instance of class
        CreateInstance(ACBF, AResult);
        Exit;
    end;

    Method := VMTable.Methods.ValuePtr[AMethodName^];
    if Method = nil then
        Exit;

    if not (Method.MethodMode = THCmdQueryClassMethodMode.Static) then
        //#! Details?!
        raise EHCmdQueryRuntimeException.Create('Cannot call non-static methods from the class context', ACBF.Position^);

    ACBF.Interpreter.Interfaces.Interpreter.CallNode(@Method.MethodNode, nil, 0, AResult);
end;

constructor THCmdQueryClass.Create;
begin
    inherited;

    StaticFields.Nullify(THCmdQueryDictionary.CompareSafeVariants, THCmdQueryDictionary.HashSafeVariant);

    _ClassIndexable.GetFromIndex := HCmdQuery_Class_GetValueFromIndex;
    _ClassIndexable.SetToIndex := HCmdQuery_Class_SetValueToIndex;
    _ClassMethodSupportable.CallMethod := HCmdQuery_Class_CallMethod;
    _ClassSimpleStringable.ToSimpleString := _ToStringSimpleClass;
    _ClassSimpleStringable.ToSimpleType := _ToStringSimpleClass;

    _ClassInterfaceTable.Indexable := @_ClassIndexable;
    _ClassInterfaceTable.MethodSupportable := @_ClassMethodSupportable;
    _ClassInterfaceTable.SimpleStringable := @_ClassSimpleStringable;
    _ClassInterfaceTable.RefCount := 1;

    _ObjectIndexable.GetFromIndex := HCmdQuery_Object_GetValueFromIndex;
    _ObjectIndexable.SetToIndex := HCmdQuery_Object_SetValueToIndex;
    _ObjectMethodSupportable.CallMethod := HCmdQuery_Object_CallMethod;
    _ObjectSimpleStringable.ToSimpleString := _ToStringSimpleObject;
    _ObjectSimpleStringable.ToSimpleType := _ToStringSimpleObject;

    _ObjectInterfaceTable.Indexable := @_ObjectIndexable;
    _ObjectInterfaceTable.MethodSupportable := @_ObjectMethodSupportable;
    _ObjectInterfaceTable.SimpleStringable := @_ObjectSimpleStringable;
    _ObjectInterfaceTable.RefCount := 1;
end;

destructor THCmdQueryClass.Destroy;
begin
    StaticFields.Destroy;

    inherited Destroy;
end;

{ THCmdQueryClassInstance }

procedure THCmdQueryClassInstance._CreateObject(const AObject: PSafeObject);
begin
    inherited _CreateObject(AObject);

    FSelfObject := AObject;
end;

procedure THCmdQueryClassInstance._DisposeObject(const AObject: PSafeObject);
begin
    //#! Call destructor here!

    inherited _DisposeObject(AObject);
end;

procedure THCmdQueryClassInstance.GetValueFromIndex(const ACBF: PHCmdQueryCallBoundaryFrame; const AIndex: PSafeVariant; const AResult: PSafeVariant);
var Value: PSafeVariant;
    Prop: PHCmdQueryClassProperty;
    CurrentVMT, TopVMT: THCmdQueryClassVirtualTable;
    Visibility: THCmdQueryClassVisibility;
begin
    AResult.VarType := HCmdQueryVarType.SkipObject;

    // Then, there are properties
    GetVMTablePointers(ACBF, CurrentVMT, TopVMT);
    if (CurrentVMT = nil) or (TopVMT = nil) then begin
        CurrentVMT := Self.PrototypeClass.VMTable;
        TopVMT := CurrentVMT;
        Visibility := THCmdQueryClassVisibility.Public;
    end
    else
        Visibility := THCmdQueryClassVisibility.Private;

    // Fields are ALWAYS on the top place
    //#! Protect from public access??
    Value := Fields.ValuePtr[AIndex^];
    if Assigned(Value) then begin
        if Visibility = THCmdQueryClassVisibility.Public then begin
            //#! Details?!
            raise EHCmdQueryRuntimeException.Create('Class member visibility rules violation', ACBF.Position^);
        end;
        AResult^ := Value^;
    end;

    Prop := CurrentVMT.Properties.ValuePtr[AIndex^];
    if Prop = nil then
        Exit;

    if (Visibility = THCmdQueryClassVisibility.Public) and not (Prop.Visibility = THCmdQueryClassVisibility.Public) or
        (Prop.Visibility = THCmdQueryClassVisibility.Private) and not (Prop.VMTable = CurrentVMT) then
    begin
        //#! Details?!
        raise EHCmdQueryRuntimeException.Create('Class member visibility rules violation', ACBF.Position^);
    end;

    case Prop.Reader.Mode of
        THCmdQueryClassPropertyAccessMode.None:
            begin
                raise EHCmdQueryRuntimeException.Create('Property is not available for reading', ACBF.Position^);
            end;
        THCmdQueryClassPropertyAccessMode.Field:
            begin
                Value := Fields.ValuePtr[Prop.Reader.Accessor];
                if not Assigned(Value) then
                    raise EHCmdQueryRuntimeException.Create('Property has not field to get!', ACBF.Position^);

                AResult^ := Value^;
            end;
        THCmdQueryClassPropertyAccessMode.Getter:
            begin
                CallArbitraryMethod(ACBF, @Prop.Reader.Accessor, THCmdQueryClassVisibility.Private, Prop.VMTable, TopVMT, AResult);
            end;
        THCmdQueryClassPropertyAccessMode.Inline:
            begin
                CallArbitraryNode(ACBF, @Prop.Reader.Accessor, Prop.VMTable.SelfObject, TopVMT.SelfObject, AResult);
            end;
    end;
end;

procedure THCmdQueryClassInstance.SetValueToIndex(const ACBF: PHCmdQueryCallBoundaryFrame; const AIndex: PSafeVariant; const AValue: PSafeVariant; const AResult: PSafeVariant);
var Value: PSafeVariant;
    Prop: PHCmdQueryClassProperty;
    CurrentVMT, TopVMT: THCmdQueryClassVirtualTable;
    Visibility: THCmdQueryClassVisibility;
begin
    AResult.VarType := HCmdQueryVarType.SkipObject;

    // Then, there are properties
    GetVMTablePointers(ACBF, CurrentVMT, TopVMT);
    if (CurrentVMT = nil) or (TopVMT = nil) then begin
        CurrentVMT := Self.PrototypeClass.VMTable;
        TopVMT := CurrentVMT;
        Visibility := THCmdQueryClassVisibility.Public;
    end
    else
        Visibility := THCmdQueryClassVisibility.Private;

    // Fields are ALWAYS on the top place
    //#! Protect from public access??
    Value := Fields.ValuePtr[AIndex^];
    if Assigned(Value) then begin
        if Visibility = THCmdQueryClassVisibility.Public then begin
            //#! Details?!
            raise EHCmdQueryRuntimeException.Create('Class member visibility rules violation', ACBF.Position^);
        end;

        Value^ := AValue^;
        AResult^ := 0;
    end;

    Prop := CurrentVMT.Properties.ValuePtr[AIndex^];
    if Prop = nil then
        Exit;

    if (Visibility = THCmdQueryClassVisibility.Public) and not (Prop.Visibility = THCmdQueryClassVisibility.Public) or
        (Prop.Visibility = THCmdQueryClassVisibility.Private) and not (Prop.VMTable = CurrentVMT) then
    begin
        //#! Details?!
        raise EHCmdQueryRuntimeException.Create('Class member visibility rules violation', ACBF.Position^);
    end;

    case Prop.Writer.Mode of
        THCmdQueryClassPropertyAccessMode.None:
            begin
                raise EHCmdQueryRuntimeException.Create('Property is not available for writing', ACBF.Position^);
            end;
        THCmdQueryClassPropertyAccessMode.Field:
            begin
                Value := Fields.ValuePtr[Prop.Writer.Accessor];
                if not Assigned(Value) then
                    raise EHCmdQueryRuntimeException.Create('Property has not field to set!', ACBF.Position^);

                // AResult^ := Value^;
                Value^ := AValue^;
            end;
        THCmdQueryClassPropertyAccessMode.Getter:
            begin
                CallArbitraryMethod(ACBF, @Prop.Writer.Accessor, THCmdQueryClassVisibility.Private, Prop.VMTable, TopVMT, AResult);
            end;
        THCmdQueryClassPropertyAccessMode.Inline:
            begin
                CallArbitraryNode(ACBF, @Prop.Writer.Accessor, Prop.VMTable.SelfObject, TopVMT.SelfObject, AResult);
            end;
    end;
end;

procedure THCmdQueryClassInstance.CallArbitraryNode(const ACBF: PHCmdQueryCallBoundaryFrame; const AMethodNode: PSafeVariant; const ACurrentVMT, ATopVMT: PSafeObject; const AResult: PSafeVariant);
var CurrentVMTVar, TopVMTVar: PHCmdQueryVariable;
begin
    CurrentVMTVar := ACBF.CreateLocalVariable('_currentVMT');
    TopVMTVar := ACBF.CreateLocalVariable('_topVMT');

    TopVMTVar.Value.VarType := HCmdQueryVarType.SafeObject;
    TopVMTVar.Value.AsObject := ATopVMT;
    ATopVMT.AddRef;

    CurrentVMTVar.Value.VarType := HCmdQueryVarType.SafeObject;
    CurrentVMTVar.Value.AsObject := ACurrentVMT;
    ACurrentVMT.AddRef;

    ACBF.Interpreter.Interfaces.Interpreter.CallNode(AMethodNode, nil, 0, AResult);
end;

procedure THCmdQueryClassInstance.CallArbitraryMethod(const ACBF: PHCmdQueryCallBoundaryFrame; const AMethodName: PSafeVariant; const AVisibility: THCmdQueryClassVisibility; ACurrentVMT, ATopVMT: THCmdQueryClassVirtualTable; const AResult: PSafeVariant; const ACallInherited: Boolean);
var Method: PHCmdQueryClassMethod;
    PrevCurrent: THCmdQueryClassVirtualTable;
begin
    AResult^ := 0;
    AResult^.VarType := HCmdQueryVarType.SkipObject;

    Method := ACurrentVMT.Methods.ValuePtr[AMethodName^];
    PrevCurrent := ACurrentVMT;

    if not Assigned(Method) then
        // It will be handled using shadow objects
        Exit;

    if ACallInherited then begin
        if not Assigned(Method.VMTable.ParentVMTable) then
            Exit;
        Method := Method.VMTable.ParentVMTable.Methods.ValuePtr[AMethodName^];
        if not Assigned(Method) then
            Exit;
    end;

    case Method.MethodMode of
        THCmdQueryClassMethodMode.Static:
            begin
                raise EHCmdQueryRuntimeException.Create('Cannot call static methods using reference to an instance', ACBF.Position^);
                //ACurrentVMT := Method.VMTable;
            end;
        THCmdQueryClassMethodMode.Normal:
            begin
                ACurrentVMT := Method.VMTable;
            end;
        THCmdQueryClassMethodMode.Dynamic,
        THCmdQueryClassMethodMode.Abstract:
            begin
                // We need to try to get method second time, now - from the top virtual table
                if not (ACurrentVMT = ATopVMT) and not ACallInherited then begin
                    Method := ATopVMT.Methods.ValuePtr[AMethodName^];
                    if not Assigned(Method) then
                        raise EHCmdQueryRuntimeException.Create('Virtual table is broken', ACBF.Position^);
                end;

                if Method.MethodMode = THCmdQueryClassMethodMode.Abstract then
                    raise EHCmdQueryRuntimeException.Create('Abstract method called', ACBF.Position^);

                ACurrentVMT := Method.VMTable;
            end;
    end;

    if (AVisibility = THCmdQueryClassVisibility.Public) and not (Method.Visibility = THCmdQueryClassVisibility.Public) or
        (Method.Visibility = THCmdQueryClassVisibility.Private) and not (PrevCurrent = ACurrentVMT) then
    begin
        //#! Details?!
        raise EHCmdQueryRuntimeException.Create('Class member visibility rules violation', ACBF.Position^);
    end;

    CallArbitraryNode(ACBF, @Method.MethodNode, ACurrentVMT.SelfObject, ATopVMT.SelfObject, AResult);
end;

procedure THCmdQueryClassInstance.CallArbitraryMethod(const ACBF: PHCmdQueryCallBoundaryFrame; const AMethodName: PSafeVariant; const AResult: PSafeVariant);
var CurrentVMT, TopVMT: THCmdQueryClassVirtualTable;
    Visibility: THCmdQueryClassVisibility;
begin
    AResult.VarType := HCmdQueryVarType.SkipObject;

    GetVMTablePointers(ACBF, CurrentVMT, TopVMT);
    if (CurrentVMT = nil) or (TopVMT = nil) then begin
        CurrentVMT := Self.PrototypeClass.VMTable;
        TopVMT := CurrentVMT;
        Visibility := THCmdQueryClassVisibility.Public;
    end
    else
        Visibility := THCmdQueryClassVisibility.Private;

    CallArbitraryMethod(ACBF, AMethodName, Visibility, CurrentVMT, TopVMT, AResult);
end;

constructor THCmdQueryClassInstance.Create;
begin
    inherited;

    Fields.Nullify(THCmdQueryDictionary.CompareSafeVariants, THCmdQueryDictionary.HashSafeVariant);
end;

destructor THCmdQueryClassInstance.Destroy;
begin
    Fields.Destroy;

    inherited Destroy;
end;

end.

