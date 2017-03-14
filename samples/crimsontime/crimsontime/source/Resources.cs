using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using QuadEngine;

namespace quadtest
{
    public struct BotResource
    {
        public IQuadTexture[] Texture;
        public int[] Frame;
    }

    public static class Resources
    {
        public static UInt32[] DeathMob;
        public static UInt32[] HitMob;
        public static UInt32[] M16;
        public static UInt32[] RPG;
        public static UInt32[] sExplosion;
        public static UInt32[] Pain;
        public static UInt32 M15Reload;  

        public static IQuadRender QuadRender;
        public static IQuadDevice QuadDevice;

        private static IQuadTexture player;
        private static IQuadTexture flashlight;
        private static IQuadTexture ground;
        private static IQuadTexture road;
        private static IQuadTexture cursor;
        private static IQuadTexture pillar;
        private static IQuadTexture muzzle;
        private static IQuadTexture muzzleLight;
        private static IQuadTexture numbers;
        private static IQuadTexture blood;
        private static IQuadTexture rocket;
        private static IQuadTexture explosion;
        private static IQuadTexture crater;
        private static IQuadTexture heart;    
        private static IQuadTexture light; 
        public static IQuadTexture GroundTarget;
        public static IQuadTexture LightTarget;
        private static IQuadTexture lantern;
        private static IQuadTexture bullet;
        private static IQuadTexture hp;
        private static IQuadFont fontConsole;
        private static IQuadFont fontBlood;
        private static BotResource mutant;
        private static BotResource mutant1;

        private static IQuadTexture bullet1;
        private static IQuadTexture shell;

        public static IQuadTexture Shell { get { return shell; } }
        public static IQuadTexture Player { get { return player; } }
        public static IQuadTexture Flashlight { get { return flashlight; } }
        public static IQuadTexture Ground { get { return ground; } }
        public static IQuadTexture Road { get { return road; } }
        public static IQuadTexture Cursor { get { return cursor; } }
        public static IQuadTexture Pillar { get { return pillar; } }
        public static IQuadTexture Muzzle { get { return muzzle; } }
        public static IQuadTexture MuzzleLight { get { return muzzleLight; } }
        public static IQuadTexture Numbers { get { return numbers; } }
        public static IQuadTexture Blood { get { return blood; } }
        public static IQuadTexture Rocket { get { return rocket; } }
        public static IQuadTexture Explosion { get { return explosion; } }
        public static IQuadTexture Crater { get { return crater; } }
        public static IQuadTexture Light { get { return light; } }
        public static IQuadTexture Heart { get { return heart; } }        
        public static IQuadTexture Bullet { get { return bullet; } }
        public static IQuadFont FontConsole { get { return fontConsole; } }
        public static IQuadFont FontBlood { get { return fontBlood; } }

        public static IQuadTexture Bullet1 { get { return bullet1; } }

        public static BotResource Mutant { get { return mutant; } }
        public static BotResource Mutant1 { get { return mutant1; } }
        public static IQuadTexture Lantern { get { return lantern; } }
        public static IQuadTexture Hp { get { return hp; } }

        public static IQuadTexture lightTarget;

        public static void InitTarget()
        {
            QuadRender.BeginRender();
            QuadRender.RenderToTexture(true, GroundTarget);
            QuadRender.Clear(0x00000000);
            QuadRender.RenderToTexture(false, GroundTarget);
            QuadRender.EndRender();
        }

        public static void Load(IQuadDevice quadDevice, IQuadRender quadRender)
        {
            QuadRender = quadRender;
            QuadDevice = quadDevice;
            quadDevice.CreateRenderTarget(1024, 768, ref GroundTarget, 0);
            quadDevice.CreateRenderTarget(1024, 768, ref LightTarget, 0);
            InitTarget();

            Pain = new UInt32[4];
            Pain[0] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\Pain1.wav", 0, 0, 32, 0);
            Pain[1] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\Pain2.wav", 0, 0, 32, 0);
            Pain[2] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\Pain3.wav", 0, 0, 32, 0);
            Pain[3] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\Pain4.wav", 0, 0, 32, 0);

            DeathMob = new UInt32[4];
            DeathMob[0] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\death1.wav", 0, 0, 32, 0);
            DeathMob[1] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\death2.wav", 0, 0, 32, 0);
            DeathMob[2] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\death3.wav", 0, 0, 32, 0);
            DeathMob[3] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\death4.wav", 0, 0, 32, 0);

            sExplosion = new UInt32[2];
            sExplosion[0] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\Explosion1.wav", 0, 0, 32, 0);
            sExplosion[1] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\Explosion2.wav", 0, 0, 32, 0);

            RPG = new UInt32[2];
            RPG[0] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\RPG1.wav", 0, 0, 32, 0);
            RPG[1] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\RPG2.wav", 0, 0, 32, 0);

            HitMob = new UInt32[7];
            HitMob[0] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\hit1.wav", 0, 0, 32, 0);
            HitMob[1] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\hit2.wav", 0, 0, 32, 0);
            HitMob[2] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\hit3.wav", 0, 0, 32, 0);
            HitMob[3] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\hit4.wav", 0, 0, 32, 0);
            HitMob[4] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\hit5.wav", 0, 0, 32, 0);
            HitMob[5] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\hit6.wav", 0, 0, 32, 0);
            HitMob[6] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\hit7.wav", 0, 0, 32, 0);
                    
            M15Reload = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\M15Reload.wav", 0, 0, 32, 0);
           
            M16 = new UInt32[3];
            M16[0] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\M161.wav", 0, 0, 32, 0);
            M16[1] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\M162.wav", 0, 0, 32, 0);
            M16[2] = Bass.Bass.BASS_SampleLoad(false, "Data\\Sound\\M163.wav", 0, 0, 32, 0);

            quadDevice.CreateAndLoadTexture(0, "Data\\Player.png", out player, 128, 128);
            quadDevice.CreateAndLoadTexture(0, "Data\\Flashlight.jpg", out flashlight);
            quadDevice.CreateAndLoadTexture(0, "Data\\Muzzle.png", out muzzle);
            quadDevice.CreateAndLoadTexture(0, "Data\\MuzzleLight.jpg", out muzzleLight);
            quadDevice.CreateAndLoadTexture(0, "Data\\Blood.png", out blood, 64, 64);
            quadDevice.CreateAndLoadTexture(0, "Data\\Rocket.png", out rocket, 8, 16);
            quadDevice.CreateAndLoadTexture(0, "Data\\Crater.png", out crater, 8, 16);
            quadDevice.CreateAndLoadTexture(0, "Data\\Light.jpg", out light);

            quadDevice.CreateAndLoadTexture(0, "Data\\Numbers.png", out numbers, 16, 32);
            quadDevice.CreateAndLoadTexture(0, "Data\\Ground.jpg", out ground);
            quadDevice.CreateAndLoadTexture(0, "Data\\Road.png", out road);
            quadDevice.CreateAndLoadTexture(0, "Data\\Cursor.png", out cursor);
            quadDevice.CreateAndLoadTexture(0, "Data\\Pillar.png", out pillar);

            quadDevice.CreateAndLoadTexture(0, "Data\\Explosion.png", out explosion, 128, 128); 
            quadDevice.CreateAndLoadTexture(0, "Data\\Lantern.jpg", out lantern);
            quadDevice.CreateAndLoadTexture(0, "Data\\Bullet.png", out bullet);
            quadDevice.CreateAndLoadTexture(0, "Data\\Bullet1.png", out bullet1);
            quadDevice.CreateAndLoadTexture(0, "Data\\Heart.png", out heart);    
            quadDevice.CreateAndLoadTexture(0, "Data\\Hp.png", out hp, 11, 16);
            quadDevice.CreateAndLoadTexture(0, "Data\\Shell.png", out shell);   
            

            quadDevice.CreateAndLoadFont("Data\\FontConsole.png", "Data\\FontConsole.qef", out fontConsole);
            quadDevice.CreateAndLoadFont("Data\\FontBlood.png", "Data\\FontBlood.qef", out fontBlood);

            mutant.Texture = new IQuadTexture[5];
            mutant.Frame = new int[5] {52, 29, 36, 32, 1};
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant\\Step.png", out mutant.Texture[0], 128, 128);
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant\\Run.png", out mutant.Texture[1], 128, 128);
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant\\Atack.png", out mutant.Texture[2], 128, 128);
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant\\Death.png", out mutant.Texture[3], 128, 128);
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant\\Dead.png", out mutant.Texture[4], 128, 128);

            mutant1.Texture = new IQuadTexture[5];
            mutant1.Frame = new int[5] { 89, 34, 48, 32, 1 };
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant1\\Step.png", out mutant1.Texture[0], 128, 128);
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant1\\Run.png", out mutant1.Texture[1], 128, 128);
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant1\\Atack.png", out mutant1.Texture[2], 128, 128);
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant1\\Death.png", out mutant1.Texture[3], 128, 128);
            quadDevice.CreateAndLoadTexture(0, "Data\\Mutant1\\Dead.png", out mutant1.Texture[4], 128, 128);
                       
        }

        public static void Free()
        {
            player = null;
            ground = null;
            road = null;
            cursor = null;

            fontConsole = null;
        }
    }
}
