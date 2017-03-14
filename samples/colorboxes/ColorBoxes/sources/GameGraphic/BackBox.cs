using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;
using Boxes.Resources;

namespace Boxes.GameGraphic
{
    class BackBox
    {
        IQuadTexture texture;
        double _x = 0;
        double _y = 0;
        double vx = 0;
        double vy = 0;
        int size = 1;
        private static Random rnd = new Random();
        
        public BackBox(int size, int x, int y) // от 1 до 4
        {
            texture = GraphicResources.TextureBox;
            _x = rnd.Next(x * 80, (x + 1) * 80);
            _y = rnd.Next(y * 80, (y + 1) * 80);
            this.size = size; //rnd.Next(2, 8);

            if (rnd.Next(2) == 0)
                vx = -1 * size;
            else
                vx = 1 * size;

            if (rnd.Next(2) == 0)
                vy = -1 * size;
            else
                vy = 1 * size;
        }

        public void Proceed(double delta)
        {
            _x += vx * delta;
            _y += vy * delta;


            if ((_x - 20 * size > 1280) && (vx > 0))
                _x = -20 * size;
            if ((_x + 20 * size < 0) && (vx < 0))
                _x = 1280 + 20 * size;
            if ((_y - 20 * size > 720) && (vy > 0))
                _y = -20 * size;
            if ((_y + 20 * size < 0) && (vy < 0))
                _y = 720 + 20 * size;

        }

        public void  Draw()
        {
            QuadColor color = new QuadColor(0, 0, 0, 0.04 + 0.01*size);
            texture.DrawRot(_x + Camera.X/20*size, _y + Camera.Y/20*size, 0, size, color);
        }
    }
}
