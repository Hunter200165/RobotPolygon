unit HCmdQuery.SafeVariant;

{$I HCmdQuery.inc}

interface

uses
    HCL.Core.Commons,
    HCL.Core.StringUtils,
    HCL.Core.HashTable;

type
    HCmdQueryVarType = (
        None = 0,
        Null = 1,
        Int64 = 2,
        Double = 3,
        Boolean = 4,
        SafeString = 5,
        NativeFunction = 6,
        SkipObject = 7,
        SafeObject = 8
    );

    THCmdQueryVarTypes = set of HCmdQueryVarType;

    // Pseudotypes to mark that variant was just converted from string/object respectively.
    // Dangling types are not reference incremented upon assignment
    //HCmdQuery_VarType_DanglingString = 8;
    //HCmdQuery_VarType_DanglingObject = 9;

type
    PSafeVariant = ^SafeVariant;
    PSafeObject = ^SafeObject;
    PSafeString = ^SafeString;

    THCmdQueryNativeFunction = procedure (const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

    (* SafeVariant
    *)
    SafeVariant = packed record
    private
        function GetIsNone: Boolean; inline;
        function GetIsNull: Boolean; inline;
        function GetIsInteger: Boolean; inline;
        function GetIsDouble: Boolean; inline;
        function GetIsNumber: Boolean; inline;
        function GetIsString: Boolean; inline;
        function GetIsObject: Boolean; inline;
        function GetIsNativeFunction: Boolean; inline;
    public
        property IsNone: Boolean read GetIsNone;
        property IsNull: Boolean read GetIsNull;
        property IsInteger: Boolean read GetIsInteger;
        property IsDouble: Boolean read GetIsDouble;
        property IsNumber: Boolean read GetIsNumber;
        property IsString: Boolean read GetIsString;
        property IsObject: Boolean read GetIsObject;
        property IsNativeFunction: Boolean read GetIsNativeFunction;
    public
        function GetBooleanValue: Boolean;
        function GetTypeString: UnicodeString;
        function GetSimpleString: UnicodeString;
    public
        function GetHashCode: UInt32;
    public
        {$I HCmdQuery.OperatorInjection.inc}
    case VarType: HCmdQueryVarType of
        HCmdQueryVarType.Int64: (
            AsInteger: Int64;
        );
        HCmdQueryVarType.Double: (
            AsDouble: Double;
        );
        HCmdQueryVarType.Boolean: (
            AsBoolean: Boolean;
        );
        HCmdQueryVarType.SafeString: (
            AsString: PSafeString;
        );
        HCmdQueryVarType.SafeObject: (
            AsObject: PSafeObject;
        );
        HCmdQueryVarType.NativeFunction: (
            AsNativeFunction: THCmdQueryNativeFunction;
        );
    end;

    { SafeString }

    SafeString = packed record
    public
        ResourceManager: Pointer;
        Address: Integer;
        RefCount: Integer;
        Value: UnicodeString;
    public
        function AddRef: Integer;
        function ReleaseRef: Integer;
    end;

    (* IHCmdQueryCreatable
        Generic interface to provide methods for creating/disposing object. It is generally advised to support this interface.
        Any object must have first 8 bytes set to the THCmdQueryCreatableCreateProcedure or nil, if object does not implement those!
        This is extremely important

        Creatable interface is the only interface which is
    *)
    THCmdQueryCreatableCreateProcedure = procedure (const ASelf: PSafeObject) of object; cdecl;
    THCmdQueryCreatableDisposeProcedure = procedure (const ASelf: PSafeObject) of object; cdecl;

    IHCmdQueryCreatable = packed record
    public
        Create: THCmdQueryCreatableCreateProcedure;
        Dispose: THCmdQueryCreatableDisposeProcedure;
    end;
    PHCmdQueryCreatable = ^IHCmdQueryCreatable;

    (**)
    THCmdQuerySimpleStringableToSimpleString = function (const ASelf: PSafeObject): UnicodeString of object; cdecl;
    THCmdQuerySimpleStringableToSimpleType = function (const ASelf: PSafeObject): UnicodeString of object; cdecl;

    IHCmdQuerySimpleStringable = packed record
        ToSimpleString: THCmdQuerySimpleStringableToSimpleString;
        ToSimpleType: THCmdQuerySimpleStringableToSimpleType;
    end;
    PIHCmdQuerySimpleStringable = ^IHCmdQuerySimpleStringable;

    (* IHCmdQueryEvaluatable
        Specific interface, made specifically for the THCmdQueryNode class, because it supports evaluation
    *)
    THCmdQueryEvaluatableEvaluateProcedure = procedure (const AInterpreter: PSafeObject; const ANode: PSafeObject; const AResult: PSafeVariant) of object; cdecl;
    THCmdQueryEvaluatableGetOpCode = function (const AInterpreter: PSafeObject; const ANode: PSafeObject): Integer of object; cdecl;
    THCmdQueryEvaluatableGetArgument = procedure (const AInterpreter: PSafeObject; const ANode: PSafeObject; const AIndex: Integer; out AResult: PSafeVariant) of object; cdecl;

    IHCmdQueryEvaluatable = packed record
    public
        Evaluate: THCmdQueryEvaluatableEvaluateProcedure;

        GetOpCode: THCmdQueryEvaluatableGetOpCode;
        GetArgument: THCmdQueryEvaluatableGetArgument;
    end;
    PIHCmdQueryEvaluatable = ^IHCmdQueryEvaluatable;

    (* IHCmdQueryContext
        Specific interface to allow allocation and deallocation of strings and objects
    *)
    THCmdQueryContextFindModuleVariable = function (const ASelf: PSafeObject; const AName: UnicodeString): Integer of object; cdecl;
    THCmdQueryContextFindLocalFunction = function (const ASelf: PSafeObject; const AName: UnicodeString): Integer of object; cdecl;
    THCmdQueryContextFindModuleFunction = function (const ASelf: PSafeObject; const AName: UnicodeString): Integer of object; cdecl;

    (* IHCmdQueryInterpreter
        Specific interface to allow interpreter interactions
    *)
    THCmdQueryInterpreterAllocateStringProcedure = function (const AValue: UnicodeString): PSafeString of object; cdecl;
    THCmdQueryInterpreterAllocateObjectProcedure = function (const AValue: Pointer; const ATypeID: UInt64): PSafeObject of object; cdecl;
    //THCmdQueryInterpreterDeallocateStringProcedure = procedure (const AString: PSafeString) of object; cdecl;
    //THCmdQueryInterpreterDeallocateObjectProcedure = procedure (const AObject: PSafeObject) of object; cdecl;

    THCmdQueryInterpreterGetCurrentCallBoundary = function: Pointer of object; cdecl;
    THCmdQueryInterpreterSetCurrentCallBoundary = procedure (const ACallBoundary: Pointer) of object; cdecl;
    THCmdQueryInterpreterSetCurrentCallBoundaryLevelDown = function: Pointer of object; cdecl;

    THCmdQueryInterpreterAllocateCallBoundaryFrame = function: Pointer of object; cdecl;
    THCmdQueryInterpreterDeallocateCallBoundaryFrame = procedure of object; cdecl;

    THCmdQueryInterpreterGetSimpleTypeShadowObject = function (const ATypeID: HCmdQueryVarType): PSafeObject of object; cdecl;

    THCmdQueryInterpreterCallNode = procedure (const ANode: PSafeVariant; const AArguments: PSafeVariant; const AArgumentsCount: Integer; const AResult: PSafeVariant) of object; cdecl;
    THCmdQueryInterpreterCallNodeFull = procedure (const ANode: PSafeVariant; const AArguments: PSafeVariant; const AArgumentsCount: Integer; const AParameters: Pointer; const AParametersCount: Integer; const AResult: PSafeVariant) of object; cdecl;

    THCmdQueryInterpreterWriteToStandardOutput = procedure (const AToWrite: UnicodeString) of object; cdecl;
    THCmdQueryInterpreterReadFromStandardInput = function: UnicodeString; cdecl;

    //THCmdQueryInterpreterFindVariable = function (const ASelf: PSafeObject; const AName: UnicodeString): Integer of object; cdecl;
    //THCmdQueryInterpreterFindFunction = function (const ASelf: PSafeObject; const AName: UnicodeString): Integer of object; cdecl;

    IHCmdQueryInterpreter = packed record
        GetCurrentCallBoundary: THCmdQueryInterpreterGetCurrentCallBoundary;
        SetCurrentCallBoundary: THCmdQueryInterpreterSetCurrentCallBoundary;
        SetCurrentCallBoundaryLevelDown: THCmdQueryInterpreterSetCurrentCallBoundaryLevelDown;

        AllocateCallBoundaryFrame: THCmdQueryInterpreterAllocateCallBoundaryFrame;
        DeallocateCallBoundaryFrame: THCmdQueryInterpreterDeallocateCallBoundaryFrame;

        AllocateString: THCmdQueryInterpreterAllocateStringProcedure;
        AllocateObject: THCmdQueryInterpreterAllocateObjectProcedure;

        GetSimpleTypeShadowObject: THCmdQueryInterpreterGetSimpleTypeShadowObject;

        CallNode: THCmdQueryInterpreterCallNode;
        CallNodeFull: THCmdQueryInterpreterCallNodeFull;

        WriteToStdOut: THCmdQueryInterpreterWriteToStandardOutput;
        ReadFromStdIn: THCmdQueryInterpreterReadFromStandardInput;
    end;
    PIHCmdQueryInterpreter = ^IHCmdQueryInterpreter;

    (* IHCmdQueryAssignable
    *)
    THCmdQueryAssignableAssign = procedure (const AInterpreter: PSafeObject; const ASelf: PSafeObject; const AValue: SafeVariant) of object; cdecl;

    IHCmdQueryAssignable = packed record
        Assign: THCmdQueryAssignableAssign;
    end;
    PIHCmdQueryAssignable = ^IHCmdQueryAssignable;

    (* IHCmdQueryBinaryOperatorOverloadable
        Interface to allow objects to overload binary operators
    *)
    IHCmdQueryBinaryOperatorOverloadable = packed record
        LeftOverload: SafeVariant;
        RightOverload: SafeVariant;
    end;
    PIHCmdQueryBinaryOperatorOverloadable = ^IHCmdQueryBinaryOperatorOverloadable;

    IHCmdQueryUnaryOperatorOverloadable = packed record
        Overload: SafeVariant;
    end;
    PIHCmdQueryUnaryOperatorOverloadable = ^IHCmdQueryUnaryOperatorOverloadable;

    THCmdQueryNullableNullify = procedure (const ASelfObject: PSafeObject) of object; cdecl;
    IHCmdQueryNullable = packed record
        Nullify: THCmdQueryNullableNullify;
    end;
    PIHCmdQueryNullable = ^IHCmdQueryNullable;

    THCmdQueryIndexableGetFromIndex = procedure (const ASelfObject: PSafeObject; const AIndexNode: PSafeVariant; const AResult: PSafeVariant) of object; cdecl;
    THCmdQueryIndexableSetToIndex = procedure (const ASelfObject: PSafeObject; const AIndexNode: PSafeVariant; const AValue: SafeVariant) of object; cdecl;

    IHCmdQueryIndexable = packed record
        GetFromIndex: SafeVariant;
        SetToIndex: SafeVariant;
    end;
    PIHCmdQueryIndexable = ^IHCmdQueryIndexable;

    IHCmdQueryMethodSupportable = packed record
        CallMethod: SafeVariant;
        AssignMethod: SafeVariant;
    end;
    PIHCmdQueryMethodSupportable = ^IHCmdQueryMethodSupportable;

    { TSafeObjectInterfaces
        Safe object virtual interface table. Basically stores all the interfaces of given class for object to know
    }

    PSafeObjectInterfaces = ^TSafeObjectInterfaces;
    TSafeObjectInterfaces = packed record
    public var
        RefCount: Integer;
    public var
        { Interfaces }
        Interpreter: PIHCmdQueryInterpreter;
        Evaluatable: PIHCmdQueryEvaluatable;
        Assignable: PIHCmdQueryAssignable;
        Nullable: PIHCmdQueryNullable;
    public var
        Negatable: PIHCmdQueryUnaryOperatorOverloadable;
        BinaryNegatable: PIHCmdQueryUnaryOperatorOverloadable;
    public var
        Addable: PIHCmdQueryBinaryOperatorOverloadable;
        Subtractable: PIHCmdQueryBinaryOperatorOverloadable;
        Multiplyable: PIHCmdQueryBinaryOperatorOverloadable;
        Divisible: PIHCmdQueryBinaryOperatorOverloadable;

        IntDivisible: PIHCmdQueryBinaryOperatorOverloadable;
        Moduloable: PIHCmdQueryBinaryOperatorOverloadable;
    public var
        BinaryOrable: PIHCmdQueryBinaryOperatorOverloadable;
        BinaryAndable: PIHCmdQueryBinaryOperatorOverloadable;
        BinaryXorable: PIHCmdQueryBinaryOperatorOverloadable;
        BinaryShlable: PIHCmdQueryBinaryOperatorOverloadable;
        BinaryShrable: PIHCmdQueryBinaryOperatorOverloadable;
    public var
        ComparableEqual: PIHCmdQueryBinaryOperatorOverloadable;
        ComparableNotEqual: PIHCmdQueryBinaryOperatorOverloadable;
        ComparableLess: PIHCmdQueryBinaryOperatorOverloadable;
        ComparableLessEqual: PIHCmdQueryBinaryOperatorOverloadable;
        ComparableGreater: PIHCmdQueryBinaryOperatorOverloadable;
        ComparableGreaterEqual: PIHCmdQueryBinaryOperatorOverloadable;
    public
        Indexable: PIHCmdQueryIndexable;
        MethodSupportable: PIHCmdQueryMethodSupportable;
    public
        SimpleStringable: PIHCmdQuerySimpleStringable;
    public
        ShadowInterfaces: PSafeObjectInterfaces;
        ShadowReference: PSafeObject;
    public
        function AddRef: Integer;
        function ReleaseRef: Integer;
    public
        procedure Destroy;
    end;

    { SafeObject }

    SafeObject = packed record
    public
        ResourceManager: Pointer;
        Address: Integer;
        RefCount: Integer;
        Timestamp: UInt64;
        TypeID: UInt64;
        { Actual pointer to an object }
        Value: Pointer;
    public
        Interfaces: PSafeObjectInterfaces;
    public
        function AddRef: Integer;
        function ReleaseRef: Integer;
    public
        procedure AttachInterfaces(const AInterfaces: PSafeObjectInterfaces);
    public
        function AllocateStandaloneInterfacesTable: PSafeObjectInterfaces;
    public
        function TreatAs<T>: T; inline;
        function IsOfType(const ATypeID: UInt64): Boolean; inline;
    public
        procedure Destroy;
    end;

const HCmdQuery_CreatableInterface_Offset = SizeOf(Pointer);

type
    HCmdQueryBinaryOperatorInterfaceOffset = (
        Add,
        Subtract,
        Multiply,
        Divide,
        IntDivide,
        Modulo,

        BinaryOr,
        BinaryAnd,
        BinaryXor,
        BinaryShl,
        BinaryShr,

        Equals,
        NotEquals,
        Less,
        LessEquals,
        Greater,
        GreaterEquals
    );

    HCmdQueryUnaryOperatorInterfaceOffset = (
        Negate,
        BinaryNot
    );

{$If not (SizeOf(SafeVariant) = 9)}
    {$Message error 'Not 9 bytes'}
{$EndIf}

const
    None: SafeVariant = (
        VarType: HCmdQueryVarType.None;
        AsInteger: 0
    );
    Null: SafeVariant = (
        VarType: HCmdQueryVarType.Null;
        AsInteger: 0
    );

function HCmdQuery_EncodeTypePair(const AType1, AType2: HCmdQueryVarType): Word; inline;
function HCmdQuery_VarTypeToString(const AVarType: HCmdQueryVarType): UnicodeString;
function HCmdQuery_VarSetToString(const AVarSet: THCmdQueryVarTypes): UnicodeString;

const
    HCmdQuery_TypePair_NoneNone = (Ord(HCmdQueryVarType.None) shl 8) or Ord(HCmdQueryVarType.None);
    HCmdQuery_TypePair_NullNull = (Ord(HCmdQueryVarType.Null) shl 8) or Ord(HCmdQueryVarType.Null);
    HCmdQuery_TypePair_IntInt = (Ord(HCmdQueryVarType.Int64) shl 8) or Ord(HCmdQueryVarType.Int64);
    HCmdQuery_TypePair_IntDouble = (Ord(HCmdQueryVarType.Int64) shl 8) or Ord(HCmdQueryVarType.Double);
    HCmdQuery_TypePair_DoubleInt = (Ord(HCmdQueryVarType.Double) shl 8) or Ord(HCmdQueryVarType.Int64);
    HCmdQuery_TypePair_DoubleDouble = (Ord(HCmdQueryVarType.Double) shl 8) or Ord(HCmdQueryVarType.Double);
    HCmdQuery_TypePair_BooleanBoolean = (Ord(HCmdQueryVarType.Boolean) shl 8) or Ord(HCmdQueryVarType.Boolean);
    HCmdQuery_TypePair_StringString = (Ord(HCmdQueryVarType.SafeString) shl 8) or Ord(HCmdQueryVarType.SafeString);
    HCmdQuery_TypePair_SkipSkip = (Ord(HCmdQueryVarType.SkipObject) shl 8) or Ord(HCmdQueryVarType.SkipObject);
    HCmdQuery_TypePair_NativeNative = (Ord(HCmdQueryVarType.NativeFunction) shl 8) or Ord(HCmdQueryVarType.NativeFunction);

implementation

uses
    HCmdQuery.Kernel.ResourceManager;

function HCmdQuery_EncodeTypePair(const AType1, AType2: HCmdQueryVarType): Word;
begin
    Result := (Ord(AType1) shl 8) or Ord(AType2);
end;

function HCmdQuery_VarTypeToString(const AVarType: HCmdQueryVarType): UnicodeString;
begin
    case AVarType of
        HCmdQueryVarType.None: Result := 'None';
        HCmdQueryVarType.Null: Result := 'Null';
        HCmdQueryVarType.Int64: Result := 'Integer';
        HCmdQueryVarType.Double: Result := 'Float';
        HCmdQueryVarType.Boolean: Result := 'Boolean';
        HCmdQueryVarType.SafeString: Result := 'String';
        HCmdQueryVarType.NativeFunction: Result := 'NativeFunction';
        HCmdQueryVarType.SkipObject: Result := 'SkipObject';
        HCmdQueryVarType.SafeObject: Result := 'Object';
    end;
end;

function HCmdQuery_VarSetToString(const AVarSet: THCmdQueryVarTypes): UnicodeString;
var First: Boolean;
    T: HCmdQueryVarType;
begin
    Result := '';
    First := True;

    for T in AVarSet do begin
        if not First then
            Result := Result + '/';
        Result := Result + HCmdQuery_VarTypeToString(T);
        First := False;
    end;
end;

{ TSafeObjectInterfaces }

function TSafeObjectInterfaces.AddRef: Integer;
begin
    Result := InterlockedIncrement(RefCount);
end;

function TSafeObjectInterfaces.ReleaseRef: Integer;
begin
    Result := InterlockedDecrement(RefCount);
    if Result <= 0 then begin
        Destroy;

        Dispose(@Self);
    end;
end;

procedure TSafeObjectInterfaces.Destroy;
begin
    if Assigned(ShadowInterfaces) then begin
        ShadowInterfaces.ReleaseRef;
        ShadowInterfaces := nil;
    end;

    if Assigned(ShadowReference) then begin
        ShadowReference.ReleaseRef;
        ShadowReference := nil;
    end;
end;

{ SafeObject }

function SafeObject.AddRef: Integer;
begin
    Result := InterlockedIncrement(RefCount);
end;

function SafeObject.ReleaseRef: Integer;
begin
    Result := InterlockedDecrement(RefCount);
    if Result <= 0 then begin
        Destroy;
        THCmdQueryResourceManager(ResourceManager).DeallocateObject(@Self);
    end;
end;

procedure SafeObject.AttachInterfaces(const AInterfaces: PSafeObjectInterfaces);
begin
    if Assigned(Interfaces) then
        Interfaces.ReleaseRef;

    Interfaces := AInterfaces;
    Interfaces.AddRef;
end;

function SafeObject.AllocateStandaloneInterfacesTable: PSafeObjectInterfaces;
begin
    Result := Interfaces;
    if Assigned(Result) then
        Exit;

    New(Interfaces);
    Interfaces^ := Default(TSafeObjectInterfaces);
    Interfaces.RefCount := 1;
    Result := Interfaces;
end;

function SafeObject.TreatAs<T>: T;
begin
    Result := T(Value);
end;

function SafeObject.IsOfType(const ATypeID: UInt64): Boolean;
begin
    Result := TypeID = ATypeID;
end;

procedure SafeObject.Destroy;
begin
    if Assigned(Interfaces) then begin
        Interfaces.ReleaseRef;
        Interfaces := nil;
    end;
end;

{ SafeString }

function SafeString.AddRef: Integer;
begin
    Result := InterlockedIncrement(RefCount);
    //Inc(RefCount);
    //Result := RefCount;
end;

function SafeString.ReleaseRef: Integer;
begin
    Result := InterlockedDecrement(RefCount);
    //Dec(RefCount);
    //Result := RefCount;
    if Result <= 0 then begin
        //WriteLn('[string]: dealloc #', Self.Address);

        THCmdQueryResourceManager(ResourceManager).DeallocateString(@Self);
    end;
end;

{ SafeVariant }

function SafeVariant.GetIsNone: Boolean;
begin
    Result := VarType = HCmdQueryVarType.None;
end;

function SafeVariant.GetIsNull: Boolean;
begin
    Result := VarType = HCmdQueryVarType.Null;
end;

function SafeVariant.GetIsInteger: Boolean;
begin
    Result := VarType = HCmdQueryVarType.Int64;
end;

function SafeVariant.GetIsDouble: Boolean;
begin
    Result := VarType = HCmdQueryVarType.Double;
end;

function SafeVariant.GetIsNumber: Boolean;
begin
    Result := VarType in [ HCmdQueryVarType.Int64, HCmdQueryVarType.Double ];
end;

function SafeVariant.GetIsString: Boolean;
begin
    Result := VarType = HCmdQueryVarType.SafeString;
end;

function SafeVariant.GetIsObject: Boolean;
begin
    Result := VarType = HCmdQueryVarType.SafeObject;
end;

function SafeVariant.GetIsNativeFunction: Boolean;
begin
    Result := VarType = HCmdQueryVarType.NativeFunction;
end;

function SafeVariant.GetBooleanValue: Boolean;
begin
    case VarType of
        HCmdQueryVarType.None,
        HCmdQueryVarType.Null:
            Result := False;
        HCmdQueryVarType.Int64:
            Result := not (AsInteger = 0);
        HCmdQueryVarType.Double:
            Result := not (AsDouble = 0);
        HCmdQueryVarType.Boolean:
            Result := AsBoolean;
        HCmdQueryVarType.SafeString:
            Result := Assigned(AsString);
        HCmdQueryVarType.SafeObject:
            Result := Assigned(AsObject);
    else
        Result := True;
    end;
end;

function SafeVariant.GetTypeString: UnicodeString;
begin
    if IsObject and Assigned(AsObject.Interfaces) and Assigned(AsObject.Interfaces.SimpleStringable) and Assigned(AsObject.Interfaces.SimpleStringable.ToSimpleType) then begin
        Result := AsObject.Interfaces.SimpleStringable.ToSimpleType(AsObject);
        Exit;
    end;

    Result := HCmdQuery_VarTypeToString(VarType);
end;

function SafeVariant.GetSimpleString: UnicodeString;
begin
    case VarType of
        HCmdQueryVarType.None: Result := 'None';
        HCmdQueryVarType.Null: Result := 'Null';
        HCmdQueryVarType.Int64: Result := IntToStr(AsInteger);
        HCmdQueryVarType.Double: Result := FloatToStr(AsDouble, 6);
        HCmdQueryVarType.Boolean:
            begin
                if AsBoolean then
                    Result := 'True'
                else
                    Result := 'False';
            end;
        HCmdQueryVarType.SkipObject: Result := 'SkipObject';
        HCmdQueryVarType.SafeString: Result := AsString.Value;
        HCmdQueryVarType.NativeFunction: Result := 'NativeFunction(0x' + IntToHex(AsInteger, 8) + ')';
        HCmdQueryVarType.SafeObject:
            begin
                if (AsObject.Interfaces = nil) or (AsObject.Interfaces.SimpleStringable = nil) or (@AsObject.Interfaces.SimpleStringable.ToSimpleString = nil) then
                    Result := 'Object(0x' + IntToHex(AsInteger, 8) + ')'
                else
                    Result := AsObject.Interfaces.SimpleStringable.ToSimpleString(AsObject);
            end;
    end;
end;

function SafeVariant.GetHashCode: UInt32;
begin
    case VarType of
        HCmdQueryVarType.None: Result := 0;
        HCmdQueryVarType.Null: Result := 1;
        HCmdQueryVarType.Int64: Result := HashInt64(AsInteger);
        HCmdQueryVarType.Double: Result := HashInt64(AsInteger);
        HCmdQueryVarType.Boolean: Result := HashInt64(AsInteger);
        HCmdQueryVarType.SafeString: Result := HashUnicodeString(AsString.Value);
        HCmdQueryVarType.NativeFunction: Result := HashInt16(AsInteger);
        HCmdQueryVarType.SkipObject: Result := 2;
        HCmdQueryVarType.SafeObject: Result := HashInt64(AsInteger);
    end;
end;

class operator SafeVariant.Initialize(var AVar: SafeVariant);
begin
    AVar.VarType := HCmdQueryVarType.None;
    AVar.AsInteger := 0;
end;

class operator SafeVariant.Finalize(var AVar: SafeVariant);
begin
    //if AVar.VarType = HCmdQueryVarType_String then begin
    //    AVar.AsString.ReleaseRef
    //end
    //else if AVar.VarType = HCmdQueryVarType_Object then begin
    //    AVar.AsObject.ReleaseRef;
    //end;

    case AVar.VarType of
        HCmdQueryVarType.SafeString: AVar.AsString.ReleaseRef;
        HCmdQueryVarType.SafeObject: AVar.AsObject.ReleaseRef;
    else
        { Nothing should be here }
    end;

    AVar.VarType := HCmdQueryVarType.None;
end;

class operator SafeVariant.Copy(constref ASrc: SafeVariant; var ADest: SafeVariant);
begin
    if (ASrc.VarType = ADest.VarType) and (ASrc.AsInteger = ADest.AsInteger) then
        // No need to change
        Exit;

    Finalize(ADest);

    ADest.VarType := ASrc.VarType;
    case ASrc.VarType of
        HCmdQueryVarType.SafeString:
            ADest.AsString := THCmdQueryResourceManager(ASrc.AsString.ResourceManager).AllocateString(ASrc.AsString.Value);
        HCmdQueryVarType.SafeObject:
            begin
                ADest.AsObject := ASrc.AsObject;
                ADest.AsObject.AddRef;
            end;
        //HCmdQueryVarType_DanglingString:
        //    begin
        //        ADest.VarType := HCmdQueryVarType_String;
        //        ADest.AsString := ASrc.AsString;
        //    end;
        //HCmdQueryVarType_DanglingObject:
        //    begin
        //        ADest.VarType := HCmdQueryVarType_Object;
        //        ADest.AsObject := ASrc.AsObject;
        //    end;
    else
        ADest.AsInteger := ASrc.AsInteger;
    end;
end;

class operator SafeVariant.Implicit(const AObject: PSafeObject): SafeVariant;
begin
    Finalize(Result);
    // Dec(AObject.RefCount);
    Result.VarType := HCmdQueryVarType.SafeObject;
    Result.AsObject := AObject;
end;

class operator SafeVariant.Implicit(const AInteger: Int64): SafeVariant;
begin
    Finalize(Result);
    Result.VarType := HCmdQueryVarType.Int64;
    Result.AsInteger := AInteger;
end;

class operator SafeVariant.Implicit(const ANumber: Double): SafeVariant;
begin
    Finalize(Result);
    Result.VarType := HCmdQueryVarType.Double;
    Result.AsDouble := ANumber;
end;

class operator SafeVariant.Implicit(const ABoolean: Boolean): SafeVariant;
begin
    Finalize(Result);
    Result.VarType := HCmdQueryVarType.Boolean;
    Result.AsBoolean := ABoolean;
end;

class operator SafeVariant.Implicit(const AString: PSafeString): SafeVariant;
begin
    //WriteLn('Implicit from safe string');

    Finalize(Result);
    Result.VarType := HCmdQueryVarType.SafeString;
    Result.AsString := AString;
end;

class operator SafeVariant.Implicit(const AFunction: THCmdQueryNativeFunction): SafeVariant;
begin
    Finalize(Result);
    Result.VarType := HCmdQueryVarType.NativeFunction;
    Result.AsNativeFunction := AFunction;
end;

class operator SafeVariant.Equal(const A, B: SafeVariant): Boolean;
begin
    if (A.VarType = HCmdQueryVarType.Int64) and (B.VarType = HCmdQueryVarType.Double) then begin
        Result := A.AsInteger = B.AsDouble;
        Exit;
    end
    else if (A.VarType = HCmdQueryVarType.Double) and (B.VarType = HCmdQueryVarType.Int64) then begin
        Result := A.AsDouble = B.AsInteger;
        Exit;
    end;

    Result := A.VarType = B.VarType;
    if not Result then
        Exit;

    if A.VarType = HCmdQueryVarType.SafeString then begin
        Result := A.AsString.Value = B.AsString.Value;
        Exit;
    end;

    Result := A.AsInteger = B.AsInteger;
end;

end.

