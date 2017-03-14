using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using QuadEngine;
using Vectors;
using System.Windows.Forms;

namespace quadtest
{
    public static class Player
    {
        public static Vec2f Position;
        public static Vec2f Vector;
        private static float speed = 100.0f;
        private static float angle = 0.0f;
        private static float Hp;
        private static int points = 0;

        public static bool Flashlight = true;

        private static Guns.M16 gun = new Guns.M16();
        private static Guns.RPG gun1 = new Guns.RPG();

        public static int GetPoints()
        {
            return points;
        }

        public static bool IsNeedToKill()
        {
            return (Hp <= 0.0f ); 
        }

        public static void Init()
        {
            Position = new Vec2f(512.0f, 350.0f);
            Vector = new Vec2f(0.0f, 0.0f);
            points = 0;
            Hp = 18.0f;
        }

        public static void AddPoints(int APoints)
        {
            points += APoints;
        }

        public static double GetAngle()
        {
            return angle * 180.0f / Math.PI;
        }

        public static double GetRadian()
        {
            return angle;
        }       

        public static void Damage(float Damage)
        {
            Hp -= Damage;
            Random rand = new Random();
            Bass.Bass.BASS_SamplePlay(Resources.Pain[rand.Next(4)]);
        }

        public static void Process(float dt)
        {
            gun.Process(dt);
            gun1.Process(dt);

            Hp += dt / 10;
            if (Hp > 18.0f)
                Hp = 18.0f;

            if (Keyboard.Down(Keys.W) && (Keyboard.Down(Keys.A)))
                Vector = new Vec2f((float)Math.Cos(Math.PI / 4.0f + Math.PI), (float)Math.Sin(Math.PI / 4.0f + Math.PI));
            else
                if (Keyboard.Down(Keys.S) && (Keyboard.Down(Keys.D)))
                    Vector = new Vec2f((float)Math.Cos(Math.PI / 4.0f), (float)Math.Sin(Math.PI / 4.0f));
                else
                    if (Keyboard.Down(Keys.W) && (Keyboard.Down(Keys.D)))
                        Vector = new Vec2f((float)Math.Cos(-Math.PI / 4.0f), (float)Math.Sin(-Math.PI / 4.0f));
                    else
                        if (Keyboard.Down(Keys.S) && (Keyboard.Down(Keys.A)))
                            Vector = new Vec2f((float)Math.Cos(-Math.PI / 4.0f + Math.PI), (float)Math.Sin(-Math.PI / 4.0f + Math.PI));
                        else
                            if (Keyboard.Down(Keys.S))
                                Vector = new Vec2f(0.0f, 1.0f);
                            else
                                if (Keyboard.Down(Keys.W))
                                    Vector = new Vec2f(0.0f, -1.0f);
                                else
                                    if (Keyboard.Down(Keys.A))
                                        Vector = new Vec2f(-1.0f, 0.0f);
                                    else
                                        if (Keyboard.Down(Keys.D))
                                            Vector = new Vec2f(1.0f, 0.0f);
                                        else
                                            Vector = new Vec2f(0.0f, 0.0f);
            
            Position += Vector * speed * dt;
            if (Position.X < 16.0f)
                Position.X = 16.0f;
            else
               if (Position.X > 1008.0f)
                   Position.X = 1008.0f;

            if (Position.Y < 16.0f)
                Position.Y = 16.0f;
            else
                if (Position.Y > 752.0f)
                    Position.Y = 752.0f;

            angle = (float)(-Math.Atan2(Position.X - Mouse.X, Position.Y - Mouse.Y) - Math.PI / 2.0f);

            if (Mouse.Down(MouseButtons.Left))
                gun.Fire(Position, angle);

            if (Mouse.Down(MouseButtons.Right))
                gun1.Fire(Position, angle);
        }
        
        public static void Draw()
        {
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            Resources.Player.DrawRotFrame(Position.X, Position.Y, angle * 180.0f / Math.PI, 0.33f, 0);

            gun.Draw();
            gun1.Draw();
        }

        public static void DrawLight()
        {
            if (Flashlight)
                Resources.Flashlight.DrawRotAxis(Position.X - 48.0f, Position.Y - 230.0f, angle * 180.0f / Math.PI, 1, Position.X, Position.Y);
            gun.DrawLight();
            gun1.DrawLight();
        }

        public static void DrawPanel()
        {
            string Str = points.ToString();
            int Len = Str.Length;
            int Num;

            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            for (int i = 10; i > 0; i--)
                Resources.Numbers.DrawFrame(165.0f - i * 16, 740.0f, 0);
            for (int i = Len-1; i >= 0; i--)
            {
                    Int32.TryParse(new string(Str[i], 1), out Num);
                    Resources.Numbers.DrawFrame(165.0f - (Len - i) * 16, 740.0f, (ushort)(Num + 1));
            }

            for (int i = 1; i <= gun.Clip; i++)
                Resources.Bullet1.Draw(196.0f + i * 4.0f, 740.0f);

            if (gun1.ClipFull())
                Resources.Rocket.DrawFrame(750, 740.0f, 0);

            Resources.Heart.DrawRot(1024.0f - 230.0f, 768.0f - 22.0f, 0.0f, 1.0f);
            for (int i = 0; i <= (int)(Hp); i++)
                Resources.Hp.DrawRotAxisFrame(1024.0f - 208.0f + i * 11, 768.0f - 28.0f, 0.0f, 1.0f, 1.0f, 1.0f, (ushort)i);
        }
    }
}
