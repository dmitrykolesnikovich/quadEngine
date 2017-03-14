using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;

namespace Boxes.GameGraphic
{
    class DrawObject
    {
        protected IQuadTexture texture;

        public double X { get; set; }
        public double Y { get; set; }
        public QuadColor Color { get; set; }

        public DrawObject(IQuadTexture Texture, QuadColor Color)
        {
            this.texture = Texture;
            this.Color = Color;
        }

        public virtual void Draw()
        {
            texture.Draw(Math.Truncate(X), Math.Truncate(Y), Color);
        }
    }
}
