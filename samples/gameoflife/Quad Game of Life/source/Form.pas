unit Form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  GameOfLifeDemo;

type
  TMainForm = class(TForm)
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    private
      FDemo: TDemo;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FDemo := TDemo.Create;
  ClientWidth := FDemo.ScreenWidth;
  ClientHeight := FDemo.ScreenHeight;

  FDemo.Initialize(Handle);
  FDemo.StartDemo;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FDemo.StopDemo;
  FreeAndNil(FDemo);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FDemo.OnKeyDown(Key);
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 27 then
  begin
    FDemo.StopDemo;
    Close
  end
  else
    FDemo.OnKeyUp(Key);
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDemo.OnMouseDown(Button, X, Y);
end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  FDemo.OnMouseMove(X, Y);
end;

procedure TMainForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDemo.OnMouseUp(Button, X, Y);
end;

end.
