unit HCmdQuery.SafeVariant.Operators;

{$I HCmdQuery.inc}

interface

uses
    Math,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.CallBoundary,
    HCmdQuery.SafeVariant.Operators.Overload;

type
    THCmdQuerySafeVariantOperator = procedure (const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);

procedure HCmdQuery_SafeVariant_Negate(const AInterpreter: PSafeObject; const AOperand: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_BinaryNot(const AInterpreter: PSafeObject; const AOperand: PSafeVariant; const AResult: PSafeVariant);

procedure HCmdQuery_SafeVariant_Add(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_Subtract(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_Multiply(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_Divide(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_IntDivide(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_Modulo(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);

procedure HCmdQuery_SafeVariant_BinaryAnd(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_BinaryOr(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_BinaryXor(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_BinaryShl(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_BinaryShr(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);

procedure HCmdQuery_SafeVariant_Equals(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_NotEquals(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_Less(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_LessEquals(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_Greater(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
procedure HCmdQuery_SafeVariant_GreaterEquals(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);

implementation

{$OverflowChecks-}
{$RangeChecks-}

procedure HCmdQuery_SafeVariant_Negate(const AInterpreter: PSafeObject; const AOperand: PSafeVariant; const AResult: PSafeVariant);
begin
    case AOperand.VarType of
        HCmdQueryVarType.Int64 : AResult^ := -AOperand.AsInteger;
        HCmdQueryVarType.Double: AResult^ := -AOperand.AsDouble;
    else
        if not HCmdQuery_Operators_CallUnaryOverload(AInterpreter, HCmdQueryUnaryOperatorInterfaceOffset.Negate, AOperand, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '-[]: Operator is not overloaded for type `%s`',
                [ AOperand.GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_BinaryNot(const AInterpreter: PSafeObject; const AOperand: PSafeVariant; const AResult: PSafeVariant);
begin
    case AOperand.VarType of
        HCmdQueryVarType.Int64: AResult^ := not AOperand.AsInteger;
    else
        if not HCmdQuery_Operators_CallUnaryOverload(AInterpreter, HCmdQueryUnaryOperatorInterfaceOffset.BinaryNot, AOperand, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '~[]: Operator is not overloaded for type `%s`',
                [ AOperand.GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_Add(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt      : AResult^ := AOperands[0].AsInteger + AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble   : AResult^ := AOperands[0].AsInteger + AOperands[1].AsDouble;
        HCmdQuery_TypePair_DoubleInt   : AResult^ := AOperands[0].AsDouble + AOperands[1].AsInteger;
        HCmdQuery_TypePair_DoubleDouble: AResult^ := AOperands[0].AsDouble + AOperands[1].AsDouble;
        HCmdQuery_TypePair_StringString: AResult^ := AInterpreter.Interfaces.Interpreter.AllocateString(AOperands[0].AsString.Value + AOperands[1].AsString.Value);
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.Add, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '+[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_Subtract(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt      : AResult^ := AOperands[0].AsInteger - AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble   : AResult^ := AOperands[0].AsInteger - AOperands[1].AsDouble;
        HCmdQuery_TypePair_DoubleInt   : AResult^ := AOperands[0].AsDouble - AOperands[1].AsInteger;
        HCmdQuery_TypePair_DoubleDouble: AResult^ := AOperands[0].AsDouble - AOperands[1].AsDouble;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.Subtract, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '-[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_Multiply(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt      : AResult^ := AOperands[0].AsInteger * AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble   : AResult^ := AOperands[0].AsInteger * AOperands[1].AsDouble;
        HCmdQuery_TypePair_DoubleInt   : AResult^ := AOperands[0].AsDouble * AOperands[1].AsInteger;
        HCmdQuery_TypePair_DoubleDouble: AResult^ := AOperands[0].AsDouble * AOperands[1].AsDouble;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.Multiply, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '*[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_Divide(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt      : AResult^ := AOperands[0].AsInteger / AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble   : AResult^ := AOperands[0].AsInteger / AOperands[1].AsDouble;
        HCmdQuery_TypePair_DoubleInt   : AResult^ := AOperands[0].AsDouble / AOperands[1].AsInteger;
        HCmdQuery_TypePair_DoubleDouble: AResult^ := AOperands[0].AsDouble / AOperands[1].AsDouble;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.Divide, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '/[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_IntDivide(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt: AResult^ := AOperands[0].AsInteger div AOperands[1].AsInteger;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.IntDivide, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                'div[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_Modulo(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt      : AResult^ := AOperands[0].AsInteger mod AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble   : AResult^ := FMod(AOperands[0].AsInteger, AOperands[1].AsDouble);
        HCmdQuery_TypePair_DoubleInt   : AResult^ := FMod(AOperands[0].AsDouble, AOperands[1].AsInteger);
        HCmdQuery_TypePair_DoubleDouble: AResult^ := FMod(AOperands[0].AsDouble, AOperands[1].AsDouble);
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.Modulo, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                'mod[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_BinaryAnd(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt: AResult^ := AOperands[0].AsInteger and AOperands[1].AsInteger;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.BinaryAnd, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '&[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_BinaryOr(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt: AResult^ := AOperands[0].AsInteger or AOperands[1].AsInteger;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.BinaryOr, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '|[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_BinaryXor(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt: AResult^ := AOperands[0].AsInteger xor AOperands[1].AsInteger;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.BinaryXor, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '^[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_BinaryShl(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt: AResult^ := AOperands[0].AsInteger shl AOperands[1].AsInteger;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.BinaryShl, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '<<[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_BinaryShr(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt: AResult^ := AOperands[0].AsInteger shr AOperands[1].AsInteger;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.BinaryShr, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '>>[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_Equals(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_NoneNone      : AResult^ := True;
        HCmdQuery_TypePair_NullNull      : AResult^ := True;
        HCmdQuery_TypePair_IntInt        : AResult^ := AOperands[0].AsInteger = AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble     : AResult^ := AOperands[0].AsInteger = AOperands[1].AsDouble;
        HCmdQuery_TypePair_DoubleInt     : AResult^ := AOperands[0].AsDouble = AOperands[1].AsInteger;
        HCmdQuery_TypePair_DoubleDouble  : AResult^ := AOperands[0].AsDouble = AOperands[1].AsDouble;
        HCmdQuery_TypePair_BooleanBoolean: AResult^ := AOperands[0].AsBoolean = AOperands[1].AsBoolean;
        HCmdQuery_TypePair_StringString  : AResult^ := AOperands[0].AsString.Value = AOperands[1].AsString.Value;
        HCmdQuery_TypePair_SkipSkip      : AResult^ := True;
        HCmdQuery_TypePair_NativeNative  : AResult^ := @AOperands[0].AsNativeFunction = @AOperands[1].AsNativeFunction;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.Equals, AOperands, AResult) then
            AResult^ := (AOperands[0].VarType = AOperands[1].VarType) and (AOperands[0].AsInteger = AOperands[1].AsInteger);
    end;
end;

procedure HCmdQuery_SafeVariant_NotEquals(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_NoneNone      : AResult^ := False;
        HCmdQuery_TypePair_NullNull      : AResult^ := False;
        HCmdQuery_TypePair_IntInt        : AResult^ := not (AOperands[0].AsInteger = AOperands[1].AsInteger);
        HCmdQuery_TypePair_IntDouble     : AResult^ := not (AOperands[0].AsInteger = AOperands[1].AsDouble);
        HCmdQuery_TypePair_DoubleInt     : AResult^ := not (AOperands[0].AsDouble = AOperands[1].AsInteger);
        HCmdQuery_TypePair_DoubleDouble  : AResult^ := not (AOperands[0].AsDouble = AOperands[1].AsDouble);
        HCmdQuery_TypePair_BooleanBoolean: AResult^ := not (AOperands[0].AsBoolean = AOperands[1].AsBoolean);
        HCmdQuery_TypePair_StringString  : AResult^ := not (AOperands[0].AsString.Value = AOperands[1].AsString.Value);
        HCmdQuery_TypePair_SkipSkip      : AResult^ := False;
        HCmdQuery_TypePair_NativeNative  : AResult^ := not (@AOperands[0].AsNativeFunction = @AOperands[1].AsNativeFunction);
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.NotEquals, AOperands, AResult) then
            AResult^ := (AOperands[0].VarType = AOperands[1].VarType) and (AOperands[0].AsInteger = AOperands[1].AsInteger);
    end;
end;

procedure HCmdQuery_SafeVariant_Less(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt        : AResult^ := AOperands[0].AsInteger < AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble     : AResult^ := AOperands[0].AsInteger < AOperands[1].AsDouble;
        HCmdQuery_TypePair_DoubleInt     : AResult^ := AOperands[0].AsDouble < AOperands[1].AsInteger;
        HCmdQuery_TypePair_DoubleDouble  : AResult^ := AOperands[0].AsDouble < AOperands[1].AsDouble;
        HCmdQuery_TypePair_BooleanBoolean: AResult^ := AOperands[0].AsBoolean < AOperands[1].AsBoolean;
        HCmdQuery_TypePair_StringString  : AResult^ := AOperands[0].AsString.Value < AOperands[1].AsString.Value;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.Less, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '<[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_LessEquals(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt        : AResult^ := AOperands[0].AsInteger <= AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble     : AResult^ := AOperands[0].AsInteger <= AOperands[1].AsDouble;
        HCmdQuery_TypePair_DoubleInt     : AResult^ := AOperands[0].AsDouble <= AOperands[1].AsInteger;
        HCmdQuery_TypePair_DoubleDouble  : AResult^ := AOperands[0].AsDouble <= AOperands[1].AsDouble;
        HCmdQuery_TypePair_BooleanBoolean: AResult^ := AOperands[0].AsBoolean <= AOperands[1].AsBoolean;
        HCmdQuery_TypePair_StringString  : AResult^ := AOperands[0].AsString.Value <= AOperands[1].AsString.Value;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.LessEquals, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '<=[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_Greater(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt        : AResult^ := AOperands[0].AsInteger > AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble     : AResult^ := AOperands[0].AsInteger > AOperands[1].AsDouble;
        HCmdQuery_TypePair_DoubleInt     : AResult^ := AOperands[0].AsDouble > AOperands[1].AsInteger;
        HCmdQuery_TypePair_DoubleDouble  : AResult^ := AOperands[0].AsDouble > AOperands[1].AsDouble;
        HCmdQuery_TypePair_BooleanBoolean: AResult^ := AOperands[0].AsBoolean > AOperands[1].AsBoolean;
        HCmdQuery_TypePair_StringString  : AResult^ := AOperands[0].AsString.Value > AOperands[1].AsString.Value;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.Greater, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '>[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

procedure HCmdQuery_SafeVariant_GreaterEquals(const AInterpreter: PSafeObject; const AOperands: PSafeVariant; const AResult: PSafeVariant);
begin
    case HCmdQuery_EncodeTypePair(AOperands[0].VarType, AOperands[1].VarType) of
        HCmdQuery_TypePair_IntInt        : AResult^ := AOperands[0].AsInteger >= AOperands[1].AsInteger;
        HCmdQuery_TypePair_IntDouble     : AResult^ := AOperands[0].AsInteger >= AOperands[1].AsDouble;
        HCmdQuery_TypePair_DoubleInt     : AResult^ := AOperands[0].AsDouble >= AOperands[1].AsInteger;
        HCmdQuery_TypePair_DoubleDouble  : AResult^ := AOperands[0].AsDouble >= AOperands[1].AsDouble;
        HCmdQuery_TypePair_BooleanBoolean: AResult^ := AOperands[0].AsBoolean >= AOperands[1].AsBoolean;
        HCmdQuery_TypePair_StringString  : AResult^ := AOperands[0].AsString.Value >= AOperands[1].AsString.Value;
    else
        if not HCmdQuery_Operators_CallBinaryOverload(AInterpreter, HCmdQueryBinaryOperatorInterfaceOffset.Less, AOperands, AResult) then
            raise EHCmdQueryNoSuchOperatorOverload.Create(
                '>=[]: Operator is not overloaded for types `%s` and `%s`',
                [ AOperands[0].GetTypeString, AOperands[1].GetTypeString ],
                PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary).Position^
            );
    end;
end;

end.

