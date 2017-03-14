using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace quadtest
{
    class Mouse
    {
        private const int buttonsCount = 5;
                    
        public static int Left = 0;
        public static int Middle = 1;
        public static int Right = 2;
        public static int XButton1 = 3;
        public static int XButton2 = 4;

        private static bool[] down = new bool[buttonsCount] { false, false, false, false, false };
        private static bool[] click = new bool[buttonsCount] { false, false, false, false, false };
        
        public static bool Down(int button)
        {
            return down[button];
        }

        public static bool Up(int button)
        {
            return !down[button];
        }

        public static bool Click(int button)
        {
            return click[button];
        }

        public static void SetDown(int button)
        {
            down[button] = true;
        }

        public static void SetUp(int button)
        {
            down[button] = false;
        }
    }
}
