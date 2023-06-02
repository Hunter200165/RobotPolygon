unit HCmdQuery.Kernel.ResourceManager;

{$I HCmdQuery.inc}

{#! [1] IHCmdQueryCreatable is the only interface that is represented by contained object's field layout, however information given in SafeVariant unit about
    this interface states, that object might either have a reference to a function to call or nil, if the function is not to call. Therefore it is needed to
    check value of given fields for equality towards zero to make sure it will not be an access violation.
}

interface

uses
    HCL.Core.GenericList,
    HCL.Core.HeapSort,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.Types;

type
    THCmdQueryIntegerList = HList<Integer>;

type

    (* THCmdQueryCachedList
    *)
    THCmdQueryCachedList<T> = record
    public
        LastObjectTimestamp: Int64;
        IndexCache: THCmdQueryIntegerList;
        Storage: HList<T>;
    public
        function Allocate: Integer;
        procedure Deallocate(const AIndex: Integer);
    public
        procedure Nullify;
    end;

type

    { THCmdQueryResourceManager }

    THCmdQueryResourceManager = class(THCmdQueryObject)
    public
        StringStorage: THCmdQueryCachedList<PSafeString>;
        ObjectStorage: THCmdQueryCachedList<PSafeObject>;
    public
        { String routines }
        function AllocateString(const AValue: UnicodeString): PSafeString;
        procedure DeallocateString(const AStr: PSafeString);
    public
        { Object routines }
        function AllocateObject(const AValue: Pointer; const ATypeID: UInt64): PSafeObject;
        procedure DeallocateObject(const AObject: PSafeObject);
    public
        constructor Create;
        destructor Destroy; override;
    end;

implementation

{ THCmdQueryCachedList }

function THCmdQueryCachedList<T>.Allocate: Integer;
begin
    if IndexCache.Count > 0 then begin
        Result := IndexCache.Items[IndexCache.Count - 1];
        IndexCache.Remove;
    end
    else begin
        Result := Storage.Count;
        New(Storage.AddReferenced^);
    end;

    Inc(LastObjectTimestamp);
end;

procedure THCmdQueryCachedList<T>.Deallocate(const AIndex: Integer);
begin
    IndexCache.Add(AIndex);
end;

procedure THCmdQueryCachedList<T>.Nullify;
begin
    IndexCache.Nullify;
    //TimeStampStorage.Nullify;
    Storage.Nullify;

    LastObjectTimestamp := 0;
end;

{ THCmdQueryResourceManager }

function THCmdQueryResourceManager.AllocateString(const AValue: UnicodeString): PSafeString;
var Address: Integer;
begin
    Address := StringStorage.Allocate;
    Result := StringStorage.Storage.Items[Address];

    //writeLn('[string]: alloc #', Address);

    Result.ResourceManager := Self;
    Result.Address := Address;
    Result.RefCount := 1;
    Result.Value := AValue;
end;

procedure THCmdQueryResourceManager.DeallocateString(const AStr: PSafeString);
begin
    //StringStorage.Storage.Items[AStr.Address];
    //WriteLn('string deallocated, ', AStr.Address);

    AStr.Value := '';
    StringStorage.Deallocate(AStr.Address);
end;

function THCmdQueryResourceManager.AllocateObject(const AValue: Pointer; const ATypeID: UInt64): PSafeObject;
//type
//    PHCmdQueryCreatableCreateProcedure = ^THCmdQueryCreatableCreateProcedure;
var Address: Integer;
begin
    Address := ObjectStorage.Allocate;
    Result := ObjectStorage.Storage.Items[Address];

    //WriteLn('[object]: alloc #', Address);

    Result^ := Default(SafeObject);
    Result.ResourceManager := Self;
    Result.Address := Address;
    Result.RefCount := 1;
    Result.Timestamp := ObjectStorage.LastObjectTimestamp;
    Result.Value := AValue;
    Result.TypeID := ATypeID;

    {#! [1] }
    THCmdQueryCreatableCreateProcedure((AValue + HCmdQuery_CreatableInterface_Offset)^)(Result);
end;

procedure THCmdQueryResourceManager.DeallocateObject(const AObject: PSafeObject);
begin
    {#! [1] }
    //WriteLn('[object]');
    if AObject.RefCount < 0 then
        raise EHCmdQueryException.Create('Something bad happened');
    AObject.RefCount := 0;
    if Assigned(THCmdQueryCreatableDisposeProcedure((Pointer(AObject.Value) + SizeOf(THCmdQueryCreatableCreateProcedure) + HCmdQuery_CreatableInterface_Offset)^)) then
        THCmdQueryCreatableDisposeProcedure((Pointer(AObject.Value) + SizeOf(THCmdQueryCreatableCreateProcedure) + HCmdQuery_CreatableInterface_Offset)^)(AObject);
    ObjectStorage.Deallocate(AObject.Address);
end;

constructor THCmdQueryResourceManager.Create;
begin
    inherited;

    StringStorage.Nullify;
    ObjectStorage.Nullify;
end;

function ObjectStorageComparer(const A, B: PSafeObject): Integer;
var TA, TB: Int64;
begin
    TA := A.Timestamp;
    TB := B.Timestamp;

    if TA < TB then
        Result := -1
    else if TA > TB then
        Result := 1
    else
        Result := 0;
end;

destructor THCmdQueryResourceManager.Destroy;
var i: Integer;
begin
    for i := 0 to ObjectStorage.Storage.Count - 1 do begin
        if (ObjectStorage.Storage.Items[i].RefCount >= 1) and Assigned(ObjectStorage.Storage.Items[i].Interfaces) and Assigned(ObjectStorage.Storage.Items[i].Interfaces.Nullable) then begin
            ObjectStorage.Storage.Items[i].Interfaces.Nullable.Nullify(ObjectStorage.Storage.Items[i]);
        end;
    end;

    //WriteLn('[hcmd::rm] Clearing object heap');

    ObjectStorage.Storage.Sort(ObjectStorageComparer);

    for i := 0 to ObjectStorage.Storage.Count - 1 do
        ObjectStorage.Storage.Items[i].Address := i;

    for i := 0 to ObjectStorage.Storage.Count - 1 do begin
        if (i > 0) and (ObjectStorage.Storage.Items[i].RefCount >= 1) then begin
            DeallocateObject(ObjectStorage.Storage.Items[i]);
        end;

        ObjectStorage.Storage.Items[i].Destroy;
        Dispose(ObjectStorage.Storage.Items[i]);
        ObjectStorage.Storage.Items[i] := nil;
    end;

    for i := 0 to StringStorage.Storage.Count - 1 do
        Dispose(StringStorage.Storage.Items[i]);


    inherited Destroy;
end;

end.

