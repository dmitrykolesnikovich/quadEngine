program ShatteredVoid;

uses
  Forms,
  MainForm in 'MainForm.pas' {Form1},
  defs in 'defs.pas',
  MainMenu in 'MainMenu.pas',
  Resources in 'Resources.pas',
  BaseGameMode in 'BaseGameMode.pas',
  gmMainMenu in 'gmMainMenu.pas',
  Player in 'Player.pas',
  fxExplosion in 'fxExplosion.pas',
  Enemies in 'Enemies.pas',
  Bullets in 'Bullets.pas';

{$R *.res}

begin
 // ReportMemoryLeaksOnShutdown:= true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
