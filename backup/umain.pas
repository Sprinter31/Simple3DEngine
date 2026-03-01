unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, uMesh, uRenderer;

type

  { TMainForm }

  TMainForm = class(TForm)
    DisplayCanvas: TPaintBox;
    procedure DisplayCanvasPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    renderer: TRenderer;
  public

  end;

var
  MainForm: TMainForm;
  ints: Array[0..10] of Integer;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.DisplayCanvasPaint(Sender: TObject);
var
  line: T2DLine;
begin
   DisplayCanvas.Canvas.Brush.Color := clBlack;
   DisplayCanvas.Canvas.Rectangle(DisplayCanvas.ClientRect);

   DisplayCanvas.Canvas.Pen.Color := clGreen;
   DisplayCanvas.Canvas.Pen.Width := 4;

   for line in renderer.RenderLines do begin
       DisplayCanvas.Canvas.MoveTo(Round(line.A.X), Round(line.A.Y));
       DisplayCanvas.Canvas.LineTo(Round(line.B.X), Round(line.B.Y));
   end;

end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  renderer := TRenderer.Create(Width, Height);
end;

end.

