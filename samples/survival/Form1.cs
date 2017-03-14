using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using QuadEngine;

namespace Survival
{
    public partial class Form1 : Form
    {
        private static TimerProcedure Timer;

        private GameModeManager gameModeManager;

        public Form1()
        {
            InitializeComponent();

            this.Cursor.Dispose();
            this.SetClientSizeCore(Resources.ScreenWidth, Resources.ScreenHeight);
            Resources.Initialize(this.Handle);

            Resources.QuadDevice.CreateTimer(out Resources.QuadTimer);
            Resources.QuadTimer.SetInterval(16);
            Timer = (TimerProcedure)OnTimer;
            Resources.QuadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(Timer));
            Resources.QuadTimer.SetState(true);

            gameModeManager = GameModeManager.Instance;
        }
        
        private void OnTimer(ref double delta, UInt32 Id)
        {
            gameModeManager.Process(delta);

            Resources.QuadRender.BeginRender();

            gameModeManager.Draw();
          
            Resources.QuadRender.EndRender();
        }

        private void Form1_MouseDown(object sender, MouseEventArgs e)
        {
            gameModeManager.MouseDown(e.X, e.Y);
        }

        private void Form1_MouseUp(object sender, MouseEventArgs e)
        {
            gameModeManager.MouseUp(e.X, e.Y);
        }

        private void Form1_MouseMove(object sender, MouseEventArgs e)
        {
            gameModeManager.MouseMove(e.X, e.Y);
        }

        private void Form1_KeyDown(object sender, KeyEventArgs e)
        {
            gameModeManager.KeyDown(e.KeyCode);
        }

        private void Form1_KeyPress(object sender, KeyPressEventArgs e)
        {
            gameModeManager.KeyPress(e.KeyChar);
        }        
        
    }
}
