package;

import APIHandler.CCVARS;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.system.debug.watch.Tracker;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class PresentationState extends FlxState
{
	private var OS_DEBUG:Bool;
	private var activeAlert:Bool;

	// Generic Graphics
	private var BG:FlxSprite;
	private var baroArrow:FlxSprite; // Genuinely thought this was a hilarious name for no reason
	private var aqArrow:FlxSprite;

	// Panels
	private var ccPanel:FlxSprite;
	private var lfPanel:FlxSprite;
	private var twaPanel:FlxSprite;
	private var noaaPanel:FlxSprite;

	// Panel Titles
	private var ccTitle:FlxSprite; // Current Conditions
	private var lfTitle:FlxSprite; // Local Forecast
	private var rrTitle:FlxSprite; // Regional Radar
	private var lrTitle:FlxSprite; // Local Radar
	private var drTitle:FlxSprite; // Satellite Radar (radar satellite)
	private var alTitle:FlxSprite; // Almanac
	private var twaTitle:FlxSprite; // The Week Ahead

	// Current condtitions panel
	private var CCTXT:FlxTypedGroup<FlxText>;

	private var ccIcon:FlxSprite;
	private var rhLabel:FlxText = new FlxText(828, 285, 'HUMIDITY');
	private var dpLabel:FlxText = new FlxText(668, 385, 450, 'DEW POINT');
	private var baroLabel:FlxText = new FlxText(668, 485, 450, 'PRESSURE');
	private var visLabel:FlxText = new FlxText(668, 585, 450, 'VISBILITY');
	private var wndLabel:FlxText = new FlxText(668, 685, 450, 'WIND');
	private var gustLabel:FlxText = new FlxText(668, 785, 450, 'GUSTS');

	private var cc_cityName:FlxText;
	private var condTxt:FlxText;
	private var tmpTxt:FlxText;
	private var rhTxt:FlxText;
	private var dpTxt:FlxText;
	private var baroTxt:FlxText;
	private var visTxt:FlxText;
	private var wndTxt:FlxText;
	private var gustTxt:FlxText;

	// 36-Hour forecast panel
	private var DOWTXT:FlxTypedGroup<FlxText>;
	private var NARRATIVES:FlxTypedGroup<FlxText>;
	private var lf_cityName:FlxText;

	// The Week Ahead panel
	private var twaIcons:FlxTypedGroup<FlxSprite>;
	private var twaHiTemps:FlxTypedGroup<FlxText>;
	private var twaLoTemps:FlxTypedGroup<FlxText>;
	private var twaPhrases:FlxTypedGroup<FlxText>;
	private var twaDays:FlxTypedGroup<FlxText>;
	private var twaWeekend:FlxTypedGroup<FlxSprite>;

	// Sounds
	private var LOCALVOCAL_CC:FlxSound; // Current Condition narration
	private var LOCALVOCAL_TMP:FlxSound; // Temperature narration
	private var LOCALVOCAL_INTRO:FlxSound; // CC Intro
	private var music_playlist:Array<String>; // String array of every music file in assets/music/

	// Maps
	private var map:FlxSprite;

	// LOT8 Slide bools
	// uses https://twcclassics.com/information/intellistar-flavors.html as reference.
	private var CURRENT_CONDITIONS:Bool;
	private var REGIONAL_OBSERVATIONS:Bool;
	private var REGIONAL_RADAR:Bool;
	private var ALMANAC:Bool;
	private var AIR_QUALITY:Bool;
	// or
	private var OUTDOOR_ACTIVITY:Bool;
	private var DAYPART_FORECAST:Bool;
	private var REGIONAL_FORECAST:Bool;
	private var LF:Bool; // Local Forecast
	private var EXTENDED_FORECAST:Bool;
	// or
	private var THE_WEEK_AHEAD:Bool;

	// this is a stupid way of doing this lmao
	private var LF_0:Bool;
	private var LF_1:Bool;
	private var LF_2:Bool;
	private var LF_3:Bool;
	private var LF_4:Bool;

	private var finished:Bool;

	private var PresentationTimers:FlxTimerManager;

	private var LDL:LowerDisplayLine;

	private var CC_PANEL:CurrentConditions;
	private var TWA_PANEL:TheWeekAhead;

	override public function create():Void
	{
		this.PresentationTimers = new FlxTimerManager();

		FlxG.mouse.visible = false;
		FlxG.autoPause = false; // Disable the program pausing when the window is out of focus
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeDownKeys = null;
		FlxG.sound.volumeUpKeys = null;
		bgColor = 0x0047bb;

		// get information from IBM
		APIHandler.getLocalForecast();
		APIHandler.getCC();

		trace(FlxG.save.data.apiKey);
		OS_DEBUG = FlxG.save.data.OS_DEBUG;

		// CREATE BACKGROUND

		if (OS_DEBUG)
		{
			FlxG.debugger.drawDebug = true;
			// vv Basically the WeatherSTAR 4000 BG gradient, a bit easier to see draw boxes with
			BG = FlxGradient.createGradientFlxSprite(1920, 1080, [FlxColor.fromString('0x1d0255'), FlxColor.fromString('0xba5c13')], 1, 90);
			add(BG);
		}
		else
		{
			BG = new FlxSprite().loadGraphic('assets/images/Backgrounds/Background-Normal.png');
			BG.screenCenter();
			BG.antialiasing = false;
			add(BG);
		}

		// makeMusicPL();

		// if (FlxG.sound.music == null)
		// {
		// 	FlxG.sound.playMusic(Resources.music(HelpfulFunctions.fromArray(music_playlist)), 0.8, false);
		// 	FlxG.sound.music.persist = false;
		// }

		// create map
		// map = new FlxSprite(0, 0);
		// map.loadGraphic(FlxAssets.getBitmapData('assets/images/radar/map.png'));
		// map.scale.x = 0.8;
		// map.scale.y = 0.8;
		// map.antialiasing = true;
		// map.alpha = 0;
		// map.screenCenter(XY);
		// add(map);

		// CREATE PANEL TITLES \\

		// TITLE GEN TESTING
		var CC_TEST_TITLE:Title = new Title('black', 'white');
		add(CC_TEST_TITLE);

		// Title Textures

		var ccTitleTex = Resources.graphic('titles', 'current_conditions');
		var lfTitleTex = Resources.graphic('titles', 'local-forecast');
		var rrTitleTex = Resources.graphic('titles', 'regional_radar');
		var lrTitleTex = Resources.graphic('titles', 'local_radar');
		var drTitleTex = Resources.graphic('titles', 'radar_satellite');
		var alTitleTex = Resources.graphic('titles', 'almanac');
		var twaTitleTex = Resources.graphic('titles', '7day_outlook');

		ccTitle = new FlxSprite(-174, -58);
		ccTitle.loadGraphic(ccTitleTex);
		ccTitle.scale.x = 0.65;
		ccTitle.scale.y = 0.65;
		ccTitle.antialiasing = true;
		ccTitle.alpha = 0;
		add(ccTitle);

		lfTitle = new FlxSprite(-174, -58);
		lfTitle.loadGraphic(lfTitleTex);
		lfTitle.scale.x = 0.65;
		lfTitle.scale.y = 0.65;
		lfTitle.antialiasing = true;
		lfTitle.alpha = 0;
		add(lfTitle);

		rrTitle = new FlxSprite(-174, -58);
		rrTitle.loadGraphic(rrTitleTex);
		rrTitle.scale.x = 0.65;
		rrTitle.scale.y = 0.65;
		rrTitle.antialiasing = true;
		rrTitle.alpha = 0;
		add(rrTitle);

		lrTitle = new FlxSprite(-174, -58);
		lrTitle.loadGraphic(lrTitleTex);
		lrTitle.scale.x = 0.65;
		lrTitle.scale.y = 0.65;
		lrTitle.antialiasing = true;
		lrTitle.alpha = 0;
		add(lrTitle);

		drTitle = new FlxSprite(-174, -58);
		drTitle.loadGraphic(drTitleTex);
		drTitle.scale.x = 0.65;
		drTitle.scale.y = 0.65;
		drTitle.antialiasing = true;
		drTitle.alpha = 0;
		add(drTitle);

		alTitle = new FlxSprite(-174, -58);
		alTitle.loadGraphic(alTitleTex);
		alTitle.scale.x = 0.65;
		alTitle.scale.y = 0.65;
		alTitle.antialiasing = true;
		alTitle.alpha = 0;
		add(alTitle);

		twaTitle = new FlxSprite(-174, -58);
		twaTitle.loadGraphic(twaTitleTex);
		twaTitle.scale.x = 0.65;
		twaTitle.scale.y = 0.65;
		twaTitle.antialiasing = true;
		twaTitle.alpha = 0;
		add(twaTitle);

		// CREATE PANELS \\

		// Panel Textures
		var ccPanelTex = Resources.graphic('Panels', 'Current-Conditions');
		var lfPanelTex = Resources.graphic('Panels', 'Local-Forecast');
		var twaPanelTex = Resources.graphic('Panels', 'The-Week-Ahead');
		var noaaPanelTex = Resources.graphic('Panels', 'Weather-Bulletin');

		ccPanel = new FlxSprite(0, 165);
		ccPanel.loadGraphic(ccPanelTex);
		ccPanel.screenCenter(X);
		ccPanel.antialiasing = true;
		ccPanel.alpha = 0;
		add(ccPanel);

		lfPanel = new FlxSprite(0, 165);
		lfPanel.loadGraphic(lfPanelTex);
		lfPanel.screenCenter(X);
		lfPanel.antialiasing = true;
		lfPanel.alpha = 0;
		add(lfPanel);

		twaPanel = new FlxSprite(0, 165);
		twaPanel.loadGraphic(twaPanelTex);
		twaPanel.screenCenter(X);
		twaPanel.antialiasing = true;
		twaPanel.alpha = 0;
		add(twaPanel);

		// Panel logic

		CC_PANEL = new CurrentConditions();
		// add(CC_PANEL);

		TWA_PANEL = new TheWeekAhead();
		add(TWA_PANEL);

		// create barometric pressure trend graphic
		switch (APIHandler._CCVARS.baroTrend)
		{
			case "Steady":
				baroArrow = new FlxSprite().loadGraphic(Resources.graphic('generic', 'steady'));
			case "Rising":
				baroArrow = new FlxSprite().loadGraphic(Resources.graphic('generic', 'arrow'));
			case "Rapidly Rising":
				baroArrow = new FlxSprite().loadGraphic(Resources.graphic('generic', 'arrow'));
			case "Falling":
				baroArrow = new FlxSprite().loadGraphic(Resources.graphic('generic', 'arrow'));
				baroArrow.angle = 180;
			case "Rapidly Falling":
				baroArrow = new FlxSprite().loadGraphic(Resources.graphic('generic', 'arrow'));
				baroArrow.angle = 180;
		}

		baroArrow.scale.x = 0.25;
		baroArrow.scale.y = 0.25;
		baroArrow.updateHitbox();
		baroArrow.antialiasing = true;
		baroArrow.setPosition(1485, 500);
		baroArrow.alpha = 0;
		add(baroArrow);



		// 7-Day Outlook
		twaIcons = new FlxTypedGroup<FlxSprite>();
		twaHiTemps = new FlxTypedGroup<FlxText>();
		twaLoTemps = new FlxTypedGroup<FlxText>();
		twaPhrases = new FlxTypedGroup<FlxText>();
		twaDays = new FlxTypedGroup<FlxText>();
		twaWeekend = new FlxTypedGroup<FlxSprite>();

		for (i in 0...7)
		{
			// Icons
			var icon:FlxSprite;
			// if (FileSystem.exists(Resources.icon(APIHandler._SEVENDAYDATA.iconCodes[i])))
			// {
			// 	icon = new FlxSprite().loadGraphic(Resources.icon(APIHandler._SEVENDAYDATA.iconCodes[i]), false);
			// }
			// else
			// {
			// 	trace('FAILED TO FIND ICON CODE ${APIHandler._SEVENDAYDATA.iconCodes[i]}, DEFAULTING TO N/A ICON');
			// 	icon = new FlxSprite().loadGraphic(Resources.icon('44'), false);
			// }

			// icon.antialiasing = true;
			// icon.scale.x = 1.5;
			// icon.scale.y = 1.5;
			// icon.updateHitbox();
			// icon.setPosition((twaIcons.members[i - 1] != null ? twaIcons.members[i - 1].x + 235 : 160), 330);
			// icon.ID = i;
			// twaIcons.add(icon);

			// Hi/Lo Temperature Labels
			var hiTemp:FlxText;
			hiTemp = new FlxText((twaHiTemps.members[i - 1] != null ? twaHiTemps.members[i - 1].x + 235 : 155), 625, 200, APIHandler._SEVENDAYDATA.hiTemps[i]);
			hiTemp.setFormat(Resources.font('interstate-bold'), 100, FlxColor.WHITE, CENTER);
			hiTemp.antialiasing = true;
			hiTemp.ID = i;
			twaHiTemps.add(hiTemp);

			var loTemp:FlxText;
			loTemp = new FlxText((twaLoTemps.members[i - 1] != null ? twaLoTemps.members[i - 1].x + 235 : 155), 725, 200, APIHandler._SEVENDAYDATA.loTemps[i]);
			loTemp.setFormat(Resources.font('interstate-bold'), 100, FlxColor.WHITE, CENTER);
			loTemp.antialiasing = true;
			loTemp.ID = i;
			twaLoTemps.add(loTemp);

			// Days + Weekend rectangle graphic
			var DOW:FlxText;
			DOW = new FlxText((twaDays.members[i - 1] != null ? twaDays.members[i - 1].x + 235 : 176), 280, 150, APIHandler._SEVENDAYDATA.dow[i]);
			DOW.setFormat(Resources.font('interstate-light'), 50, (APIHandler._SEVENDAYDATA.isWeekend[i] ? FlxColor.fromString("0x102a70") : FlxColor.WHITE),
				CENTER);
			DOW.antialiasing = true;
			DOW.ID = i;
			twaDays.add(DOW);

			var WEEKEND_RECT:FlxSprite;
			WEEKEND_RECT = new FlxSprite((twaWeekend.members[i - 1] != null ? twaWeekend.members[i - 1].x + 235 : 145.5),
				274).makeGraphic(218, 60, FlxColor.WHITE);
			WEEKEND_RECT.antialiasing = true;
			WEEKEND_RECT.visible = APIHandler._SEVENDAYDATA.isWeekend[i];
			WEEKEND_RECT.alpha = 0.95;
			WEEKEND_RECT.ID = i;
			twaWeekend.add(WEEKEND_RECT);
		}

		for (i in 0...twaDays.members.length)
		{
			twaDays.members[i].alpha = 0;
			twaWeekend.members[i].alpha = 0;
			twaHiTemps.members[i].alpha = 0;
			twaLoTemps.members[i].alpha = 0;
			// twaIcons.members[i].alpha = 0;
		}

		add(twaIcons);
		add(twaHiTemps);
		add(twaLoTemps);
		add(twaWeekend);
		add(twaDays);

		// 36-hour forecast
		DOWTXT = new FlxTypedGroup<FlxText>();
		NARRATIVES = new FlxTypedGroup<FlxText>();

		lf_cityName = new FlxText(150, 176, 0, APIHandler._LOCATIONDATA.cityName.toUpperCase());
		lf_cityName.setFormat(Resources.font('interstate-bold'), 70, FlxColor.YELLOW);
		lf_cityName.antialiasing = true;
		lf_cityName.alpha = 0;

		// tfw I was about to do this by making a shitload of FlxText variables
		// https://github.com/AyeTSG/Funkin_SmallThings/blob/master/source/OptionsMenu.hx
		for (i in 0...APIHandler._FORECASTDATA.daypart_name.length)
		{
			var txt = new FlxText(150, 275, 700, APIHandler._FORECASTDATA.daypart_name[i]);
			txt.setFormat(Resources.font('interstate-regular'), 70, FlxColor.YELLOW, LEFT);
			txt.alpha = 0;
			txt.antialiasing = true;
			txt.ID = i;
			DOWTXT.add(txt);
		}

		for (i in 0...APIHandler._FORECASTDATA.narrative.length)
		{
			var txt = new FlxText(150, 350, 1620, APIHandler._FORECASTDATA.narrative[i]);
			txt.setFormat(Resources.font('interstate-bold'), 65, FlxColor.WHITE, LEFT);
			txt.alpha = 0;
			txt.antialiasing = true;
			txt.ID = i;
			NARRATIVES.add(txt);
		}

		add(lf_cityName);
		add(DOWTXT);
		add(NARRATIVES);

		// Narrations

		if (FlxG.save.data.localVocal)
		{
			LOCALVOCAL_INTRO = FlxG.sound.load(Resources.narration("CC_INTRO1", null), 1.0, false, null, false, false, null, () -> LOCALVOCAL_TMP.play());
			LOCALVOCAL_TMP = FlxG.sound.load(Resources.narration('${APIHandler._CCVARS.temperature}', "temperatures"), 1.0, false, null, false, false, null,
				() -> LOCALVOCAL_CC.play());
			LOCALVOCAL_CC = FlxG.sound.load(Resources.narration('${APIHandler._CCVARS.ccIconCode}', "conditions"));

			/*
				I genuinely don't know why, but for some god-forsaken reason,
				using the StartTime variable in the play() function for FlxG doesn't actually
				do anything besides completely ignoring the onComplete() function that's done when
				these are all loaded into the state.
			 */
			new FlxTimer().start(0.2, timer -> LOCALVOCAL_INTRO.play());
		}
		else
			trace("Skipping local vocal initalization because it's false..");

		LDL = new LowerDisplayLine(FlxColor.TRANSPARENT);
		openSubState(LDL);

		// createPresentationTimers();
	}

	function makeMusicPL():Array<String>
	{
		music_playlist = [];

		trace(FileSystem.readDirectory('assets/music'));

		for (i in 0...FileSystem.readDirectory('assets/music').length)
		{
			var filename:String = FileSystem.readDirectory('assets/music')[i];

			if (filename.endsWith('ogg'))
				music_playlist.push(FileSystem.readDirectory('assets/music')[i]);
			else
				trace('SKIPPING OVER ${FileSystem.readDirectory('assets/music')[i]} -- NOT A .OGG FILE');
		}

		trace(music_playlist);
		return music_playlist;
	}

	function createPresentationTimers():Void // Real units keep all of these within 2 Minutes (120 seconds), so everything should be at 7-second intervals.
	{
		var timers:Array<FlxTimer> = [];
		// TODO: Find some way to automate the creation of these timers, this is kinda rediculous.
		// Using a for loop wont work for some reason
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);
		new FlxTimer(PresentationTimers);


		PresentationTimers.forEach(function(tmr:FlxTimer)
		{
			timers.push(tmr);
		});


		timers[0].start(0, timer -> CURRENT_CONDITIONS = true);
		timers[1].start(timers[0].time + 7, timer -> REGIONAL_OBSERVATIONS = true);
		timers[2].start(timers[1].time + 7, timer -> REGIONAL_RADAR = true);
		timers[3].start(timers[2].time + 7, timer -> ALMANAC = true);
		timers[4].start(timers[3].time + 7, timer -> AIR_QUALITY = true);
		timers[5].start(timers[4].time + 7, timer -> OUTDOOR_ACTIVITY = true); // TODO: Handle this somehow in panel logic
		timers[6].start(timers[5].time + 7, timer -> DAYPART_FORECAST = true);
		timers[7].start(timers[6].time + 7, timer -> REGIONAL_FORECAST = true);
		timers[8].start(timers[7].time + 7, timer -> LF = true);
		timers[9].start(timers[8].time, timer -> LF_0 = true);
		timers[10].start(timers[9].time + 7, timer -> LF_1 = true);
		timers[11].start(timers[10].time + 7, timer -> LF_2 = true);
		timers[12].start(timers[11].time + 7, timer -> LF_3 = true);
		timers[13].start(timers[12].time + 7, timer -> LF_4 = true);
		timers[14].start(timers[13].time + 7, timer -> THE_WEEK_AHEAD = true);
		timers[15].start(timers[14].time + 7, timer -> finished = true);
	}

	// Everything in this function will be called every frame
	// Remember to destroy your timers!
	override public function update(elapsed):Void
	{
		// // Lower audio when any of the local vocals are playing
		// if (LOCALVOCAL_INTRO.playing || LOCALVOCAL_TMP.playing || LOCALVOCAL_CC.playing && FlxG.sound.music != null)
		// 	FlxG.sound.music.volume = 0.1;
		// else
		// 	FlxG.sound.music.volume = 0.8;

		if (PresentationTimers.active)
			PresentationTimers.update(elapsed);

		// Alot of this is just copy and paste code, most of the panel creation and logic is handled in create()


		super.update(elapsed);
	}
}
