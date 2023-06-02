unit HCmdQuery.Types;

{$I HCmdQuery.inc}

interface

uses
    SysUtils;

type

    (* THCmdQueryPosition
    *)
    THCmdQueryPosition = packed record
    public
        FileName: UnicodeString;
        Line: Integer;
        Character: Integer;
    public
        procedure IncChar;
        procedure IncLine;
    public
        function ToString: UnicodeString;
    public
        constructor Create(const AFileName: UnicodeString);
    end;
    PHCmdQueryPosition = ^THCmdQueryPosition;

const
    HCmdQueryUnknownPosition: THCmdQueryPosition = (
        FileName: '';
        Line: -1;
        Character: -1;
    );

implementation

{ THCmdQueryPosition }

procedure THCmdQueryPosition.IncChar;
begin
    Inc(Character);
end;

procedure THCmdQueryPosition.IncLine;
begin
    Inc(Line);
    Character := 0;
end;

function THCmdQueryPosition.ToString: UnicodeString;
begin
    if (Character < 0) or (Line < 0) then
        Result := '[pascal]:?';

    Result := UnicodeFormat('%s:%d,%d', [ FileName, Line, Character ]);
end;

constructor THCmdQueryPosition.Create(const AFileName: UnicodeString);
begin
    FileName := AFileName;
    Line := 0;
    Character := 0;
end;

end.

