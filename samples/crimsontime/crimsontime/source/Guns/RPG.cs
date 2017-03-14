using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Guns
{
    class RPG : CustomGun
    {
        private const float Cooldown = 20.00f;

        private float recharge = Cooldown;

        public bool ClipFull()
        {
            return (recharge >= Cooldown);
        }

        public override void Process(float dt)
        {
            if (Cooldown > recharge)
                recharge += dt;
        }

        public override void Fire(Vec2f APosition, float AAngle)
        {
            Random rand = new Random();
            while (recharge >= Cooldown)
            {
                new Bullets.Rocket(APosition, AAngle);
                Bass.Bass.BASS_SamplePlay(Resources.RPG[rand.Next(2)]);
                recharge -= Cooldown;
                //Bass.Bass.BASS_SamplePlay(Resources.M16[rand.Next(3)]);
            }
        }

    }
}
