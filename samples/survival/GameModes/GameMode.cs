using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Survival
{
    public abstract class GameMode
    {
        public double ElapsedTime;
        public int xpos;
        public int ypos;

        public abstract void Draw();

        public virtual void Process(double dt)
        {
            ElapsedTime += dt;
        }

        public virtual void MouseDown(int X, int Y)
        {

        }

        public virtual void MouseUp(int X, int Y)
        {

        }

        public virtual void MouseMove(int X, int Y)
        {
            this.xpos = X;
            this.ypos = Y;
        }

        public virtual void KeyDown(Keys KeyCode)
        {

        }

        public virtual void KeyPress(Char KeyChar)
        {

        }
    }
}
