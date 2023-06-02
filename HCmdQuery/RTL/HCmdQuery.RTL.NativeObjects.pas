unit HCmdQuery.RTL.NativeObjects;

{$I HCmdQuery.inc}

interface

uses
    TypInfo,
    HCL.Core.HashTable,
    HCL.Core.GenericList,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary;

type

    { THCmdQueryArrayType }

    THCmdQueryArrayType = class(THCmdQueryObject)
    public const
        TypeID = 1683915050161;
    protected var
        _Indexable: IHCmdQueryIndexable;
        _MethodSupportable: IHCmdQueryMethodSupportable;
        _SimpleStringable: IHCmdQuerySimpleStringable;
        _InterfacesTable: TSafeObjectInterfaces;
    protected
        // function _ToStringSimpleType(const AObject: PSafeObject): UnicodeString; cdecl;
        function _ToStringSimpleObject(const AObject: PSafeObject): UnicodeString; cdecl;
    public
        constructor Create;
        destructor Destroy; override;
    end;

    THCmdQueryArray = class(THCmdQueryObject)
    public const
        TypeID = 1683915069128;
    public var
        // Keep reference to type, so interface table will not be disposed until all the instances of array are dead
        ArrayType: SafeVariant;
        Storage: HList<SafeVariant>;
    end;

type

    { THCmdQueryDictionaryType }

    THCmdQueryDictionaryType = class(THCmdQueryObject)
    public const
        TypeID = 1683915088785;
    protected var
        _Indexable: IHCmdQueryIndexable;
        _MethodSupportable: IHCmdQueryMethodSupportable;
        _SimpleStringable: IHCmdQuerySimpleStringable;
        _InterfacesTable: TSafeObjectInterfaces;
    protected
        function _ToStringSimpleObject(const AObject: PSafeObject): UnicodeString; cdecl;
    public
        constructor Create;
        destructor Destroy; override;
    end;

    THCmdQueryDictionary = class(THCmdQueryObject)
    public const
        TypeID = 1683915121180;
    public
        class function CompareSafeVariants(constref A, B: SafeVariant): Integer; static;
        class function HashSafeVariant(constref A: SafeVariant): UInt32; static;
    public var
        DictionaryType: SafeVariant;
        Storage: THCLHashTable<SafeVariant, SafeVariant>;
    public
        constructor Create;
        destructor Destroy; override;
    end;

procedure HCmdQuery_NativeObjects_ArrayCreate(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
procedure HCmdQuery_NativeObjects_DictionaryCreate(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

procedure HCmdQuery_NativeObjects_SetArguments(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;

implementation

procedure HCmdQuery_Array_GetValueFromIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryArray;
    IndexGeneral: PSafeVariant;
{ Aux }
    procedure GetProperty;
    var IndexString: UnicodeString;
    begin
        IndexString := IndexGeneral.AsString.Value;

        if IndexString = 'Length' then
            AResult^ := SelfObj.Storage.Count;
    end;

    procedure GetIndex;
    var Index: Integer;
    begin
        Index := IndexGeneral.AsInteger;

        if (Index < 0) or (Index >= SelfObj.Storage.Count) then
            raise EHCmdQueryArgumentOutOfBounds.Create(
                'Array index is out of bounds (given %d, there is %d elements overall)',
                [ Index, SelfObj.Storage.Count ],
                CBF.Position^
            );

        AResult^ := SelfObj.Storage.Items[Index];
    end;
{ Main routine }
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryArray;
    IndexGeneral := CBF.ExpectNode(1);

    AResult.VarType := HCmdQueryVarType.SkipObject;

    case IndexGeneral.VarType of
        HCmdQueryVarType.Int64: GetIndex;
        HCmdQueryVarType.SafeString: GetProperty;
    else
        // Else it is skip object, which means that it was not processed
    end;
end;

procedure HCmdQuery_Array_SetValueToIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryArray;
    IndexGeneral: PSafeVariant;
{ Aux }
    procedure SetIndex;
    var Index: Integer;
    begin
        Index := IndexGeneral.AsInteger;

        if (Index < 0) or (Index >= SelfObj.Storage.Count) then
            raise EHCmdQueryArgumentOutOfBounds.Create(
                'Array index is out of bounds (given %d, there is %d elements overall)',
                [ Index, SelfObj.Storage.Count ],
                CBF.Position^
            );

        SelfObj.Storage.Items[Index] := CBF.ExpectNode(2)^;
        AResult^ := Index;
    end;
{ Main routine }
begin
    AResult.VarType := HCmdQueryVarType.SkipObject;

    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryArray;
    IndexGeneral := CBF.ExpectNode(1);

    AResult.VarType := HCmdQueryVarType.SkipObject;

    if IndexGeneral.IsInteger then
        SetIndex;
end;

procedure HCmdQuery_Array_CallMethod(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryArray;
    MethodName: PSafeVariant;
{ Aux }
    procedure CallMethod;
    var Name: UnicodeString;
    begin
        Name := MethodName.AsString.Value;

        if Name = 'Add' then begin
            CBF.EndExpectation(1);

            AResult^ := CBF.ExpectValue(0, '.Add![0]: Expected value to add');
            SelfObj.Storage.Add(AResult^);
        end
        else if Name = 'Remove' then begin
            CBF.EndExpectation(0);

            if SelfObj.Storage.Count <= 0 then
                raise EHCmdQueryArgumentOutOfBounds.Create('.Remove![]: List is empty', CBF.Position^);

            SelfObj.Storage.LastItemPointer^ := None;
            SelfObj.Storage.Remove;

            AResult^ := SelfObj.Storage.Count;
        end;
    end;
{ Main routine }
begin
    AResult.VarType := HCmdQueryVarType.SkipObject;

    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryArray;
    MethodName := CBF.ExpectNode(1);

    CBF.ArgumentStack := CBF.ArgumentStack + 2;
    CBF.ArgumentStackCount := CBF.ArgumentStackCount - 2;

    if MethodName.IsString then
        CallMethod;
end;

procedure HCmdQuery_Dictionary_GetValueFromIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryDictionary;
    IndexGeneral, Res: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryDictionary;
    IndexGeneral := CBF.ExpectNode(1);

    AResult.VarType := HCmdQueryVarType.SkipObject;

    Res := SelfObj.Storage.ValuePtr[IndexGeneral^];
    if Assigned(Res) then
        AResult^ := Res^;
end;

procedure HCmdQuery_Dictionary_SetValueToIndex(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryDictionary;
    IndexGeneral: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryDictionary;
    IndexGeneral := CBF.ExpectNode(1);

    AResult^ := 0;

    SelfObj.Storage.AddOrSetElement(IndexGeneral^, CBF.ExpectNode(2)^);
end;

procedure HCmdQuery_Dictionary_CallMethod(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    SelfObj: THCmdQueryDictionary;
    IndexGeneral, Temp: PSafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    SelfObj := TObject(CBF.ExpectNode(0).AsObject.Value) as THCmdQueryDictionary;
    IndexGeneral := CBF.ExpectNode(1);

    AResult.VarType := HCmdQueryVarType.SkipObject;
    if IndexGeneral.IsString then begin
        if IndexGeneral.AsString.Value = 'Contains' then begin
            CBF.ArgumentStackCount := CBF.ArgumentStackCount - 2;
            CBF.ArgumentStack := CBF.ArgumentStack + 2;
            CBF.EndExpectation(1);

            AResult^ := Assigned(SelfObj.Storage.GetBucket(CBF.ExpectValue(0, '.Contains![0]: Expected key to probe')));
            Exit;
        end;
    end;

    Temp := SelfObj.Storage.ValuePtr[IndexGeneral^];
    if not Assigned(Temp) then
        Exit;

    CBF.ArgumentStackCount := CBF.ArgumentStackCount - 2;
    CBF.ArgumentStack := CBF.ArgumentStack + 2;

    AInterpreter.Interfaces.Interpreter.CallNode(Temp, nil, 0, AResult);
end;

procedure HCmdQuery_NativeObjects_ArrayCreate(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Res: THCmdQueryArray;
    Index, i: Integer;
    VarPtr: PHCmdQueryVariable;
    Temp: SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    Index := CBF.FindGlobalVariable('ArrayType');
    if Index < 0 then
        raise EHCmdQueryTypeVariableCorrupted.Create(
            'There is type variable `ArrayType`. Have array type been registered?',
            CBF.Position^
        );

    VarPtr := CBF.GetGlobalVariablePointer(Index);
    if not VarPtr.Value.IsObject then
        raise EHCmdQueryTypeVariableCorrupted.Create(
            '`ArrayType` variable is not an object',
            CBF.Position^
        );

    Res := THCmdQueryArray.Create;
    AResult^ := CBF.AllocateObject(Res, Res.TypeID);
    AResult.AsObject.AttachInterfaces(@(TObject(VarPtr.Value.AsObject.Value) as THCmdQueryArrayType)._InterfacesTable);

    for i := 0 to CBF.ArgumentStackCount - 1 do begin
        Temp := None;
        Temp := CBF.ExpectValue(i);

        if not (Temp.VarType = HCmdQueryVarType.SkipObject) then
            Res.Storage.Add(Temp);
    end;
end;

procedure HCmdQuery_NativeObjects_DictionaryCreate(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Res: THCmdQueryDictionary;
    Index, i: Integer;
    VarPtr: PHCmdQueryVariable;
    Key, Value: SafeVariant;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;

    Index := CBF.FindGlobalVariable('DictionaryType');
    if Index < 0 then
        raise EHCmdQueryTypeVariableCorrupted.Create(
            'There is type variable `DictionaryType`. Have dictionary type been registered?',
            CBF.Position^
        );

    VarPtr := CBF.GetGlobalVariablePointer(Index);
    if not VarPtr.Value.IsObject then
        raise EHCmdQueryTypeVariableCorrupted.Create(
            '`DictionaryType` variable is not an object',
            CBF.Position^
        );

    Res := THCmdQueryDictionary.Create;
    AResult^ := CBF.AllocateObject(Res, Res.TypeID);
    AResult.AsObject.AttachInterfaces(@(TObject(VarPtr.Value.AsObject.Value) as THCmdQueryDictionaryType)._InterfacesTable);

    CBF.EndExpectation(0);

    for i := 0 to CBF.ParameterStackCount - 1 do begin

        // Temp := CBF.ExpectValue(i);

        Key := None;
        Value := None;

        Key := CBF.ParameterStack[i].Name;
        Value := CBF.CallNodeWithPreviousFrame(@CBF.ParameterStack[i].Value);

        if not (Key.VarType = HCmdQueryVarType.SkipObject) and not (Value.VarType = HCmdQueryVarType.SkipObject) then
            Res.Storage.AddOrSetElement(Key, Value);

        // Res.Storage.Add(Temp);
    end;
end;

procedure HCmdQuery_NativeObjects_SetArguments(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Obj: SafeVariant;
    From, Count, VarPos: Integer;
    SelfObj: THCmdQueryArray;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(3);

    Obj := CBF.ExpectValue(0, 'setArguments[0]: Expected Array to set arguments from');
    if not Obj.IsObject or not Obj.AsObject.IsOfType(THCmdQueryArray.TypeID) then
        raise EHCmdQueryArgumentException.Create(
            'setArguments[0]: Expected Array type, however value of type %s was passed',
            [ Obj.GetTypeString ],
            CBF.Position^
        );

    SelfObj := THCmdQueryArray(Obj.AsObject.Value);

    From := CBF.ExpectIntegerDefault(1, 0);
    Count := CBF.ExpectIntegerDefault(2, SelfObj.Storage.Count);

    if (From < 0) or (From > SelfObj.Storage.Count) then
        raise EHCmdQueryArgumentOutOfBounds.Create(
            'setArguments[1]: From-index is out of bounds (given %d, expected to be %d..%d)',
            [ From, 0, SelfObj.Storage.Count ],
            CBF.Position^
        );

    if (Count < 0) or (Count > (SelfObj.Storage.Count - From)) then
        raise EHCmdQueryArgumentOutOfBounds.Create(
            'setArguments[2]: Elements count is out of bounds (given %d, expected to be %d..%d)',
            [ Count, 0, SelfObj.Storage.Count - From ],
            CBF.Position^
        );


end;

{ THCmdQueryArrayType }

function THCmdQueryArrayType._ToStringSimpleObject(const AObject: PSafeObject): UnicodeString; cdecl;
begin
    Result := 'Array';
end;

constructor THCmdQueryArrayType.Create;
begin
    inherited;

    _Indexable.GetFromIndex := HCmdQuery_Array_GetValueFromIndex;
    _Indexable.SetToIndex := HCmdQuery_Array_SetValueToIndex;

    _MethodSupportable.CallMethod := HCmdQuery_Array_CallMethod;

    _SimpleStringable.ToSimpleString := _ToStringSimpleObject;
    _SimpleStringable.ToSimpleType := _ToStringSimpleObject;

    _InterfacesTable.Indexable := @_Indexable;
    _InterfacesTable.MethodSupportable := @_MethodSupportable;
    _InterfacesTable.SimpleStringable := @_SimpleStringable;
    _InterfacesTable.RefCount := 1;
end;

destructor THCmdQueryArrayType.Destroy;
begin
    _InterfacesTable.Destroy;

    inherited Destroy;
end;

{ THCmdQueryDictionaryType }

function THCmdQueryDictionaryType._ToStringSimpleObject(const AObject: PSafeObject): UnicodeString; cdecl;
begin
    Result := 'Dictionary';
end;

constructor THCmdQueryDictionaryType.Create;
begin
    _Indexable.GetFromIndex := HCmdQuery_Dictionary_GetValueFromIndex;
    _Indexable.SetToIndex := HCmdQuery_Dictionary_SetValueToIndex;

    _MethodSupportable.CallMethod := HCmdQuery_Dictionary_CallMethod;

    _SimpleStringable.ToSimpleString := _ToStringSimpleObject;
    _SimpleStringable.ToSimpleType := _ToStringSimpleObject;

    _InterfacesTable.Indexable := @_Indexable;
    _InterfacesTable.MethodSupportable := @_MethodSupportable;
    _InterfacesTable.SimpleStringable := @_SimpleStringable;
    _InterfacesTable.RefCount := 1;

    inherited;
end;

destructor THCmdQueryDictionaryType.Destroy;
begin
    _InterfacesTable.Destroy;

    inherited Destroy;
end;

{ THCmdQueryDictionary }

class function THCmdQueryDictionary.CompareSafeVariants(constref A, B: SafeVariant): Integer;
begin
    Result := 1;
    if A = B then
        Result := 0;
end;

class function THCmdQueryDictionary.HashSafeVariant(constref A: SafeVariant): UInt32;
begin
    Result := A.GetHashCode;
end;

constructor THCmdQueryDictionary.Create;
begin
    inherited;

    Storage.Nullify(CompareSafeVariants, HashSafeVariant);
end;

destructor THCmdQueryDictionary.Destroy;
begin
    Storage.Destroy;

    inherited Destroy;
end;

end.

