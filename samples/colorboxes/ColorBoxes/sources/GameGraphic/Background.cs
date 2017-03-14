using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;
using Boxes.GameLogic;

namespace Boxes.GameGraphic
{
    class Background
    {
        protected ColorChanger changer;
        protected ColorChanger changer_left;
        protected ColorChanger changer_right;
        List<BackBox> backBoxes = new List<BackBox>();

        public delegate void OnColorChangedHandler(BoxColor Color, EventArgs args);
        public event OnColorChangedHandler OnColorChanged;

        public Background(BoxColor Color)
        {
            changer = new ColorChanger(Color, 1.5);
            changer_left = new ColorChanger(Color.Prev(), 1.5);
            changer_right = new ColorChanger(Color.Next(), 1.5);

            for (int i = 0; i < 16; i++)
                for (int j = 0; j < 9; j++)
                {
                    backBoxes.Add(new BackBox(1, i, j));
                    if ((i % 2) == 0)
                    {
                        backBoxes.Add(new BackBox(2, i, j));
                        if ((j % 3) == 0)
                            backBoxes.Add(new BackBox(3, i, j));
                    }
                }
        }
        public QuadColor DrawColor { get { return changer.DrawColor; } }
        public void SetNewColor(BoxColor NewColor)
        {
            changer.SetNewColor(NewColor);
            changer_left.SetNewColor(NewColor.Prev());
            changer_right.SetNewColor(NewColor.Next());
        }
        public void Proceed(double delta)
        {
            changer_left.Proceed(delta);
            changer_right.Proceed(delta);
            if (changer.Proceed(delta) && (OnColorChanged != null))
                OnColorChanged(changer.NewBoxColor, new EventArgs());
            foreach (BackBox box in backBoxes)
                box.Proceed(delta);
        }
        public virtual void Draw(IQuadRender render)
        {
            foreach (BackBox box in backBoxes)
                box.Draw();
        }
    }
}
