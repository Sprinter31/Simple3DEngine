unit uGLTF;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, contnrs, fgl;

type
  TGLBParser = class
  private
    type
      TVertex = class
        X, Y, Z: Single;
        constructor Create(aX, aY, aZ: Single);
      end;

      TGLBHeader = class
        Magic, Version, Length: Cardinal;
      end;

      TGLBChunk = class
         Length, Typ: Cardinal;
         Data: TBytes;
      end;

      TGLBBufferView = class
         Buffer, ByteOffset, ByteLength: Integer;
      end;

      TGLBAccessor = class
         BufferView, ByteOffset, Count, ComponentType: Integer;
         Typ: String;
      end;

      TGLBPrimitive = class
         Attributes: specialize TFPGMap<String, Integer>;
         Indices: Integer;
      end;

      TGLBMesh = class
         Primitives: Array of TGLBPrimitive;
      end;

      TGLBRoot = class
         BufferViews: Array of TGLBBufferView;
         Accessors: Array of TGLBAccessor;
         Meshes: Array of TGLBMesh;
      end;

      TGLBData = class
      end;

    function ReadHeader(stream: TFileStream): TGLBHeader;
    function ReadChuck(stream: TFileStream): TGLBChunk;
    function ReadVertices(accessor: TGLBAccessor; view: TGLBBufferView; binData: TBytes): specialize TArray<TVertex>;
  public
    function LoadGLB(path: String): TGLBData;
  end;



implementation

{ TGLBParser }

function TGLBParser.LoadGLB(path: String): TGLBData;
var
  stream: TFileStream;
  header: TGLBHeader;
  jsonChunk, binChunk: TGLBChunk;
  jsonString: String;
  root: TGLBRoot;
begin
   header := ReadHeader(stream);

   if header.Magic <> $46546C67 then // $46546C67 gibt an, dass die Datei vom typ GLB ist
      raise Exception.Create('Invalid GLB');

  jsonChunk := ReadChunk(stream);
  binChunk := ReadChunk(stream);

  SetString(json, PChar(@jsonChunk.Data[0]), Length(jsonChunk.Data);
  root := DeserializeJsonToRoot(jsonString);
end;

function TGLBParser.DeserializeJsonToRoot(jsonString: String): TGLBRoot;
var
  i: Integer;
  arrays: TJSONArray;
begin
  Result := TGLBRoot.Create;
  arrays := TJSONObject(GetJSON(jsonString)).Arrays;


  SetLength(Result.BufferViews, arrays['bufferViews'].Count);
  for i := 0 to High(arrays['bufferViews']) do
  begin
    Result.BufferViews[i] := TGLBBufferView.Create;
    Result.BufferViews[i].Buffer := arrays['bufferViews'].Objects[i].Get('buffer', 0);
    Result.BufferViews[i].ByteOffset := arrays['bufferViews'].Objects[i].Get('byteOffset', 0);
    Result.BufferViews[i].ByteLength := arrays['bufferViews'].Objects[i].Get('byteLength', 0);
  end;

  SetLength(Result.Accessors, arrays['accessors'].Count);
  for i := 0 to High(arrays['accessors']) do
  begin
    Result.Accessors[i] := TGLBAccessor.Create;
    Result.Accessors[i].BufferView := arrays['accessors'].Objects[i].Get('bufferView', 0);
    Result.Accessors[i].ByteOffset := arrays['accessors'].Objects[i].Get('byteOffset', 0);
    Result.Accessors[i].Count := arrays['accessors'].Objects[i].Get('count', 0);
    Result.Accessors[i].ComponentType := arrays['accessors'].Objects[i].Get('componentType', 0);
    Result.Accessors[i].Typ := arrays['accessors'].Objects[i].Get('type', 0);
  end;

  SetLength(Result.Meshes, arrays['meshes'].Count);
  for i := 0 to High(arrays['meshes']) do
  begin
    Result.Meshes[i] := TGLBMesh.Create;
    Result.Meshes[i].Buffer := arrays['meshes'].Objects[i].Get('buffer', 0);
    Result.Meshes[i].ByteOffset := arrays['meshes'].Objects[i].Get('byteOffset', 0);
    Result.Meshes[i].ByteLength := arrays['meshes'].Objects[i].Get('byteLength', 0);
  end;
end;

function TGLBParser.ReadVertices(accessor: TGLTFAccessor; view: TGLTFBufferView; binData: specialize TArray<Byte>): specialize TArray<TVertex>;
var
  vertices: specialize TArray<TVertex>;
  offset, baseOffset: Integer;
  x, y, z: Integer;
begin
   if accessor.ComponentType <> 5126 then
      raise Exception.Create('POSITION is not single');

   if accessor.Type <> 'VEC3' then
      raise Exception.Create('POSITION is not VEC3 (Vector3)');

   offset := accessor.ByteOffset + view.ByteOffset;
   SetLength(vertices, accessor.Count);

   for i := 0 to High(vertices) do begin
     baseOffset := offset + i * 12; // 3 singles = 12 bytes

     Move(binData[baseOffset], x, SizeOf(x));
     Move(binData[baseOffset], y, SizeOf(x + 4));
     Move(binData[baseOffset], z, SizeOf(x + 8));

     vertices[i] := TVertex.Create(x, y, z);
   end;

   Result := vertices;
end;

function TGLBParser.ReadHeader(stream: TFileStream): TGLBHeader;
begin
   Result := TGLBHeader.Create;
   stream.Read(Result.Magic, SizeOf(Result.Magic));
   stream.Read(Result.Version, SizeOf(Result.Version));
   stream.Read(Result.Length, SizeOf(Result.Length));
end;

function TGLBParser.ReadChuck(stream: TFileStream): TGLBChunk;
begin
   Result := TGLBChunk.Create;
   stream.Read(Result.Length, SizeOf(Result.Length));
   stream.Read(Result.ChunkType, SizeOf(Result.ChunkType));
   stream.Read(Result.Data, Result.Length);
end;

{ TVertex }

constructor TVertex.Create(aX, aY, aZ: Single);
begin
   X := aX;
   Y := aY;
   Z := aZ;
end;

end.

