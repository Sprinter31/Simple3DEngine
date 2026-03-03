unit uAnimation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, uMesh, uGLTF;

type
  TAnimation = class
    private
      FMeshStates: specialize TArray<TMesh>;
    public
      constructor Create(data: TGLBData);
      property States: specialize TArray<TMesh> read FMeshStates;
  end;

implementation

{ TAnimation }

constructor TAnimation.Create(data: TGLBData);
var
  mesh: TMesh;
  i, j, a, b, c, vertexOffset, lineOffset: Integer;
begin
   mesh := TMesh.Create;

   for i := 0 to High(data.Meshes) do begin
      SetLength(mesh.Vertices, Length(mesh.Vertices) + Length(data.Meshes[i].Vertices));
      vertexOffset := Length(mesh.Vertices) - Length(data.Meshes[i].Vertices);
      for j := 0 to High(data.Meshes[i].Vertices) do
          mesh.Vertices[vertexOffset + j] := TVertex.Create(data.Meshes[i].Vertices[j].X, data.Meshes[i].Vertices[j].Y * -1, data.Meshes[i].Vertices[j].Z * -1);

      lineOffset := Length(mesh.Lines);
      SetLength(mesh.Lines, lineOffset + Length(data.Meshes[i].Faces));
      for j := 0 to Length(data.Meshes[i].Faces) div 3 - 1 do begin
         a := data.Meshes[i].Faces[j * 3] + vertexOffset;
         b := data.Meshes[i].Faces[j * 3 + 1] + vertexOffset;
         c := data.Meshes[i].Faces[j * 3 + 2] + vertexOffset;

         mesh.Lines[lineOffset + j * 3] := TLine.Create(a, b);
         mesh.Lines[lineOffset + j * 3 + 1] := TLine.Create(b, c);
         mesh.Lines[lineOffset + j * 3 + 2] := TLine.Create(c, a);
      end;
   end;

   SetLength(FMeshStates, 1);
   FMeshStates[0] := mesh;
end;

end.

