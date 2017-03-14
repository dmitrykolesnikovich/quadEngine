using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Drawing;
using QuadEngine;

namespace Survival
{
    public sealed class GameModeGame:GameMode
    {
        private int position = 0;
        private bool isMoving = false;
        private int lastX;
        private int lastDay;

        private double gameTime;

        private VirusManager virusManager;

        public GameModeGame()
        {
            virusManager = new VirusManager();   
        }

        public override void Draw()
        {
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            Resources.QuadRender.Clear(0xFF222222);
            Resources.worldMap.Draw(-position, 0);

            virusManager.Draw(position);

            // todo day
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmAdd);
            Resources.sun.DrawRot(day * pixelPerDay - position, 600 + Math.Cos(ElapsedTime / 64) * 100, ElapsedTime * 2, 0.5f, 0x88FFFF99);
            Resources.sun.DrawRot(day * pixelPerDay - position, 600 + Math.Cos(ElapsedTime / 64) * 100, -ElapsedTime * 1.5, 0.55f, 0x88FFCC33);
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlphaMul);
            Resources.QuadFont.TextOut((float)day * pixelPerDay - position, (float)(600 + Math.Cos(ElapsedTime / 64) * 100) - 25, 0.5f, 
                day.ToString(), 0xFF000000, TqfAlign.qfaCenter);


            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);

            Country country = Resources.countries.GetCountry(base.xpos + position, base.ypos);

            if (country != null)
            {
                Resources.QuadRender.Rectangle(Resources.ScreenWidth / 2 - 150, 0, Resources.ScreenWidth / 2 + 150, 130, 0x88000000);
                Resources.QuadFont.TextOut(Resources.ScreenWidth / 2, 5.0f, 0.75f, country.name, 0xFFFFFFFF, TqfAlign.qfaCenter);
                Resources.QuadFont.TextOut(Resources.ScreenWidth / 2, 50.0f, 0.33f, "Population: " + country.maxPopulation.ToString(), 0xFFFFFFFF, TqfAlign.qfaCenter);
                Resources.QuadFont.TextOut(Resources.ScreenWidth / 2, 70.0f, 0.33f, "Year temp: " + country.maxYearTemperature.ToString(), 0xFFFFFFFF, TqfAlign.qfaCenter);
                Resources.QuadFont.TextOut(Resources.ScreenWidth / 2, 90.0f, 0.33f, "Min temp: " + country.minMonthTemperature.ToString(), 0xFFFFFFFF, TqfAlign.qfaCenter);
            }

            Resources.QuadFont.TextOut(Resources.ScreenWidth / 2, 680.0f, 0.5f, "World Population: " + Resources.countries.WorldPopulation.ToString(), 0xFFFFFFFF, TqfAlign.qfaCenter);

            #region progressbars
            Resources.QuadRender.Rectangle(4, 9, 206, 16, 0xFF000000); // spread
            Resources.QuadRender.Rectangle(4, 19, 206, 26, 0xFF000000); // cure
            Resources.QuadRender.Rectangle(4, 29, 206, 36, 0xFF000000); // dna errors
            
            Resources.QuadRender.Rectangle(5, 10, 205, 15, 0xFF22CC22); // spread
            Resources.QuadRender.Rectangle(5, 20, 105, 25, 0xFFCCCC22); // cure
            Resources.QuadRender.Rectangle(5, 30, 165, 35, 0xFFCC2222); // dna errors

            Resources.QuadFont.TextOut(210, 0, 0.25f, "Spread", 0xFF22CC22);
            Resources.QuadFont.TextOut(210, 12.5f, 0.25f, "Cure", 0xFFCCCC22);
            Resources.QuadFont.TextOut(210, 25, 0.25f, "DNA errors", 0xFFCC2222);
            #endregion
        }

        public override void Process(double dt)
        {
            base.Process(dt);

            if (!virusManager.IsEmpty)
            {
                gameTime += dt;
                if (lastDay != day)
                {
                    virusManager.Spread();
                    lastDay = day;
                }
            }
        }

        public override void MouseUp(int X, int Y)
        {            
            if ((lastX == X) && (virusManager.IsEmpty))
                virusManager.AddVirus(X + position, Y);

            isMoving = false;   
        }

        public override void MouseDown(int X, int Y)
        {
            isMoving = true;
            lastX = X;
        }

        public override void MouseMove(int X, int Y)
        {
            base.MouseMove(X, Y);

            if (isMoving)
            {
                position -= X - lastX;

                if (position > Resources.countries.WorldSize - Resources.ScreenWidth)
                    position = Resources.countries.WorldSize - Resources.ScreenWidth;

                if (position < 0)
                    position = 0;

                lastX = X;
            }
        }

        public override void KeyDown(Keys KeyCode)
        {
            switch (KeyCode)
            {
                case Keys.Escape:
                    GameModeManager.Instance.GameMode = GameModeManager.gameModeMenu;
                    break;
                case Keys.Space:
                    GameModeManager.Instance.GameMode = GameModeManager.gameModeCustomize;
                    break;
            }
        }

        public int year
        {
            get
            {
                return (int)Math.Floor(gameTime / 365) + 2013;
            }
        }

        private int day
        {
            get
            {
                return (int)(gameTime - Math.Floor(gameTime / 365) * 365);
            }
        }

        private float pixelPerDay
        {
            get
            {
                return Resources.countries.WorldSize / 365;
            }
        }
             
    }
}
