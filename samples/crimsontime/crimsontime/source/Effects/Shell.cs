using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Effects
{
    class Shell : CustomEffect
    {
        private float Angle;
        private float Time = 0.0f;
        private Vec2f Vector;

        public Shell(Vec2f APosition): base(APosition)
        {
            Random rand = new Random();
            Angle = rand.Next(360);
        }

        public override void Process(float dt)
        {
            
        }

        public override void Draw()
        {
            if (IsNeedToKill)
                return;

            Resources.Shell.DrawRot(Position.X, Position.Y, Angle, 1.5f, 0xFFf2a952);

            if (Time > 2.0f)
            {
                Resources.QuadRender.RenderToTexture(true, Resources.GroundTarget);
                Random rand = new Random();
                Resources.Shell.DrawRot(Position.X, Position.Y, rand.Next(360), 1.5f, 0xFFf2a952);
                Resources.QuadRender.RenderToTexture(false, Resources.GroundTarget);
            }
        }
    }
}
