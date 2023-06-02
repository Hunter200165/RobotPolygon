unit HCmdQuery.Kernel.Types;

{$I HCmdQuery.inc}

interface

uses
    SysUtils,
    HCL.Core.Types,
    HCL.Core.Unused,
    HCL.Core.GenericList,
    HCmdQuery.Types,
    HCmdQuery.SafeVariant;

//type
//    THCmdQueryVariableLocation = (
//        // Local variables are always linked against their position on the stack and usually are fastest to access
//        Local,
//        // Module local variables are variables that are laying in the root of the module itself
//        ModuleLocal,
//        ModuleGlobal,
//        Global,
//        NonDeterministic
//    );

type
    THCmdQueryControlFlowFlag = (
        None,
        Break,
        Continue,
        Return
    );

    THCmdQueryNodeType = (
        Integer,
        Double,
        Variable,
        UnicodeString,
        Evaluated,
        Body,
        Indexing,
        MethodCall
    );

    THCmdQueryScopeLocation = (
        NotKnown,
        Local,
        ModuleLocal,
        ModuleGlobal,
        Global
    );

type
    THCmdQueryVariable = record
        Name: UnicodeString;
        Value: SafeVariant;
    end;
    PHCmdQueryVariable = ^THCmdQueryVariable;

    THCmdQueryFunction = record
        Name: UnicodeString;
        Value: SafeVariant;
    end;
    PHCmdQueryFunction = ^THCmdQueryFunction;

    THCmdQueryParameter = packed record
        Name: SafeVariant;
        Value: SafeVariant;
    end;
    PHCmdQueryParameter = ^THCmdQueryParameter;

type
    THCmdQueryLocalStack = HList<THCmdQueryVariable>;
    THCmdQueryArgumentStack = HList<SafeVariant>;
    THCmdQueryParameterStack = HList<THCmdQueryParameter>;

    THCmdQueryFunctions = HList<THCmdQueryFunction>;

type
    THCmdQueryExceptionStackFrame = packed record
    public
        Message: UnicodeString;
        Position: THCmdQueryPosition;
    end;

type

    { EHCmdQueryException }

    EHCmdQueryException = class(Exception)
    protected var
        FMessageUnicode: UnicodeString;
    protected
        procedure SetMessage(const ANewValue: UnicodeString);
    public
        property Message: UnicodeString read FMessageUnicode write SetMessage;
    public
        constructor Create(const AMsg: UnicodeString); reintroduce; overload;
        constructor Create(const AFmt: UnicodeString; const AArgs: array of const); overload;
    end;

    { EHCmdQueryCompilationException }

    EHCmdQueryCompilationException = class(EHCmdQueryException)
    public var
        FPosition: THCmdQueryPosition;
    public
        constructor Create(const AMessage: UnicodeString; const APosition: THCmdQueryPosition); overload;
        constructor Create(const AFmt: UnicodeString; const AArgs: array of const; const APosition: THCmdQueryPosition); overload;
    end;

    { EHCmdQueryRuntimeException }

    EHCmdQueryRuntimeException = class(EHCmdQueryException)
    public var
        Position: THCmdQueryPosition;
        StackTrace: HList<THCmdQueryExceptionStackFrame>;
    public
        function DumpToString: UnicodeString;
    public
        procedure AppendStackTrace(const AMessage: UnicodeString; const APosition: THCmdQueryPosition); overload;
        procedure AppendStackTrace(const AFmt: UnicodeString; const AArgs: array of const; const APosition: THCmdQueryPosition); overload;
    public
        constructor Create(const AMessage: UnicodeString; const APosition: THCmdQueryPosition); overload;
        constructor Create(const AFmt: UnicodeString; const AArgs: array of const; const APosition: THCmdQueryPosition); overload;
    end;

type
    EHCmdQueryInternalException = class(EHCmdQueryRuntimeException);
    EHCmdQueryArgumentException = class(EHCmdQueryRuntimeException);
    EHCmdQueryParameterException = class(EHCmdQueryRuntimeException);
    EHCmdQueryNoSuchFunctionException = class(EHCmdQueryRuntimeException);
    EHCmdQueryNoSuchVariableException = class(EHCmdQueryRuntimeException);

    EHCmdQueryNoSuchOperatorOverload = class(EHCmdQueryRuntimeException);

    EHCmdQueryNotAnObject = class(EHCmdQueryRuntimeException);
    EHCmdQueryObjectDoesNotSupportInterfaces = class(EHCmdQueryRuntimeException);
    EHCmdQueryObjectDoesNotSupportInterface = class(EHCmdQueryRuntimeException);

    EHCmdQueryArgumentOutOfBounds = class(EHCmdQueryArgumentException);
    EHCmdQueryParameterOutOfBounds = class(EHCmdQueryParameterException);

    EHCmdQueryTypeVariableCorrupted = class(EHCmdQueryRuntimeException);
    EHCmdQueryNoSuchOverload = class(EHCmdQueryRuntimeException);

type
    (* THCmdQueryObject
    *)
    THCmdQueryObject = class(THCLObjectBase)
    private
        procedure _CreateObjectInitialHandler(const AObject: PSafeObject); cdecl;
        procedure _DisposeObjectInitialHandler(const AObject: PSafeObject); cdecl;
    protected var
        { IHCmdQueryCreatable interface support }
        FCreateProc: THCmdQueryCreatableCreateProcedure;
        FDisposeProc: THCmdQueryCreatableDisposeProcedure;
    protected var
        FRefCount: Integer;
        FLock: Integer;
    protected
        procedure _CreateObject(const AObject: PSafeObject); virtual;
        procedure _DisposeObject(const AObject: PSafeObject); virtual;
    public
        function _GetRefCount: PInteger; override;
        function _GetLock: PInteger; override;
    public
        constructor Create;
    end;

function HCmdQueryProcessException(const E: Exception; const AMessage: UnicodeString; const APosition: THCmdQueryPosition): EHCmdQueryRuntimeException;

implementation

function HCmdQueryProcessException(const E: Exception; const AMessage: UnicodeString; const APosition: THCmdQueryPosition): EHCmdQueryRuntimeException;
begin
    if E is EHCmdQueryRuntimeException then begin
        // AcquireExceptionObject;
        Result := EHCmdQueryRuntimeException(E);
        Result.AppendStackTrace(AMessage, APosition);
    end
    else begin
        Result := EHCmdQueryInternalException.Create('Internal exception: `%s`, class: `%s` (%s)', [ E.Message, E.ClassName, AMessage ], APosition);
        // E.Free;
    end;
end;

{ EHCmdQueryException }

procedure EHCmdQueryException.SetMessage(const ANewValue: UnicodeString);
begin
    FMessageUnicode := ANewValue;
    inherited Message := AnsiString(ANewValue);
end;

constructor EHCmdQueryException.Create(const AMsg: UnicodeString);
begin
    FMessageUnicode := AMsg;
    inherited Message := AnsiString(AMsg);
end;

constructor EHCmdQueryException.Create(const AFmt: UnicodeString; const AArgs: array of const);
begin
    Create(UnicodeFormat(AFmt, AArgs));
end;

{ EHCmdQueryCompilationException }

constructor EHCmdQueryCompilationException.Create(const AMessage: UnicodeString; const APosition: THCmdQueryPosition);
begin
    inherited Create(AMessage);
    FPosition := APosition;
end;

constructor EHCmdQueryCompilationException.Create(const AFmt: UnicodeString; const AArgs: array of const; const APosition: THCmdQueryPosition);
begin
    inherited Create(AFmt, AArgs);
    FPosition := APosition;
end;

{ EHCmdQueryRuntimeException }

function EHCmdQueryRuntimeException.DumpToString: UnicodeString;
var Frame: THCmdQueryExceptionStackFrame;
begin
    Result := Position.ToString + ': ' + FMessageUnicode;

    for Frame in StackTrace do begin
        Result := Result + #13#10#9 + Frame.Message + ' at ' + Frame.Position.ToString;
    end;
end;

procedure EHCmdQueryRuntimeException.AppendStackTrace(const AMessage: UnicodeString; const APosition: THCmdQueryPosition);
begin
    with StackTrace.AddReferenced^ do begin
        Message := AMessage;
        Position := APosition;
    end;
end;

procedure EHCmdQueryRuntimeException.AppendStackTrace(const AFmt: UnicodeString; const AArgs: array of const; const APosition: THCmdQueryPosition);
begin
    AppendStackTrace(UnicodeFormat(AFmt, AArgs), APosition);
end;

constructor EHCmdQueryRuntimeException.Create(const AMessage: UnicodeString; const APosition: THCmdQueryPosition);
begin
    Message := AMessage;
    Position := APosition;
end;

constructor EHCmdQueryRuntimeException.Create(const AFmt: UnicodeString; const AArgs: array of const; const APosition: THCmdQueryPosition);
begin
    Create(UnicodeFormat(AFmt, AArgs), APosition);
end;

{ THCmdQueryObject }

procedure THCmdQueryObject._CreateObjectInitialHandler(const AObject: PSafeObject); cdecl;
begin
    _CreateObject(AObject);
end;

procedure THCmdQueryObject._DisposeObjectInitialHandler(const AObject: PSafeObject); cdecl;
begin
    _DisposeObject(AObject);
end;

procedure THCmdQueryObject._CreateObject(const AObject: PSafeObject);
begin
    { Nothing to do }
    Unused<Pointer>(AObject);
end;

procedure THCmdQueryObject._DisposeObject(const AObject: PSafeObject);
begin
    Unused<Pointer>(AObject);

    //WriteLn('[hcmdobj]: Disposing ', ClassName);
    Free;
end;

function THCmdQueryObject._GetRefCount: PInteger;
begin
    Result := @FRefCount;
end;

function THCmdQueryObject._GetLock: PInteger;
begin
    Result := @FLock;
end;

constructor THCmdQueryObject.Create;
begin
    FRefCount := 1;

    FCreateProc := _CreateObjectInitialHandler;
    FDisposeProc := _DisposeObjectInitialHandler;
end;

end.

