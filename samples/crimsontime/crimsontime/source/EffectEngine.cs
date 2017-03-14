using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace quadtest
{
    class EffectEngine
    {
        private static List<Effects.CustomEffect> list = new List<Effects.CustomEffect>();

        public static int Count()
        {
            return list.Count;
        }

        public static void Init()
        {
            list.Clear();
        }

        public static void Add(Effects.CustomEffect Effect)
        {
            list.Add(Effect);
        }

        public static void Process(float dt)
        {
            for (int i = list.Count - 1; i >= 0; i--)
                if (list[i].IsNeedToKill)
                    list.RemoveAt(i);
                else
                    list[i].Process(dt);
        }

        public static void Draw()
        {
            foreach (Effects.CustomEffect Effect in list)
                Effect.Draw();
        }

        public static void DrawLight()
        {
            foreach (Effects.CustomEffect Effect in list)
                Effect.DrawLight();
        }

    }
}
