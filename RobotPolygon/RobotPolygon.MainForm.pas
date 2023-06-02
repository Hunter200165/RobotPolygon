unit RobotPolygon.MainForm;

{$mode delphi}{$H+}
{$codepage utf-8}
{$modeswitch autoderef+}

interface

uses
    Classes, SysUtils, LCLType, Forms, Controls, Graphics, Dialogs,
    StdCtrls, PairSplitter, ExtCtrls, ActnList, BGRAVirtualScreen, BGRAGraphicControl,
    BGRABitmapTypes, BGRABitmap, BCTypes, SynEdit, RobotPolygon.Robot,
    SynFacilHighlighter, SynEditMarkupWordGroup, SynEditTypes,
    Math,
    HCL.Core.Types,
    RobotPolygon.InjectStandards,
    HCmdQuery.SafeVariant,
    HCmdQuery.Kernel.CallBoundary,
    HCmdQuery.Compiler,
    HCmdQuery.Kernel.Types,
    HCmdQuery.Kernel.InterpreterBase,
    HCmdQuery.Kernel.Node;

type

    { TExecutionThread }

    TExecutionThread = class(TThread)
    public var
        NodeToExecute: SafeVariant;
        OutputString: UnicodeString;
    protected
        procedure WriteToStdOut; overload;
        procedure WriteToStdOut(const S: UnicodeString); cdecl; overload;
        procedure Execute; override;
    end;

type

    { TMainForm }

    TMainForm = class(TForm)
        SaveSource: TAction;
        ExecuteSource: TAction;
        Actions: TActionList;
        CodeMessageSplitter: TPairSplitter;
        MainSplitter: TPairSplitter;
        Messages: TMemo;
        PairSplitterSide1: TPairSplitterSide;
        PairSplitterSide2: TPairSplitterSide;
        PairSplitterSide3: TPairSplitterSide;
        PairSplitterSide4: TPairSplitterSide;
        RenderBox: TBGRAVirtualScreen;
        RenderPanel: TPanel;
        RenderTimer: TTimer;
        SourceCodeEditor: TSynEdit;
        procedure ExecuteSourceExecute(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure HelloButtonClick(Sender: TObject);
        procedure RenderBoxRedraw(Sender: TObject; Bitmap: TBGRABitmap);
        procedure RenderTimerTimer(Sender: TObject);
        procedure SaveSourceExecute(Sender: TObject);
    private
        procedure DrawTriangle(const ATo: TBGRABitmap; constref AT: TTriangle);
        procedure DrawWall(const ATo: TBGRABitmap; constref Wall: TWall);
        procedure DrawRobot(const ATo: TBGRABitmap; constref Robot: TRobot; AIntersection: Double);
    public var
        Kernel: THCmdQueryInterpreterBase;
        Highlighter: TSynFacilSyn;
        World: TWorld;
        WorldLock: THCLObject;
        Runs: Integer;
        ExecutionThread: TExecutionThread;
        MaxDistance: Double;

        T1, T2: TTriangle;
    end;

var
    MainForm: TMainForm;

implementation

{$R *.lfm}

procedure ClearMessages;
begin
    MainForm.Messages.Clear;
end;

procedure HCmdQuery_ScriptHost_ClearOutput(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);
    TThread.CurrentThread.Synchronize(TThread.CurrentThread, ClearMessages);
    AResult^ := True;
end;

procedure HCmdQuery_World_CreateWall(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    FromX, FromY, ToX, ToY, Width: Double;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(4);

    FromX := CBF.ExpectNumber(0, 'world::createWall[0]: Expected x of starting point');
    FromY := CBF.ExpectNumber(1, 'world::createWall[1]: Expected y of starting point');
    ToX := CBF.ExpectNumber(2, 'world::createWall[2]: Expected x of ending point');
    ToY := CBF.ExpectNumber(3, 'world::createWall[3]: Expected y of ending point');

    Width := CBF.ExpectParameterNumberDefault('width', 6);

    MainForm.WorldLock.Lock;
    try
        MainForm.World.CreateWall(TPoint.Create(FromX, FromY), TPoint.Create(ToX, ToY), Width);
    finally
        MainForm.WorldLock.Unlock;
    end;

    AResult^ := True;
end;

procedure HCmdQuery_World_SetRobotPosition(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    X, Y: Double;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(2);

    X := CBF.ExpectNumber(0, 'world::setRobotPos[0]: Expected x coordinate of robot');
    Y := CBF.ExpectNumber(1, 'world::setRobotPos[1]: Expected y coordinate of robot');

    MainForm.WorldLock.Lock;
    try
        MainForm.World.Robot.Position.X := X;
        MainForm.World.Robot.Position.Y := Y;
        MainForm.World.Robot.ApplyRotation;
    finally
        MainForm.WorldLock.Unlock;
    end;

    AResult^ := True;
end;

procedure HCmdQuery_World_SetRobotRotation(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Angle: Double;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    Angle := CBF.ExpectNumber(0, 'world::setRobotRotation[0]: Expected angle of robot');

    MainForm.WorldLock.Lock;
    try
        MainForm.World.Robot.Rotation := Angle;
        MainForm.World.Robot.ApplyRotation;
    finally
        MainForm.WorldLock.Unlock;
    end;

    AResult^ := True;
end;

procedure HCmdQuery_World_GetRobotX(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := MainForm.World.Robot.Position.X;
end;

procedure HCmdQuery_World_GetRobotY(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := MainForm.World.Robot.Position.Y;
end;

procedure HCmdQuery_World_GetRobotRotation(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    AResult^ := MainForm.World.Robot.Rotation;
end;

procedure HCmdQuery_World_SetRobotVisionDistance(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    MainForm.MaxDistance := CBF.ExpectNumber(0, 'world::setRobotVisionDistance[0]: Expected distance of vision');

    AResult^ := True;
end;

procedure HCmdQuery_World_DestroyWalls(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    MainForm.World.Walls.Clear;
    AResult^ := True;
end;

procedure HCmdQuery_Robot_Retrieve(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
var CBF: PHCmdQueryCallBoundaryFrame;
    Res: Double;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(0);

    Res := MainForm.World.GetDistanceToWall;

    if (Res = Double.PositiveInfinity) or (Res > MainForm.MaxDistance) then
        Res := -1;

    AResult^ := Res;
end;

procedure HCmdQuery_Robot_Rotate(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
const Delta = 0.025;
var CBF: PHCmdQueryCallBoundaryFrame;
    Angle, Dr, Remainder, CurrentRotation: Double;
    Deltas, CurrentIndex: Integer;
    Prev: TRobot;
begin
    CBF := AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary;
    CBF.EndExpectation(1);

    Angle := CBF.ExpectNumber(0, 'robot::rotate[0]: Expected angle (number) to rotate robot by');
    if Angle = 0 then begin
        AResult^ := MainForm.World.Robot.Rotation;
        Exit;
    end;

    Deltas := Floor(Angle / Delta);
    Remainder := Angle - Deltas * Delta;
    Deltas := Deltas + Sign(Deltas);
    Dr := Sign(Deltas) * Delta;
    CurrentRotation := MainForm.World.Robot.Rotation;
    CurrentIndex := 1;

    while not (Deltas = 0) do begin
        Prev := MainForm.World.Robot;
        MainForm.WorldLock.Lock;
        try
            if Deltas > 1 then
                MainForm.World.Robot.Rotation := CurrentRotation + CurrentIndex * Dr
            else
                MainForm.World.Robot.Rotation := CurrentRotation + (CurrentIndex - 1) * Dr + Remainder;
            MainForm.World.Robot.ApplyRotation;

            if Assigned(MainForm.World.GetCollision) then begin
                MainForm.World.Robot := Prev;
                Break;
            end;
        finally
            MainForm.WorldLock.Unlock;
        end;
        Deltas := Deltas - Sign(Deltas);
        CurrentIndex := CurrentIndex + 1;
        Sleep(1);
    end;

    AResult^ := MainForm.World.Robot.Rotation;
end;

procedure HCmdQuery_Robot_Forward(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
const Delta = 0.5;
var Sight: TPoint;
    Prev: TRobot;
    i: Integer;
begin
    PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).EndExpectation(0);

    MainForm.WorldLock.Lock;
    try
        Sight := MainForm.World.Robot.SightVector;
        Sight.X := Sight.X * Delta;
        Sight.Y := Sight.Y * Delta;

        Prev := MainForm.World.Robot;

        MainForm.World.Robot.Position.X := MainForm.World.Robot.Position.X + Sight.X;
        MainForm.World.Robot.Position.Y := MainForm.World.Robot.Position.Y + Sight.Y;

        for i := 0 to 3 do begin
            MainForm.World.Robot.Points[i].X := MainForm.World.Robot.Points[i].X + Sight.X;
            MainForm.World.Robot.Points[i].Y := MainForm.World.Robot.Points[i].Y + Sight.Y;
        end;

        AResult^ := True;

        if Assigned(MainForm.World.GetCollision) then begin
            AResult^ := False;
            MainForm.World.Robot := Prev;
        end;
    finally
        MainForm.WorldLock.Unlock;
    end;

    Sleep(2);
end;

procedure HCmdQuery_Robot_Backward(const AInterpreter: PSafeObject; const AResult: PSafeVariant); cdecl;
const Delta = 0.25;
var Sight: TPoint;
    Prev: TRobot;
    i: Integer;
begin
    PHCmdQueryCallBoundaryFrame(AInterpreter.Interfaces.Interpreter.GetCurrentCallBoundary()).EndExpectation(0);

    MainForm.WorldLock.Lock;
    try
        Sight := MainForm.World.Robot.SightVector;
        Sight.X := -Sight.X * Delta;
        Sight.Y := -Sight.Y * Delta;

        Prev := MainForm.World.Robot;

        MainForm.World.Robot.Position.X := MainForm.World.Robot.Position.X + Sight.X;
        MainForm.World.Robot.Position.Y := MainForm.World.Robot.Position.Y + Sight.Y;

        for i := 0 to 3 do begin
            MainForm.World.Robot.Points[i].X := MainForm.World.Robot.Points[i].X + Sight.X;
            MainForm.World.Robot.Points[i].Y := MainForm.World.Robot.Points[i].Y + Sight.Y;
        end;

        AResult^ := True;

        if Assigned(MainForm.World.GetCollision) then begin
            AResult^ := False;
            MainForm.World.Robot := Prev;
        end;
    finally
        MainForm.WorldLock.Unlock;
    end;

    Sleep(2);
end;

{ TExecutionThread }

procedure TExecutionThread.WriteToStdOut;
begin
    MainForm.Messages.Text := MainForm.Messages.Text + AnsiString(OutputString);
    MainForm.Messages.SelStart := Length(MainForm.Messages.Text);
end;

procedure TExecutionThread.WriteToStdOut(const S: UnicodeString); cdecl;
begin
    OutputString := S;
    Synchronize(WriteToStdOut);
end;

procedure TExecutionThread.Execute;
var CBF: PHCmdQueryCallBoundaryFrame;
    Res: SafeVariant;
begin
    FreeOnTerminate := True;
    try
        try
            MainForm.Kernel.SelfObject.Interfaces.Interpreter.WriteToStdOut := WriteToStdOut;

            CBF := MainForm.Kernel.AllocateCallBoundaryFrame;
            try
                CBF.Module := NodeToExecute.AsObject.TreatAs<THCmdQueryNode>.ParentContext.AsObject;
                CBF.Position := @(NodeToExecute.AsObject.TreatAs<THCmdQueryNode>.Position);
                //Start := THCLTimespan.GetCurrentTime;
                Res := None;
                NodeToExecute.AsObject.Interfaces.Evaluatable.Evaluate(MainForm.Kernel.SelfObject, NodeToExecute.AsObject, @Res);
                Res := None;
                //Finish := THCLTimespan.GetCurrentTime;

                //WriteLn('#= Time: ', (Finish - Start).ToString);
            finally
                NodeToExecute := None;
                MainForm.Kernel.DeallocateCallBoundaryFrame;
            end;
        finally
            MainForm.ExecutionThread := nil;
        end;

    except
        on E: EHCmdQueryRuntimeException do begin
            //WriteLn(E.ClassName, ' : ', E.FMessageUnicode);
            WriteToStdOut(E.DumpToString);
        end;
        on E: Exception do begin
            WriteToStdOut('Exception: ' + E.Message);
        end;
    end;
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
const N = 500;
var i, Y: Integer;
begin
    Caption := 'Robot modelling';

    Highlighter := TSynFacilSyn.Create(Self);
    Highlighter.LoadFromFile('hcmd.xml');

    Highlighter.CommentAttribute.Style := [];
    Highlighter.SymbolAttribute.Style := [];

    SourceCodeEditor.Highlighter := Highlighter;

    SourceCodeEditor.BracketMatchColor.Style := [ fsBold ];

    SourceCodeEditor.MarkupManager.MarkupByClass[TSynEditMarkupWordGroup].MarkupInfo.Clear;
    SourceCodeEditor.MarkupManager.MarkupByClass[TSynEditMarkupWordGroup].MarkupInfo.FrameColor := clNone;
    SourceCodeEditor.MarkupManager.MarkupByClass[TSynEditMarkupWordGroup].MarkupInfo.Style := [];

    Randomize;

    //for i := 0 to 2 do begin
        //T1.Points[i].X := Random(N);
        //T1.Points[i].Y := Random(N);

        //T2.Points[i].X := Random(N) + N;
        //T2.Points[i].Y := Random(N) + N;
    //end;

    WorldLock := THCLObject.Create;

    Kernel := THCmdQueryInterpreterBase.Create;
    InjectStandards(Kernel);

    Kernel.RegisterGlobalFunction('robot::forward', HCmdQuery_Robot_Forward);
    Kernel.RegisterGlobalFunction('robot::backward', HCmdQuery_Robot_Backward);
    Kernel.RegisterGlobalFunction('robot::rotate', HCmdQuery_Robot_Rotate);
    Kernel.RegisterGlobalFunction('robot::retrieve', HCmdQuery_Robot_Retrieve);
    Kernel.RegisterGlobalFunction('world::createWall', HCmdQuery_World_CreateWall);
    Kernel.RegisterGlobalFunction('world::destroyWalls', HCmdQuery_World_DestroyWalls);
    Kernel.RegisterGlobalFunction('world::setRobotPosition', HCmdQuery_World_SetRobotPosition);
    Kernel.RegisterGlobalFunction('world::setRobotRotation', HCmdQuery_World_SetRobotRotation);
    Kernel.RegisterGlobalFunction('world::setRobotVisionDistance', HCmdQuery_World_SetRobotVisionDistance);
    Kernel.RegisterGlobalFunction('world::getRobotX', HCmdQuery_World_GetRobotX);
    Kernel.RegisterGlobalFunction('world::getRobotY', HCmdQuery_World_GetRobotY);
    Kernel.RegisterGlobalFunction('world::getRobotRotation', HCmdQuery_World_GetRobotRotation);
    Kernel.RegisterGlobalFunction('scripthost::clearStdOut', HCmdQuery_ScriptHost_ClearOutput);

    World.Robot.Position := TPoint.Create(50, 50);
    World.Robot.Rotation := 0;
    World.Robot.Height := 20;
    World.Robot.Width := 20;
    World.Robot.ApplyRotation;

    if FileExists('project.hcmd') then
        SourceCodeEditor.Lines.LoadFromFile('project.hcmd', TEncoding.UTF8);

    //for i := 0 to 50 do begin
    //    Y := Random(N);
    //    World.CreateWall(TPoint.Create(i * 20, Y), TPoint.Create((i + 1) * 20, Y), 8);
    //end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
    WorldLock.Free;
    Kernel.Free;
end;

procedure TMainForm.ExecuteSourceExecute(Sender: TObject);
var Compiler: THCmdQueryCompiler;
    Node: THCmdQueryCompilerNode;
begin
    if Assigned(ExecutionThread) then
        Exit;

    try
        Compiler := THCmdQueryCompiler.Create;
        try
            Node := Compiler.CompileText(UnicodeString(SourceCodeEditor.Text), 'project.hcmd(' + UnicodeString(Runs.ToString) + ')');
            Runs := Runs + 1;

            try
                ExecutionThread := TExecutionThread.Create(True);
                ExecutionThread.NodeToExecute := Kernel.ConvertNodes(Node, 'not set', 'not set');

                ExecutionThread.Start;
                //TestKernel(Node);
            finally
                Node.Free;
            end;
        finally
            Compiler.Free;
        end;
    except
        on E: EHCmdQueryCompilationException do begin
            ShowMessage('Compilation error: ' + E.FPosition.ToString + ' ' + E.Message);
        end;
    end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
const Delta = 2;
var i: Integer;
    Sight: TPoint;
    Prev: TRobot;
begin

    if (Key = VK_W) or (Key = VK_S) then begin
        //for i := 0 to 2 do
        //    T1.Points[i].Y := T1.Points[i].Y - Delta;

    end
    else if Key = VK_Q then begin
        World.Robot.Rotation := World.Robot.Rotation - 0.1;
        World.Robot.ApplyRotation;
    end
    else if Key = VK_E then begin
        World.Robot.Rotation := World.Robot.Rotation + 0.1;
        World.Robot.ApplyRotation;
    end;
end;

procedure TMainForm.HelloButtonClick(Sender: TObject);
begin
    ShowMessage('Hello world');
end;

procedure TMainForm.RenderBoxRedraw(Sender: TObject; Bitmap: TBGRABitmap);
var i: Integer;
    Dist: Double;
begin
    // ShowMessage('Redraw');

    Bitmap.CanvasBGRA.Brush.Color := Color; // clWhite;
    //Bitmap.Canvas.AntialiasingMode := amOn;
    Bitmap.CanvasBGRA.AntialiasingMode := amOn;
    Bitmap.AntialiasingDrawMode := dmDrawWithTransparency;
    Bitmap.Canvas.Brush.Color := Color;
    Bitmap.Canvas.Clear;

    //if TWorld.TrianglesIntersect(T1, T2) then

    //else
        //Bitmap.CanvasBGRA.Brush.Color := clRed;
    Bitmap.CanvasBGRA.Pen.Width := 2;
    Bitmap.CanvasBGRA.Pen.Color := clGray;

    //DrawTriangle(Bitmap, T1);
    //DrawTriangle(Bitmap, T2);

    WorldLock.Lock;
    try
        Dist := World.GetDistanceToWall;
        Bitmap.CanvasBGRA.Font.Height := 14;
        Bitmap.CanvasBGRA.Font.Color := clWhite;
        Bitmap.CanvasBGRA.TextOut(10, 10, 'Расстояние до преграды: ' + FloatToStr(Dist));

        Bitmap.CanvasBGRA.Brush.Color := clYellow;

        for i := 0 to World.Walls.Count - 1 do
            DrawWall(Bitmap, World.Walls.Items[i]);

        Bitmap.CanvasBGRA.Brush.Color := clRed;
        DrawRobot(Bitmap, World.Robot, Dist);
    finally
        WorldLock.Unlock;
    end;
end;

procedure TMainForm.RenderTimerTimer(Sender: TObject);
const Delta = 1;
var i: Integer;
begin
    RenderTimer.Enabled := False;

    // RenderBox.Invalidate;
    RenderBox.RedrawBitmap;

    //for i := 0 to 2 do
    //    T1.Points[i].X := T1.Points[i].X + Delta;

    RenderTimer.Enabled := True;
end;

procedure TMainForm.SaveSourceExecute(Sender: TObject);
begin
    SourceCodeEditor.Lines.SaveToFile('project.hcmd', TEncoding.UTF8);
    SourceCodeEditor.MarkTextAsSaved;
end;

procedure TMainForm.DrawTriangle(const ATo: TBGRABitmap; constref AT: TTriangle);
var Points: array of Classes.TPoint;
    i: Integer;
begin
    Points := nil;
    SetLength(Points, 3);

    for i := 0 to 2 do begin
        Points[i].X := Trunc(AT.Points[i].X);
        Points[i].Y := Trunc(AT.Points[i].Y);
    end;

    // RenderBox.Canvas.Polygon(Points);
    ATo.CanvasBGRA.Polygon(Points);
end;

procedure TMainForm.DrawWall(const ATo: TBGRABitmap; constref Wall: TWall);
var Points: array of Classes.TPoint;
    i: Integer;
begin
    Points := nil;
    SetLength(Points, 4);

    for i := 0 to 3 do begin
        Points[i].X := Trunc(Wall.Points[i].X);
        Points[i].Y := Trunc(Wall.Points[i].Y);
    end;

    ATo.CanvasBGRA.Polygon(Points);
end;

procedure TMainForm.DrawRobot(const ATo: TBGRABitmap; constref Robot: TRobot; AIntersection: Double);
const Len = 600;
var Points: array of Classes.TPoint;
    Sight: TPoint;
    i: Integer;
begin
    Points := nil;
    SetLength(Points, 4);
    for i := 0 to 3 do begin
        Points[i].X := Trunc(Robot.Points[i].X);
        Points[i].Y := Trunc(Robot.Points[i].Y);
    end;

    ATo.CanvasBGRA.Polygon(Points);

    if AIntersection.IsInfinity then
        AIntersection := 20;

    Sight := Robot.SightVector;
    ATo.CanvasBGRA.Line(Trunc(Robot.Position.X), Trunc(Robot.Position.Y), Trunc(Robot.Position.X + Sight.X * AIntersection), Trunc(Robot.Position.Y + Sight.Y * AIntersection));
end;

end.

