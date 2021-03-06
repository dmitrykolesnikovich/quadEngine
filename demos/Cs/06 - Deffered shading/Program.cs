﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;
using System.Runtime.InteropServices;

namespace Demo06
{
    class Program
    {
        private struct Particle {
            public float X, Y, Z;
            public uint color;
            public float radius;            
         };

        private static IQuadDevice quadDevice;
        private static IQuadWindow quadWindow;
        private static IQuadRender quadRender;
        private static IQuadTimer quadTimer;

        private static IQuadInput quadInput;
        private static IQuadGBuffer quadGBuffer;
        private static IQuadTexture texture;
        private static IQuadCamera camera;
        private static IQuadTexture diff;

        private static List<Particle> mList = new List<Particle>();

        private static double t = 0.0f;

        private static TimerProcedure timer;

        private static void OnTimer(ref double delta, UInt32 Id)
        {
            quadInput.Update();


            quadRender.BeginRender();
            quadRender.Clear(0);

            camera.Enable();
            quadRender.RenderToGBuffer(true, quadGBuffer);
            quadRender.SetBlendMode(TQuadBlendMode.qbmNone);
            texture.Draw(new Vec2f());
            quadRender.RenderToGBuffer(false, quadGBuffer);
            camera.Disable();

            IQuadTexture DiffuseMap;
            quadGBuffer.GetDiffuseMap(out DiffuseMap);
            DiffuseMap.Draw(new Vec2f(), 0xFF080808);

            t += delta;
            Particle prt;
            if (t > 1.0)
            {
                t = 0.0f;
                Random rand = new Random();
                prt = new Particle();             
                prt.radius = rand.Next(50, 250);
                prt.X = rand.Next(800);
                prt.Y = -100;
                prt.Z = rand.Next(5, 35);
                prt.color = (uint)(rand.NextDouble() * 0xFFFFFF) + 0xFF000000;
                mList.Add(prt);
            }

            quadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlphaAdd);
            
            for (int i = mList.Count - 1; i >= 0; i--)
            {
                prt = mList[i];
                prt.Y += (float)delta * 100.0f;
                mList[i] = prt;

                quadGBuffer.DrawLight(new Vec2f(prt.X, prt.Y), prt.Z, prt.radius, prt.color);

                camera.Enable();
                quadRender.Rectangle(new Vec2f(prt.X - 2, prt.Y - 2), new Vec2f(prt.X + 2, prt.Y + 2), prt.color);
                camera.Disable();

                quadRender.FlushBuffer();
                if (prt.Y > 1000)
                    mList.RemoveAt(i);
            }
            
            quadRender.EndRender();
        }

        static void Main(string[] args)
        {
            QuadEngine.QuadEngine.CreateQuadDevice(out quadDevice);
            quadDevice.CreateWindow(out quadWindow);
            quadWindow.SetCaption("QuadEngine - Demo06 - Deffered shading");
            quadWindow.SetSize(800, 600);
            quadWindow.SetPosition(100, 100);

            quadDevice.CreateRender(out quadRender);
            quadRender.Initialize((IntPtr)(int)(uint)quadWindow.GetHandle(), 800, 600, false);

            quadDevice.CreateAndLoadTexture(0, "data\\Diffuse.jpg", out diff);
            quadDevice.CreateAndLoadTexture(0, "data\\Diffuse.jpg", out texture);
            texture.LoadFromFile(1, "data\\Normal.jpg");
            texture.LoadFromFile(2, "data\\Specular.jpg");
            texture.LoadFromFile(3, "data\\Bump.jpg");

            quadDevice.CreateGBuffer(out quadGBuffer);
            quadDevice.CreateCamera(out camera);
            quadWindow.CreateInput(out quadInput);

            quadDevice.CreateTimer(out quadTimer);

            timer = (TimerProcedure)OnTimer;
            quadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(timer));
            quadTimer.SetInterval(16);
            quadTimer.SetState(true);

            quadWindow.Start();
        }
    }
}
