using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Effects
{
    class Explosion : CustomEffect
    {
        private float Frame;
        private float Angle;
        private float Scale;
        private float Scale1;
        private bool Crater = false;

        public Explosion(Vec2f APosition): base(APosition)
        {
            Frame = 0.0f;
            Random rand = new Random();
            Angle = rand.Next(360);
            Scale = 1.0f;
            Bass.Bass.BASS_SamplePlay(Resources.sExplosion[rand.Next(2)]);
        }

        public override void Process(float dt)
        {
            Frame += 30.0f * dt;
            if (Frame > 53.0f)
                IsNeedToKill = true;

            if (Frame < 5.0f)
                Scale += 5.0f * dt;
            else
                if (Frame > 25.0f)
                    Scale -= 10.0f * dt;
            
            Random rand = new Random();
            if ((Frame < 32.0f) && (Scale > 0.0f))
                Scale1 = Scale + (float)(rand.NextDouble() / 2);
        }

        public override void Draw()
        {
            if (IsNeedToKill)
                return;

            Resources.Explosion.DrawRotFrame(Position.X, Position.Y, Angle, 1.5f, (ushort)Math.Truncate(Frame));

            if (!Crater && (Frame > 7.0f))
            {
                Resources.QuadRender.RenderToTexture(true, Resources.GroundTarget);
                Random rand = new Random();
                Resources.Crater.DrawRot(Position.X, Position.Y, rand.Next(360), 1.5f);
                Resources.QuadRender.RenderToTexture(false, Resources.GroundTarget);
                Crater = true;
            }
        }

        public override void  DrawLight()
        {
            if (IsNeedToKill || (Frame > 32.0f) || (Scale <= 0.0f))
                return;

            Resources.Light.DrawRot(Position.X, Position.Y, 0.0f, Scale1, 0xFFffb538);
        }
    }
}
