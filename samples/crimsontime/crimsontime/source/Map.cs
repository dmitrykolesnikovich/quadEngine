using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using QuadEngine;
using Vectors;

namespace quadtest
{
    class Map
    {        
        public void Init()
        {
            for (int x = 0; x <= 3; x++)
                if (x == 2)
                    new Light.LanternBlink(new Vec2f(x * 256.0f + 132.0f, 326.0f));
                else
                    new Light.Lantern(new Vec2f(x * 256.0f + 132.0f, 326.0f));
        }

        public void Draw()
        {
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmNone);
            for (int y = 0; y <= 2; y++)
                for (int x = 0; x <= 3; x++)
                    Resources.Ground.Draw(x * 256.0f, y * 256.0f);

            for (int x = 0; x <= 7; x++)
                Resources.Road.Draw(x * 128.0f, 300.0f);
        }

        public void Draw1()
        {
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            for (int x = 0; x <= 3; x++)
                Resources.Pillar.Draw(x * 256.0f + 128.0f, 270.0f);
        }
    }
}
