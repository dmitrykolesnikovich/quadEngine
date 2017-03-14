using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.GameGraphic;
using System.Windows.Forms;
using System.IO;
using QuadEngine;
using System.Drawing;
using Boxes.Resources;

namespace Boxes.GameLogic
{
    class GameManager
    {
        private Dictionary<Keys, bool> down = new Dictionary<Keys, bool>();
        public MyBox myBox;
        public TargetBox targetBox;
        public static List<Box> boxes = new List<Box>();
        private List<Box> visibleBoxes = new List<Box>();
        private List<Box> collideBoxes = new List<Box>();
        //private List<Platform> platforms = new List<Platform>();
        private bool Win = false;
        private List<Collision> currentCollisions = new List<Collision>();
        public Background back;
        public static List<IEffect> effects = new List<IEffect>();

        public static BoxColor CurrentColor { get; set; }
 
        public GameManager()
        {
            Box.Size = 40;
            BoxPart.Size = 10;

            down.Clear();
            // этот код я пока не очень понял Enum.GetValues(typeof(Keys))
            foreach (Keys key in Enum.GetValues(typeof(Keys)))
                if (!down.ContainsKey(key))
                    down.Add(key, false);

            CurrentColor = BoxColor.Red;
            back = new Background(CurrentColor);
            back.OnColorChanged += this.ChangeColor;

            myBox = new MyBox(0, 1);
            myBox.OnMainBoxMove += Camera.ChangeCamera;
            targetBox = new TargetBox(-1, -1);

            visibleBoxes.Clear();
        }
        public void SetKeyDown(Keys key)
        {
            if ((key == Keys.W || key == Keys.Up) && !myBox.CanJump)
                return;
            down[key] = true;
        }
        public void SetKeyUp(Keys key)
        {
            down[key] = false;
        }

        private void ChangeColor(BoxColor Color, EventArgs args)
        {
            CurrentColor = Color;
        }
        public void Proceed(double delta)
        {
            #region Обработка игровых элементов
            back.Proceed(delta);

            for (int i = effects.Count - 1; i >= 0; i--)
            {
                effects[i].Proceed(delta);
            }


            visibleBoxes.Clear();
            for (int i = boxes.Count - 1; i>=0; i--)
            {
                boxes[i].Proceed(delta);
                if (Math.Abs(myBox.X - boxes[i].X) <= 20 && Math.Abs(myBox.Y - boxes[i].Y) <= 12)
                    visibleBoxes.Add(boxes[i]);
            }
            #endregion

            myBox.Proceed(delta);

            if (!myBox.IsAlive)
                return;

            double dx = 0;
            double dy = 0;

            if (down[Keys.Left] || down[Keys.A])
                dx -= 8 * delta;
            if (down[Keys.Right] || down[Keys.D])
                dx += 8 * delta;
            if ((down[Keys.Up] || down[Keys.W]) && myBox.CanJump)
            {
                myBox.IsJumping = true;
                myBox.CanJump = false;
                //down[Keys.Up] = false;
                //down[Keys.W] = false;
            }

            if (myBox.IsJumping)
            {
                myBox.JumpTimer += delta;
                dy -= 8 * delta;
            }
            else
                dy += 8 * delta;

            myBox.X += dx;
            myBox.Y += dy;
            myBox.CanJump = false;

            // расчет и обработка коллизий
            collideBoxes.Clear();
            foreach (Box box in visibleBoxes)
            {
                currentCollisions.Clear();
                currentCollisions = box.Collision(myBox, CurrentColor);
                if (!currentCollisions.Contains(Collision.None))
                    collideBoxes.Add(box);
                if (currentCollisions.Contains(Collision.Top))
                {
                    myBox.CanJump = true;
                    down[Keys.Up] = false;
                    down[Keys.W] = false;
                }
                if (currentCollisions.Contains(Collision.Bottom))
                  
                    myBox.IsJumping = false;

            }
            foreach (Box box in collideBoxes)
                if (!box.ResolveCollision(myBox, CurrentColor, ref dx, ref dy))
                {
                    myBox.Destroy();
                    NewLevelScreen nls = new NewLevelScreen(1.5);
                    nls.OnBlackScreen += RestartLevel;
                }

            if (Level.DeathCheck(myBox))
            {
                myBox.Destroy();
                NewLevelScreen nls = new NewLevelScreen(1.5);
                nls.OnBlackScreen += RestartLevel;
            }

            if (!targetBox.Collision(myBox, CurrentColor).Contains(Collision.None) && !Win)
            {
                NewLevelScreen nls = new NewLevelScreen(0.75);
                nls.OnBlackScreen += this.ChangeLevel;
                Win = true;
            }
        }
        public void Draw()
        {
            // выводить надо не все, а только те, что попадают в экран
            foreach (Box box in visibleBoxes)
                box.Draw();

            myBox.Draw();
            targetBox.Draw();

            float w = GraphicResources.TitleFont.TextWidth(Level.name.ToLower(), (float)1.25);
            //GraphicResources.TitleFont.TextOut((1280 - w)/2, 10, (float)0.75, Level.name.ToUpper(),
            //    Box.Colors[BoxColor.Black], TqfAlign.qfaLeft);
            //GraphicResources.TextFont.TextOut(1280/2, 55,(float)0.95, Level.description,
            //    Box.Colors[BoxColor.Black], TqfAlign.qfaCenter);
            GraphicResources.TitleFont.TextOut(10, 10, (float)0.75, Level.name.ToUpper(),
                Box.Colors[BoxColor.Black], TqfAlign.qfaLeft);
            GraphicResources.TextFont.TextOut(10, 55,(float)0.95, Level.description,
                Box.Colors[BoxColor.Black], TqfAlign.qfaLeft);

            foreach (IEffect effect in effects)
                effect.Draw();
        }
        #region этот способ загрузки уровня не используется
        public void LoadLevel(int levelNumber)
        {
            boxes.Clear();
            effects.Clear();

            string FilePath = "levels\\" + levelNumber.ToString() + ".txt";
            string[] Lines = File.ReadAllLines(FilePath);

            for(int i = 0; i < Lines.Length; i++)
                for (int j = 0; j < Lines[i].Length; j++)
                {
                    char s = Lines[i][j];
                    switch (s)
                    {
                        case '9': boxes.Add(new Box(j, i, BoxColor.Black)); break;
                        case '1': boxes.Add(new Box(j, i, BoxColor.Red)); break;
                        case '2': boxes.Add(new Box(j, i, BoxColor.Blue)); break;
                        case '3': boxes.Add(new Box(j, i, BoxColor.Yellow)); break;
                        case '4': boxes.Add(new ExplosiveBox(j, i, BoxColor.Red)); break;
                        case '5': boxes.Add(new VaryingBox(j, i, BoxColor.Blue)); break;
                        case '0': myBox.X = j; myBox.Y = i; break;
                    }
                }
            myBox.IsAlive = true;
            BoxDestroy bd = new BoxDestroy(myBox);
            effects.Add(bd);
        }
        #endregion
        private void ChangeLevel()
        {
            Level.NextLevel(this);
        }
        private void RestartLevel()
        {
            Level.LoadLevel(Level.Number,this);
        }
        public void LoadLevel2(int levelNumber, BoxColor levelColor, LevelOrientation orientation)
        {
            boxes.Clear();
            targetBox.X = -100;
            targetBox.Y = -100;
            //effects.Clear();
            //platforms.Clear();

            switch(orientation)
            {
                case LevelOrientation.Horizontal:
                    back = new BackGroundHorizontal(levelColor);
                    break;
                case LevelOrientation.Vertical:
                    back = new BackGroundVertical(levelColor);
                    break;
            }

            back.OnColorChanged += this.ChangeColor;
            back.SetNewColor(levelColor);

            string FilePath = "levels\\" + levelNumber.ToString() + "\\map.png";
            #region Разбор цветов
            using (Bitmap map = new Bitmap(FilePath))
            {
                for (int i = 0; i < map.Width; i++)
                    for (int j = 0; j < map.Height; j++)
                    {
                        uint pixelColor = (uint)map.GetPixel(i, j).ToArgb();
                        if (pixelColor == QuadColor.Black)
                            boxes.Add(new Box(i, j, BoxColor.Black));
                        if (pixelColor == QuadColor.Red)
                            boxes.Add(new Box(i, j, BoxColor.Red));
                        if (pixelColor == QuadColor.Blue)
                            boxes.Add(new Box(i, j, BoxColor.Blue));
                        if (pixelColor == QuadColor.Yellow)
                            boxes.Add(new Box(i, j, BoxColor.Yellow));

                        if (pixelColor == QuadColor.Maroon)
                            boxes.Add(new ExplosiveBox(i, j, BoxColor.Red));
                        if (pixelColor == QuadColor.Fuchsia)
                            boxes.Add(new ExplosiveBox(i, j, BoxColor.Blue));
                        if (pixelColor == new QuadColor(255, 128, 0))
                            boxes.Add(new ExplosiveBox(i, j, BoxColor.Yellow));

                        if (pixelColor == QuadColor.Aqua)
                            boxes.Add(new VaryingBox(i, j, BoxColor.Blue));
                        if (pixelColor == new QuadColor(128, 128, 0))
                            boxes.Add(new VaryingBox(i, j, BoxColor.Yellow));
                        if (pixelColor == new QuadColor(255, 128, 128))
                            boxes.Add(new VaryingBox(i, j, BoxColor.Red));

                        if (pixelColor == QuadColor.Lime)
                        {
                            myBox.X = i; myBox.Y = j;
                        }
                        if (pixelColor == QuadColor.Green)
                        {
                            targetBox.X = i; targetBox.Y = j;
                        }
                    }
                Level.level.maxX = map.Width + 5;
                Level.level.maxY = map.Height + 5;
            }
            #endregion
            myBox.IsAlive = true;
            Win = false;
        }
    }
}
