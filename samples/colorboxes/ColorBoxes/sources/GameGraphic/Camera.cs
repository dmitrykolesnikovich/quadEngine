using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.GameLogic;

namespace Boxes.GameGraphic
{
    static class Camera
    {
        private static double _x;
        private static double _y;
        public static double X { get { return _x; } }
        public static double Y { get { return _y; } }

        public static void ChangeCamera(MyBox box, EventArgs e)
        {
            _x = (1280  /2) - Box.Size * (box.X + 0.5);
            _y = (720 / 2) - Box.Size * (box.Y + 0.5);
        }

    }
}
