using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace quadtest.Light
{
    class CustomLight
    {
        public bool IsNeedToKill { get; set; }

        public virtual void Process(float dt)
        {
        }

        public virtual void Draw()
        {
        }
    }
}
