package game;

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

import core.AssetCache;
import core.Paths;
import core.Options;
import core.SaveManager;

import data.CharacterData;
import data.Chart;
import data.Chart.EventData;
import data.ChartBuilder;
import data.Difficulty;
import data.LevelData;
import data.WeekData;

import data.PlayStats;

import game.levels.LevelL;

import game.notes.Note;
import game.notes.Strumline;

import game.notes.events.GhostTapEvent;
import game.notes.events.NoteHitEvent;

import game.events.SetCamFocusEvent;
import game.events.SetCamZoomEvent;

import game.stages.Stage;

import interfaces.ISequenceHandler;

import menus.options.OptionsMenu;

import music.Conductor;

import ui.Countdown;

import util.MacroUtil;

using StringTools;

using util.ArrayUtil;
using tools.ObjectHelpers;
using util.TimingUtil;

class PlayState extends FlxState implements IBeatDispatcher implements ISequenceHandler
{
    public static var week:WeekData;

    public static var level:LevelData;

    public static var isWeek(get, never):Bool;

    @:noCompletion
    static function get_isWeek():Bool
    {
        return week != null;
    }

    public static var weekStats:Map<String, PlayStats> = new Map<String, PlayStats>();
    
    public static function getClassFromLevel(level:LevelData = null):PlayState
    {
        level ??= PlayState.level;
        
        if (level == null)
            throw "`level` is `null` for `getClassFromLevel`. Make sure you added your level to `data.Playlist`!";

        var c:Class<Dynamic> = Type.resolveClass(level.getClassPath());

        if (c == null)
        {
            trace('Couldn\'t generate level class, make sure you named it correctly (${level.getClassPath()}).');

            trace("Falling back to `game.levels.LevelL`!");

            return new LevelL();
        }

        return Type.createInstance(c, []);
    }

    public static function loadWeek(week:WeekData):Void
    {
        PlayState.week = week.copy();

        level = week.levels[0];

        weekStats.clear();

        FlxG.switchState(() -> getClassFromLevel());
    }

    public static function loadLevel(level:LevelData):Void
    {
        week = null;

        PlayState.level = level;

        weekStats.clear();

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
     * Simplistic representation of what the camera is viewing. Values include "POINT" and "CHARACTER".
     */
    public var cameraTarget:String;

    /**
     * A more specific version `cameraTarget` that explicitly refers to the type of character the camera is viewing.
     */
    public var cameraCharTarget:String;

    public var cameraLock:CameraLockMode;

    public var gameCamBopStrength:Float;

    public var gameCameraZoom:Float;

    /**
     * Most UI elements are drawn on this camera.
     */
    public var hudCamera:FlxCamera;

    public var hudCamBopStrength:Float;

    /**
     * Elements such as the pause menu and other sub states are drawn on this camera.
     */
    public var topCamera:FlxCamera;

    public var chart:Chart;

    public var eventIndex:Int;

    public var instrumental:FlxSound;

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

        hudCamBopStrength = 0.015;

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

        playField.onUpdateScore.add(updateScore);

        add(playField);

        FlxG.watch.add(playField.playStats, "score", "Score");

        FlxG.watch.add(playField.playStats, "misses", "Misses");

        FlxG.watch.add(playField.playStats, "accuracy", "Accuracy (%)");

        playField.getSongTime = getSongTime;

        playField.getSongLength = getSongLength;

        #if FLX_DEBUG
        var healthBar:HealthBar = playField.healthBar;

        healthBar.onEmptied.add(gameOver);
        #end

        oppStrumline.onNoteSpawn.add(noteSpawn);
        
        plrStrumline.onNoteSpawn.add(noteSpawn);

        oppStrumline.characters = opponents;

        oppStrumline.spectators = spectators;

        oppStrumline.vocals = opponentVocals ?? mainVocals;

        plrStrumline.characters = players;

        plrStrumline.spectators = spectators;

        plrStrumline.vocals = playerVocals ?? mainVocals;

        spectators.group.memberAdded.add((spectator:Character) -> spectator.strumline = oppStrumline);

        opponents.group.memberAdded.add((opponent:Character) -> opponent.strumline = oppStrumline);

        players.group.memberAdded.add((player:Character) -> player.strumline = plrStrumline);

        if (spectator != null)
            spectators.add(spectator);

        opponents.add(opponent);

        players.add(player);

        updateHealthBar();

        updateScore(playField.playStats);

        countdown = new Countdown(this, this);
        
        countdown.camera = hudCamera;

        add(countdown);

        startingSong = true;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Calculate new time here, we need to update camera target fields before updating the conductor.
        var timeToUpdateTo:Float = conductor.time + 1000.0 * elapsed;

        if (startingSong)
            timeToUpdateTo = Math.min(timeToUpdateTo, 0.0);

        // Update the camera target fields.
        updateCameraTarget(timeToUpdateTo);
            
        // Update the conductor now.
        conductor.update(timeToUpdateTo);

        while (eventIndex < chart.events.length)
        {
            var event:EventData = chart.events[eventIndex];

            if (conductor.time < event.time)
                break;

            onEvent(event);
        }

        if (startingSong)
        {
            if (conductor.time == 0.0)
                startSong();
        }
        else
        {
            if (instrumental.playing)
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
            else
            {
                if (conductor.time >= instrumental.length)
                    endSong();
            }
        }

        gameCamera.zoom = FlxMath.lerp(gameCamera.zoom, gameCameraZoom, FlxMath.getElapsedLerp(0.15, elapsed));

        #if NO_HUD_CAMERA_ZOOM
        #else
        hudCamera.zoom = FlxMath.lerp(hudCamera.zoom, 1.0, FlxMath.getElapsedLerp(0.15, elapsed));
        #end

        if (FlxG.keys.justPressed.SEVEN)
            FlxG.switchState(() -> new OptionsMenu(() -> getClassFromLevel()));

        #if FLX_DEBUG
        if (FlxG.keys.justPressed.EIGHT)
            FlxG.switchState(() -> new editors.CharacterEditorState(() -> PlayState.getClassFromLevel()));
        #end

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.resetState();
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

        #if NO_HUD_CAMERA_ZOOM
        #else
        hudCamera.zoom += hudCamBopStrength;
        #end
    }

    public function loadChart():Void
    {
        chart = ChartBuilder.buildFromFolder(Paths.data('game/levels/${level.name}'));

        chart.notes.sortTimed();

        #if NOTE_SHUFFLE
        var keyCount:Int = chart.keyCount;

        #if NOTE_SHUFFLE_FAST
        for (i in 0 ... chart.notes.length)
        {
            var note:NoteData = chart.notes[i];

            note.direction = FlxG.random.int(0, keyCount - 1);
        }
        #else
        var ds:Array<Int> = new Array<Int>();

        for (i in 0 ... chart.keyCount)
            ds.push(FlxG.random.int(0, keyCount - 1, ds));

        for (i in 0 ... chart.notes.length)
        {
            var note:NoteData = chart.notes[i];

            note.direction = ds[note.direction];
        }
        #end
        #end

        chart.events.sortTimed();

        chart.timingPoints.sortTimed();

        conductor.calibrateTimingPoints(chart.timingPoints);

        conductor.update(-conductor.beatLength * 5.0);

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
        var songPath:String = 'game/levels/${level.name}/';

        instrumental = FlxG.sound.load(AssetCache.getMusic('${songPath}Instrumental'));

        if (Paths.exists(Paths.music(Paths.ogg('${songPath}Vocals-Main'))))
            mainVocals = FlxG.sound.load(AssetCache.getMusic('${songPath}Vocals-Main'));
        else
        {
            if (Paths.exists(Paths.music(Paths.ogg('${songPath}Vocals-Opponent'))))
                opponentVocals = FlxG.sound.load(AssetCache.getMusic('${songPath}Vocals-Opponent'));

            if (Paths.exists(Paths.music(Paths.ogg('${songPath}Vocals-Player'))))
                playerVocals = FlxG.sound.load(AssetCache.getMusic('${songPath}Vocals-Player'));
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

            weekStats[level.name] = playField.playStats.copy();

            week.levels.shift();

            if (week.levels.length == 0.0)
            {
                var totalStats:PlayStats = PlayStats.empty();

                for (k => v in weekStats)
                    totalStats.concat(v);

                score = totalStats.score;

                misses = totalStats.misses;

                accuracy = totalStats.accuracy;

                if (HighScore.isWeekHighScore(week.name, level.difficulty, score))
                {
                    HighScore.setWeekScore(week.name, level.difficulty, {score: score, misses: misses, accuracy: accuracy});

                    SaveManager.saveHighScores();
                }
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

    public function changeTime(newTime:Float):Void
    {
        if (startingSong)
            return;

        if (conductor.time == newTime)
            return;

        if (conductor.time > newTime)
        {
            pauseMusic();

            setMusicTime(newTime);

            conductor.time = newTime;
            
            playField.noteSpawner.setNoteIndexAt(newTime);

            setEventIndexAt(newTime);

            resumeMusic();
        }
        else
        {
            pauseMusic();

            setMusicTime(newTime);

            playField.noteSpawner.setNoteIndexAt(newTime);

            while (conductor.time < newTime)
            {
                @:privateAccess
                FlxG.game.step();
            }

            resumeMusic();
        }
    }

    public function setEventIndexAt(time:Float):Void
    {
        eventIndex = 0;
        
        var event:EventData = chart.events[eventIndex];

        while (eventIndex < chart.events.length && event.time <= time)
        {
            eventIndex++;
            
            event = chart.events[eventIndex];
        }
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
        var playAsWho:Int = Std.parseInt(MacroUtil.sanitizeDefine(MacroUtil.getDefine("PLAY_AS_WHO"))) ?? 1;

        var playAsOpponent:Bool = playAsWho == 0;

        var healthBar:HealthBar = playField.healthBar;

        healthBar.fillDirection = playAsOpponent ? LEFT_TO_RIGHT : RIGHT_TO_LEFT;

        var oppColor:FlxColor = FlxColor.fromString(opponent.config.healthColor);

        var plrColor:FlxColor = FlxColor.fromString(player.config.healthColor);

        healthBar.emptiedSide.color = playAsOpponent ? plrColor : oppColor;

        healthBar.filledSide.color = playAsOpponent ? oppColor : plrColor;

        if (playAsOpponent)
        {
            healthBar.opponentIcon.setIcon(player.config.healthIcon);

            healthBar.playerIcon.setIcon(opponent.config.healthIcon);
        }
        else
        {
            healthBar.opponentIcon.setIcon(opponent.config.healthIcon);

            healthBar.playerIcon.setIcon(player.config.healthIcon);
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

        if (ev.value.charType == "")
            return "POINT";
        else
            return ev.value.charType.toUpperCase();
    }

    public function updateCameraTarget(timeToCheck:Float):Void
    {
        var target:String = getCameraTarget(timeToCheck);

        if (target == "POINT")
            cameraTarget = target;
        else
        {
            cameraTarget = "CHARACTER";

            cameraCharTarget = target;
        }
    }

    public function noteSpawn(note:Note):Void {}

    public function updateScore(playStats:PlayStats):Void
    {

    }

    public function gameOver():Void
    {
        persistentDraw = false;

        openSubState(new GameOverScreen(this));

        tweens.cancelTweensOf(gameCamera, ["scroll"]);

        cameraPoint.centerTo();

        gameCamera.snapToTarget();

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

    public function setMusicTime(time:Float):Void
    {
        instrumental.time = time;

        if (mainVocals != null)
            mainVocals.time = time;

        if (opponentVocals != null)
            opponentVocals.time = time;

        if (playerVocals != null)
            playerVocals.time = time;
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
}

enum CameraLockMode
{
    /**
     * No camera events are restricted.
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
     * All camera events are restricted.
     */
    NONE;
}