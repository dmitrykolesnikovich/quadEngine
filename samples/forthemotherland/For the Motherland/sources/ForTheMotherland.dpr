program ForTheMotherland;

uses
  Forms,
  Main in 'Main.pas' {GameWin},
  BattleGameMode in 'BattleGameMode.pas',
  Map in 'Map.pas',
  CustomUnit in 'CustomUnit.pas',
  Collision in 'Collision.pas',
  mSettings in 'mSettings.pas',
  Resources in 'Resources.pas',
  Cursor in 'Cursor.pas',
  Effects in 'Effects.pas',
  AI in 'AI.pas',
  MainMenuMode in 'MainMenuMode.pas',
  UnitsConfig in 'UnitsConfig.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGameWin, GameWin);
  Application.Run;
end.
