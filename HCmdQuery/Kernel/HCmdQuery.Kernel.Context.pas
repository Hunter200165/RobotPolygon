unit HCmdQuery.Kernel.Context;

{$I HCmdQuery.inc}

interface

uses
    HCL.Core.GenericList,
    HCL.Core.Unused,
    HCmdQuery.SafeVariant,
    // HCmdQuery.Interfaces,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.InterpreterBase;

type

    (* THCmdQueryContext
    *)
    THCmdQueryContext = class(THCmdQueryObject)
    public const
        TypeID = 1683914277235;
    private var
        _Nullable: IHCmdQueryNullable;
        FInterpreter: THCmdQueryInterpreterBase;
    public var
        ModuleLocalVariables: THCmdQueryLocalStack;
        ModuleGlobalVariables: THCmdQueryLocalStack;
    public
        ModuleFunctions: THCmdQueryFunctions;
        LocalFunctions: THCmdQueryFunctions;
        //GlobalFunctions: THCmdQueryFunctions;
    public
        property Interpreter: THCmdQueryInterpreterBase read FInterpreter;
    public
        procedure _CreateObject(const AObject: PSafeObject); override;
        procedure _Nullify(const ASelf: PSafeObject); cdecl;
    public
        function FindModuleLocalVariable(const AName: UnicodeString): Integer; cdecl;
        function FindModuleGlobalVariable(const AName: UnicodeString): Integer; cdecl;
    public
        function FindLocalFunction(const AName: UnicodeString): Integer; cdecl;
        function FindModuleFunction(const AName: UnicodeString): Integer; cdecl;
    public
        procedure Clear;
    public
        constructor Create;
    end;

implementation

{ THCmdQueryContext }

procedure THCmdQueryContext._CreateObject(const AObject: PSafeObject);
begin
    //AObject.Contextable.FindVariable := FindVariable;

    AObject.AllocateStandaloneInterfacesTable;
    AObject.Interfaces.Nullable := @_Nullable;

    _Nullable.Nullify := _Nullify;
end;

procedure THCmdQueryContext._Nullify(const ASelf: PSafeObject); cdecl;
begin
    // Unused<Pointer>(ASelf);

    ASelf.AddRef;
    try
        //WriteLn('Clearing module...');
        Clear;
    finally
        ASelf.ReleaseRef;
    end;
end;

function THCmdQueryContext.FindModuleLocalVariable(const AName: UnicodeString): Integer; cdecl;
var i: Integer;
begin
    Result := -1;

    for i := ModuleLocalVariables.Count - 1 downto 0 do
        if ModuleLocalVariables.Items[i].Name = AName then begin
            Result := i;
            Break;
        end;
end;

function THCmdQueryContext.FindModuleGlobalVariable(const AName: UnicodeString): Integer; cdecl;
var i: Integer;
begin
    Result := -1;

    for i := ModuleGlobalVariables.Count - 1 downto 0 do
        if ModuleGlobalVariables.Items[i].Name = AName then begin
            Result := i;
            Break;
        end;
end;

function THCmdQueryContext.FindLocalFunction(const AName: UnicodeString): Integer; cdecl;
var i: Integer;
begin
    Result := -1;

    for i := LocalFunctions.Count - 1 downto 0 do
        if LocalFunctions.Items[i].Name = AName then begin
            Result := i;
            Break;
        end;
end;

function THCmdQueryContext.FindModuleFunction(const AName: UnicodeString): Integer; cdecl;
var i: Integer;
begin
    Result := -1;

    for i := ModuleFunctions.Count - 1 downto 0 do
        if ModuleFunctions.Items[i].Name = AName then begin
            Result := i;
            Break;
        end;
end;

procedure THCmdQueryContext.Clear;
var i: Integer;
begin
    for i := 0 to LocalFunctions.Count - 1 do
        LocalFunctions.Items[i].Value := None;

    for i := 0 to ModuleFunctions.Count - 1 do
        ModuleFunctions.Items[i].Value := None;

    for i := 0 to ModuleLocalVariables.Count - 1 do
        ModuleLocalVariables.Items[i].Value := None;

    for i := 0 to ModuleGlobalVariables.Count - 1 do
        ModuleGlobalVariables.Items[i].Value := None;

    LocalFunctions.Clear;
    ModuleFunctions.Clear;
    ModuleLocalVariables.Clear;
    ModuleGlobalVariables.Clear;
end;

constructor THCmdQueryContext.Create;
begin
    inherited Create;

    ModuleLocalVariables.Nullify;
    ModuleGlobalVariables.Nullify;
    //CallDepth := 0;
end;

end.

