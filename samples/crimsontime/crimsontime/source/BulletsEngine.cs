using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest
{
     static class BulletsEngine
    {
        private static List<Bullets.CustomBullet> list = new List<Bullets.CustomBullet>();

        public static int Count()
        {
            return list.Count;
        }

        public static void Init()
        {
            list.Clear();
        }

        public static void Add(Bullets.CustomBullet bullet)
        {
            list.Add(bullet);
        }

        public static void Process(float dt)
        {
           // foreach (Bullets.CustomBullet Bullet in list)
            for (int i = list.Count - 1; i >= 0; i--)
                if (list[i].IsNeedToKill)
                    list.RemoveAt(i);
                else
                    list[i].Process(dt);
        }

        public static void Draw()
        {   
            foreach (Bullets.CustomBullet Bullet in list)
                Bullet.Draw();
        }

        public static void DrawLight()
        {
            foreach (Bullets.CustomBullet Bullet in list)
                Bullet.DrawLight();
        }
    }
}
