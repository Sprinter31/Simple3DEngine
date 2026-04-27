unit uAnimation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Math, uMesh, uGLTF;

type
  TAnimation = class
    private
      FMeshStates: specialize TArray<TMesh>;
      function ConvertAndCombineMeshes(meshes: specialize TArray<TVFs>): TMesh;
      function ApplyRotation(mesh: TMesh; rotation: TVec4): TMesh;
      function Cross(a, b: TVec3): TVec3;
    public
      constructor Create(data: TGLBData);
      property States: specialize TArray<TMesh> read FMeshStates;
      destructor Destroy; override;
  end;

implementation

{ TAnimation }

constructor TAnimation.Create(data: TGLBData);
var
  i, frameCount: Integer;
  quaternion: TVec4;
  baseMesh: TMesh;
begin
   frameCount := 60;
   SetLength(FMeshStates, frameCount);

   baseMesh := ConvertAndCombineMeshes(data.Meshes);
   try
     for i := 0 to frameCount - 1 do begin
         quaternion := TVec4.Create(0, Sin(((i / frameCount) * 2 * Pi) / 2), 0, Cos(((i / frameCount) * 2 * Pi) / 2));

         FMeshStates[i] := ApplyRotation(baseMesh, quaternion);
     end;
   finally
     baseMesh.Free;
   end;
end;

function TAnimation.ConvertAndCombineMeshes(meshes: specialize TArray<TVFs>): TMesh;
var
  mesh: TMesh;
  i, j, a, b, c, vertexOffset, lineOffset: Integer;
begin
   mesh := TMesh.Create;
   for i := 0 to High(meshes) do begin
      SetLength(mesh.Vertices, Length(mesh.Vertices) + Length(meshes[i].Vertices));
      vertexOffset := Length(mesh.Vertices) - Length(meshes[i].Vertices);
      for j := 0 to High(meshes[i].Vertices) do
          mesh.Vertices[vertexOffset + j] := TVertex.Create(meshes[i].Vertices[j].X, meshes[i].Vertices[j].Y, meshes[i].Vertices[j].Z);

      lineOffset := Length(mesh.Lines);
      SetLength(mesh.Lines, lineOffset + Length(meshes[i].Faces));

      for j := 0 to (Length(meshes[i].Faces) div 3) - 1 do begin
         a := meshes[i].Faces[j * 3] + vertexOffset;
         b := meshes[i].Faces[j * 3 + 1] + vertexOffset;
         c := meshes[i].Faces[j * 3 + 2] + vertexOffset;

         mesh.Lines[lineOffset + j * 3] := TLine.Create(a, b);
         mesh.Lines[lineOffset + j * 3 + 1] := TLine.Create(b, c);
         mesh.Lines[lineOffset + j * 3 + 2] := TLine.Create(c, a);
      end;
   end;
   Result := mesh;
end;

function TAnimation.ApplyRotation(mesh: TMesh; rotation: TVec4): TMesh;
var
  quaternionVectorPart: TVec3;
  quaternionScalarPart: Single;
  firstCross, secondCross: TVec3;
  i: Integer;
begin
   Result := mesh.Clone;
   quaternionVectorPart := TVec3.Create(rotation.X, rotation.Y, rotation.Z);
   quaternionScalarPart := rotation.W;

   for i := 0 to High(mesh.Vertices) do begin
       firstCross := Cross(quaternionVectorPart, TVec3.Create(Result.Vertices[i].X, Result.Vertices[i].Y, Result.Vertices[i].Z));
       secondCross := Cross(quaternionVectorPart, firstCross);

       Result.Vertices[i] := TVertex.Create(
          Result.Vertices[i].X + 2 * (quaternionScalarPart * firstCross.X + secondCross.X),
          Result.Vertices[i].Y + 2 * (quaternionScalarPart * firstCross.Y + secondCross.Y),
          Result.Vertices[i].Z + 2 * (quaternionScalarPart * firstCross.Z + secondCross.Z)
       );
   end;
end;

function TAnimation.Cross(a, b: TVec3): TVec3;
begin
  Result := TVec3.Create(
    a.Y * b.Z - a.Z * b.Y,
    a.Z * b.X - a.X * b.Z,
    a.X * b.Y - a.Y * b.X
  );
end;

destructor TAnimation.Destroy;
var
  i: Integer;
begin
  for i := 0 to High(FMeshStates) do
    FMeshStates[i].Free;

  inherited Destroy;
end;

end.

