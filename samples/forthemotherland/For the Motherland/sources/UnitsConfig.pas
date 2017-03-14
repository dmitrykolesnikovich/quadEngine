unit UnitsConfig;

interface

const
  MAP_COUNT_TYPE = 7;

  MAP_WATER  = 0;
  MAP_WADE   = 1;
  MAP_GROUND = 2;
  MAP_BRIDGE = 3;
  MAP_FOREST = 4;
  MAP_HOME   = 5;
  MAP_SAND   = 6;

  UNIT_TANK_LIGHT = 0;
  UNIT_TANK_MEDIUM = 1;
  UNIT_TANK_HEAVY = 2;
  UNIT_ARTILLERY = 3;
  UNIT_REACT_ART = 4;
  UNIT_STATIC = 5;
  UNIT_NEUTRAL = 6;
  UNIT_SOLDIER = 7;

type
  PUnitConfig = ^TUnitConfig;
  TUnitConfig = record
    Name: AnsiString;
    Map: array[0..MAP_COUNT_TYPE-1] of Integer;
    Speed: Integer;
    Distance: Integer;
    HP: Integer;
    DmgMin: Integer;
    DmgMax: Integer;
    Armor: Integer;
    Arack: Integer;
    Visible: Integer;
    VisibleForest: Integer;
    UnitType: Integer;
    Frame: Integer;
  end;

const
  UnitsConfigs: array[0..14] of TUnitConfig = (
    (
      Name: 'Солдат';
      Map : (
        26,  //MAP_WATER
        16,    //MAP_WADE
        10,    //MAP_GROUND
        10,    //MAP_BRIDGE
        12,    //MAP_FOREST
        20,  //MAP_HOME
        10     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 40;
      HP            : 20;
      DmgMin        : 5;
      DmgMax        : 10;
      Armor         : 0;
      Arack         : 100;
      Visible       : 120;
      VisibleForest : 80;
      UnitType      : UNIT_SOLDIER;
      Frame         : 0;
    ),
    (
      Name: 'M3 Stuart';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        10,    //MAP_GROUND
        10,    //MAP_BRIDGE
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 50;
      HP            : 40;
      DmgMin        : 10;
      DmgMax        : 15;
      Armor         : 2;
      Arack         : 150;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_TANK_LIGHT;
      Frame         : 1;
    ),
    (
      Name: 'H39 Captured';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        10,    //MAP_GROUND
        10,    //MAP_BRIDGE
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 50;
      HP            : 50;
      DmgMin        : 13;
      DmgMax        : 15;
      Armor         : 2;
      Arack         : 150;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_TANK_LIGHT;
      Frame         : 2;
    ) ,
    (
      Name: 'SU-26';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        11,    //MAP_BRIDGE
        11,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        6     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 40;
      HP            : 35;
      DmgMin        : 40;
      DmgMax        : 60;
      Armor         : 1;
      Arack         : 300;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_ARTILLERY;
      Frame         : 3;
    )  ,
    (
      Name: 'Grille';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        11,    //MAP_BRIDGE
        11,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        6     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 40;
      HP            : 35;
      DmgMin        : 40;
      DmgMax        : 70;
      Armor         : 1;
      Arack         : 300;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_ARTILLERY;
      Frame         : 4;
    ) ,
    (
      Name: 'G20 Marder II';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        10,    //MAP_BRIDGE
        10,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 50;
      HP            : 120;
      DmgMin        : 20;
      DmgMax        : 25;
      Armor         : 3;
      Arack         : 150;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_TANK_LIGHT;
      Frame         : 5;
    ) ,
    (
      Name: 'Tetrarch LL';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        10,    //MAP_BRIDGE
        10,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 50;
      HP            : 100;
      DmgMin        : 24;
      DmgMax        : 28;
      Armor         : 3;
      Arack         : 150;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_TANK_LIGHT;
      Frame         : 6;
    ) ,
    (
      Name: 'БМ-13 "Катюша"';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        11,    //MAP_BRIDGE
        11,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        6     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 40;
      HP            : 35;
      DmgMin        : 60;
      DmgMax        : 100;
      Armor         : 1;
      Arack         : 300;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_REACT_ART;//UNIT_ARTILLERY;
      Frame         : 7;
    ),
    (
      Name: 'T-34';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        10,    //MAP_BRIDGE
        10,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 50;
      HP            : 220;
      DmgMin        : 50;
      DmgMax        : 70;
      Armor         : 6;
      Arack         : 150;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_TANK_MEDIUM;
      Frame         : 8;
    ) ,
    (
      Name: 'PzIV Hydro';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        10,    //MAP_BRIDGE
        10,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 50;
      HP            : 210;
      DmgMin        : 55;
      DmgMax        : 70;
      Armor         : 7;
      Arack         : 150;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_TANK_MEDIUM;
      Frame         : 9;
    ),
    (
      Name: 'КВ2';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        10,    //MAP_BRIDGE
        10,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 35;
      HP            : 400;
      DmgMin        : 60;
      DmgMax        : 100;
      Armor         : 10;
      Arack         : 150;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_TANK_HEAVY;
      Frame         : 10;
    ) ,
    (
      Name: 'PzVIB Tiger II';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        10,    //MAP_BRIDGE
        10,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 35;
      HP            : 430;
      DmgMin        : 60;
      DmgMax        : 110;
      Armor         : 11;
      Arack         : 150;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_TANK_HEAVY;
      Frame         : 11;
    ),
    (
      Name: 'SU-8';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        11,    //MAP_BRIDGE
        11,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 40;
      HP            : 80;
      DmgMin        : 100;
      DmgMax        : 160;
      Armor         : 3;
      Arack         : 300;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_ARTILLERY;
      Frame         : 12;
    ),
    (
      Name: 'JagdPz E100';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        11,    //MAP_BRIDGE
        11,    //MAP_GROUND
        40,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 40;
      HP            : 80;
      DmgMin        : 110;
      DmgMax        : 150;
      Armor         : 3;
      Arack         : 270;
      Visible       : 150;
      VisibleForest : 80;
      UnitType      : UNIT_ARTILLERY;
      Frame         : 13;
    ),
    (
      Name: 'Грузовик';
      Map : (
        1000,  //MAP_WATER
        20,    //MAP_WADE
        10,    //MAP_BRIDGE
        10,    //MAP_GROUND
        25,    //MAP_FOREST
        1000,  //MAP_HOME
        5     //MAP_SAND
      );
      Speed         : 100;
      Distance      : 50;
      HP            : 40;
      DmgMin        : 0;
      DmgMax        : 0;
      Armor         : 1;
      Arack         : 0;
      Visible       : 100;
      VisibleForest : 80;
      UnitType      : UNIT_NEUTRAL;
      Frame         : 14;
    )
  );

implementation

end.
