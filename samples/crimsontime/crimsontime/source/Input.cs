using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Vectors;
using System.Windows.Forms;

namespace quadtest
{
    public static class Mouse
    {
        private static Vec2f position = new Vec2f(0.0f, 0.0f);
        private static Dictionary<MouseButtons, bool> down = new Dictionary<MouseButtons, bool>();

        public static void Init()
        {
            down.Clear();
            foreach (MouseButtons button in Enum.GetValues(typeof(MouseButtons)))
                down.Add(button, false);
        }

        public static Vec2f Position
        {
            get { return position; }
        }

        public static bool Down(MouseButtons button)
        {
            return down[button];
        }

        public static bool Up(MouseButtons button)
        {
            return !down[button];
        }

        public static void SetDown(MouseButtons button)
        {
            down[button] = true;
        }

        public static void SetUp(MouseButtons button)
        {
            down[button] = false;
        }

        public static float X
        {
            get { return position.X; }
        }

        public static float Y
        {
            get { return position.Y; }
        }
        public static void SetPosition(float X, float Y)
        {
            position.X = X;
            position.Y = Y;
        }
    }

    public static class Keyboard
    {
        private static Dictionary<Keys, bool> down = new Dictionary<Keys, bool>();
        
        public static void Init()
        {
            down.Clear();
            foreach (Keys key in Enum.GetValues(typeof(Keys)))
                if (!down.ContainsKey(key))
                    down.Add(key, false);
        }

        public static bool Down(Keys key)
        {
            return down[key];
        }

        public static bool Up(Keys key)
        {
            return !down[key];
        }

        public static void SetDown(Keys key)
        {
            down[key] = true;
        }

        public static void SetUp(Keys key)
        {
            down[key] = false;
        }
    }
}
