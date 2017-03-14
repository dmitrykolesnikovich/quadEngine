using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Bots
{
    class BigMutant : CustomBot
    {
        private float[] Speed = new float[5] { 30.0f, 60.0f, 0.0f, 0.0f, 0.0f };
        private float[] FrameSpeed = new float[5] { 25.0f, 30.0f, 40.0f, 40.0f, 0.0f };
        private const BotAnimation DefaultAnimation = BotAnimation.Step;
        private bool Atack;

        public BigMutant(Vec2f APosition): base(APosition)
        {
            Radius = 20;
            Hp = 100;
        }

        public override void DrawBlood(Vec2f APosition)
        {
            Resources.QuadRender.BeginRender();
            Resources.QuadRender.RenderToTexture(true, Resources.GroundTarget);
            Random rand = new Random();
            Resources.QuadRender.SetBlendMode(QuadEngine.TQuadBlendMode.qbmSrcAlpha);
            Vec2f vec = APosition + APosition.Normalize() * 30.0f;

            Resources.Blood.DrawRotFrame(vec.X, vec.Y, rand.Next(360), rand.NextDouble() / 4 + 0.4f, 0);
            Resources.QuadRender.RenderToTexture(false, Resources.GroundTarget);
            Resources.QuadRender.EndRender();
        }

        public override void Hit()
        {
            Random rand = new Random();
            Bass.Bass.BASS_SamplePlay(Resources.HitMob[rand.Next(7)]);
        }

        public override void Death()
        {
            Random rand = new Random();
            Bass.Bass.BASS_SamplePlay(Resources.DeathMob[rand.Next(4)]);
        }

        public override void Kill()
        {
            if (!IsNeedToKill)
            {
                Resources.QuadRender.BeginRender();
                Resources.QuadRender.RenderToTexture(true, Resources.GroundTarget);
                Vec2f vec = Position + new Vec2f((float)Math.Cos(Angle + Math.PI * 1.30f), (float)Math.Sin(Angle + Math.PI * 1.30f)) * 30.0f;
                Random rand = new Random();
                Resources.Blood.DrawRotFrame(vec.X, vec.Y, rand.Next(360), rand.NextDouble() / 2 + 0.75f, 0);
                Resources.Mutant.Texture[(int)Animation].DrawRotFrame(Position.X, Position.Y, Angle * 180.0f / Math.PI, Scale, (ushort)Math.Truncate(Frame));
                Resources.QuadRender.RenderToTexture(false, Resources.GroundTarget);
                Resources.QuadRender.EndRender();
                IsNeedToKill = true;
                Player.AddPoints(100);
            }
        }

        public override void Process(float dt)
        {
            if ((IsNeedToKill) || (Animation == BotAnimation.Dead))
                return;

            Vector = (Player.Position - Position).Normalize();
            Angle = Vector.Angle() + (float)Math.PI;
            if ((Animation == BotAnimation.Step) || (Animation == BotAnimation.Run))
                Position += Vector * Speed[(int)Animation] * dt * Scale;

            if (DefaultAnimation == Animation && (Position.Distance(Player.Position) < 40.0f))
            {
                SetAnimation(BotAnimation.Atack);
                Atack = false;
            }

            if (Animation == BotAnimation.Atack && !Atack)
            {
                Atack = true;
                if (Position.Distance(Player.Position) < 40.0f)
                    Player.Damage(1.0f);
            }

            Frame += dt * FrameSpeed[(int)Animation];
            
            if (Frame > Resources.Mutant.Frame[(int)Animation])
            {
                switch (Animation)
                {
                    case (BotAnimation.Step): Frame -= Resources.Mutant.Frame[(int)Animation]; break;
                    case (BotAnimation.Run): Frame -= Resources.Mutant.Frame[(int)Animation]; break;
                    case (BotAnimation.Atack): SetAnimation(DefaultAnimation); break;
                    case (BotAnimation.Death): SetAnimation(BotAnimation.Dead); Kill(); break;
                }
            }
        }

        public override void Draw()
        {
            if (IsNeedToKill) 
                return;
            Resources.Mutant.Texture[(int)Animation].DrawRotFrame(Position.X, Position.Y, Angle * 180.0f / Math.PI, Scale, (ushort)Math.Truncate(Frame));
        }
    }
}
