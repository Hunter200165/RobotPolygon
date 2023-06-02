program RobotPolygon;

{$mode objfpc}{$H+}

uses
    {$IFDEF UNIX}
    cthreads,
    {$ENDIF}
    {$IFDEF HASAMIGA}
    athreads,
    {$ENDIF}
    Interfaces, // this includes the LCL widgetset
    Forms,
    uMetaDarkStyle,
    uDarkStyleParams,
    RobotPolygon.MainForm, RobotPolygon.Robot, RobotPolygon.InjectStandards
    { you can add units after this };

{$R *.res}

begin
    RequireDerivedFormResource := True;
    Application.Scaled := True;
    PreferredAppMode := TPreferredAppMode.pamForceDark;
    uMetaDarkStyle.ApplyMetaDarkStyle;
    Application.Initialize;
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
end.

