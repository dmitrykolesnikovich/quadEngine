using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.Resources;
using QuadEngine;
using Boxes.GameGraphic;

namespace Boxes.GameLogic
{
    class ExplosiveBox: Box
    {
        bool _exploding = false;
        double _timer = 0;
        double EXPLODE_TIME = 0.4;
        IQuadTexture center = GraphicResources.TextureCenter;
        QuadColor curCenterColor;
        double dist = 0;
        bool transparent = false;

        public ExplosiveBox(double X, double Y, BoxColor Color) : base(X, Y, Color) 
        {
            curCenterColor = Box.Colors[Color];
        }
        public override List<Collision> Collision(Box otherBox, BoxColor backColor)
        {
            List<Collision> result = base.Collision(otherBox, backColor);
            if (result.Contains(GameLogic.Collision.Top))
                _exploding = true;

            return result;
        }
        public override void Proceed(double delta)
        {
            if (transparent == false)
                dist += delta * 2.5;
            else
                dist -= delta * 2.5;

            if (dist >= 1)
            {
                dist = 1;
                transparent = true;
            }
            else if (dist <= 0)
            {
                dist = 0;
                transparent = false;
            }

            curCenterColor.A = dist;
            
            if (!_exploding)
                return;

            _timer += delta;
            if (_timer >= EXPLODE_TIME)
                this.Destroy();
        }
        public override void Draw()
        {
            base.Draw();
            center.Draw(Math.Truncate(this.X * Size + Camera.X + 15), 
                        Math.Truncate(this.Y * Size + Camera.Y + 15), curCenterColor);

        }
    }
}
