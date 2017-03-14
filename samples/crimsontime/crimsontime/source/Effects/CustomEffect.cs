using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Effects
{
    class CustomEffect
    {
        public bool IsNeedToKill { get; set; }
        public Vec2f Position { get; set; }

        public CustomEffect(Vec2f APosition)
        {
            IsNeedToKill = false;
            Position = APosition;
            EffectEngine.Add(this);
        }

        public virtual void Process(float dt)
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
