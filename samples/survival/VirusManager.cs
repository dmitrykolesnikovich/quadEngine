using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;
using QuadEngine;

namespace Survival
{
    public sealed class VirusManager
    {
        public List<Virus> Items;
        public List<int> Mutations;

        public VirusManager()
        {
            Items = new List<Virus>();
        }

        public void Draw(int position)
        {
            if (this.IsEmpty)
            {
                Resources.QuadFont.TextOut(Resources.ScreenWidth / 2 - 2, Resources.ScreenHeight / 2 - 2, 1, "Choose a spot to infect", 0xFF111111, TqfAlign.qfaCenter);
                Resources.QuadFont.TextOut(Resources.ScreenWidth / 2, Resources.ScreenHeight / 2, 1, "Choose a spot to infect", 0xFFFFCC33, TqfAlign.qfaCenter);
                return;
            }

            Resources.QuadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlphaAdd);
            foreach (Virus virus in Items)
            {
                virus.Draw(position);
            }
        }

        public void AddVirus(int xpos, int ypos)
        {
            Color col = Color.FromArgb((int)Resources.worldMapPolitical.GetPixelColor(xpos, ypos));
            if (col.A == 0)
                return;

            Random rand = new Random();
            Items.Add(new Virus(xpos, ypos, Resources.countries.GetCountry(xpos, ypos), rand.Next(100) + 50));
        }

        public void Spread() 
        {
            Random rnd = new Random();
            int count = Items.Count;

            for (int i = 0; i < count; i++)
            {
                Virus virus = Items[i];
                virus.Grow();
                
                Vec2f pos = virus.Pos;
                Vec2f vec = new Vec2f(rnd.Next(-11, 11), rnd.Next(-11, 11));
                vec = vec.Normalize() * 10;
                pos += vec;

                bool isMatched = false;

                foreach (Virus virus_in in Items)
                {
                    if (virus != virus_in)
                    if (virus_in.Pos.Distance(pos) < 5)
                    {
                        isMatched = true;
                        break;
                    }
                }

                if (!isMatched)
                {
                    int seed = 1;
                    if (Resources.countries.GetCountry((int)pos.X, (int)pos.Y) != virus.Country) { seed += 20; }

                    if (rnd.Next(seed) == 0)
                        AddVirus((int)pos.X, (int)pos.Y);
                }
            }
        }

        public bool IsEmpty 
        { 
            get
            {
                return Items.Count == 0;
            }
        }
    }
}
