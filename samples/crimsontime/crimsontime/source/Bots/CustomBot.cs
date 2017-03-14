using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Bots
{
    public enum BotAnimation
    {
        Step = 0,
        Run = 1, 
        Atack = 2,
        Death = 3,
        Dead = 4
    }

    public class CustomBot
    {
        public bool IsNeedToKill { get; set; }
        protected float Radius { get; set; }
        protected float Frame { get; set; }
        protected Vec2f Vector { get; set; }
        protected float Angle { get; set; }
        protected BotAnimation Animation { get; set; }
        protected float Hp { get; set; }
        protected float Scale { get; set; }
        public Vec2f Position;

        public void Damage(float ADamage, bool IsHit = true)
        {
            Hit();
            if (Hp <= 0.0f)
                return;
            Hp -= ADamage;

            if (Hp <= 0.0f)
            {
                SetAnimation(BotAnimation.Death);
                Hp = 0.0f;
                Death();
            }
            Player.AddPoints((int)ADamage);
        }

        public virtual void Hit()
        {
        }

        public virtual void Death()
        {
        }

        public virtual void DrawBlood(Vec2f APosition)
        {
        }

        public float GetRadius()
        {
            return Radius;
        }

        public CustomBot(Vec2f APosition)
        {
            BotsEngine.Add(this);
            IsNeedToKill = false;
            SetAnimation(BotAnimation.Step);
            Position = APosition;
            Vector = (Player.Position - Position).Normalize();
            Angle = (float)(-Math.Atan2(Vector.X, Vector.Y));
            BotsEngine.Add(this);
            Random rand = new Random();
            Scale = (float)(rand.NextDouble() / 2 + 0.75f);
        }

        public virtual void Kill()
        {
        }

        protected void SetAnimation(BotAnimation AAnimation)
        {
            Animation = AAnimation;
            Frame = 0.0f;
        }

        public virtual void Process(float dt)
        {          
        }

        public virtual void Draw()
        {
        }
    }
}
