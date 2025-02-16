package game;

import sys.FileSystem;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import flixel.util.FlxStringUtil;

import core.Assets;
import core.Paths;
import core.Options;

import data.CharacterData;
import data.Chart;
import data.Chart.RawEvent;
import data.Chart.RawNote;
import data.ChartConverters;
import data.HealthBarIconData;

import editors.CharacterEditorState;

import game.events.CameraFollowEvent;
import game.events.CameraZoomEvent;
import game.events.ScrollSpeedChangeEvent;

import menus.OptionsMenu;

import music.MusicSubState;

import ui.Countdown;

import util.TimedObjectUtil;

using StringTools;

using util.ArrayUtil;

class PlayState extends MusicSubState
{
    public var gameCamera(get, never):FlxCamera;
    
    @:noCompletion
    function get_gameCamera():FlxCamera
    {
        return FlxG.camera;
    }

    public var gameCameraTarget:FlxObject;

    public var gameCameraZoom:Float;

    public var hudCamera:FlxCamera;

    public var hudCameraZoom:Float;

    public var chart:Chart;

    public var eventIndex:Int;

    public var instrumental:FlxSound;

    public var mainVocals:FlxSound;

    public var opponentVocals:FlxSound;

    public var playerVocals:FlxSound;

    public var stage:FlxGroup;

    public var spectators:FlxTypedSpriteGroup<Character>;

    public var spectator:Character;

    public var opponents:FlxTypedSpriteGroup<Character>;

    public var opponent:Character;

    public var players:FlxTypedSpriteGroup<Character>;

    public var player:Character;

    public var playField:PlayField;

    public var countdown:Countdown;

    public var debugInputs:Map<String, Int>;

    override function create():Void
    {
        super.create();

        gameCamera.zoom = 0.75;

        gameCameraTarget = new FlxObject();

        add(gameCameraTarget);

        gameCamera.follow(gameCameraTarget, LOCKON, 0.05);

        gameCameraZoom = gameCamera.zoom;

        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        hudCameraZoom = hudCamera.zoom;

        loadChart(FlxStringUtil.getClassName(this, true));

        loadSong(FlxStringUtil.getClassName(this, true));

        stage ??= new FlxGroup();

        add(stage);

        spectators = new FlxTypedSpriteGroup<Character>();

        stage.add(spectators);

        spectator = new Character(conductor, 0.0, 0.0, CharacterData.get("assets/data/game/Character/GIRLFRIEND"));

        spectator.skipSing = true;

        opponents = new FlxTypedSpriteGroup<Character>();

        stage.add(opponents);

        opponent = new Character(conductor, 0.0, 0.0, CharacterData.get("assets/data/game/Character/BOYFRIEND_PIXEL"));

        players = new FlxTypedSpriteGroup<Character>();

        stage.add(players);

        player = new Character(conductor, 0.0, 0.0, CharacterData.get("assets/data/game/Character/BOYFRIEND"));

        playField = new PlayField(conductor, chart, instrumental);

        playField.camera = hudCamera;

        add(playField);

        playField.healthBar.onEmptied.add(gameOver);

        playField.healthBar.opponentIcon.config = HealthBarIconData.get('assets/data/game/HealthBarIcon/${opponent.config.name}');

        playField.healthBar.opponentIcon = playField.healthBar.opponentIcon;

        playField.healthBar.playerIcon.config = HealthBarIconData.get('assets/data/game/HealthBarIcon/${player.config.name}');

        playField.healthBar.playerIcon = playField.healthBar.playerIcon;

        playField.opponentStrumline.characters = opponents;

        playField.opponentStrumline.vocals = opponentVocals ?? mainVocals;

        playField.playerStrumline.characters = players;

        playField.playerStrumline.vocals = playerVocals ?? mainVocals;

        spectators.group.memberAdded.add((spectator:Character) -> spectator.strumline = playField.opponentStrumline);

        opponents.group.memberAdded.add((opponent:Character) -> opponent.strumline = playField.opponentStrumline);

        players.group.memberAdded.add((player:Character) -> player.strumline = playField.playerStrumline);

        spectators.add(spectator);

        opponents.add(opponent);

        players.add(player);

        countdown = new Countdown(conductor);
        
        countdown.camera = hudCamera;

        countdown.onPause.add(() -> conductor.active = false);

        countdown.onResume.add(() -> conductor.active = true);

        countdown.onFinish.add(() ->
        {
            conductor.time = 0.0;

            countdown.kill();

            startSong();
        });

        countdown.onSkip.add(() ->
        {
            conductor.time = 0.0;

            countdown.kill();

            startSong();
        });

        countdown.start();

        add(countdown);

        debugInputs = new Map<String, Int>();

        debugInputs["EDITORS:CHARACTEREDITORSTATE"] = 55;

        debugInputs["MENUS:OPTIONSMENU"] = 56;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        gameCamera.zoom = FlxMath.lerp(gameCamera.zoom, gameCameraZoom, FlxMath.getElapsedLerp(0.15, elapsed));

        hudCamera.zoom = FlxMath.lerp(hudCamera.zoom, hudCameraZoom, FlxMath.getElapsedLerp(0.15, elapsed));

        while (eventIndex < chart.events.length)
        {
            var event:RawEvent = chart.events[eventIndex];

            if (conductor.time < event.time)
                break;

            switch (event.name:String)
            {
                case "Camera Follow":
                    CameraFollowEvent.dispatch(this, event.value.x ?? 0.0, event.value.y ?? 0.0, event.value.characterRole ?? "", event.value.duration ?? -1.0, event.value.ease ?? "linear");

                case "Camera Zoom":
                    CameraZoomEvent.dispatch(this, event.value.camera, event.value.zoom, event.value.duration, event.value.ease);

                case "Scroll Speed Change":
                    ScrollSpeedChangeEvent.dispatch(this, event.value.scrollSpeed, event.value.duration, event.value.ease);
            }

            eventIndex++;
        }

        if (countdown.finished || countdown.skipped)
        {
            if (Math.abs(conductor.time - instrumental.time) >= 25.0)
                conductor.time = instrumental.time;

            if (mainVocals != null)
                if (Math.abs(mainVocals.time - instrumental.time) >= 5.0)
                    mainVocals.time = instrumental.time;

            if (opponentVocals != null)
                if (Math.abs(opponentVocals.time - instrumental.time) >= 5.0)
                    opponentVocals.time = instrumental.time;

            if (playerVocals != null)
                if (Math.abs(playerVocals.time - instrumental.time) >= 5.0)
                    playerVocals.time = instrumental.time;
        }

        if (FlxG.keys.checkStatus(debugInputs["EDITORS:CHARACTEREDITORSTATE"], JUST_PRESSED))
            FlxG.switchState(() -> new CharacterEditorState());

        if (FlxG.keys.checkStatus(debugInputs["MENUS:OPTIONSMENU"], JUST_PRESSED))
            FlxG.switchState(() -> new OptionsMenu());
        
        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.resetState();
    }

    override function measureHit(measure:Int):Void
    {
        super.measureHit(measure);

        gameCamera.zoom += 0.035;

        hudCamera.zoom += 0.015;
    }

    public function loadChart(level:String):Void
    {
        chart = ChartConverters.build('assets/data/game/levels/${level}/');

        TimedObjectUtil.sort(chart.notes);

        if (Options.gameModifiers["shuffle"])
        {
            var shuffledDirections:Array<Int> = new Array<Int>();

            for (i in 0 ... 4)
                shuffledDirections.push(FlxG.random.int(0, 4 - 1, shuffledDirections));

            for (i in 0 ... chart.notes.length)
            {
                var note:RawNote = chart.notes[i];

                note.direction = shuffledDirections[note.direction];
            }
        }

        if (Options.gameModifiers["mirror"])
        {
            var mirroredDirections:Array<Int> = new Array<Int>();

            for (i in 0 ... 4)
                mirroredDirections.insert(0, i);

            for (i in 0 ... chart.notes.length)
            {
                var note:RawNote = chart.notes[i];

                note.direction = mirroredDirections[note.direction];
            }
        }

        TimedObjectUtil.sort(chart.events);

        TimedObjectUtil.sort(chart.timeChanges);

        conductor.tempo = chart.tempo;

        conductor.timeChange = {time: 0.0, tempo: chart.tempo, step: 0.0};

        conductor.timeChanges = chart.timeChanges;

        conductor.time = -conductor.beatLength * 5.0;

        eventIndex = 0;
    }

    public function loadSong(level:String):Void
    {
        instrumental = FlxG.sound.load(Assets.getSound(Paths.ogg('assets/music/game/levels/${level}/Instrumental')));

        instrumental.onComplete = endSong;

        if (FileSystem.exists(Paths.ogg('assets/music/game/levels/${level}/Vocals-Main')))
            mainVocals = FlxG.sound.load(Assets.getSound(Paths.ogg('assets/music/game/levels/${level}/Vocals-Main')));
        else
        {
            opponentVocals = FlxG.sound.load(Assets.getSound(Paths.ogg('assets/music/game/levels/${level}/Vocals-Opponent')));

            playerVocals = FlxG.sound.load(Assets.getSound(Paths.ogg ('assets/music/game/levels/${level}/Vocals-Player')));
        }
    }

    public function startSong():Void
    {
        instrumental.play();

        mainVocals?.play();

        opponentVocals?.play();

        playerVocals?.play();
    }

    public function endSong():Void
    {
        FlxG.resetState();
    }

    public function gameOver():Void
    {
        persistentDraw = false;

        openSubState(new GameOverScreen(this));

        instrumental.stop();

        mainVocals?.stop();

        opponentVocals?.stop();

        playerVocals?.stop();

        for (i in 0 ... playField.strumlines.members.length)
            playField.strumlines.members[i].removeKeyboardListeners();
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
}