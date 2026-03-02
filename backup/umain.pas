unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, uMesh, uAnimation, uRenderer;

type

  { TMainForm }

  TMainForm = class(TForm)
    DisplayCanvas: TPaintBox;
    PaintTimer: TTimer;
    procedure DisplayCanvas_Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TMainForm.DisplayCanvas_Paint(Sender: TObject);
begin
   DisplayCanvas.Canvas.Draw(0, 0, FCurBitmap);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FCurAnimationIndex := 0;
  FRenderer := TRenderer.Create(DisplayCanvas.Width, DisplayCanvas.Height);
  FAnimation := TAnimation.Create;
  FCurBitmap := FRenderer.RenderMesh(FAnimation.States[FCurAnimationIndex]);

  PaintTimer.Enabled := true;
end;

procedure TMainForm.PaintTimer_Tick(Sender: TObject);
begin
   FCurBitmap := FRenderer.RenderMesh(FAnimation.States[FCurAnimationIndex]);

   Inc(FCurAnimationIndex);
   if FCurAnimationIndex >= Length(FAnimation.States) then
      FCurAnimationIndex := 0;

   DisplayCanvas.Invalidate;
end;

end.

