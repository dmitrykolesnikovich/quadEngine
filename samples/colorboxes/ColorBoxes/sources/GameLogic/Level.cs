using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;
using System.IO;
using System.Windows.Forms;
using System.Xml;
//using Microsoft.Xna.Framework.Input;

namespace Boxes.GameLogic
{
    public enum LevelOrientation { Horizontal, Vertical }
    static class Level
    {
        public static LevelObj level = new LevelObj();
        public static BoxColor Color { get { return level.levelColor; } }
        public static int Number { get { return level.Number; } set { level.Number = value; } }
        public static LevelOrientation Orientation { get { return level.Orientation; } }
        public static string description { get { return level.description; } }
        public static string name { get { return level.name; } }

        public static void LoadLevel(int Number, GameManager gm)
        {
            Level.Number = Number;
            
            string FilePath = "levels\\" + Number.ToString() + "\\description.xml";
            XmlSerializer serializer = new XmlSerializer(typeof(LevelObj));
            StringReader reader = new StringReader(File.ReadAllText(FilePath));
            level = (LevelObj)serializer.Deserialize(reader);
            gm.LoadLevel2(Number, level.levelColor, level.Orientation);
            level.minX = -10;
            level.minY = -10;
        }
        public static void NextLevel(GameManager gm)
        {
            // добавить затемнение
            LoadLevel(Number + 1, gm);
        }
        public static bool DeathCheck(MyBox box)
        {
            if ((box.X < level.minX) || (box.X > level.maxX) || (box.Y < level.minY) || (box.Y > level.maxY))
                return true;
            else
                return false;
        }
    }
    public class LevelObj
    {
        public double minX = -10;
        public double minY = -10;
        public double maxX = 100;
        public double maxY = 35;

        public BoxColor levelColor;

        public int Number { get; set; }
        public LevelOrientation Orientation { get; set; }
        public string description = "";
        public string name = "";
    }
}
