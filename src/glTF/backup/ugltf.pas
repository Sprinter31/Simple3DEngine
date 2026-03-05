unit uGLTF;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, fgl;

type
  TGLBData = class;
  TGLBNode = class;

  TVec3 = class
     X, Y, Z: Single;
     constructor Create(aX, aY, aZ: Single);
  end;

  TVec4 = class
     X, Y, Z, W: Single;
     constructor Create(aX, aY, aZ, aW: Single);
  end;

  TGLBParser = class
  private
    type
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

      TGLBAnimationSampler = class
         Input, Output: Integer;
         Interpolation: String;
      end;

      TGLBAnimationTarget = class
         Node: Integer;
         Path: String;
      end;

      TGLBAnimationChannel = class
         Sampler: Integer;
         Target: TGLBAnimationTarget;
      end;

      TGLBAnimation = class
         Samplers: specialize TArray<TGLBAnimationSampler>;
         Channels: specialize TArray<TGLBAnimationChannel>;
      end;

      TGLBRoot = class
         BufferViews: Array of TGLBBufferView;
         Accessors: Array of TGLBAccessor;
         Meshes: Array of TGLBMesh;
         Animations: specialize TArray<TGLBAnimation>;
         Nodes: specialize TArray<TGLBNode>;
      end;

    function DeserializeJsonToRoot(jsonString: String): TGLBRoot;
    function ReadHeader(stream: TFileStream): TGLBHeader;
    function ReadChunk(stream: TFileStream): TGLBChunk;
    function ReadVec3Array(accessor: TGLBAccessor; view: TGLBBufferView; binData: TBytes): specialize TArray<TVec3>;
    function ReadVec4Array(accessor: TGLBAccessor; view: TGLBBufferView; binData: TBytes): specialize TArray<TVec4>;
    function ReadSingleArray(accessor: TGLBAccessor; view: TGLBBufferView; binData: TBytes): specialize TArray<Single>;
    function ReadIndices(accessor: TGLBAccessor; view: TGLBBufferView; binData: TBytes): specialize TArray<Integer>;
  public
    function LoadGLB(path: String): TGLBData;
  end;

  TGLBNode = class
     Mesh: Integer;
     Children: specialize TArray<Integer>;
     Translation: TVec3;
     Rotation: TVec4;
     Scale: TVec3;
  end;

  TVFs = class
     Vertices: specialize TArray<TVec3>;
     Faces: specialize TArray<Integer>;
  end;

  TAnimationData = class
     Translations: specialize TArray<TVec3>;
     TranslationTimes: specialize TArray<Single>;
     Rotations: specialize TArray<TVEC4>;
     RotationTimes: specialize TArray<Single>;
     Scales: specialize TArray<TVec3>;
     ScaleTimes: specialize TArray<Single>;
  end;

  TGLBData = class
     Meshes: specialize TArray<TVFs>;
     Animation: TAnimationData;
     Nodes: specialize TArray<TGLBNode>;
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
  primitive: TGLBPrimitive;
  positionAccessor, indexAccessor, inputAccessor, outputAccessor: TGLBAccessor;
  positionView, indexView, inputView, outputView: TGLBBufferView;
  channel: TGLBAnimationChannel;
  sampler: TGLBAnimationSampler;
  i: Integer;
begin
   Result := TGLBData.Create;
   Result.Animation := TAnimationData.Create;

   stream := TFileStream.Create(path, fmOpenRead);
   try
      header := ReadHeader(stream);

      if header.Magic <> $46546C67 then // $46546C67 gibt an, dass die Datei vom typ GLB ist
         raise Exception.Create('Invalid GLB');

      jsonChunk := ReadChunk(stream);
      binChunk := ReadChunk(stream);

      SetString(jsonString, PAnsiChar(@jsonChunk.Data[0]), Length(jsonChunk.Data));
      root := DeserializeJsonToRoot(jsonString);

      SetLength(Result.Meshes, Length(root.Meshes));
      for i := 0 to High(root.Meshes) do begin
          primitive := root.Meshes[i].Primitives[0];

          positionAccessor := root.Accessors[primitive.Attributes['POSITION']];
          positionView := root.BufferViews[positionAccessor.BufferView];

          Result.Meshes[i] := TVFs.Create;
          Result.Meshes[i].Vertices := ReadVec3Array(positionAccessor, positionView, binChunk.Data);

          indexAccessor := root.Accessors[primitive.Indices];
          indexView := root.BufferViews[indexAccessor.BufferView];

          Result.Meshes[i].Faces := ReadIndices(indexAccessor, indexView, binChunk.Data);
      end;

      if Length(root.Animations) <= 0 then
         Exit;

      for channel in root.Animations[0].Channels do begin
          sampler := root.Animations[0].Samplers[channel.Sampler];

          inputAccessor := root.Accessors[sampler.Input];
          inputView := root.BufferViews[inputAccessor.BufferView];

          outputAccessor := root.Accessors[sampler.Output];
          outputView := root.BufferViews[outputAccessor.BufferView];

          case channel.Target.Path of
             'translation': begin
                Result.Animation.Translations := ReadVec3Array(outputAccessor, outputView, binChunk.Data);
                Result.Animation.TranslationTimes := ReadSingleArray(inputAccessor, inputView, binChunk.Data);
             end;
             'rotation': begin
                Result.Animation.Rotations := ReadVec4Array(outputAccessor, outputView, binChunk.Data);
                Result.Animation.RotationTimes := ReadSingleArray(inputAccessor, inputView, binChunk.Data);
             end;
             'scale': begin
                Result.Animation.Scales := ReadVec3Array(outputAccessor, outputView, binChunk.Data);
                Result.Animation.ScaleTimes := ReadSingleArray(inputAccessor, inputView, binChunk.Data);
             end;
          end;
      end;

      Result.Nodes := root.Nodes;
  finally
    stream.Free;
  end;
end;

function TGLBParser.DeserializeJsonToRoot(jsonString: String): TGLBRoot;
var
  i, j, k: Integer;
  rootObj, primitiveObj, attributesObj, targetObj, nodeObj: TJSONObject;
  bufferViewsArr, accessorsArr, meshesArr, animationsArr, primitiveArray, samplersArr, channelsArr, nodesArr, childrenArr, floatsArr: TJSONArray;
  key: String;
begin
  Result := TGLBRoot.Create;
  rootObj := TJSONObject(GetJSON(jsonString));

  bufferViewsArr := rootObj.Arrays['bufferViews'];
  accessorsArr  := rootObj.Arrays['accessors'];
  meshesArr := rootObj.Arrays['meshes'];
  if rootObj.Find('animations') <> Nil then
     animationsArr := rootObj.Arrays['animations'];
  nodesArr := rootObj.Arrays['nodes'];

  { BufferViews }
  SetLength(Result.BufferViews, bufferViewsArr.Count);
  for i := 0 to bufferViewsArr.Count - 1 do
  begin
    Result.BufferViews[i] := TGLBBufferView.Create;
    Result.BufferViews[i].Buffer := bufferViewsArr.Objects[i].Get('buffer', 0);
    Result.BufferViews[i].ByteOffset := bufferViewsArr.Objects[i].Get('byteOffset', 0);
    Result.BufferViews[i].ByteLength := bufferViewsArr.Objects[i].Get('byteLength', 0);
  end;

  { Accessors }
  SetLength(Result.Accessors, accessorsArr.Count);
  for i := 0 to accessorsArr.Count - 1 do
  begin
    Result.Accessors[i] := TGLBAccessor.Create;
    Result.Accessors[i].BufferView := accessorsArr.Objects[i].Get('bufferView', 0);
    Result.Accessors[i].ByteOffset := accessorsArr.Objects[i].Get('byteOffset', 0);
    Result.Accessors[i].Count := accessorsArr.Objects[i].Get('count', 0);
    Result.Accessors[i].ComponentType := accessorsArr.Objects[i].Get('componentType', 0);
    Result.Accessors[i].Typ := accessorsArr.Objects[i].Get('type', '');
  end;

  { Meshes }
  SetLength(Result.Meshes, meshesArr.Count);
  for i := 0 to meshesArr.Count - 1 do
  begin
    Result.Meshes[i] := TGLBMesh.Create;

    primitiveArray := meshesArr.Objects[i].Arrays['primitives'];
    SetLength(Result.Meshes[i].Primitives, primitiveArray.Count);

    { Primitives }
    for j := 0 to primitiveArray.Count - 1 do
    begin
       primitiveObj := primitiveArray.Objects[j];

       Result.Meshes[i].Primitives[j] := TGLBPrimitive.Create;
       Result.Meshes[i].Primitives[j].Attributes := specialize TFPGMap<String, Integer>.Create;

       { Attributes }
       attributesObj := PrimitiveObj.Objects['attributes'];
       for k := 0 to attributesObj.Count - 1 do
       begin
         key := attributesObj.Names[k];
         Result.Meshes[i].Primitives[j].Attributes.Add(key, attributesObj.Integers[key]);
       end;

       { Indives }
       Result.Meshes[i].Primitives[j].Indices := primitiveObj.Get('indices', 0);
    end;
  end;

  { Animations }
  SetLength(Result.Animations, animationsArr.Count);
  for i := 0 to animationsArr.Count - 1 do begin
     Result.Animations[i] := TGLBAnimation.Create;

     { Samplers }
     samplersArr := animationsArr.Objects[i].Arrays['samplers'];
     SetLength(Result.Animations[i].Samplers, samplersArr.Count);

     for j := 0 to samplersArr.Count - 1 do begin
        Result.Animations[i].Samplers[j] := TGLBAnimationSampler.Create;
        Result.Animations[i].Samplers[j].Input := samplersArr.Objects[j].Get('input', 0);
        Result.Animations[i].Samplers[j].Output := samplersArr.Objects[j].Get('output', 0);
        Result.Animations[i].Samplers[j].Interpolation := samplersArr.Objects[j].Get('interpolation', 'LINEAR');
     end;

     { Channels }
     channelsArr := animationsArr.Objects[i].Arrays['channels'];
     SetLength(Result.Animations[i].Channels, channelsArr.Count);

     for j := 0 to channelsArr.Count - 1 do begin
        Result.Animations[i].Channels[j] := TGLBAnimationChannel.Create;
        Result.Animations[i].Channels[j].Sampler := channelsArr.Objects[j].Get('sampler', 0);

        targetObj := channelsArr.Objects[j].Objects['target'];
        Result.Animations[i].Channels[j].Target := TGLBAnimationTarget.Create;
        Result.Animations[i].Channels[j].Target.Node := targetObj.Get('node', 0);
        Result.Animations[i].Channels[j].Target.Path := targetObj.Get('path', '');
     end;
  end;

  { Nodes }
  SetLength(Result.Nodes, nodesArr.Count);
  for i := 0 to nodesArr.Count - 1 do begin
     nodeObj := nodesArr.Objects[i];
     Result.Nodes[i] := TGLBNode.Create;
     Result.Nodes[i].Mesh := nodeObj.Get('mesh', -1);

     { Children }
     if nodeObj.Find('children') <> Nil then begin
        childrenArr := nodeObj.Arrays['children'];
        SetLength(Result.Nodes[i].Children, childrenArr.Count);

        for j := 0 to childrenArr.Count - 1 do
            Result.Nodes[i].Children[j] := childrenArr.Integers[j];
     end;

     { Translation }
     if nodeObj.Find('translation') <> Nil then begin
        floatsArr := nodeObj.Arrays['translation'];
        if floatsArr.Count >= 3 then
           Result.Nodes[i].Translation := TVec3.Create(floatsArr.Floats[0], floatsArr.Floats[1], floatsArr.Floats[2]);
     end;

     { Rotation }
     if nodeObj.Find('rotation') <> Nil then begin
        floatsArr := nodeObj.Arrays['rotation'];
        if floatsArr.Count >= 4 then
           Result.Nodes[i].Rotation := TVec4.Create(floatsArr.Floats[0], floatsArr.Floats[1], floatsArr.Floats[2], floatsArr.Floats[3]);
     end;

     { Scale }
     if nodeObj.Find('scale') <> Nil then begin
        floatsArr := nodeObj.Arrays['scale'];
        if floatsArr.Count >= 3 then
           Result.Nodes[i].Scale := TVec3.Create(floatsArr.Floats[0], floatsArr.Floats[1], floatsArr.Floats[2]);
     end;
  end;
end;

function TGLBParser.ReadVec3Array(accessor: TGLBAccessor; view: TGLBBufferView; binData: TBytes): specialize TArray<TVec3>;
var
  vertices: specialize TArray<TVec3>;
  offset, baseOffset: Integer;
  x, y, z: Single;
  i: Integer;
begin
   if accessor.ComponentType <> 5126 then
      raise Exception.Create('POSITION is not single');

   if accessor.Typ <> 'VEC3' then
      raise Exception.Create('POSITION is not VEC3');

   offset := accessor.ByteOffset + view.ByteOffset;
   SetLength(vertices, accessor.Count);

   for i := 0 to High(vertices) do begin
     baseOffset := offset + i * 12; // 3 singles = 12 bytes

     Move(binData[baseOffset], x, SizeOf(Single));
     Move(binData[baseOffset + 4], y, SizeOf(Single));
     Move(binData[baseOffset + 8], z, SizeOf(Single));

     vertices[i] := TVec3.Create(x, y, z);
   end;

   Result := vertices;
end;

function TGLBParser.ReadVec4Array(accessor: TGLBAccessor; view: TGLBBufferView; binData: TBytes): specialize TArray<TVec4>;
var
  rotations: specialize TArray<TVec4>;
  offset, baseOffset: Integer;
  x, y, z, w: Single;
  i: Integer;
begin
   if accessor.ComponentType <> 5126 then
      raise Exception.Create('POSITION is not single');

   if accessor.Typ <> 'VEC4' then
      raise Exception.Create('POSITION is not VEC4');

   offset := accessor.ByteOffset + view.ByteOffset;
   SetLength(rotations, accessor.Count);

   for i := 0 to High(rotations) do begin
     baseOffset := offset + i * 16; // 4 singles = 16 bytes

     Move(binData[baseOffset], x, SizeOf(Single));
     Move(binData[baseOffset + 4], y, SizeOf(Single));
     Move(binData[baseOffset + 8], z, SizeOf(Single));
     Move(binData[baseOffset + 12], w, SizeOf(Single));

     rotations[i] := TVec4.Create(x, y, z, w);
   end;

   Result := rotations;
end;

function TGLBParser.ReadSingleArray(accessor: TGLBAccessor; view: TGLBBufferView; binData: TBytes): specialize TArray<Single>;
var
  offset, i: Integer;
begin
   offset := view.ByteOffset + accessor.ByteOffset;
   SetLength(Result, accessor.Count);

   for i := 0 to accessor.Count - 1 do
       Move(binData[offset + i * 4], Result[i], SizeOf(single));
end;

function TGLBParser.ReadIndices(accessor: TGLBAccessor; view: TGLBBufferView; binData: TBytes): specialize TArray<Integer>;
var
  i, offset: Integer;
begin
   offset := accessor.ByteOffset + view.ByteOffset;
   SetLength(Result, accessor.Count);

   if accessor.ComponentType = 5123 then // ushort/Word
      for i := 0 to High(Result) do
          Move(binData[offset + i * 2], Result[i], SizeOf(Word))
   else if accessor.ComponentType = 5125 then // uint/cardinal
      for i := 0 to High(Result) do
          Move(binData[offset + i * 4], Result[i], SizeOf(Cardinal))
   else
      raise Exception.Create('Unsupported index type')
end;

function TGLBParser.ReadHeader(stream: TFileStream): TGLBHeader;
begin
   Result := TGLBHeader.Create;
   stream.Read(Result.Magic, SizeOf(Result.Magic));
   stream.Read(Result.Version, SizeOf(Result.Version));
   stream.Read(Result.Length, SizeOf(Result.Length));
end;

function TGLBParser.ReadChunk(stream: TFileStream): TGLBChunk;
begin
   Result := TGLBChunk.Create;
   stream.Read(Result.Length, SizeOf(Result.Length));
   stream.Read(Result.Typ, SizeOf(Result.Typ));

   SetLength(Result.Data, Result.Length);
   stream.Read(Result.Data[0], Result.Length);
end;

{ TVec3 }

constructor TVec3.Create(aX, aY, aZ: Single);
begin
   X := aX;
   Y := aY;
   Z := aZ;
end;

{ TVec4 }

constructor TVec4.Create(aX, aY, aZ, aW: Single);
begin
   X := aX;
   Y := aY;
   Z := aZ;
   W := aW;
end;

end.

