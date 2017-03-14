using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QuadEngine;

namespace Survival
{
    public sealed class GameModeCustomize:GameMode
    {
        public override void Draw()
        {
            Resources.QuadRender.Clear(0x00000000);
            Resources.QuadRender.RectangleEx(0, 0, Resources.ScreenWidth / 3, Resources.ScreenHeight, 
                0xFFCC8888, 0xFFCC8888, 0xFF882222, 0xFF882222);
            Resources.QuadRender.RectangleEx(Resources.ScreenWidth / 3, 0, Resources.ScreenWidth / 3 * 2, Resources.ScreenHeight, 
                0xFF88CC88, 0xFF88CC88, 0xFF228822, 0xFF228822);
            Resources.QuadRender.RectangleEx(Resources.ScreenWidth / 3 * 2, 0, Resources.ScreenWidth / 3 * 3, Resources.ScreenHeight, 
                0xFF8888CC, 0xFF8888CC, 0xFF222288, 0xFF222288);
            Resources.QuadFont.TextOut(Resources.ScreenWidth / 2, 0.0f, 0.75f, "Customize", 0xFFFFFFFF, TqfAlign.qfaCenter);
        }

        public override void MouseUp(int X, int Y)
        {
            GameModeManager.Instance.GameMode = GameModeManager.gameModeGame;
        }

        public override void KeyDown(Keys KeyCode)
        {
            switch (KeyCode)
            {
                case Keys.Escape:
                    GameModeManager.Instance.GameMode = GameModeManager.gameModeGame;
                    break;
            }
        }
    }
}
