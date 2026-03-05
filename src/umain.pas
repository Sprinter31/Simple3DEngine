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
  parser: TGLBParser;
begin
  parser := TGLBParser.Create;
  data := parser.LoadGLB('C:\Users\Leo\Downloads\the_origin_chapter_3_season_2.glb');

  FCurAnimationIndex := 0;
  FRenderer := TRenderer.Create(DisplayCanvas.Width, DisplayCanvas.Height);
  FAnimation := TAnimation.Create(data);
  FCurBitmap := FRenderer.RenderMesh(FAnimation.States[FCurAnimationIndex]);

  PaintTimer.Enabled := true;
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

