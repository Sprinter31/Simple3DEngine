unit uAnimation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, uMesh;

type
  TAnimation = class
    private
      FMeshStates: specialize TArray<TMesh>;
    public
      constructor Create;
      property States: specialize TArray<TMesh> read FMeshStates;
  end;

implementation

{ TAnimation }

constructor TAnimation.Create;
var
  i, k: Integer;
  mesh: TMesh;
begin
  mesh := TMesh.Create;

  SetLength(FMeshStates, 100);
  for i := 0 to High(FMeshStates) do begin
     mesh := mesh.Clone;
     FMeshStates[i] := mesh;

     for k := 0 to High(mesh.Vertices) do
         mesh.Vertices[k] := TVertex.Create(mesh.Vertices[k].X, mesh.Vertices[k].Y, mesh.Vertices[k].Z + 0.1);
  end;
end;

end.

