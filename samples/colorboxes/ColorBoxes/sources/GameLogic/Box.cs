using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Boxes.GameGraphic;
using Boxes.Resources;
using QuadEngine;

namespace Boxes.GameLogic
{
    public enum BoxColor
    {
        Black = 9,  // непроходимые, неизменяемые цветом коробки
        White = 0,  // главный персонаж, не изменяется цветом
        Red = 1,    // красный
        Blue = 2,   // синий
        Yellow = 3, // желтый
        DarkRed = 4,  // темно-красный
        DarkBlue = 5, // темно-синий
        DarkYellow = 6, // темно-желтый
        Orange = 106,  // оранжевый
        Purple = 107,  // фиолетовый
        Green = 105,
        Transparent = -1 // прозрачный
    }
    enum Collision
    {
        None = 0,
        Left = 1,
        Right = 2,
        Top = 3,
        Bottom = 4
    }

    static class BoxColorExtention
    {
        public static BoxColor Next(this BoxColor Color)
        {
            if ((int)Color == 3)
                return (BoxColor)1;
            else
                return (BoxColor)((int)Color + 1);
        }
        public static BoxColor Prev(this BoxColor Color)
        {
            if ((int)Color == 1)
                return (BoxColor)3;
            else
                return (BoxColor)((int)Color - 1);
        }
    }

    class Box
    {
        protected internal DrawObject DrawBox;

        #region Коллекция цветов
        public static IDictionary<BoxColor, QuadColor> Colors = new Dictionary<BoxColor, QuadColor>()
        {
            {BoxColor.White, QuadColor.White},
            //{BoxColor.Black, QuadColor.Black},
            {BoxColor.Black,  new QuadColor(63, 55, 115)},
            //{BoxColor.Red, QuadColor.Red},
            //{BoxColor.Red,  new QuadColor(242, 120, 159)},
            //{BoxColor.Red,  new QuadColor(255, 105, 134)},
            {BoxColor.Red,  new QuadColor(218, 93, 88)},
            //{BoxColor.Blue, QuadColor.Blue},
            //{BoxColor.Blue,  new QuadColor(120, 221, 242)},
            {BoxColor.Blue,  new QuadColor(101, 170, 247)},
            //{BoxColor.Blue,  new QuadColor(106, 158, 255)},
            //{BoxColor.Yellow, QuadColor.Yellow},
            {BoxColor.Yellow,  new QuadColor(250, 215, 118)},
            //{BoxColor.Yellow,  new QuadColor(232, 194, 72)},
            {BoxColor.Orange, QuadColor.Olive},
            {BoxColor.Purple, QuadColor.Fuchsia},
            {BoxColor.DarkRed, new QuadColor(222, 100, 139)},
            {BoxColor.DarkBlue, new QuadColor(100, 201, 222)},
            {BoxColor.DarkYellow, new QuadColor(230, 195, 98)},
            {BoxColor.Green, QuadColor.Green},
            {BoxColor.Transparent, new QuadColor(0,0,0,0)}
        };
        #endregion

        public static double Size { get; set; }
  
        public virtual double X { get; set; }
        public  virtual double Y { get; set; }
        public BoxColor Color { get; set; }

        public bool IsPassable { get { return false; } } 

        public Box(double X, double Y, BoxColor Color)
        {
            this.X = X;
            this.Y = Y;
            this.Color = Color;

            DrawBox = new DrawObject(GraphicResources.TextureBox, Colors[Color]);
            DrawBox.X = X * Size;
            DrawBox.Y = Y * Size;
        }
        public virtual void Draw()
        {
            DrawBox.X = this.X * Size + Camera.X;
            DrawBox.Y = this.Y * Size + Camera.Y;
            DrawBox.Draw();
        }
        public virtual List<Collision> Collision(Box otherBox, BoxColor backColor)
        {
            if (this.Color == backColor)
                return new List<GameLogic.Collision>(){GameLogic.Collision.None};

            double x1 = this.X;
            double y1 = this.Y;

            double x2 = otherBox.X;
            double y2 = otherBox.Y;

            if ((x1 >= x2 + 0.95) || (x2 >= x1 + 0.95) || (y1 >= y2 + 1) || (y2 >= y1 + 1))
                return new List<GameLogic.Collision>() { GameLogic.Collision.None };
            else
            {
                List<GameLogic.Collision> result = new List<GameLogic.Collision>();

                double width = 1 - Math.Abs(x1 - x2);
                double height = 1 - Math.Abs(y1 - y2);

                if ((x1 > x2) && (height >= 0.2))
                    result.Add(GameLogic.Collision.Left);
                else if ((x1 < x2) && (height >= 0.2))
                    result.Add(GameLogic.Collision.Right);

                if ((y1 > y2) && (width >= 0.2))
                    result.Add(GameLogic.Collision.Top);
                else if ((y1 < y2) && (width >= 0.2))
                    result.Add(GameLogic.Collision.Bottom);

                return result;
            }
        }
        public bool ResolveCollision(MyBox otherBox, BoxColor backColor, ref double dx, ref double dy)
        {
            double x1 = Math.Max(this.X, otherBox.X) - this.X;
            double y1 = Math.Max(this.Y, otherBox.Y) - this.Y;
            double x2 = Math.Min(this.X, otherBox.X) + 1 - this.X;
            double y2 = Math.Min(this.Y, otherBox.Y) + 1 - this.Y;

            double width = x2 - x1;
            double height = y2 - y1;

            if (width >= 0.5 && height >= 0.5)
                return false;

            if (width >= 0.2)
            {
                if (y1 == 0)
                    otherBox.Y = this.Y - 1;
                else
                    otherBox.Y = this.Y + 1;
            }
            if (height >= 0.3)
            {
                if (x1 == 0)
                    otherBox.X = this.X - 1;
                else
                    otherBox.X = this.X + 1;
            }
            return true;
        }
        public virtual void Proceed(double delta)
        { }
        public virtual void Destroy()
        {
            if (GameManager.boxes.Contains(this))
                GameManager.boxes.Remove(this);
            BoxDestroy bd = new BoxDestroy(this);
        }
        #region Не использующиеся функции смены цвета
        public void AddColor(BoxColor Color)
        {
            // для черного ничего не меняется
            // если меняют на тот же цвет, его отображение не меняется, но свойства меняются
            // наверное, это можно как-то лучше сделать
            if ((Color == this.Color) || (this.Color == BoxColor.Black))
                return;
            this.Color = (BoxColor)((int)this.Color + (int)Color);
            this.DrawBox.Color = Colors[this.Color];
        }
        public void SubstractColor(BoxColor Color)
        {
            // для черного ничего не меняется
            // если меняют на тот же цвет, его отображение не меняется, но свойства меняются
            // наверное, это можно как-то лучше сделать
            if ((Color == this.Color) || (this.Color == BoxColor.Black))
                return;
            this.Color = (BoxColor)((int)this.Color - (int)Color);
            this.DrawBox.Color = Colors[this.Color];
        }
        #endregion
    }
}
