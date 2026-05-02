unit uMesh;

{$mode ObjFPC}{$H+}

interface

type
  TLine = record;
  TVertex = record;

  TLineArray = Array of TLine;
  TVertexArray = Array of TVertex;

  TMesh = class
    public
      Lines: TLineArray;
      Vertices: TVertexArray;
      constructor Create;
      function Clone: TMesh;
      destructor Destroy; override;
  end;

  TLine = record
    A, B: Integer; // Indizes von den zu verbindenden Vertices
  end;

  TVertex = record // Eckpunkt im drei dimensionalen Raum
    X, Y, Z: Double;
  end;

implementation


{ TMesh }

constructor TMesh.Create;
begin

end;

function TMesh.Clone: TMesh;
var
  i: Integer;
begin
  Result := TMesh.Create;

  SetLength(Result.Vertices, Length(Vertices));
  SetLength(Result.Lines, Length(Lines));

  for i := 0 to High(Vertices) do
    Result.Vertices[i] := TVertex.Create(
      Vertices[i].X,
      Vertices[i].Y,
      Vertices[i].Z
    );

  for i := 0 to High(Lines) do
    Result.Lines[i] := TLine.Create(
      Lines[i].A,
      Lines[i].B
    );
end;

destructor TMesh.Destroy;
var
  i: Integer;
begin
  for i := 0 to High(Vertices) do
    Vertices[i].Free;

  for i := 0 to High(Lines) do
    Lines[i].Free;

  inherited Destroy;
end;

{ TLine }

constructor TLine.Create(aA, aB: Integer);
begin
  A := aA;
  B := aB;
end;


{ TVertex }

constructor TVertex.Create(aX, aY, aZ: Double);
begin
  X := aX;
  Y := aY;
  Z := aZ;
end;

end.

