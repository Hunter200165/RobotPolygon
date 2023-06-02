class operator Initialize(var AVar: SafeVariant);
class operator Finalize(var AVar: SafeVariant);
class operator Copy(constref ASrc: SafeVariant; var ADest: SafeVariant);

class operator Implicit(const AObject: PSafeObject): SafeVariant;
class operator Implicit(const AInteger: Int64): SafeVariant;
class operator Implicit(const ANumber: Double): SafeVariant;
class operator Implicit(const ABoolean: Boolean): SafeVariant;
class operator Implicit(const AString: PSafeString): SafeVariant;
class operator Implicit(const AFunction: THCmdQueryNativeFunction): SafeVariant;

class operator Equal(const A, B: SafeVariant): Boolean;
