local E = {
    ID = "default",
    Name = "Exteriors.DefaultPoliceBox",
    Base = "base",
    Category = "Exteriors.Categories.PoliceBoxes",

    Model="models/vtalanov98/toyota_ext/exterior.mdl",
    Mass=2900,
    DoorAnimationTime = 0.6,

    Parts = {
        door = {
            model="models/vtalanov98/toyota_ext/doors_exterior.mdl",
            posoffset=Vector(-1,0,-52.8),
            angoffset=Angle(0,0,0),
        }
    },
    Portal = {
        pos = Vector(27.8,0,52.33),
        ang = Angle(0,0,0),
        width = 50,
        height = 92,
        thickness = 42,
        inverted = true,
    },
    Sounds = {
        Teleport = {
            demat = "p00gie/tardis/default/demat_ext.ogg",
            demat_fast = "p00gie/tardis/default/demat_ext.ogg",
            demat_hads = "p00gie/tardis/demat_hads.wav",
            mat = "p00gie/tardis/default/mat_ext.ogg",
            mat_fast = "p00gie/tardis/default/mat_fast.ogg",
            mat_damaged_fast = "p00gie/tardis/mat_damaged_fast.wav",
            fullflight = "p00gie/tardis/default/full_ext.ogg",
            interrupt = "drmatt/tardis/repairfinish.wav",
        },
        Door = {
            enabled = true,
            open = "p00gie/tardis/default/door_open2.ogg",
            close = "p00gie/tardis/default/door_close.ogg",
        },
        Spawn = "drmatt/tardis/repairfinish.wav",
        Delete = "p00gie/tardis/tardis_delete.wav",
        RepairFinish = "drmatt/tardis/repairfinish.wav",
        FlightLand = "p00gie/tardis/default/tardis_land.ogg",
    },
    Light = {
        enabled = true,
        pos = Vector(0,0,122),
        color = Color(160,190,255),
        dynamicpos = Vector(0,0,130),
        dynamicbrightness = 2,
        dynamicsize = 300,
        warncolor = Color(255,200,200),
    },
    Teleport = {
        DematSequenceDelays={
			[1] = 2.5
		},
    }
}

TARDIS:AddExterior(E)

TARDIS:AddInteriorTemplate("default_exterior", { Exterior = E, })