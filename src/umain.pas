unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus, uMesh,
  uAnimation, uRenderer, uGLTF;

type

  { TMainForm }

  TMainForm = class(TForm)
    DisplayCanvas: TPaintBox;
    FileDialog: TOpenDialog;
    TopBar: TMainMenu;
    MiLoadFile: TMenuItem;
    MiExit: TMenuItem;
    PaintTimer: TTimer;
    procedure DisplayCanvas_Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Form_Destroy(Sender: TObject);
    procedure MiExitClick(Sender: TObject);
    procedure MiLoadFileClick(Sender: TObject);
    procedure PaintTimer_Tick(Sender: TObject);
  private
    FCurBitmap: TBitmap;
    FAnimation: TAnimation;
    FCurAnimationIndex: Integer;
    FRenderer: TRenderer;
    FFileParser: TGLBParser;
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
begin
   // Startet im Models-Ordner des Projekts
   FileDialog.InitialDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Models';

  FFileParser := TGLBParser.Create;
  // Lädt am Anfang das Standardmodell
  data := FFileParser.LoadGLB('.\Models\cube.glb');

  FCurAnimationIndex := 0;
  FRenderer := TRenderer.Create(DisplayCanvas.Width, DisplayCanvas.Height);
  FAnimation := TAnimation.Create(data);
  FCurBitmap := FRenderer.RenderMesh(FAnimation.States[FCurAnimationIndex]);

  PaintTimer.Enabled := true;
end;

procedure TMainForm.DisplayCanvas_Paint(Sender: TObject);
begin
   // Zeichnet das aktuell gerenderte Bild auf die PaintBox
   DisplayCanvas.Canvas.Draw(0, 0, FCurBitmap);
end;

procedure TMainForm.PaintTimer_Tick(Sender: TObject);
var newBitmap: TBitmap;
begin
   // Rendert das nächste Bild der Animation
   newBitmap := FRenderer.RenderMesh(FAnimation.States[FCurAnimationIndex]);

   FCurBitmap.Free;

   FCurBitmap := NewBitmap;

   Inc(FCurAnimationIndex);
   if FCurAnimationIndex >= Length(FAnimation.States) then
      // Springt nach dem letzten Bild wieder zum Anfang
      FCurAnimationIndex := 0;

   DisplayCanvas.Invalidate;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
   // Passt Zeichenfläche und Renderer an die Fenstergröße an
   DisplayCanvas.SetBounds(0, 0, Width, Height);
   FRenderer.FScreenWidth := Width;
   FRenderer.FScreenHeight := Height;
end;

procedure TMainForm.Form_Destroy(Sender: TObject);
begin
  FCurBitmap.Free;
  FAnimation.Free;
  FRenderer.Free;
  FFileParser.Free;
end;

procedure TMainForm.MiExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.MiLoadFileClick(Sender: TObject);
var data: TGLBData;
begin
   PaintTimer.Enabled := False;

   if FileDialog.Execute then begin
      // Lädt das vom Benutzer ausgewählte Modell
      data := FFileParser.LoadGLB(FileDialog.FileName);
      FCurAnimationIndex := 0;
      FAnimation.Free;

      FAnimation := TAnimation.Create(data);
      FCurBitmap.Free;
      FCurBitmap := FRenderer.RenderMesh(FAnimation.States[FCurAnimationIndex]);
   end;

   PaintTimer.Enabled := True;
end;

end.

