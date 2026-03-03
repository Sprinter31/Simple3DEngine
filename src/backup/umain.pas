unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, uMesh, uAnimation, uRenderer, uGLTF;

type

  { TMainForm }

  TMainForm = class(TForm)
    DisplayCanvas: TPaintBox;
    PaintTimer: TTimer;
    procedure DisplayCanvas_Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Form_Destroy(Sender: TObject);
    procedure PaintTimer_Tick(Sender: TObject);
  private
    FCurBitmap: TBitmap;
    FAnimation: TAnimation;
    FCurAnimationIndex: Integer;
    FRenderer: TRenderer;
    FGLBParser: TGLBParser;
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  data: TGLBData;
  i: Integer;
begin
  FCurAnimationIndex := 0;
  FRenderer := TRenderer.Create(DisplayCanvas.Width, DisplayCanvas.Height);
  FAnimation := TAnimation.Create;
  FCurBitmap := FRenderer.RenderMesh(FAnimation.States[FCurAnimationIndex]);
  FGLBParser := TGLBParser.Create;
  PaintTimer.Enabled := true;



  data := FGLBParser.LoadGLB('C:\Users\Leo\Downloads\henry_waternoose_monsters_inc.glb');


  for i := 0 to High(data.Vertices) do
      ShowMessage('Vertex: ' + FloatToStr(data.Vertices[i].X)) + ', ' + FloatToStr(data.Vertices[i].Y) + ', ' + FloatToStr(data.Vertices[i].Z));
end;



procedure TMainForm.DisplayCanvas_Paint(Sender: TObject);
begin
   DisplayCanvas.Canvas.Draw(0, 0, FCurBitmap);
end;

procedure TMainForm.PaintTimer_Tick(Sender: TObject);
var newBitmap: TBitmap;
begin
   newBitmap := FRenderer.RenderMesh(FAnimation.States[FCurAnimationIndex]);

   FCurBitmap.Free;

   FCurBitmap := NewBitmap;

   Inc(FCurAnimationIndex);
   if FCurAnimationIndex >= Length(FAnimation.States) then
      FCurAnimationIndex := 0;

   DisplayCanvas.Invalidate;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
   DisplayCanvas.SetBounds(0, 0, Width, Height);
   FRenderer.FScreenWidth := Width;
   FRenderer.FScreenHeight := Height;
end;

procedure TMainForm.Form_Destroy(Sender: TObject);
begin
  FCurBitmap.Free;
  FAnimation.Free;
  FRenderer.Free;
end;

end.

