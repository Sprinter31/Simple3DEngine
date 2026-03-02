unit uRenderer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, uMesh;

type
  T2DPoint = class;
  T2DLine = class;

  T2DLineArray = Array of T2DLine;

  TRenderer = class
    private
      FScreenWidth, FScreenHeight: Double;
      function RenderLines(mesh: TMesh): T2DLineArray;
      function ProjectTo2D(vertex: TVertex): T2DPoint;
      function TranslateToScreen(p: T2DPoint): T2DPoint;
    public
      function RenderMesh(mesh: TMesh): TBitmap;
      constructor Create(ScreenWidth, ScreenHeight: Double);
  end;

  T2DLine = class
    A, B: T2DPoint;
    constructor Create(aA, aB: T2DPoint);
  end;

  T2DPoint = class
      X: Double;
      Y: Double;
      constructor Create(aX, aY: Double);
    end;


implementation

{ TRenderer }

constructor TRenderer.Create(ScreenWidth, ScreenHeight: Double);
begin
  FScreenWidth := ScreenWidth;
  FScreenHeight := ScreenHeight;
end;

function TRenderer.RenderMesh(mesh: TMesh): TBitmap;
var line: T2DLine;
begin
  Result := TBitmap.Create;

  Result.Width := Round(FScreenWidth);
  Result.Height := Round(FScreenHeight);

  Result.Canvas.Brush.Color := clBlack;
  Result.Canvas.FillRect(Rect(0, 0, Result.Width, Result.Height));

  Result.Canvas.Pen.Color := clGreen;
  Result.Canvas.Pen.Width := 2;

  for line in RenderLines(mesh) do
       Result.Canvas.Line(Round(line.A.X), Round(line.A.Y), Round(line.B.X), Round(line.B.Y));
end;

function TRenderer.RenderLines(mesh: TMesh): T2DLineArray;
var
  line: TLine;
  vertexA, vertexB: TVertex;
  pointA, pointB: T2DPoint;
  i: Integer;
begin
   SetLength(Result, Length(mesh.Lines));
   for i := Low(mesh.Lines) to High(mesh.Lines) do begin
      line := mesh.Lines[i];

      vertexA := mesh.Vertices[line.A];
      vertexB := mesh.Vertices[line.B];

      pointA := TranslateToScreen(ProjectTo2D(vertexA));
      pointB := TranslateToScreen(ProjectTo2D(vertexB));

      Result[i] := T2DLine.Create(pointA, pointB);
   end;
end;

function TRenderer.ProjectTo2D(vertex: TVertex): T2DPoint;
begin
  if vertex.Z = 0 then
    Result := T2DPoint.Create(FScreenWidth*2, FScreenWidth*2) // Außerhalb des Sichtfeldes
  else
    Result := T2DPoint.Create(vertex.X / vertex.Z, vertex.Y / vertex.Z);
end;

function TRenderer.TranslateToScreen(p: T2DPoint): T2DPoint;
var x, y: Double;
begin
   x := (p.X + 1) * FScreenWidth/2;
   y := (p.Y * -1 + 1) * FScreenHeight/2;
   Result := T2DPoint.Create(x, y);
end;

{ T2DPoint }

constructor T2DPoint.Create(aX, aY: Double);
begin
  X := aX;
  Y := aY;
end;

{ T2DLine }

constructor T2DLine.Create(aA, aB: T2DPoint);
begin
  A := aA;
  B := aB;
end;

end.

