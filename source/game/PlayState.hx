package game;

import haxe.ds.ArraySort;

import openfl.filters.BitmapFilter;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.NextState;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

import core.AssetCache;
import core.Paths;
import core.Options;
import core.SaveManager;
import data.CharacterData;
import data.Chart;
import data.Chart.EventData;
import data.ChartBuilder;
import data.LevelData;
import data.PlayStats;
import data.WeekData;
import game.levels.LevelL;
import game.notes.Note;
import game.notes.Strumline;
import game.notes.events.GhostTapEvent;
import game.notes.events.NoteHitEvent;
import game.events.SetCamFocusEvent;
import game.events.SetCamZoomEvent;
import game.stages.Stage;
import interfaces.IBeatDispatcher;
import interfaces.ISequenceHandler;
import menus.CharacterEditMenu;
import menus.PauseMenu;
import menus.options.OptionsMenu;
import music.Conductor;
import tools.CompilerTools;
import ui.Countdown;

using StringTools;

using tools.AlignTools;
using tools.ArrayTools;
using tools.TimeSortTools;

class PlayState extends FlxState implements IBeatDispatcher implements ISequenceHandler
{
    public static var week:WeekData;

    public static var isWeek(get, never):Bool;

    @:noCompletion
    static function get_isWeek():Bool
    {
        return week != null;
    }

    public static var levelIndex:Int = 0;

    public static var level:LevelData;

    public static var weekStats:Array<PlayStats> = new Array<PlayStats>();
    
    public static function getClassFromLevel():PlayState
    {
        if (level == null)
            throw "`level` is `null`. Make sure you added your level to `data.Playlist`!";

        // Try to find a level class with the desired difficulty.
        var c:Class<Dynamic> = Type.resolveClass(level.toString());

        if (c == null)
        {
            // Try to find a level class with no difficulty.
            var level:LevelData = {week: null, name: level.name}

            c = Type.resolveClass(level.toString());

            // Give up and fall back to the default `game.levels.LevelL` class.
            if (c == null)
            {
                trace('Couldn\'t generate level class, make sure it is in the correct path (`${PlayState.level.toString()}`)!');

                trace("Falling back to `game.levels.LevelL`!");

                return new LevelL();
            }
        }

        return Type.createInstance(c, []);
    }

    public static function loadWeek(week:WeekData, difficulty:String):Void
    {
        PlayState.week = week;

        week.difficulty = difficulty;

        levelIndex = 0;

        level = week.levels[0];

        weekStats.resize(0);

        FlxG.switchState(() -> getClassFromLevel());
    }

    public static function loadLevel(level:LevelData, difficulty:String):Void
    {
        week = null;

        levelIndex = 0;

        PlayState.level = level;

        level.difficulty = difficulty;

        weekStats.resize(0);

        FlxG.switchState(() -> getClassFromLevel());
    }

    public var conductor:Conductor;

    public var tweens:FlxTweenManager;

    public var timers:FlxTimerManager;

    public var stage:Stage;

    /**
     * Characters and stages are drawn on this camera.
     */
    public var gameCamera(get, never):FlxCamera;
    
    @:noCompletion
    function get_gameCamera():FlxCamera
    {
        return FlxG.camera;
    }

    public var cameraPoint:FlxObject;

    /**
     * Simplified representation of what the camera is viewing. Values include "POINT" and "CHARACTER".
     */
    public var cameraTarget:String;

    /**
     * A more specific version of `cameraTarget` that explicitly refers to the type of character the camera is viewing.
     */
    public var cameraCharTarget:String;

    public var cameraLock:CameraLockMode;

    public var gameCamBopStrength:Float;

    public var gameCameraZoom:Float;

    /**
     * Most UI elements are drawn on this camera.
     */
    public var hudCamera:FlxCamera;

    /**
     * Elements such as the pause menu and other sub states are drawn on this camera.
     */
    public var topCamera:FlxCamera;

    public var chart:Chart;

    public var eventIndex:Int;

    public var instrumental:FlxSound;

    public var vocals:FlxSoundGroup;

    public var mainVocals:FlxSound;

    public var opponentVocals:FlxSound;

    public var playerVocals:FlxSound;

    public var spectators:FlxTypedSpriteGroup<Character>;

    public var spectator:Character;

    public var opponents:FlxTypedSpriteGroup<Character>;

    public var opponent:Character;

    public var players:FlxTypedSpriteGroup<Character>;

    public var player:Character;

    public var playField:PlayField;

    public var oppStrumline(get, never):Strumline;

    @:noCompletion
    function get_oppStrumline():Strumline
    {
        return playField.strumlines.members[0];
    }

    public var plrStrumline(get, never):Strumline;

    @:noCompletion
    function get_plrStrumline():Strumline
    {
        return playField.strumlines.members[1];
    }

    public var countdown:Countdown;

    public var startingSong:Bool;

    override function create():Void
    {
        super.create();
        
        FlxG.console.registerObject("game", this);

        gameCamera.filters = new Array<BitmapFilter>();
        
        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        hudCamera.filters = new Array<BitmapFilter>();

        FlxG.cameras.add(hudCamera, false);

        topCamera = new FlxCamera();

        topCamera.bgColor.alpha = 0;

        FlxG.cameras.add(topCamera, false);

        conductor = new Conductor();

        conductor.onStepHit.add(stepHit);

        conductor.onBeatHit.add(beatHit);

        conductor.onMeasureHit.add(measureHit);

        add(conductor);

        tweens = new FlxTweenManager();

        add(tweens);

        timers = new FlxTimerManager();

        add(timers);

        add(stage);

        gameCamera.zoom = stage.zoom;

        cameraPoint = new FlxObject();

        add(cameraPoint);

        gameCamera.follow(cameraPoint, LOCKON, 0.05);

        cameraTarget = "POINT";

        cameraCharTarget = "";

        cameraLock = DEFAULT;

        gameCamBopStrength = 0.035;

        gameCameraZoom = gameCamera.zoom;

        loadChart();

        loadSong();

        add(stage);

        spectators = new FlxTypedSpriteGroup<Character>();

        stage.add(spectators);

        if (chart.spectator != "")
            spectator = new Character(this, 0.0, 0.0, Character.getConfig(chart.spectator));

        opponents = new FlxTypedSpriteGroup<Character>();

        stage.add(opponents);

        opponent = new Character(this, 0.0, 0.0, Character.getConfig(chart.opponent));

        players = new FlxTypedSpriteGroup<Character>();

        stage.add(players);

        player = new Character(this, 0.0, 0.0, Character.getConfig(chart.player));

        playField = new PlayField(this, this, chart);

        playField.camera = hudCamera;

        add(playField);

        FlxG.watch.add(playField.playStats, "score", "Score");

        FlxG.watch.add(playField.playStats, "misses", "Misses");

        FlxG.watch.add(playField.playStats, "accuracy", "Accuracy (%)");

        playField.getSongTime = getSongTime;

        playField.getSongLength = getSongLength;

        #if !debug
        var healthBar:HealthBar = playField.healthBar;

        healthBar.onEmptied.add(gameOver);
        #end

        oppStrumline.charGroup = opponents;

        oppStrumline.spectators = spectators;

        oppStrumline.vocals.pushMany(mainVocals, opponentVocals);

        plrStrumline.charGroup = players;

        plrStrumline.spectators = spectators;

        plrStrumline.vocals.pushMany(mainVocals, playerVocals);

        spectators.group.memberAdded.add((spectator:Character) -> spectator.strumline = oppStrumline);

        opponents.group.memberAdded.add((opponent:Character) -> opponent.strumline = oppStrumline);

        players.group.memberAdded.add((player:Character) -> player.strumline = plrStrumline);

        spectators.add(spectator);

        opponents.add(opponent);

        players.add(player);

        updateHealthBar();

        countdown = new Countdown(this);
        
        countdown.camera = hudCamera;

        add(countdown);

        startingSong = true;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        while (eventIndex < chart.events.length)
        {
            var event:EventData = chart.events[eventIndex];

            if (conductor.time < event.time)
                break;

            onEvent(event);
        }

        updateCameraTarget(conductor.time);

        conductor.updateSteps();

        if (startingSong)
        {
            if (conductor.time >= 0.0)
                startSong();
        }
        else
        {
            var conductorDesync:Float = Math.abs(conductor.time - instrumental.time);

            if (conductorDesync >= 20.0)
                conductor.time = instrumental.time;

            var mainVocalsDesync:Float = 0.0;

            if (mainVocals != null)
                mainVocalsDesync = Math.abs(mainVocals.time - instrumental.time);

            var opponentVocalsDesync:Float = 0.0;

            if (opponentVocals != null)
                opponentVocalsDesync = Math.abs(opponentVocals.time - instrumental.time);

            var playerVocalsDesync:Float = 0.0;

            if (playerVocals != null)
                playerVocalsDesync = Math.abs(playerVocals.time - instrumental.time);

            if (mainVocalsDesync >= 20.0 || opponentVocalsDesync >= 20.0 || playerVocalsDesync >= 20.0)
                resyncVocals();
        }

        gameCamera.zoom = FlxMath.lerp(gameCamera.zoom, gameCameraZoom, FlxMath.getElapsedLerp(0.15, elapsed));

        if (Options.keysJustPressed("ui back"))
            pause();

        if (Options.keysJustPressed("editors character"))
            FlxG.switchState(() -> new CharacterEditMenu(() -> getClassFromLevel()));
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.console.removeByAlias("game");
    }

    public function stepHit(step:Int):Void
    {

    }

    public function beatHit(beat:Int):Void
    {

    }

    public function measureHit(measure:Int):Void
    {
        gameCamera.zoom += gameCamBopStrength;
    }

    public function loadChart():Void
    {
        chart = ChartBuilder.buildFromLevel(level);

        ArraySort.sort(chart.notes, sortNotes);

        #if NOTE_SHUFFLE
        var keyCount:Int = chart.keyCount;

        #if NOTE_SHUFFLE_FAST
        for (i in 0 ... chart.notes.length)
        {
            var note:NoteData = chart.notes[i];

            note.direction = FlxG.random.int(0, keyCount - 1);
        }
        #else
        var directions:Array<Int> = new Array<Int>();

        for (i in 0 ... chart.keyCount)
            directions.push(FlxG.random.int(0, keyCount - 1, directions));

        for (i in 0 ... chart.notes.length)
        {
            var note:NoteData = chart.notes[i];

            note.direction = directions[note.direction];
        }
        #end
        #end

        chart.events.sortTimed();

        chart.timingPoints.sortTimed();

        conductor.setTimingPoints(chart.timingPoints);

        conductor.time = -conductor.measureLength * 1.25;

        conductor.updateSteps();

        FlxG.watch.add(conductor, "time", "Time");

        FlxG.watch.add(conductor, "step", "Step");

        FlxG.watch.add(conductor, "beat", "Beat");

        FlxG.watch.add(conductor, "measure", "Measure");

        eventIndex = 0;
    }

    public function onEvent(ev:EventData):Void
    {
        var val:Dynamic = ev.value;

        switch (ev.name:String)
        {
            case "SetCamFocus":
                SetCamFocusEvent.dispatch(this, val.x, val.y, val.charType, val.duration, val.ease);

            case "SetCamZoom":
                SetCamZoomEvent.dispatch(this, val.zoom, val.duration, val.mode, val.ease);
        }

        eventIndex++;
    }

    public function loadSong():Void
    {
        var difficulty:String = level.difficulty;
        
        var prefix:String = 'game/levels/${level.name}/';

        var suffix:String = "";

        if (difficulty != "Normal")
           suffix = '-${difficulty}';

        var instrumentalPath:String = Paths.music(Paths.ogg('${prefix}Instrumental${suffix}'));

        if (!Paths.exists(instrumentalPath))
            instrumentalPath = Paths.music(Paths.ogg('${prefix}Instrumental'));

        instrumental = FlxG.sound.load(AssetCache.getMusic(instrumentalPath));

        instrumental.onComplete = endSong;

        vocals = new FlxSoundGroup();

        var mainVocalsPath:String = Paths.music(Paths.ogg('${prefix}Vocals-Main${suffix}'));

        if (!Paths.exists(mainVocalsPath))
            mainVocalsPath = Paths.music(Paths.ogg('${prefix}Vocals-Main'));

        if (Paths.exists(mainVocalsPath))
        {
            mainVocals = FlxG.sound.load(AssetCache.getMusic(mainVocalsPath));

            vocals.add(mainVocals);
        }

        var opponentVocalsPath:String = Paths.music(Paths.ogg('${prefix}Vocals-Opponent${suffix}'));

        if (!Paths.exists(opponentVocalsPath))
            opponentVocalsPath = Paths.music(Paths.ogg('${prefix}Vocals-Opponent'));

        if (Paths.exists(opponentVocalsPath))
        {
            opponentVocals = FlxG.sound.load(AssetCache.getMusic(opponentVocalsPath));

            vocals.add(opponentVocals);
        }

        var playerVocalsPath:String = Paths.music(Paths.ogg('${prefix}Vocals-Player${suffix}'));

        if (!Paths.exists(playerVocalsPath))
            playerVocalsPath = Paths.music(Paths.ogg('${prefix}Vocals-Player'));

        if (Paths.exists(playerVocalsPath))
        {
            playerVocals = FlxG.sound.load(AssetCache.getMusic(playerVocalsPath));

            vocals.add(playerVocals);
        }
    }

    public function startSong():Void
    {
        instrumental.play();

        mainVocals?.play();

        opponentVocals?.play();

        playerVocals?.play();

        startingSong = false;
    }

    public function endSong():Void
    {
        mainVocals?.stop();

        opponentVocals?.stop();

        playerVocals?.stop();
        
        var playStats:PlayStats = playField.playStats;

        var score:Int = playStats.score;

        var misses:Int = playStats.misses;

        var accuracy:Float = playStats.accuracy;

        if (isWeek)
        {
            if (HighScore.isLevelHighScore(level.name, level.difficulty, score))
            {
                HighScore.setLevelScore(level.name, level.difficulty, {score: score, misses: misses, accuracy: accuracy});

                SaveManager.saveHighScores();
            }

            weekStats.push(playField.playStats.copy());

            levelIndex++;

            if (levelIndex > week.levels.length - 1.0)
            {
                var totalStats:PlayStats = PlayStats.empty();

                for (key => value in weekStats)
                    totalStats.concat(value);

                score = totalStats.score;

                misses = totalStats.misses;

                accuracy = totalStats.accuracy;

                if (HighScore.isWeekHighScore(week.name, level.difficulty, score))
                {
                    HighScore.setWeekScore(week.name, level.difficulty, {score: score, misses: misses, accuracy: accuracy});

                    SaveManager.saveHighScores();

                    return;
                }
            }
            else
            {
                level = week.levels[levelIndex];

                FlxG.switchState(() -> getClassFromLevel());

                return;
            }
        }
        else
        {
            if (HighScore.isLevelHighScore(level.name, level.difficulty, score))
            {
                HighScore.setLevelScore(level.name, level.difficulty, {score: score, misses: misses, accuracy: accuracy});

                SaveManager.saveHighScores();
            }
        }
        
        FlxG.resetState();
    }
    
    public function getSongTime():Float
    {
        return instrumental.time;
    }

    public function getSongLength():Float
    {
        return instrumental.length;
    }

    public function getSpectator(name:String):Character
    {
        return spectators.group.getFirst((spectator:Character) -> spectator.config.name == name);
    }

    public function getOpponent(name:String):Character
    {
        return opponents.group.getFirst((opponent:Character) -> opponent.config.name == name);
    }

    public function getPlayer(name:String):Character
    {
        return players.group.getFirst((player:Character) -> player.config.name == name);
    }

    public function updateHealthBar():Void
    {
        var playAsWho:Int = Std.parseInt(CompilerTools.getDefine("PLAY_AS_WHO")) ?? 1;

        var playAsOpponent:Bool = playAsWho == 0;

        var healthBar:HealthBar = playField.healthBar;

        healthBar.fillDirection = playAsOpponent ? LEFT_TO_RIGHT : RIGHT_TO_LEFT;

        var oppColor:FlxColor = FlxColor.fromString(opponent.config.healthColor);

        var plrColor:FlxColor = FlxColor.fromString(player.config.healthColor);

        healthBar.emptiedSide.color = playAsOpponent ? plrColor : oppColor;

        healthBar.filledSide.color = playAsOpponent ? oppColor : plrColor;

        if (playAsOpponent)
        {
            healthBar.opponentIcon.setCharacter(player.config.healthIcon);

            healthBar.playerIcon.setCharacter(opponent.config.healthIcon);
        }
        else
        {
            healthBar.opponentIcon.setCharacter(opponent.config.healthIcon);

            healthBar.playerIcon.setCharacter(player.config.healthIcon);
        }
    }

    public function getStartingCamFocusEvent():EventData
    {
        return chart.events.first((e:EventData) -> e.name == "SetCamFocus");
    }

    public function setCamStartPos():Void
    {
        var ev:EventData = getStartingCamFocusEvent();

        SetCamFocusEvent.dispatch(this, ev.value.x, ev.value.y, ev.value.charType, 0.0, "linear");

        gameCamera.snapToTarget();
    }

    public function getCameraTarget(timeToCheck:Float):String
    {
        var ev:EventData = chart.events.last((e:EventData) -> e.name == "SetCamFocus" && e.time <= timeToCheck);

        if (ev == null)
            ev = getStartingCamFocusEvent();

        if (ev == null)
            return "";

        if (ev.value.charType == "")
            return "POINT";
        else
            return ev.value.charType.toUpperCase();
    }

    public function updateCameraTarget(timeToCheck:Float):Void
    {
        var target:String = getCameraTarget(timeToCheck);

        if (target == "")
            return;

        if (target == "POINT")
            cameraTarget = target;
        else
        {
            cameraTarget = "CHARACTER";

            cameraCharTarget = target;
        }
    }

    public function pause():Void
    {
        var pauseMenu:PauseMenu = new PauseMenu(this);

        pauseMenu.camera = hudCamera;

        openSubState(pauseMenu);

        gameCamera.active = false;

        pauseMusic();
    }

    public function resume():Void
    {
        closeSubState();

        gameCamera.active = true;

        resumeMusic();

        resyncVocals();
    }

    public function gameOver():Void
    {
        persistentDraw = false;

        openSubState(new GameOverScreen(this));

        pauseMusic();
    }

    public function pauseMusic():Void
    {
        instrumental.pause();

        mainVocals?.pause();

        opponentVocals?.pause();

        playerVocals?.pause();
    }

    public function resumeMusic():Void
    {
        instrumental.resume();

        mainVocals?.resume();

        opponentVocals?.resume();

        playerVocals?.resume();
    }

    public function resyncVocals():Void
    {
        if (mainVocals != null)
            mainVocals.time = instrumental.time;

        if (opponentVocals != null)
            opponentVocals.time = instrumental.time;

        if (playerVocals != null)
            playerVocals.time = instrumental.time;
    }

    public function sortNotes(a:NoteData, b:NoteData):Int
    {
        if (a.time < b.time)
            return -1;

        if (a.time > b.time)
            return 1;

        if (a.direction < b.direction)
            return -1;

        if (a.direction > b.direction)
            return 1;

        return 0;
    }
}

enum CameraLockMode
{
    /**
     * No camera events are locked.
     */
    DEFAULT;

    /**
     * Camera movement is limited to the use of `SetCamFocus` events with `charType != ""`.
     */
    FOCUS_CAM_CHAR;

    /**
     * Camera movement is limited to the use of `SetCamFocus` events with `charType == ""`.
     */
    FOCUS_CAM_POINT;

    /**
     * All camera events are locked.
     */
    NONE;
}