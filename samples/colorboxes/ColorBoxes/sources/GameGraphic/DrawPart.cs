using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;

namespace Boxes.GameGraphic
{
    class DrawPart : DrawObject
    {
        int _frameNo;

        public DrawPart(IQuadTexture Texture, QuadColor Color, int FrameNo) :
            base(Texture, Color)
        {
            _frameNo = FrameNo;
        }
        public override void Draw()
        {
            texture.DrawFrame(Math.Truncate(X), Math.Truncate(Y), (ushort)_frameNo, Color);
            //texture.Draw(Math.Truncate(X), Math.Truncate(Y), Color);
        }
    }
}
