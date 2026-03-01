unit uMesh;

{$mode ObjFPC}{$H+}

interface

type
  TLine = class;
  TVertex = class;

  TLineArray = Array of TLine;
  TVertexArray = Array of TVertex;

  TMesh = class
    private
      FLines: TLineArray;
      FVertices: TVertexArray;
    public
      constructor Create;
      property Lines: TLineArray read FLines;
      property Vertices: TVertexArray read FVertices;
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
  SetLength(FVertices, 4);
  FVertices[0] := TVertex.Create(-0.8, 0.8, 0);
  FVertices[1] := TVertex.Create(0.8, 0.8, 0);
  FVertices[2] := TVertex.Create(0.8, -0.8, 0);
  FVertices[3] := TVertex.Create(-0.8, -0.8, 0);

  SetLength(FLines, 4);
  FLines[0] := TLine.Create(0, 1);
  FLines[1] := TLine.Create(1, 2);
  FLines[2] := TLine.Create(2, 3);
  FLines[3] := TLine.Create(3, 0);
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

