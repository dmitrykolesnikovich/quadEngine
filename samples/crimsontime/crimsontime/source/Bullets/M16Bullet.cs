using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Bullets
{
    class M16Bullet : CustomBullet
    {
        private const float Length = 300.0f;
        private float length;

        public M16Bullet(Vec2f APosition, float AAngle): base(APosition, AAngle)
        {
            Speed = 1000.0f;
            length = Length;
            
            MinDamage = 10;
            MaxDamage = 20;
        }

        public override void Process(float dt)
        {
            Position += Vector * Speed * dt;
            if ((Position.X < -500.0f) || (Position.Y < -500.0f) || (Position.X > 1500.0f) || (Position.Y > 1300.0f))
                IsNeedToKill = true;
            
            Bots.CustomBot Bot = BotsEngine.GetBotColl(Position - Vector * Speed * dt, Position + Vector * length);
            if (Bot != null)
            {
                length = Position.Distance(Bot.Position);
                Random rand = new Random();
                Bot.Damage((float)(rand.Next(MaxDamage - MinDamage) + MinDamage));
                Bot.DrawBlood(Position + Vector * length);
                IsNeedToKill = true;
            }
        }

        public override void Draw()
        {
            float l = length / Length;
            Resources.Bullet.DrawMapRotAxis(Position.X, Position.Y, Position.X + length, Position.Y + 1.0f,
                Length - l, 0.0f, l, 1.0f, 
                Position.X, Position.Y, Angle * 180.0f / Math.PI, 1.0f, 0x99FFFFFF); 
        }
    }
}
