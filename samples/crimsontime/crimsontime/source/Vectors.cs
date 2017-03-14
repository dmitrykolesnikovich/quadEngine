using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Vectors
{
    public class Vec2f
    {
        public float X;
        public float Y;

        public static Vec2f Zero = new Vec2f(0.0f, 0.0f);

        public Vec2f(float X, float Y)
        {
            this.X = X;
            this.Y = Y;
        }

        public Vec2f()
        {
            this.X = 0;
            this.Y = 0;
        }

        public static Vec2f operator +(Vec2f Value1, Vec2f Value2)
        {
            return new Vec2f(Value1.X + Value2.X, Value1.Y + Value2.Y);
        }
        public static Vec2f operator +(Vec2f Value1, float Value2)
        {
            return new Vec2f(Value1.X + Value2, Value1.Y + Value2);
        }
        
        public static Vec2f operator -(Vec2f Value1, Vec2f Value2)
        {
            return new Vec2f(Value1.X - Value2.X, Value1.Y - Value2.Y);
        }
        public static Vec2f operator -(Vec2f Value1, float Value2)
        {
            return new Vec2f(Value1.X - Value2, Value1.Y - Value2);
        }

        public static Vec2f operator *(Vec2f Value1, Vec2f Value2)
        {
            return new Vec2f(Value1.X * Value2.X, Value1.Y * Value2.Y);
        }
        public static Vec2f operator *(Vec2f Value1, float Value2)
        {
            return new Vec2f(Value1.X * Value2, Value1.Y * Value2);
        }
        
        public static Vec2f operator /(Vec2f Value1, Vec2f Value2)
        {
            return new Vec2f(Value1.X / Value2.X, Value1.Y / Value2.Y);
        }
        public static Vec2f operator /(Vec2f Value1, float Value2)
        {
            return new Vec2f(Value1.X / Value2, Value1.Y / Value2);
        }

        public float Length()
        {
            return (float)Math.Sqrt(this.X * this.X + this.Y * this.Y);
        }        

        public float Distance(Vec2f APoint)
        {
            return (float)Math.Sqrt(Math.Pow(APoint.X - this.X, 2.0f) + Math.Pow(APoint.Y - this.Y, 2.0f));
        }
           
        public Vec2f Normalize()
        {
            if ((Math.Abs(this.X) > 0.0001f) || (Math.Abs(this.Y) > 0.0001))
            {
                float d = 1.0f / this.Length();
                return new Vec2f(d * this.X, d * this.Y);
            }
            else
                return Zero;                
        }

        public float Angle()
        {
            return (float)(-Math.Atan2(X, Y));
        }

        public float Angle360()
        {
            return (float)(Angle() * 180.0f / Math.PI);
        }

    }
}
