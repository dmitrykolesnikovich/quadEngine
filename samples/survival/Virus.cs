using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;

namespace Survival
{
    public class Virus
    {
        private int xpos;
        private int ypos;
        private Country country;
        private int count;

        public Virus(int xpos, int ypos, Country country, int count)
        {
            this.xpos = xpos;
            this.ypos = ypos;
            this.country = country;
            this.count = count;
        }

        public void Draw(int position)
        {
            int x = xpos - position;
            if (x < 0) x += Resources.worldMap.GetSpriteWidth();
            if (x > Resources.worldMap.GetSpriteWidth()) x -= Resources.worldMap.GetSpriteWidth();
            Resources.spot.DrawRot(x, ypos, 0, count / 1000.0, 0xFFFF9933);
        }

        public void Grow() 
        {
            count = (int)Math.Round(count * 1.02);
        }

        public Vec2f Pos
        {
            get
            {
                return new Vec2f(xpos, ypos);
            }
        }

        public Country Country
        {
            get
            {
                return country;
            }
        }

    }
}
