using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace quadtest
{
    class LightEngine
    {
        private static List<Light.CustomLight> list = new List<Light.CustomLight>();
        
        public static int Count()
        {
            return list.Count;
        }

        public static void Init()
        {
            list.Clear();
        }

        public static void Add(Light.CustomLight Light)
        {
            list.Add(Light);
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
            Resources.QuadRender.RenderToTexture(true, Resources.LightTarget);
            Resources.QuadRender.Clear(0xFF111111);
            Resources.QuadRender.SetBlendMode(QuadEngine.TQuadBlendMode.qbmAdd);
            foreach (Light.CustomLight Light in list)
                Light.Draw();

            Player.DrawLight();
            BulletsEngine.DrawLight();
            EffectEngine.DrawLight();
            Resources.QuadRender.RenderToTexture(false, Resources.LightTarget);

            Resources.QuadRender.SetBlendMode(QuadEngine.TQuadBlendMode.qbmMul);
            Resources.LightTarget.Draw(0.0f, 0.0f);
        }
    }
}
