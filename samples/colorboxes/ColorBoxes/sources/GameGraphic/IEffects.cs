using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Boxes.GameGraphic
{
    interface IEffect
    {
        void Proceed(double delta);
        void Draw();
    }
}
