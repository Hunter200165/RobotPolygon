unit RobotPolygon.InjectStandards;

{$mode Delphi}{$H+}

interface

uses
    Classes, SysUtils,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary,
    HCmdQuery.Kernel.InterpreterBase,
    HCmdQuery.RTL.Classes,
    HCmdQuery.RTL.ControlFlow,
    HCmdQuery.RTL.Format,
    HCmdQuery.RTL.Functions,
    HCmdQuery.RTL.Math,
    HCmdQuery.RTL.NativeObjects,
    HCmdQuery.RTL.Operators,
    HCmdQuery.RTL.StandardIO,
    HCmdQuery.RTL.Variables;

procedure InjectStandards(const AKernel: THCmdQueryInterpreterBase);

implementation

procedure HCmdQuery_True(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).EndExpectation(0);
    AResult^ := True;
end;

procedure HCmdQuery_False(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
begin
    PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).EndExpectation(0);
    AResult^ := False;
end;

procedure HCmdQuery_Const(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    AResult^ := CBF.ExpectValue(0, 'const[0]: Expected value to be returned');
end;

procedure InjectStandards(const AKernel: THCmdQueryInterpreterBase);
begin
    AKernel.RegisterGlobalFunction('local', HCmdQuery_Variables_CreateLocal);
    AKernel.RegisterGlobalFunction('field', HCmdQuery_Variables_CreateModuleField);
    AKernel.RegisterGlobalFunction('global-field', HCmdQuery_Variables_CreateModuleGlobalField);
    AKernel.RegisterGlobalFunction('global-var', HCmdQuery_Variables_CreateGlobalVariable);

    AKernel.RegisterGlobalFunction('global', HCmdQuery_Variables_HandleGlobal);

    AKernel.RegisterGlobalFunction('function', HCmdQuery_Functions_CreateLocalFunction);
    AKernel.RegisterGlobalFunction('method', HCmdQuery_Functions_CreateModuleFunction);
    AKernel.RegisterGlobalFunction('global-function', HCmdQuery_Functions_CreateGlobalFunction);

    AKernel.RegisterGlobalFunction('arg', HCmdQuery_Functions_Arg);
    AKernel.RegisterGlobalFunction('arg::ref', HCmdQuery_Functions_ArgRef);
    AKernel.RegisterGlobalFunction('arg::raw', HCmdQuery_Functions_ArgRaw);
    AKernel.RegisterGlobalFunction('arg::int', HCmdQuery_Functions_ArgInt);
    AKernel.RegisterGlobalFunction('arg::real', HCmdQuery_Functions_ArgNumber);
    AKernel.RegisterGlobalFunction('arg::string', HCmdQuery_Functions_ArgString);

    AKernel.RegisterGlobalFunction('defaultarg', HCmdQuery_Functions_DefaultArg);
    AKernel.RegisterGlobalFunction('defaultarg::int', HCmdQuery_Functions_DefaultArgInt);
    AKernel.RegisterGlobalFunction('defaultarg::real', HCmdQuery_Functions_DefaultArgNumber);
    AKernel.RegisterGlobalFunction('defaultarg::string', HCmdQuery_Functions_DefaultArgString);

    AKernel.RegisterGlobalFunction('endexp', HCmdQuery_Functions_EndExp);

    AKernel.RegisterGlobalFunction(':=', HCmdQuery_Variables_Assign);
    AKernel.RegisterGlobalFunction('+=', HCmdQuery_Variables_AssignAdd);
    AKernel.RegisterGlobalFunction('-=', HCmdQuery_Variables_AssignSub);
    AKernel.RegisterGlobalFunction('*=', HCmdQuery_Variables_AssignMultiply);
    AKernel.RegisterGlobalFunction('/=', HCmdQuery_Variables_AssignDivide);
    AKernel.RegisterGlobalFunction('//=', HCmdQuery_Variables_AssignIntDivide);
    AKernel.RegisterGlobalFunction('%=', HCmdQuery_Variables_AssignModulo);
    AKernel.RegisterGlobalFunction('&=', HCmdQuery_Variables_AssignBitwiseAnd);
    AKernel.RegisterGlobalFunction('|=', HCmdQuery_Variables_AssignBitwiseOr);
    AKernel.RegisterGlobalFunction('^=', HCmdQuery_Variables_AssignBitwiseXor);
    AKernel.RegisterGlobalFunction('>>=', HCmdQuery_Variables_AssignBitwiseShl);
    AKernel.RegisterGlobalFunction('<<=', HCmdQuery_Variables_AssignBitwiseShr);

    AKernel.RegisterGlobalFunction('true', HCmdQuery_True);
    AKernel.RegisterGlobalFunction('false', HCmdQuery_False);
    AKernel.RegisterGlobalFunction('const', HCmdQuery_Const);

    AKernel.RegisterGlobalFunction('if', HCmdQuery_ControlFlow_If);
    AKernel.RegisterGlobalFunction('while', HCmdQuery_ControlFlow_While);
    AKernel.RegisterGlobalFunction('for-sequential', HCmdQuery_ControlFlow_ForSequential);
    AKernel.RegisterGlobalFunction('for', HCmdQuery_ControlFlow_For);

    AKernel.RegisterGlobalFunction('break', HCmdQuery_ControlFlow_Break);
    AKernel.RegisterGlobalFunction('continue', HCmdQuery_ControlFlow_Continue);
    AKernel.RegisterGlobalFunction('return', HCmdQuery_ControlFlow_Return);

    AKernel.RegisterGlobalFunction('+', HCmdQuery_Operators_Add);
    AKernel.RegisterGlobalFunction('-', HCmdQuery_Operators_Minus);
    AKernel.RegisterGlobalFunction('negate', HCmdQuery_Operators_Negate);
    AKernel.RegisterGlobalFunction('subtract', HCmdQuery_Operators_Subtract);
    AKernel.RegisterGlobalFunction('*', HCmdQuery_Operators_Multiply);
    AKernel.RegisterGlobalFunction('/', HCmdQuery_Operators_Divide);
    AKernel.RegisterGlobalFunction('div', HCmdQuery_Operators_IntDivide);
    AKernel.RegisterGlobalFunction('mod', HCmdQuery_Operators_Modulo);

    AKernel.RegisterGlobalFunction('not', HCmdQuery_Operators_LogicalNot);
    AKernel.RegisterGlobalFunction('and', HCmdQuery_Operators_LogicalAnd);
    AKernel.RegisterGlobalFunction('or', HCmdQuery_Operators_LogicalOr);

    AKernel.RegisterGlobalFunction('~', HCmdQuery_Operators_BinaryNot);
    AKernel.RegisterGlobalFunction('&', HCmdQuery_Operators_BinaryAnd);
    AKernel.RegisterGlobalFunction('|', HCmdQuery_Operators_BinaryOr);
    AKernel.RegisterGlobalFunction('<<', HCmdQuery_Operators_BinaryShl);
    AKernel.RegisterGlobalFunction('>>', HCmdQuery_Operators_BinaryShr);

    AKernel.RegisterGlobalFunction('==', HCmdQuery_Operators_Equals);
    AKernel.RegisterGlobalFunction('!=', HCmdQuery_Operators_NotEquals);
    AKernel.RegisterGlobalFunction('<', HCmdQuery_Operators_Less);
    AKernel.RegisterGlobalFunction('<=', HCmdQuery_Operators_LessEquals);
    AKernel.RegisterGlobalFunction('>', HCmdQuery_Operators_Greater);
    AKernel.RegisterGlobalFunction('>=', HCmdQuery_Operators_GreaterEquals);

    AKernel.RegisterGlobalFunction('math::pi', HCmdQuery_Math_Pi);
    AKernel.RegisterGlobalFunction('math::abs', HCmdQuery_Math_Abs);
    AKernel.RegisterGlobalFunction('math::round', HCmdQuery_Math_Round);
    AKernel.RegisterGlobalFunction('math::floor', HCmdQuery_Math_Floor);
    AKernel.RegisterGlobalFunction('math::ceil', HCmdQuery_Math_Ceil);
    AKernel.RegisterGlobalFunction('math::frac', HCmdQuery_Math_Frac);
    AKernel.RegisterGlobalFunction('math::trunc', HCmdQuery_Math_Trunc);
    AKernel.RegisterGlobalFunction('math::int', HCmdQuery_Math_Int);
    AKernel.RegisterGlobalFunction('math::exp', HCmdQuery_Math_Exp);
    AKernel.RegisterGlobalFunction('math::ln', HCmdQuery_Math_Ln);
    AKernel.RegisterGlobalFunction('math::sqrt', HCmdQuery_Math_Sqrt);
    AKernel.RegisterGlobalFunction('math::sqr', HCmdQuery_Math_Sqr);
    AKernel.RegisterGlobalFunction('math::sin', HCmdQuery_Math_Sin);
    AKernel.RegisterGlobalFunction('math::cos', HCmdQuery_Math_Cos);
    AKernel.RegisterGlobalFunction('math::tan', HCmdQuery_Math_Tan);
    AKernel.RegisterGlobalFunction('math::cotan', HCmdQuery_Math_Cotan);
    AKernel.RegisterGlobalFunction('math::arcsin', HCmdQuery_Math_ArcSin);
    AKernel.RegisterGlobalFunction('math::arccos', HCmdQuery_Math_ArcCos);
    AKernel.RegisterGlobalFunction('math::arctan', HCmdQuery_Math_ArcTan);
    AKernel.RegisterGlobalFunction('math::arccot', HCmdQuery_Math_ArcCotan);
    AKernel.RegisterGlobalFunction('math::randomize', HCmdQuery_Math_Randomize);
    AKernel.RegisterGlobalFunction('math::randint', HCmdQuery_Math_RandomInteger);
    AKernel.RegisterGlobalFunction('math::randfloat', HCmdQuery_Math_RandomFloat);

    AKernel.RegisterGlobalFunction('sprintf', HCmdQuery_Format_Sprintf);

    AKernel.RegisterTypeVariable('ArrayType', THCmdQueryArrayType.Create, THCmdQueryArrayType.TypeID);
    AKernel.RegisterTypeVariable('DictionaryType', THCmdQueryDictionaryType.Create, THCmdQueryDictionaryType.TypeID);
    AKernel.RegisterGlobalFunction('array::create', HCmdQuery_NativeObjects_ArrayCreate);
    AKernel.RegisterGlobalFunction('dictionary::create', HCmdQuery_NativeObjects_DictionaryCreate);

    AKernel.RegisterGlobalFunction('class', HCmdQuery_Classes_Class);
    AKernel.RegisterGlobalFunction('public', HCmdQuery_Classes_Public);
    AKernel.RegisterGlobalFunction('protected', HCmdQuery_Classes_Protected);
    AKernel.RegisterGlobalFunction('private', HCmdQuery_Classes_Private);
    AKernel.RegisterGlobalFunction('inherited', HCmdQuery_Classes_Inherited);

    AKernel.RegisterGlobalFunction('write', HCmdQuery_StandardIO_Write);
    AKernel.RegisterGlobalFunction('print', HCmdQuery_StandardIO_Print);
    AKernel.RegisterGlobalFunction('printf', HCmdQuery_StandardIO_PrintF);
end;

end.

