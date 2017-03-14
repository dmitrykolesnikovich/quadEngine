using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Guns
{
    public class CustomGun
    {
        public virtual void Process(float dt)
        {
        }

        public virtual void Fire(Vec2f APosition, float AAngle)
        {
        }

        public virtual void Draw()
        {
        }

        public virtual void DrawLight()
        {
        }
    }
}
