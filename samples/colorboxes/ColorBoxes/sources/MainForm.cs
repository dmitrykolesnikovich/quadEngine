using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QuadEngine;
using System.Runtime.InteropServices;
using Boxes.Resources;
using Boxes.GameLogic;
using Boxes.GameGraphic;

namespace Boxes
{
    public partial class MainForm : Form
    {
        public IQuadDevice quadDevice;
        IQuadRender quadRender;
        IQuadTimer quadTimer;

        TimerProcedure timer;

        GameManager gm;

        BoxColor currentColor = BoxColor.White;
        static bool paused = false;
        static bool color_changing = false;
        
        public MainForm()
        {
            InitializeComponent();

            this.SetClientSizeCore(1280, 720);

            QuadEngine.QuadEngine.CreateQuadDevice(out quadDevice);
            quadDevice.CreateRender(out quadRender);

            Cursor.Hide();

            quadRender.Initialize(this.Handle, 1280, 720, false);

            quadDevice.CreateTimer(out quadTimer);
            quadTimer.SetInterval(16);
            timer = (TimerProcedure)OnTimer;
            quadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(timer));

            quadTimer.SetState(true);

            Cursor.Hide();

            GraphicResources.Initialize(quadDevice);

            gm = new GameManager();
            Level.LoadLevel(1, gm);
        }

        private void OnTimer(ref double delta, UInt32 Id)
        {
            quadRender.BeginRender();
            if (!paused)
             gm.Proceed(delta);
            quadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            //quadRender.SetBlendMode(TQuadBlendMode.qbmInvertSrcColor);
            gm.back.Draw(quadRender);
            //quadRender.Clear(gm.back.DrawColor);

            /*quadRender.RenderToTexture(true, GraphicResources.TextureGlow);
                quadRender.Clear(0xFF000000);
                quadRender.SetBlendMode(TQuadBlendMode.qbmNone);
                gm.Draw();
            quadRender.RenderToTexture(false, GraphicResources.TextureGlow);
            //quadRender.SetBlendMode(TQuadBlendMode.qbmSrcColor);
            GraphicResources.TextureGlow.DrawMap(0, 0, 1024, 768, 0, 0, 1, 1);
             */
            
            gm.Draw();
            quadRender.EndRender();
        }

        private void MainForm_KeyDown(object sender, KeyEventArgs e)
        {
            gm.SetKeyDown(e.KeyCode);
        }
        private void MainForm_KeyPress(object sender, KeyPressEventArgs e)
        {
            switch(e.KeyChar)
            {
                case 'я':
                case 'z':
                case ' ':
                    if (!color_changing)
                    {
                        gm.back.SetNewColor(GameManager.CurrentColor.Next());
                        color_changing = true;
                    }
                    break;
                case 'к':
                case 'r':
                    Level.LoadLevel(Level.Number, gm);
                    break;
                case (char)Keys.Enter:
                    paused = !paused;
                    break;
                case (char)Keys.Escape:
                    this.Close();
                    break;
                default:
                    return;
            }
        }
        private void MainForm_KeyUp(object sender, KeyEventArgs e)
        {
            gm.SetKeyUp(e.KeyCode);
            if (e.KeyCode == Keys.Space || e.KeyCode == Keys.Z)
                color_changing = false;
        }

    }
}
