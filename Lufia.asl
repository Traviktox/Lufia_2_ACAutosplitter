// Lufia 2 - Ancient Cave Autosplitter by Traviktox

// Feedback, bug report or suggestions:
// Discord: Traviktox#5818 
// twitch.tv/traviktox

// Basic format of the script is based on:
// https://github.com/Spiraster/ASLScripts/tree/master/LiveSplit.SMW

state("higan"){}
state("bsnes"){}
state("snes9x"){}
state("snes9x-x64"){}
state("emuhawk"){}
state("retroarch"){}
state("lsnes-bsnes"){}

startup
{
    settings.Add("Floors", true, "Floors");
    settings.SetToolTip("Floors", "Split on floors");
    settings.Add("EveryFloor", true, "Every floor", "Floors");
    settings.SetToolTip("EveryFloor", "Split on every floor");
    settings.Add("Every10th", false, "Every 10th floor", "Floors");
    settings.SetToolTip("Every10th", "Split every 10th floor");
    settings.Add("1st", false, "1st floor", "Floors");
    settings.SetToolTip("1st", "Splits, when you enter the ancient cave");
    settings.Add("98th", false, "98th floor", "Every10th");
    settings.SetToolTip("98th", "Splits, when you enter the blob room");
    settings.Add("Blobkill", true, "Blobkill");
    settings.SetToolTip("Blobkill", "Split at blobkill");
	
	vars.frameRate = 60.0;
}

init
{
    var states = new Dictionary<int, long>
    {
        { 10330112, 0x789414 },     //snes9x 1.52-rr
        { 7729152, 0x890EE4 },      //snes9x 1.54-rr
        { 5914624, 0x6EFBA4 },      //snes9x 1.53
        { 6909952, 0x140405EC8 },   //snes9x 1.53 (x64)
        { 6447104, 0x7410D4 },      //snes9x 1.54/1.54.1
        { 7946240, 0x1404DAF18 },   //snes9x 1.54/1.54.1 (x64)
        { 6602752, 0x762874 },      //snes9x 1.55
        { 8355840, 0x1405BFDB8 },   //snes9x 1.55 (x64)
        { 6856704, 0x78528C },      //snes9x 1.56/1.56.2
        { 9003008, 0x1405D8C68 },   //snes9x 1.56 (x64)
        { 6848512, 0x7811B4 },      //snes9x 1.56.1
        { 8945664, 0x1405C80A8 },   //snes9x 1.56.1 (x64)
        { 9015296, 0x1405D9298 },   //snes9x 1.56.2 (x64)
        { 6991872, 0x7A6EE4 },      //snes9x 1.57
        { 9048064, 0x1405ACC58 },   //snes9x 1.57 (x64)
        { 7000064, 0x7A7EE4 },      //snes9x 1.58
        { 9060352, 0x1405AE848 },   //snes9x 1.58 (x64)
        { 8953856, 0x975A54 },      //snes9x 1.59.2
        { 12537856, 0x1408D86F8 },  //snes9x 1.59.2 (x64)
	{ 9646080, 0x97EE04 },	    //Snes9x-rr 1.60
	{ 13565952, 0x140925118 },  //Snes9x-rr 1.60 (x64)
        { 9027584, 0x94DB54 },      //snes9x 1.60
        { 12836864, 0x1408D8BE8 },  //snes9x 1.60 (x64)
	{ 10399744,  0x9B74D0 },    // Snes9x 1.62.3
        { 15474688,  0x140A62390 }, // Snes9x 1.62.3 (x64)
        { 12509184, 0x915304 },     //higan v102
        { 13062144, 0x937324 },     //higan v103
        { 15859712, 0x952144 },     //higan v104
        { 16756736, 0x94F144 },     //higan v105tr1
        { 16019456, 0x94D144 },     //higan v106
	{ 15360000, 0x8AB144 },     //higan v106.112
        { 10096640, 0x72BECC },     //bsnes v107
        { 10338304, 0x762F2C },     //bsnes v107.1
        { 47230976, 0x765F2C },     //bsnes v107.2/107.3
	{ 142282752, 0xA65464 },	//bsnes v108
	{ 131354624, 0xA6ED5C },	//bsnes v109
	{ 131543040, 0xA9BD5C },	//bsnes v110
	{ 51924992, 0xA9DD5C },		//bsnes v111
	{ 52056064, 0xAAED7C }, 	//bsnes v112
	{ 52477952,  0xB16D7C },      // bsnes v115
	{ 9662464, 0x67dac8 },		//bsnes+ 0.5
	{ 6152192, 0x08EB0000 }, //BizHawk 1.6
        { 7061504, 0x36F11500240 }, //BizHawk 2.3
        { 7249920, 0x36F11500240 }, //BizHawk 2.3.1
	{ 6938624, 0x36F11500240 }, //BizHawk 2.3.2
	{ 5406720, 0x36F11500240 }, //BizHawk 2.4.0
	{ 5054464, 0x36F11500240 }, //BizHawk 2.4.1/2
	{ 4784128, 0x36F08F92040 }, //BizHawk 2.5.0/1
	{ 4759552, 0x36F08F92040 }, //BizHawk 2.5.2
	{ 4538368, 0x36F05F94040 }, // BizHawk 2.6.0/2.6.2
	{ 4546560, 0x36F05F94040 }, // BizHawk 2.6.1
    };

    long memoryOffset;
    if (states.TryGetValue(modules.First().ModuleMemorySize, out memoryOffset))
        if (memory.ProcessName.ToLower().Contains("snes9x"))
            memoryOffset = memory.ReadValue<int>((IntPtr)memoryOffset);

    if (memoryOffset == 0)
        throw new Exception("Memory not yet initialized.");

    vars.watchers = new MemoryWatcherList
    {
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0370) { Name = "musicTrack" },
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0B75) { Name = "floor" },
    	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x421d) { Name = "blob" },
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x11E8) { Name = "round_counter" },
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0B50) { Name = "igtFrames" },
    	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0B4F) { Name = "igtSeconds" },
    	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0B4E) { Name = "igtMinutes" },
    	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0B4D) { Name = "igtHours" },
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0054) { Name = "menu1" },
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x005A) { Name = "menu2" },
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x14AC) { Name = "fadeout" },
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0573) { Name = "screen1" },
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0574) { Name = "screen2" },

    };
}

update
{
    vars.watchers.UpdateAll(game);
}

start
{
    return (vars.watchers["menu1"].Current == 2 && vars.watchers["menu2"].Current == 4 && vars.watchers["screen1"].Current == 140 && vars.watchers["screen2"].Current == 53 && vars.watchers["fadeout"].Old == 0 && vars.watchers["fadeout"].Current == 16);
}

reset
{
    return vars.watchers["floor"].Old != 0 && vars.watchers["floor"].Current == 0;
}

split
{
    var nextfloor = settings["EveryFloor"] && (vars.watchers["floor"].Old + 1 == vars.watchers["floor"].Current) && vars.watchers["floor"].Current !=1;
    var tenfloor = settings["Every10th"] && (vars.watchers["floor"].Old + 1 == vars.watchers["floor"].Current) && (((vars.watchers["floor"].Current - 1) % 10) == 0) && vars.watchers["floor"].Current !=1;
    var first = settings["1st"] && (vars.watchers["floor"].Old + 1 == vars.watchers["floor"].Current) && vars.watchers["floor"].Current ==1;
    var nineeight = settings["98th"] && (vars.watchers["floor"].Old + 1 == vars.watchers["floor"].Current) && vars.watchers["floor"].Current == 99;
    var blobkill = settings["Blobkill"] && vars.watchers["blob"].Current == 31 && vars.watchers["blob"].Old == 00 && vars.watchers["floor"].Current == 99 && (vars.watchers["round_counter"].Current == 1 || vars.watchers["round_counter"].Current == 2 || vars.watchers["round_counter"].Current == 3);
    return nextfloor || blobkill || tenfloor || nineeight || first;
}

gameTime
{
    var frames  = vars.watchers["igtFrames"].Current;
    var seconds = vars.watchers["igtSeconds"].Current;
    var minutes = vars.watchers["igtMinutes"].Current;
    var hours   = vars.watchers["igtHours"].Current;

    if(frames == 0 && vars.watchers["igtFrames"].Old == 49){
        vars.frameRate = 50.0;
    }

    current.totalTime = (frames / vars.frameRate) + seconds + (60 * minutes) + (60 * 60 * hours);
    return TimeSpan.FromSeconds(current.totalTime);
}

isLoading
{
    // From the AutoSplit documentation:
    // "If you want the Game Time to not run in between the synchronization interval and only ever return
    // the actual Game Time of the game, make sure to implement isLoading with a constant
    // return value of true."
    return true;
}
