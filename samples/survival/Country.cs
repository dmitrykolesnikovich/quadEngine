using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;
using System.Drawing;

namespace Survival
{
    [XmlRoot("Countries")]
    public class Countries
    {
        public Countries() 
        {
            Items = new List<Country>();
        }

        public Country GetCountry(int xpos, int ypos)
        {
            Color col = Color.FromArgb((int)Resources.worldMapPolitical.GetPixelColor(xpos, ypos));

            foreach (Country country in this.Items)
            {
                if (col == Color.FromArgb(country.red, country.green, country.blue))
                {
                    return country;
                }
            }

            return null;
        }

        [XmlElement("Country")]
        public List<Country> Items { get; set; }

        public int WorldSize { 
            get 
            { 
                return Resources.worldMapPolitical.GetSpriteWidth();                     
            }
        }

        public Int64 WorldPopulation {
            get
            {
                Int64 worldPopulation = 0;

                foreach (Country country in Resources.countries.Items)
                {
                    worldPopulation += country.maxPopulation;
                }

                return worldPopulation;
            }

        }
    }

    public class Country
    {
            public string name {get; set;}
            [XmlElement("maxPopulation")]
            public int maxPopulation { get; set; }
            public double maxYearTemperature;
            public double minMonthTemperature;
            public byte red;
            public byte green;
            public byte blue;
    }
}
