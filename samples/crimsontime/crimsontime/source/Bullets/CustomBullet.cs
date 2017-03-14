using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest.Bullets
{
    public class CustomBullet
    {
        protected float Speed;
        protected int MinDamage;
        protected int MaxDamage;
        
        public Vec2f Position;
        protected Vec2f Vector;
        protected float Angle;
        public bool IsNeedToKill;
        
        public CustomBullet(Vec2f APosition, Vec2f AVector)
        {
            this.Position = APosition;
            this.Vector = AVector;
            this.Angle = (float)(-Math.Atan2(AVector.X, AVector.Y));
            BulletsEngine.Add(this);
        }

        public CustomBullet(Vec2f APosition, float AAngle)
        {
            this.Position = APosition;
            this.Angle = AAngle;
            this.Vector = new Vec2f((float)Math.Cos(Angle), (float)Math.Sin(Angle));
            BulletsEngine.Add(this);
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
