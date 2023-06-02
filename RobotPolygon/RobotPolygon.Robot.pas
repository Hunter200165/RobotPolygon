unit RobotPolygon.Robot;

{$mode delphiunicode}{$H+}

interface

uses
    HCL.Core.GenericList,
    HCL.Core.HashTable,
    Classes,
    SysUtils;

type

    { TPoint }

    TPoint = packed record
    public var
        X, Y: Double;
    public
        procedure RotateAround(const AOriginX, AOriginY, SinTheta, CosTheta: Double);
        procedure Normalize;
        function Abs: Double;
    public
        constructor Create(const AX, AY: Double);
    end;

    TWall = packed record
    public var
        Points: array [0..3] of TPoint;
    end;
    PWall = ^TWall;
    TWalls = HList<TWall>;

    { TRobot }

    TRobot = packed record
    public var
        Position: TPoint;
        Points: array [0..3] of TPoint;
        Rotation: Double;
        Width: Double;
        Height: Double;
    public
        function SightVector: TPoint;
    public
        procedure ApplyRotation;
    end;

    { TWorld }

    TTriangle = packed record
    case Boolean of
        True: (A, B, C: TPoint);
        False: (Points: array [0..2] of TPoint);
    end;

    TWorld = record
    public var
        Walls: TWalls;
        Robot: TRobot;
    public
        class function SameSide(constref P1, P2, A, B: TPoint): Boolean; static;
        class function PointInTriangle(constref P, A, B, C: TPoint): Boolean; static;
        class function TrianglesIntersect(constref A, B: TTriangle): Boolean; static;
    public
        function CreateWall(const AFrom, ATo: TPoint; const AWidth: Double): TWall;
        function GetCollision: PWall;
        function GetDistanceToWall: Double;
    end;

implementation

{ TRobot }

function TRobot.SightVector: TPoint;
begin
    Result.X := Sin(Rotation);
    Result.Y := -Cos(Rotation);

    //Result.RotateAround(0, 0, Sin(Rotation), Cos(Rotation));
end;

procedure TRobot.ApplyRotation;
var W2, H2: Double;
    SinTheta, CosTheta: Double;
begin
    W2 := Width / 2;
    H2 := Height / 2;
    Points[0].X := Position.X - W2;
    Points[0].Y := Position.Y - H2;
    Points[1].X := Position.X + W2;
    Points[1].Y := Position.Y - H2;
    Points[2].X := Position.X + W2;
    Points[2].Y := Position.Y + H2;
    Points[3].X := Position.X - W2;
    Points[3].Y := Position.Y + H2;

    SinTheta := Sin(Rotation);
    CosTheta := Cos(Rotation);

    Points[0].RotateAround(Position.X, Position.Y, SinTheta, CosTheta);
    Points[1].RotateAround(Position.X, Position.Y, SinTheta, CosTheta);
    Points[2].RotateAround(Position.X, Position.Y, SinTheta, CosTheta);
    Points[3].RotateAround(Position.X, Position.Y, SinTheta, CosTheta);
end;

{ TPoint }

procedure TPoint.RotateAround(const AOriginX, AOriginY, SinTheta, CosTheta: Double);
var NewX, NewY: Double;
begin
    X := X - AOriginX;
    Y := Y - AOriginY;

    NewX := X * CosTheta - Y * SinTheta;
    NewY := Y * CosTheta + X * SinTheta;

    X := NewX + AOriginX;
    Y := NewY + AOriginY;
end;

procedure TPoint.Normalize;
var Len: Double;
begin
    Len := Abs;
    X := X / Len;
    Y := Y / Len;
end;

function TPoint.Abs: Double;
begin
    Result := Sqrt(X * X + Y * Y);
end;

constructor TPoint.Create(const AX, AY: Double);
begin
    X := AX;
    Y := AY;
end;

{ TWorld }

class function TWorld.SameSide(constref P1, P2, A, B: TPoint): Boolean;
var CP1, CP2: Double;
    BA, P1A, P2A: TPoint;
begin
    BA.X := B.X - A.X;
    BA.Y := B.Y - A.Y;

    P1A.X := P1.X - A.X;
    P1A.Y := P1.Y - A.Y;

    P2A.X := P2.X - A.X;
    P2A.Y := P2.Y - A.Y;

    (*
        | BA.X  BA.Y  |
        |             | = BA.X * P1A.Y - BA.Y * P1A.X
        | P1A.X P1A.Y |
    *)
    CP1 := BA.X * P1A.Y - BA.Y * P1A.X;
    CP2 := BA.X * P2A.Y - BA.Y * P2A.X;

    if (CP1 >= 0) and (CP2 >= 0) or (CP1 <= 0) and (CP2 <= 0) then
        Result := True
    else
        Result := False;
end;

class function TWorld.PointInTriangle(constref P, A, B, C: TPoint): Boolean;
begin
    Result := SameSide(P, A, B, C) and SameSide(P, B, A, C) and SameSide(P, C, A, B);
end;

class function TWorld.TrianglesIntersect(constref A, B: TTriangle): Boolean;
begin
    Result :=
        PointInTriangle(A.A, B.A, B.B, B.C) or PointInTriangle(A.B, B.A, B.B, B.C) or PointInTriangle(A.C, B.A, B.B, B.C) or
        PointInTriangle(B.A, A.A, A.B, A.C) or PointInTriangle(B.B, A.A, A.B, A.C) or PointInTriangle(B.C, A.A, A.B, A.C);
end;

function TWorld.CreateWall(const AFrom, ATo: TPoint; const AWidth: Double): TWall;
var Normal: TPoint;
begin
    Normal.X := ATo.Y - AFrom.Y;
    Normal.Y := AFrom.X - ATo.X;
    Normal.Normalize;

    Normal.X := Normal.X * AWidth / 2;
    Normal.Y := Normal.Y * AWidth / 2;

    Result.Points[0].X := AFrom.X - Normal.X;
    Result.Points[0].Y := AFrom.Y - Normal.Y;
    Result.Points[1].X := AFrom.X + Normal.X;
    Result.Points[1].Y := AFrom.Y + Normal.Y;
    Result.Points[2].X := ATo.X + Normal.X;
    Result.Points[2].Y := ATo.Y + Normal.Y;
    Result.Points[3].X := ATo.X - Normal.X;
    Result.Points[3].Y := ATo.Y - Normal.Y;

    Walls.Add(Result);
end;

function TWorld.GetCollision: PWall;
var Robot1, Robot2: TTriangle;
    Wall1, Wall2: TTriangle;
    Wall: PWall;
    i: Integer;
begin
    Robot1.A := Robot.Points[0];
    Robot1.B := Robot.Points[1];
    Robot1.C := Robot.Points[2];

    Robot2.A := Robot.Points[2];
    Robot2.B := Robot.Points[3];
    Robot2.C := Robot.Points[0];

    for i := 0 to Walls.Count - 1 do begin
        Wall := @Walls.Items[i];

        Wall1.A := Wall.Points[0];
        Wall1.B := Wall.Points[1];
        Wall1.C := Wall.Points[2];

        Wall2.A := Wall.Points[2];
        Wall2.B := Wall.Points[3];
        Wall2.C := Wall.Points[0];

        if TrianglesIntersect(Robot1, Wall1) or
            TrianglesIntersect(Robot2, Wall1) or
            TrianglesIntersect(Robot1, Wall2) or
            TrianglesIntersect(Robot2, Wall2) then
        begin
            Result := Wall;
            Exit;
        end;
    end;

    Result := nil;
end;

function TWorld.GetDistanceToWall: Double;
const Eps = 0.000005;
var Sight, WallVector: TPoint;
    Wall: PWall;
    D, s, t: Double;
    i, k: Integer;
begin
    Result := Double.PositiveInfinity;

    Sight := Robot.SightVector;
    for i := 0 to Walls.Count - 1 do begin
        Wall := @Walls.Items[i];

        for k := 0 to 3 do begin
            WallVector.X := Wall.Points[(k + 1) mod 4].X - Wall.Points[k].X;
            WallVector.Y := Wall.Points[(k + 1) mod 4].Y - Wall.Points[k].Y;

            D := Sight.Y * WallVector.X - Sight.X * WallVector.Y;
            if Abs(D) < Eps then
                Continue;

            S := (1 / D) * (
                -(Wall.Points[k].X - Robot.Position.X) * Sight.Y +
                (Wall.Points[k].Y - Robot.Position.Y) * Sight.X
            );

            T := (1 / D) * (
                -(Wall.Points[k].X - Robot.Position.X) * WallVector.Y +
                (Wall.Points[k].Y - Robot.Position.Y) * WallVector.X
            );

            if (S < 0) or (S > 1) then
                Continue;

            if (T >= 0) and (T < Result) then
                Result := T;

            //T := (1 / D) * (Robot.Position.X - Wall.Points[k].X);
            //if (T < 0) or (T > 1) then
            //    Continue;

            //S := (1 / D) * (Robot.Position.Y - Wall.Points[k].Y);
            //if S < Result then
            //    Result := S;
        end;
    end;
end;

end.

