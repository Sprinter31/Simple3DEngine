unit uMesh;

{$mode ObjFPC}{$H+}

interface

type
  TLine = class;
  TVertex = class;

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

  TLine = class
    A, B: Integer; // Indizes von den zu verbindenden Vertices
    constructor Create(aA, aB: Integer);
  end;

  TVertex = class // Eckpunkt im drei dimensionalen Raum
    X, Y, Z: Double;
    constructor Create(aX, aY, aZ: Double);
  end;

implementation


{ TMesh }

constructor TMesh.Create;
begin

end;

function TMesh.Clone: TMesh;
var i: Integer;
begin
  Result := TMesh.Create;
  SetLength(Result.Vertices, Length(Vertices));
  SetLength(Result.Lines, Length(Lines));

  for i := 0 to High(Result.Vertices) do
        Result.Vertices[i] := Vertices[i];

  for i := 0 to High(Result.Lines) do
        Result.Lines[i] := Lines[i];
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

