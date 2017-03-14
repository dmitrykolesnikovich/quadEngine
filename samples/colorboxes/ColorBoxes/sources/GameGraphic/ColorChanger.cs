using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;
using Boxes.GameLogic;

namespace Boxes.GameGraphic
{
    class ColorChanger
    {
        private QuadColor _oldColor;
        private QuadColor _newColor;
        private BoxColor _newBoxColor;
        private double _timer;
        private double dist;

        public BoxColor NewBoxColor { get { return _newBoxColor; } }
        public double Timer { get { return _timer; } }

        public ColorChanger(BoxColor Color, double Timer)
        {
            _oldColor = Box.Colors[Color];//Color;
            _newColor = Box.Colors[Color];
            _newBoxColor = Color;
            _timer = Timer;
            dist = _timer;
        }
        public QuadColor DrawColor 
        {
            get
            {
                if (dist < _timer)
                    return _oldColor.Lerp(_newColor, dist/_timer);
                else
                {
                    _oldColor = _newColor;
                    return _oldColor;
                }
            }
        }
        public void SetNewColor(BoxColor NewColor)
        {
            if (dist < _timer)
                return;
            _oldColor = DrawColor;
            _newColor = Box.Colors[NewColor];
            _newBoxColor = NewColor;
            dist = 0;
        }
        public bool Proceed(double delta)
        {
            if (dist >= _timer)
                return false;
            else
            {
                dist += delta * 3;
                return (dist >= _timer);
            }
        }
    }
}
