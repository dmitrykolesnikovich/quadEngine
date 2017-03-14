using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Bullets
{
    public class Rocket : CustomBullet
    {
        private const float Length = 300.0f;
        private const float DistanceDamage = 128.0f;
        private float length;
        private Vec2f Cursor;
        private float Frame = 0.0f;
        private float Scale = 0.0f;
        private float Scale1 = 0.0f;

        public Rocket(Vec2f APosition, float AAngle): base(APosition, AAngle)
        {
            Cursor = new Vec2f(Mouse.X, Mouse.Y);
            Speed = 50.0f;
            length = Length;
            
            MinDamage = 10;
            MaxDamage = 20;
        }

        public override void Process(float dt)
        {
            Speed *= 1.1f;
            if (Speed > 400.0f)
                Speed = 400.0f;
            Vec2f temp = Position;
            Position += Vector * Speed * dt;
            if (Position.Distance(Cursor) > temp.Distance(Cursor))
            {
                IsNeedToKill = true;
            }
            if ((Position.X < -500.0f) || (Position.Y < -500.0f) || (Position.X > 1500.0f) || (Position.Y > 1300.0f))
                IsNeedToKill = true;

            Bots.CustomBot Bot = BotsEngine.GetBotColl(temp, Position);
            if ((Bot != null) || (Position.Distance(Cursor) > temp.Distance(Cursor)))
            {
                float Dis = Position.Distance(Player.Position);
                if (Dis < DistanceDamage)
                {
                    Player.Damage(18.0f / DistanceDamage * (DistanceDamage - Dis) * 2.0f);
                }
                new Effects.Explosion(Position);
                for (int i = 0; i < BotsEngine.Count(); i++)
                {
                    Dis = BotsEngine.Bots(i).Position.Distance(Position);
                    if (DistanceDamage > Dis)
                    {
                        BotsEngine.Bots(i).Damage((DistanceDamage - Dis) * 2.0f, false);
                    }
                }  
                IsNeedToKill = true;
            }

            Frame += 10.0f * dt;
            if (Frame >= 4.0f)
                Frame -= 4.0f;

            Random rand = new Random();
            Scale1 = Scale + (float)(0.2 + rand.NextDouble() / 10);
        }

        public override void Draw()
        {
            Resources.Rocket.DrawRotFrame(Position.X, Position.Y, Angle * 180.0f / Math.PI + 90.0f, 1, (ushort)Math.Truncate(Frame));
        }

        public override void DrawLight()
        {
            if (IsNeedToKill)
                return;
            Vec2f pos = Position - Vector * 10.0f;
            Resources.Light.DrawRot(pos.X, pos.Y, 0.0f, Scale1, 0xFFffb538);
        }
    }
}
