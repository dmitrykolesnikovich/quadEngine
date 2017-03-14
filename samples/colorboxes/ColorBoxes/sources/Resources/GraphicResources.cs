using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;

namespace Boxes.Resources
{
    static class GraphicResources
    {
        public static IQuadTexture TextureBox;
        public static IQuadTexture TextureBoxDestroyed;
        public static IQuadTexture TextureGlow;
        public static IQuadTexture TextureCenter;
        public static IQuadTexture TextureMyBox;
        public static IQuadRender Render;
        public static IQuadFont TitleFont;
        public static IQuadFont TextFont;
        
        public static void Initialize(IQuadDevice QuadDevice)
        {
            QuadDevice.CreateTexture(out TextureBox);
            TextureBox.LoadFromFile(0, "textures\\box_transparent_2.png");

            QuadDevice.CreateTexture(out TextureBoxDestroyed);
            TextureBoxDestroyed.LoadFromFile(0, "textures\\box_transparent_2.png", 10, 10);

            QuadDevice.CreateTexture(out TextureCenter);
            TextureCenter.LoadFromFile(0, "textures\\center.png");

            QuadDevice.CreateTexture(out TextureMyBox);
            TextureMyBox.LoadFromFile(0, "textures\\box_my2.png");

            QuadDevice.CreateRender(out Render);

            QuadDevice.CreateFont(out TitleFont);
            TitleFont.LoadFromFile("fonts\\title_font.png", "fonts\\title_font.qef");

            QuadDevice.CreateFont(out TextFont);
            TextFont.LoadFromFile("fonts\\text_font.png", "fonts\\text_font.qef");
         
            QuadDevice.CreateRenderTarget(128, 96, ref TextureGlow, 0); 
           
            //MainForm.quadDevice не видит. Потому что это класс, для которого создается анонимный экземпляр.
        }
    }
}
