using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.GameLogic;
using Boxes.Resources;

namespace Boxes.GameGraphic
{
    class NewLevelScreen: IEffect
    {
        double timer = 0;
        double _mult = 1;
        bool flag = false;
        public delegate void OnBlackScreenHandler();
        public event OnBlackScreenHandler OnBlackScreen; 
        public NewLevelScreen(double mult)
        {
            GameManager.effects.Add(this);
            _mult = mult;
        }

        void IEffect.Proceed(double delta)
        {
            timer += delta * _mult;
            if (timer >= 3.14)
                GameManager.effects.Remove(this);
            if ((timer >= 3.14 / 2) && !flag && OnBlackScreen != null)
            {
                flag = true;
                OnBlackScreen();
            }
        }

        void IEffect.Draw()
        {
            QuadEngine.QuadColor color = Box.Colors[BoxColor.Black];
            color.A = Math.Sin(timer);
            GraphicResources.Render.Rectangle(0, 0, 1280, 720, color);
        }
    }
}
