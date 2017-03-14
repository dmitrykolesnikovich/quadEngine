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
    public partial class frmMain : Form
    {
        private IQuadDevice quadDevice;
        private IQuadRender quadRender;
        private IQuadTimer quadTimer;

        private TimerProcedure timer;

        private Map map;

        public frmMain()
        {
            InitializeComponent();

            bool bb = Bass.Bass.BASS_Init(1, 44100, 0, this.Handle, IntPtr.Zero);
            bool cc = Bass.Bass.BASS_Start();

            Mouse.Init();
            Keyboard.Init();
            this.SetClientSizeCore(1024, 768);

            QuadEngine.QuadEngine.CreateQuadDevice(out quadDevice);
            quadDevice.CreateRender(out quadRender);

            Cursor.Hide();

            quadRender.Initialize(this.Handle, 1024, 768, false);

            quadDevice.CreateTimer(out quadTimer);
            quadTimer.SetInterval(16);
            timer = (TimerProcedure)OnTimer;
            quadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(timer));

            Player.Init();
            map = new Map();
            
            Resources.Load(quadDevice, quadRender);
            map.Init();
            quadTimer.SetState(true);
        }

        private void OnTimer(ref double delta, UInt32 Id)
        {
            Process((float)delta);
            quadRender.BeginRender();
            quadRender.Clear(0xFF000000);
            Draw();
            quadRender.EndRender();
        }

        private void Process(float dt)
        {
            if (Player.IsNeedToKill())
            {
                if (Keyboard.Down(Keys.Space))
                {
                    Player.Init();
                    BulletsEngine.Init();
                    BotsEngine.Init();
                    LightEngine.Init();
                    EffectEngine.Init();
                    map.Init();
                    Resources.InitTarget();
                }
            }
            else
            {
                Player.Process(dt);
                BulletsEngine.Process(dt);
                BotsEngine.Process(dt);
                LightEngine.Process(dt);
                EffectEngine.Process(dt);
            }
        }

        private void Draw()
        {
            map.Draw();

            quadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            Resources.GroundTarget.Draw(0.0f, 0.0f);

            BulletsEngine.Draw();
            Player.Draw();
            BotsEngine.Draw();

            map.Draw1();

            EffectEngine.Draw();
            LightEngine.Draw();

            Player.DrawPanel();

            quadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            Resources.Cursor.DrawRot(Mouse.X, Mouse.Y, 0.0f, 1.0f, 0xFF00FF00);

            if (Player.IsNeedToKill())
            {
                Resources.QuadRender.Rectangle(512.0f - 196.0f, 384.0f - 96.0f, 512.0f + 196.0f, 384.0f + 148.0f, 0xFF000000);

                Resources.FontBlood.TextOut(512.0f, 384.0f - 70.0f, 2.0f, "you loose", 0xFFFFFFFF, TqfAlign.qfaCenter);
                Resources.FontBlood.TextOut(512.0f, 384.0f, 1.0f, "you have gained points", 0xFFFFFFFF, TqfAlign.qfaCenter);
                Resources.FontBlood.TextOut(512.0f, 384.0f + 30.0f, 1.5f, Player.GetPoints().ToString(), 0xFFFFFFFF, TqfAlign.qfaCenter);
                Resources.FontBlood.TextOut(512.0f, 384.0f + 100.0f, 1.0f, "press space to try again", 0xFFFFFFFF, TqfAlign.qfaCenter); 

            }
            /*
            Resources.FontConsole.TextOut(10, 10, 1, quadTimer.GetFPS().ToString());
            Resources.FontConsole.TextOut(10, 30, 1, quadTimer.GetCPUload().ToString());

            Resources.FontConsole.TextOut(10, 50, 1, BulletsEngine.Count().ToString());
            Resources.FontConsole.TextOut(10, 70, 1, BotsEngine.Count().ToString());*/
        }

        private void Form1_FormClosed(object sender, FormClosedEventArgs e)
        {
            quadTimer.SetState(false);
            Resources.Free();

            quadTimer = null;
            quadRender = null;
            quadDevice = null;
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

        private void frmMain_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 'f')
                Player.Flashlight = !Player.Flashlight;
        }
    }
}
