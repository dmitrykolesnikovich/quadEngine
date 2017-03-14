program QuadShaderProject;

uses
  Forms,
  Form in 'Form.pas' {MainForm},
  GameOfLifeDemo in 'GameOfLifeDemo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
