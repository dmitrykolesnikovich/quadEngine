using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;

namespace quadtest
{
    class BotsEngine
    {
        private static List<Bots.CustomBot> list = new List<Bots.CustomBot>();
        private static float CreateTimer = 1.0f;
        private static float Time = 0.0f;

        private static void CreateBots()
        {
            Vec2f Point = new Vec2f();
            Random rand = new Random();
            if (rand.Next(2) == 1)
            {
                Point.X = rand.Next(1450) - 225;
                if (rand.Next(2) == 1)
                    Point.Y = rand.Next(100) - 200;
                else
                    Point.Y = rand.Next(100) + 800;
            }
            else
            {
                Point.Y = rand.Next(1168) - 20;
                if (rand.Next(2) == 1)
                    Point.X = rand.Next(100) - 200;
                else
                    Point.X = rand.Next(100) + 1024;
            }

            float r = (float)rand.NextDouble();
            if (r < 0.6f)
                new Bots.BigMutant(Point);
            else
                if (r < 0.8f)
                    new Bots.SmallMutant(Point);
                else
                    new Bots.BigMutant1(Point);
        }

        public static void Init()
        {
            list.Clear();
        }

        public static int Count()
        {
            return list.Count;
        }

        public static Bots.CustomBot Bots(int Index)
        {
            return list[Index];
        }

        public static void Add(Bots.CustomBot bullet)
        {
            list.Add(bullet);
        }
        
        public static void Process(float dt)
        {
            Time += dt;
            while (Time >= CreateTimer)
            {
                CreateBots();
                Time -= CreateTimer;
            }

            for (int i = list.Count - 1; i >= 0; i--)
                if (list[i].IsNeedToKill)
                    list.RemoveAt(i);
                else
                    list[i].Process(dt);
        }

        public static void Draw()
        {
            foreach (Bots.CustomBot Bot in list)
                Bot.Draw();
        }

        public static Bots.CustomBot GetBotColl(Vec2f APoint1, Vec2f APoint2)
        {
            Bots.CustomBot ResultBot = null;
            float Distance = 2000.0f;
            float temp = 0.0f;
            foreach (Bots.CustomBot Bot in list)
            {
                if (BotColl(APoint1, APoint2, Bot))
                {
                    temp = Bot.Position.Distance(Player.Position);
                    if ((ResultBot == null) || (temp < Distance))
                    {
                        ResultBot = Bot;
                        Distance = temp;
                    }
                }
            }
            return ResultBot;
        }

        private static bool BotColl(Vec2f APoint1, Vec2f APoint2, Bots.CustomBot Bot)
        {
            Vec2f p1 = APoint1 - Bot.Position;
            Vec2f p2 = APoint2 - Bot.Position;
            Vec2f d = p2 - p1;
            
            float a = d.X * d.X + d.Y * d.Y;
            float b = (p1.X * d.X + p1.Y * d.Y) * 2;
            float c = p1.X * p1.X + p1.Y * p1.Y - Bot.GetRadius() * Bot.GetRadius();

            if (-b < 0)
                return (c < 0);
            else
                if (-b < a * 2)
                    return (a * c * 4 - b * b < 0);
                else
                    return (a + b + c < 0);
        }
    }
}
