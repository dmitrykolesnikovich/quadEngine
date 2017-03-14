using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.GameGraphic;

namespace Boxes.GameLogic
{
    class VaryingBox: Box
    {
        ColorChanger changer;

        public VaryingBox(double X, double Y, BoxColor Color): base(X, Y, Color) 
        {
            changer = new ColorChanger(Color, 4);
            changer.SetNewColor(Color);
        }
        public override void Proceed(double delta)
        {
            if (changer.Proceed(delta))
                changer.SetNewColor(this.Color.Next());    
            if (changer.Timer >= 2)
                this.Color = changer.NewBoxColor;
            /*
            if (changer.Proceed(delta))
            {
                this.Color = changer.NewBoxColor;
                changer.SetNewColor(this.Color.Next());
            }
             */
        }
        public override void Draw()
        {
            DrawBox.X = this.X * Size + Camera.X;
            DrawBox.Y = this.Y * Size + Camera.Y;
            DrawBox.Color = changer.DrawColor;
            DrawBox.Draw();
        }
    }
}
