program Shadow;

uses
  Forms,
  Main in 'Main.pas' {GameWin},
  CustomGameObject in 'CustomGameObject.pas',
  Resources in 'Resources.pas',
  GameMode in 'GameMode.pas',
  Floor in 'Floor.pas',
  Inputs in 'Inputs.pas',
  Maps in 'Maps.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGameWin, GameWin);
  Application.Run;
end.
