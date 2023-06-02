{$IfDef FPC}
    {$Mode DelphiUnicode}
    {$Codepage UTF8}
    {$H+}

    {$ScopedEnums on}
    {$PointerMath on}
    {$TypedAddress on}

    (* Build attunment *)

    { Compiles debugger support into an interpreter. It *will* always slow down the execution of any program, but also will make it possible for program workflow analysis.
        Recommended state: Depends on the goals
    }
    {.$Define HCmdQuery_Debugger}

    (* Performance switched and other settings *)

    { Allow inlining of Create*Variable functions
        Recommended state: Defined
    }

    // {$Define HCmdQuery_CallBoundary_InlineCreateVariable}
    { Allow inlining of GetVariable* functions
        Recommended state: Defined
    }
    //{$Define HCmdQuery_CallBoundary_InlineGetVariable}

{$EndIf}
