using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.GameLogic;

namespace Boxes.GameGraphic
{
    class BackGroundVertical : Background
    {
        public BackGroundVertical(BoxColor Color) : base(Color) { }
        public override void Draw(QuadEngine.IQuadRender render)
        {
            render.RectangleEx(0, 0, 1280, 150, changer_left.DrawColor, changer_left.DrawColor, 
                changer.DrawColor, changer.DrawColor);
            render.RectangleEx(0, 570, 1280, 720, changer.DrawColor, changer.DrawColor, 
                changer_right.DrawColor, changer_right.DrawColor);
            render.Rectangle(0, 150, 1280, 570, changer.DrawColor);
            base.Draw(render);
        }
    }
}
