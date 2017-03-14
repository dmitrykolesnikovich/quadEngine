using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using QuadEngine;
using System.Runtime.InteropServices;
using Vectors;
using System.Windows;

namespace quadtest
{
    public partial class Form1 : Form
    {
        private TimerProcedure timer;

        private Player player;
        private Map map;

        private void OnTimer(ref double delta, UInt32 Id)
        {
            Process((float)delta);
            Resources.QuadRender.BeginRender();
            Resources.QuadRender.Clear(0xFF000000);
            Draw();
            Resources.QuadRender.EndRender();
        }

        private void Process(float dt)
        {
            player.Process(dt);
            BulletsEngine.Process(dt);
        }

        private void Draw()
        {
            map.Draw();
            player.Draw();
            BulletsEngine.Draw();
            
            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            Resources.Cursor.Draw(Mouse.X - 8, Mouse.Y);
        }

        public Form1()
        {
            InitializeComponent();
            Resources.Load();
            Mouse.Init();
            Keyboard.Init();
            this.SetClientSizeCore(1024, 768);

            Resources.QuadRender.Initialize(this.Handle, 1024, 768, false);
            
            timer = new TimerProcedure(OnTimer);
            Resources.QuadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(timer));

            player = new Player();
            map = new Map();           


            Resources.QuadTimer.SetState(true);
        }

        private void Form1_FormClosed(object sender, FormClosedEventArgs e)
        {
            Resources.QuadTimer.SetState(false);
            Resources.Free();
        }

        private void Form1_KeyPress(object sender, KeyPressEventArgs e)
        {

        }

        private void Form1_MouseMove(object sender, MouseEventArgs e)
        {
            Mouse.SetPosition(e.X, e.Y);
        }

        private void Form1_MouseDown(object sender, MouseEventArgs e)
        {
            Mouse.SetPosition(e.X, e.Y);
            Mouse.SetDown(e.Button);
        }

        private void Form1_MouseUp(object sender, MouseEventArgs e)
        {
            Mouse.SetPosition(e.X, e.Y);
            Mouse.SetUp(e.Button);
        }

        private void Form1_KeyUp(object sender, KeyEventArgs e)
        {
            Keyboard.SetUp(e.KeyCode);
        }

        private void Form1_KeyDown(object sender, KeyEventArgs e)
        {
            Keyboard.SetDown(e.KeyCode);
        }
    }
}
