using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.GameLogic;

namespace Boxes.GameGraphic
{
    class BackGroundHorizontal : Background
    {
        public BackGroundHorizontal(BoxColor Color) : base(Color) { }
        public override void Draw(QuadEngine.IQuadRender render)
        {
            render.RectangleEx(0, 0, 200, 720, changer_left.DrawColor, changer.DrawColor,
                changer_left.DrawColor, changer.DrawColor);
            render.RectangleEx(1080, 0, 1280, 720, changer.DrawColor, changer_right.DrawColor,
                changer.DrawColor, changer_right.DrawColor);
            render.Rectangle(200, 0, 1080, 720, changer.DrawColor);
            base.Draw(render);
        }
    }
}
