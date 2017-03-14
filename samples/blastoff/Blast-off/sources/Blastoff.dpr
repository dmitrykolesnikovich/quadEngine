program Blastoff;

uses
  Forms,
  Main_Form in 'Main_Form.pas' {Form2},
  FlyStone in 'FlyStone.pas',
  BaseSprite in 'BaseSprite.pas',
  GlobalConst in 'GlobalConst.pas',
  PlayerHero in 'PlayerHero.pas',
  Bullets in 'Bullets.pas',
  Collision_2d in 'Collision_2d.pas',
  GameRecord in 'GameRecord.pas',
  GameModes in 'GameModes.pas',
  iSettings in 'iSettings.pas',
  iSpriteEngine in 'iSpriteEngine.pas',
  MainMenu in 'MainMenu.pas',
  Pyro in 'Pyro.pas',
  Resources in 'Resources.pas',
  iCamera in 'iCamera.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
