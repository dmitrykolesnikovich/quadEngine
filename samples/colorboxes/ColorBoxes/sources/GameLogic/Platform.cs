using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Boxes.GameLogic
{
    class Platform
    {
        List<Box> boxes = new List<Box>();
        double range = 0;
        double timer = 0;
        double cycle = 0;
        Collision direction;
        double x = 0;
        double y = 0;
        double prev_x = 0;
        double prev_y = 0;
        const double PI = 3.1416;

        public Platform(Collision direction, double range, double cycle)
        {
            this.direction = direction;
            this.range = range;
            this.cycle = cycle;
            //задаем направление, максимальное движение и скорость
        }

        public void AddBox(Box box)
        {
            boxes.Add(box);
        }

        public void Proceed(double delta)
        {
            timer += delta;
            switch (direction)
            {
                case Collision.Bottom: y = (1 +  Math.Sin(timer * PI / cycle - PI/2)) * range/2; break;
                case Collision.Top: y = (-1 + Math.Sin(timer * PI / cycle + PI/2)) * range/2; break;
                case Collision.Left: x = (-1 + Math.Sin(timer * PI / cycle + PI / 2)) * range/2; break;
                case Collision.Right: x = (1 + Math.Sin(timer * PI / cycle - PI / 2)) * range/2; break;
            }
            foreach (Box box in boxes)
            {
                box.X += (x - prev_x);
                box.Y += (y - prev_y);
            }
            prev_x = x;
            prev_y = y;
        }

    }
}
