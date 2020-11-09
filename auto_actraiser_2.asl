// Lufia 2 - Ancient Cave Autosplitter by Traviktox

// Feedback or bug report:
// Discord: Traviktox#5818 
// twitch.tv/traviktox

// Basic format of the script is based on:
// https://github.com/Spiraster/ASLScripts/tree/master/LiveSplit.SMW

// Delay from the start of the autosplitter 

state("higan") {}
state("snes9x") {}
state("snes9x-x64") {}
state("emuhawk") {}

startup
{
    settings.Add("easy", true);
    settings.SetToolTip("easy", "Splits on every Boss on difficulty easy");
    settings.Add("normal/hard", false);
    settings.SetToolTip("normal/hard", "Splits on every Boss on difficulty normal or hard");
}

init
{
	vars.i = 25;
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
		{ 9646080, 0x97EE04 },		//Snes9x-rr 1.60
		{ 13565952, 0x140925118 },	//Snes9x-rr 1.60 (x64)
        { 9027584, 0x94DB54 },      //snes9x 1.60
        { 12836864, 0x1408D8BE8 },  //snes9x 1.60 (x64)
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
		{ 9662464, 0x67dac8 },		//bsnes+ 0.5
        { 7061504, 0x36F11500240 }, //BizHawk 2.3
        { 7249920, 0x36F11500240 }, //BizHawk 2.3.1
		{ 6938624, 0x36F11500240 }, //BizHawk 2.3.2
    };

    long memoryOffset;
    if (states.TryGetValue(modules.First().ModuleMemorySize, out memoryOffset))
        if (memory.ProcessName.ToLower().Contains("snes9x"))
            memoryOffset = memory.ReadValue<int>((IntPtr)memoryOffset);

    if (memoryOffset == 0)
        throw new Exception("Memory not yet initialized.");

    vars.watchers = new MemoryWatcherList
    {
		new MemoryWatcher<ushort>((IntPtr)memoryOffset + 0x0957) { Name = "score" }, // score
		new MemoryWatcher<ushort>((IntPtr)memoryOffset + 0x0929) { Name = "boss_score" }, // for boss
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x091D) { Name = "player_hp" }, // your HP
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0046) { Name = "map_x" }, // x coord on overworld
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0048) { Name = "map_y" }, // y coord on overworld
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x130A4) { Name = "final_boss_easy" }, // hp final boss on easy
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x13104) { Name = "final_boss_hard" }, // hp final boss on hard
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x090D) { Name = "tos_trigger" }, // trigger for tower of souls
    };
}

update
{
    vars.watchers.UpdateAll(game);
}

start
{
	if (vars.watchers["map_x"].Old == 248 && vars.watchers["map_x"].Current != 248) {
		return true;
	}
	if (vars.watchers["map_y"].Old == 120 && vars.watchers["map_y"].Current != 120) {
		return true;
	}
}

split
{
	if (vars.watchers["score"].Current != 0 && vars.watchers["score"].Old == 0){
		return true;
	}
	
	//if ((vars.watchers["score"].Current != 0 && vars.watchers["score"].Old == 0) || (vars.i < 25)){
	//	vars.i--;
	//	if (vars.i == 0) {
	//		vars.i = 25;
	//		return true;
	//	}
	//}
	
	if (vars.watchers["final_boss_easy"].Old > 0 && vars.watchers["final_boss_easy"].Current == 20 && vars.watchers["final_boss_easy"].Old < 5 && settings["easy"] && vars.watchers["tos_trigger"].Current == 93 && vars.watchers["boss_score"].Old != vars.watchers["boss_score"].Current) {
		return true;
	}
	
	if (vars.watchers["final_boss_hard"].Old > 0 && vars.watchers["final_boss_hard"].Current == 50 && vars.watchers["final_boss_hard"].Old < 3 && settings["normal/hard"]) {
	 	return true;
	}
}

