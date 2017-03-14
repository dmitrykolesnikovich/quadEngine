using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Light
{
    class Lantern : CustomLight
    {
        private Vec2f position;

        public Lantern(Vec2f Position)
        {
            position = Position;
            LightEngine.Add(this);
        }

        public override void Process(float dt)
        {

        }

        public override void Draw()
        {
            Resources.Lantern.DrawRot(position.X, position.Y, 0.0f, 1.0f, 0xFFFFF890);
        }
    }

    class LanternBlink : CustomLight
    {
        private bool Included = true;
        private double Time = 0.0f;
        private double Timer = 0.0f;
        private Vec2f position;

        public LanternBlink(Vec2f Position)
        {
            position = Position;
            LightEngine.Add(this);
        }

        public override void Process(float dt)
        {
            Time += dt;
            if (Time > Timer)
            {
                Included = !Included;
                Time = 0.0f;
                Random rand = new Random();
                Timer = rand.NextDouble();
            }
        }

        public override void Draw()
        {
            if (Included)
                Resources.Lantern.DrawRot(position.X, position.Y, 0.0f, 1.0f, 0xFFFFF890);
        }
    }

}
