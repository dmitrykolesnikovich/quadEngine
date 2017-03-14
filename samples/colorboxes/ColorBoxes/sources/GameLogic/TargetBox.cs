using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.GameGraphic;
using QuadEngine;
using Boxes.Resources;

namespace Boxes.GameLogic
{
    class TargetBox: MyBox
    {
        private IQuadTexture myTexture;
        public TargetBox(double X, double Y) : base(X, Y) { myTexture = GraphicResources.TextureMyBox; }
        public override void Draw()
        {
            DrawBox.X = this.X * Size + Camera.X;
            DrawBox.Y = this.Y * Size + Camera.Y;
            myTexture.Draw(Math.Truncate(DrawBox.X), Math.Truncate(DrawBox.Y));
            //DrawBox.Draw();
        }
    }
}
