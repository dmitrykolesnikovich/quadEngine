using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QuadEngine;

namespace Survival
{
    public sealed class GameModeManager
    {
        private static GameModeManager instance = null;
        
        public static GameModeMenu gameModeMenu;
        public static GameModeGame gameModeGame;
        public static GameModeCustomize gameModeCustomize;
        public static GameModeQuote gameModeQuote;

        private double xpos;
        private double ypos;

        private GameModeManager() 
        {
            gameModeMenu = new GameModeMenu();
            gameModeGame = new GameModeGame();
            gameModeCustomize = new GameModeCustomize();
            gameModeQuote = new GameModeQuote();

            this.GameMode = gameModeQuote;
        }

        public static GameModeManager Instance
        { 
            get
            {
                if (instance == null)
                {
                    instance = new GameModeManager();
                }
                return instance;
            }
        }

        public void Process(double delta)
        {
            if (GameMode != null)
                GameMode.Process(delta);
        }

        public void Draw()
        {
            if (GameMode != null)
                GameMode.Draw();

            if (GameMode == gameModeQuote)
                return;
            
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmNone);
            Resources.QuadRender.Rectangle(xpos - 3, ypos - 3, xpos + 3, ypos + 3, 0xFF000000);
            Resources.QuadRender.Rectangle(xpos - 2, ypos - 2, xpos + 2, ypos + 2, 0xFFCCFF00);
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
        }

        public void MouseDown(int X, int Y)
        {
            if (GameMode != null)
                GameMode.MouseDown(X, Y);
        }

        public void MouseUp(int X, int Y)
        {
            if (GameMode != null)
                GameMode.MouseUp(X, Y);
        }

        public void MouseMove(int X, int Y)
        {
            if (GameMode != null)
                GameMode.MouseMove(X, Y);

            this.xpos = X;
            this.ypos = Y;
        }

        public void KeyDown(Keys KeyCode)
        {
            if (GameMode != null)
                GameMode.KeyDown(KeyCode);           
        }

        public void KeyPress(Char KeyChar)
        {
            if (GameMode != null)
                GameMode.KeyPress(KeyChar);
        }

        public GameMode GameMode { get; set; }

    }
}
