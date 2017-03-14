using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Drawing;
using System.Xml.Serialization;
using System.IO;
using QuadEngine;

namespace Survival
{
    public static class Resources
    {
        private const string DataFolder = "data\\";
        private const string FontsFolder = DataFolder + "fonts\\";
        private const string GFXFolder = DataFolder + "gfx\\";

        public const int ScreenWidth = 1280;
        public const int ScreenHeight = 720;

        public static IQuadDevice QuadDevice;
        public static IQuadRender QuadRender;
        public static IQuadTimer QuadTimer;
        public static IQuadFont QuadFont;

        public static IQuadTexture worldMap;
        public static IQuadTexture worldMapPolitical;
        public static IQuadTexture spot;
        public static IQuadTexture sun;

        public static Countries countries;

        public static void Initialize(IntPtr AHandle)
        {
            XmlSerializer ser = new XmlSerializer(typeof(Countries));
            FileStream st = new FileStream("x.xml", FileMode.Open);
            countries = (Countries)ser.Deserialize(st);



            QuadEngine.QuadEngine.CreateQuadDevice(out QuadDevice);
            QuadDevice.CreateRender(out QuadRender);
            QuadRender.Initialize(AHandle, ScreenWidth, ScreenHeight, false);

            QuadDevice.CreateFont(out QuadFont);
            QuadFont.LoadFromFile(FontsFolder + "quad.png", FontsFolder + "quad.qef");
            QuadFont.SetIsSmartColoring(true);

            QuadDevice.CreateAndLoadTexture(0, GFXFolder + "world.png", out worldMap);
            QuadDevice.CreateAndLoadTexture(0, GFXFolder + "worldpol.png", out worldMapPolitical);
            QuadDevice.CreateAndLoadTexture(0, GFXFolder + "spot.png", out spot);
            QuadDevice.CreateAndLoadTexture(0, GFXFolder + "star.jpg", out sun);
        }
    }
}
