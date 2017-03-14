using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QuadEngine;

namespace Survival
{
    public sealed class GameModeQuote:GameMode
    {
        private enum Mode{mIn, mWait, mOut, mWait2};

        private Mode mode = Mode.mIn;
        private double position = 0;

        public override void Draw()
        {
            Resources.QuadRender.Clear(0xFF111111);
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            
            switch (mode)
            {
                case Mode.mIn:
                    Resources.QuadRender.SetClipRect(0, 0, Resources.ScreenWidth, (uint)position);
                    break;
                case Mode.mOut:
                    if (position > Resources.ScreenHeight / 2)
                        Resources.QuadRender.SetClipRect(0, (uint)position - Resources.ScreenHeight / 2 + 1, Resources.ScreenWidth, Resources.ScreenHeight);
                    break;
            }

            if (mode != Mode.mWait2)
            {
                Resources.QuadFont.TextOut(Resources.ScreenWidth / 2, Resources.ScreenHeight / 2 - 100, 0.75f, "\"If you don't hunt it down and kill it,\r\nit will hunt you down and kill you.\"", 0xFFFFFFFF, TqfAlign.qfaCenter);
                Resources.QuadFont.TextOut(Resources.ScreenWidth / 2 + 330, Resources.ScreenHeight / 2 + 30, 0.33f, "Flannery O'Connor", 0xFFFFFFFF, TqfAlign.qfaRight);
            }

            switch (mode)
            {
                case Mode.mIn:
                    Resources.QuadRender.RectangleEx(0.0, position - Resources.ScreenHeight / 2, Resources.ScreenWidth, position, 0x00111111, 0x00111111, 0xFF111111, 0xFF111111);
                    break;
                case Mode.mOut:
                    Resources.QuadRender.RectangleEx(0.0, position - Resources.ScreenHeight / 2, Resources.ScreenWidth, position, 0xFF111111, 0xFF111111, 0x00111111, 0x00111111);
                    break;
            }

            Resources.QuadRender.SkipClipRect();
        }

        public override void Process(double dt)
        {
            base.Process(dt);

            position += Resources.ScreenHeight / 2 * dt;

            switch (mode)
            { 
                case Mode.mIn:
                    if (position > Resources.ScreenHeight)
                    {
                        mode = Mode.mWait;
                        position = 0;
                    }
                    break;
                case Mode.mWait:
                    if (position > Resources.ScreenHeight * 1.5)
                    {
                        mode = Mode.mOut;
                        position = 0;
                    }
                    break;
                case Mode.mOut:
                    if (position > Resources.ScreenHeight)
                    {
                        mode = Mode.mWait2;
                        position = 0;
                    }
                    break;
                case Mode.mWait2:
                    if (position > Resources.ScreenHeight / 2)
                        GameModeManager.Instance.GameMode = GameModeManager.gameModeMenu;
                    break;     
            }
        }

        public override void KeyDown(Keys KeyCode)
        {
            GameModeManager.Instance.GameMode = GameModeManager.gameModeMenu;
        }
    }
}
