using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;
using System.Windows.Forms;

namespace quadtest.Guns
{
    class M16 : CustomGun
    {
        private const float Cooldown = 0.05f;
        private const float Dispersal = 0.05f;
        private const int ClipSize = 128;

        private float recharge = 0.0f;
        private bool muzzle = false;
        private int clip = ClipSize;

        public int Clip { get { return clip; } }

        public void Reload()
        {
            clip = 0;
            recharge = 0.0f;
            Bass.Bass.BASS_SamplePlay(Resources.M15Reload);  
        }

        public override void Process(float dt)
        {
            if (Keyboard.Down(Keys.R) && clip > 0)
                Reload();

            if ((Cooldown > recharge) || (clip == 0))
                recharge += dt;
            if (muzzle)
                muzzle = false;
            if (clip == 0 && recharge > 2.0f)
            {
                clip = ClipSize;
                recharge -= 2.0f;
            }
        }

        public override void Fire(Vec2f APosition, float AAngle)
        {
            if (clip == 0)
                return;
            Random rand = new Random();
            while (recharge > Cooldown)
            {
                AAngle += (float)(rand.NextDouble() * 2.0f - 1.0f) * Dispersal;
                new Bullets.M16Bullet(APosition, AAngle);
                recharge -= Cooldown;
                muzzle = true;
                Bass.Bass.BASS_SamplePlay(Resources.M16[rand.Next(3)]);
                clip--;
                if (clip == 0)
                    Reload();
            }
        }

        public override void Draw()
        {
            if (muzzle)
            {
                Vec2f Position = Player.Position + new Vec2f((float)Math.Cos(Player.GetRadian()), (float)Math.Sin(Player.GetRadian())) * 20.0f;
                Resources.Muzzle.DrawRotAxis(Position.X - 32.0f, Position.Y - 28.0f, Player.GetAngle(), 1.0f, Position.X, Position.Y);
            }
        }

        public override void DrawLight()
        {
            if (muzzle)
            {
                Vec2f Position = Player.Position + new Vec2f((float)Math.Cos(Player.GetRadian()), (float)Math.Sin(Player.GetRadian())) * 20.0f;
                Resources.MuzzleLight.DrawRotAxis(Position.X - 60.0f, Position.Y - 64.0f, Player.GetAngle(), 0.8f, Position.X, Position.Y, 0xFFFFFF00);
            }
        }
    }
}
