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
    class MyBox : Box
    {
        // особого смысла наследоваться, выходит, и не было. Но все же.
        private IQuadTexture myTexture;
        private double _x = 0;
        private double _y = 0;

        private const double JumpTime = 0.3;
        private bool _isJumping = false;
        private double _jumpTimer = 0;
        private bool _isAlive = true;
        private double _timer = 0;
        private int frameNo = 0;

        public bool IsAlive { get { return _isAlive; } set { _isAlive = value; } }

        public delegate void OnMainBoxMoveHandler(MyBox box, EventArgs args);
        public event OnMainBoxMoveHandler OnMainBoxMove;

        public override sealed double X
        {
            get { return _x; }
            set
            {
                _x = value;
                if (OnMainBoxMove != null)
                    OnMainBoxMove(this, new EventArgs());
            }
        }
        public override sealed double Y
        {
            get { return _y; }
            set
            {
                _y = value;
                if (OnMainBoxMove != null)
                    OnMainBoxMove(this, new EventArgs());
            }
        }
        public bool CanJump { get; set; }
        public bool IsJumping
        {
            get { return _isJumping; }
            set
            {
                _jumpTimer = 0;
                _isJumping = value;
            }
        }
        public double JumpTimer
        {
            get { return _jumpTimer; }
            set
            {
                if (_isJumping)
                {
                    if (_jumpTimer >= JumpTime)
                    {
                        _jumpTimer = 0;
                        _isJumping = false;
                    }
                    _jumpTimer = value;
                }
            }
        }

        public MyBox(double X, double Y)
            : base(X, Y, BoxColor.Black)
        {
            myTexture = GraphicResources.TextureMyBox;
        }
        public override void Draw()
        {
            if (!IsAlive)
                return;
            //myTexture.DrawFrame((1280 - Box.Size) / 2, (720 - Box.Size) / 2, (ushort)frameNo);
            myTexture.Draw((1280 - Box.Size) / 2, (720 - Box.Size) / 2);
            //DrawBox.X = (1280 - Box.Size) / 2;
            //DrawBox.Y = (1280 - Box.Size) / 2;
            //DrawBox.Draw();
        }
        public override void Proceed(double delta)
        {
            _timer += delta;
            if (_timer >= 0.2)
            {
                _timer = 0;
                if (frameNo == 5)
                    frameNo = 0;
                else
                    frameNo++;
            }
        }
        public override void Destroy()
        {
            _isAlive = false;
            BoxDestroy bd = new BoxDestroy(this);
        }
    }

}
