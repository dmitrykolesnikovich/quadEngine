using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QuadEngine;

namespace Survival
{
    public sealed class GameModeMenu:GameMode
    {
        public override void Draw()
        {
            Resources.QuadRender.Clear(0x00000000);
            Resources.QuadFont.TextOut(Resources.ScreenWidth / 2, 0.0f, 0.75f, "Press space to start", 0xFFFFFFFF, TqfAlign.qfaCenter);
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmNone);
        }

        public override void MouseUp(int X, int Y)
        {
            GameModeManager.Instance.GameMode = GameModeManager.gameModeGame;
        }

        public override void KeyDown(Keys KeyCode)
        {
            switch (KeyCode)
            {
                case Keys.Space:
                    GameModeManager.Instance.GameMode = GameModeManager.gameModeGame;
                    break;
                case Keys.Escape:
                    Application.Exit();
                    break;
            }
        }
    }
}
