using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.GameLogic;
using Boxes.Resources;
using QuadEngine;

namespace Boxes.GameGraphic
{
    class BoxDestroy: IEffect
    {
        private IList<BoxPart> parts = new List<BoxPart>();
        private double timer = 0;
        public const double FINISH_TIME = 2; 
        
        public BoxDestroy(Box box)
        {
            for (int i = -2; i < 2; i++)
                for (int j = -2; j < 2; j++)
                parts.Add(new BoxPart(box, i, j));
            GameManager.effects.Add(this);
        }
        public void Proceed(double delta)
        {
            if (timer >= FINISH_TIME)
                GameManager.effects.Remove(this);

            foreach (BoxPart part in parts)
                part.Proceed(delta);
            timer += delta;
        }       
        public void Draw()
        {
            foreach (BoxPart part in parts)
                part.Draw();     
        }
    }

    class BoxPart
    {
        private int partNo;
        private DrawPart DrawPartObject;
        private double _x;
        private double _y;
        private double _vx;
        private double _vy;
        private double timer = 0;

        public static double Size { get; set; }
        private static Random rnd = new Random();

        private double X { get; set; }
        private double Y { get; set; }
        private BoxColor Color { get; set; }

        public BoxPart(Box box, int x, int y)
        {
            this.Color = box.Color;
            this.partNo = (x + 2) + (y + 2) * 4;

            _x = x;
            _y = y;

            this.X = box.X + (x+2) * BoxPart.Size/Box.Size;
            this.Y = box.Y + (y+2) * BoxPart.Size/Box.Size;

            DrawPartObject = new DrawPart(GraphicResources.TextureBoxDestroyed, Box.Colors[this.Color], partNo);
            DrawPartObject.X = this.X;
            DrawPartObject.Y = this.Y;

            _vx = (rnd.Next(-15, 15)+_x);
            _vy = (rnd.Next(-15, 15)+_y);
        }

        public void Proceed(double delta)
        {
            _vy += 8 * delta;
            Y += _vy * delta;
            X += _vx * delta;
            timer += delta;
            // хочу сделать прозрачным
            DrawPartObject.Color =  DrawPartObject.Color.Lerp(new QuadColor(1,1,1,0), timer/100);
        }

        public void Draw()
        {
            DrawPartObject.X = this.X * Box.Size + Camera.X;
            DrawPartObject.Y = this.Y * Box.Size + Camera.Y;
            DrawPartObject.Draw();
        }
    }
}
