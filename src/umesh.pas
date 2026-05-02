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
var
  i: Integer;
begin
  Result := TMesh.Create;

  // Erstellt gleich große Arrays für die Kopie
  SetLength(Result.Vertices, Length(Vertices));
  SetLength(Result.Lines, Length(Lines));

  // Kopiert alle Eckpunkte des Meshes
  for i := 0 to High(Vertices) do
    Result.Vertices[i] := TVertex.Create(
      Vertices[i].X,
      Vertices[i].Y,
      Vertices[i].Z
    );

  // Kopiert alle Verbindungen zwischen den Eckpunkten
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
  // Gibt zuerst die Eckpunkte frei
  for i := 0 to High(Vertices) do
    Vertices[i].Free;

  // Gibt danach die Linien frei
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

