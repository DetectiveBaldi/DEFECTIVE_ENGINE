package game;

import sys.FileSystem;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

import core.Assets;
import core.Inputs;
import core.Paths;
import core.Options;

import editors.CharacterEditorState;

import game.Chart.LoadedNote;
import game.ChartConverters.FunkConverter;
import game.ChartConverters.PsychConverter;
import game.events.EventSpawner;
import game.notes.Note;
import game.notes.NoteSpawner;
import game.notes.NoteSplash;
import game.notes.Strum;
import game.notes.StrumLine;
import game.Stage;

import menus.OptionsMenu;

import music.MusicSubState;

import ui.Countdown;

import util.StringUtil;
import util.TimingUtil;

using StringTools;

using util.ArrayUtil;

class GameState extends MusicSubState
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

    public var stage:Stage;

    public var spectatorMap:Map<String, Character>;

    public var spectatorGroup:FlxTypedGroup<Character>;

    public var spectator:Character;

    public var opponentMap:Map<String, Character>;

    public var opponentGroup:FlxTypedGroup<Character>;

    public var opponent:Character;

    public var playerMap:Map<String, Character>;

    public var playerGroup:FlxTypedGroup<Character>;

    public var player:Character;

    public var points:Int;

    public var hits:Int;

    public var misses:Int;

    public var bonus:Float;

    public var judgements:Array<Judgement>;

    public var healthBar:HealthBar;

    public var scoreText:FlxText;

    public var chart:Chart;

    public var chartSpeed:Float;

    public var instrumental:FlxSound;

    public var mainVocals:FlxSound;

    public var opponentVocals:FlxSound;

    public var playerVocals:FlxSound;

    public var strumLines:FlxTypedGroup<StrumLine>;

    public var opponentStrumLine:StrumLine;

    public var playerStrumLine:StrumLine;

    public var eventSpawner:EventSpawner;

    public var noteSpawner:NoteSpawner;

    public var noteSplashes:FlxTypedGroup<NoteSplash>;

    public var countdown:Countdown;

    public var debugInputs:Map<String, Input>;

    public function new(stage:Stage):Void
    {
        super();

        this.stage = stage;
    }

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

        add(stage);

        spectatorMap = new Map<String, Character>();

        spectatorGroup = new FlxTypedGroup<Character>();

        add(spectatorGroup);

        spectator = new Character(conductor, 0.0, 0.0, Character.findConfig("assets/data/game/Character/GIRLFRIEND"), OTHER);

        spectator.skipSing = true;

        spectatorMap[spectator.config.name] = spectator;

        spectatorGroup.add(spectator);

        opponentMap = new Map<String, Character>();

        opponentGroup = new FlxTypedGroup<Character>();

        add(opponentGroup);

        opponent = new Character(conductor, 0.0, 0.0, Character.findConfig("assets/data/game/Character/BOYFRIEND_PIXEL"), OTHER);

        opponentMap[opponent.config.name] = opponent;

        opponentGroup.add(opponent);

        playerMap = new Map<String, Character>();

        playerGroup = new FlxTypedGroup<Character>();

        add(playerGroup);

        player = new Character(conductor, 0.0, 0.0, Character.findConfig("assets/data/game/Character/BOYFRIEND"), PLAYABLE);

        playerMap[player.config.name] = player;

        playerGroup.add(player);

        points = 0;

        hits = 0;

        misses = 0;

        bonus = 0.0;

        judgements =
        [
            new Judgement("Epic!", 22.5, 1.0, 2.85, 0),

            new Judgement("Sick!", 45.0, 1.0, 2.5, 0),

            new Judgement("Good", 90.0, 0.65, 1.5, 0),

            new Judgement("Bad", 135.0, 0.35, -1.5, 0),

            new Judgement("Shit", 166.6, -2.5, 0.0, 0)
        ];

        healthBar = new HealthBar(0.0, 0.0, 600, 25, RIGHT_TO_LEFT, conductor);

        healthBar.camera = hudCamera;

        healthBar.onEmptied.add(loadGameOverScreen);

        healthBar.opponentIcon.config = HealthBarIcon.findConfig('assets/data/game/HealthBarIcon/${opponent.config.name}');

        healthBar.opponentIcon = healthBar.opponentIcon;

        healthBar.playerIcon.config = HealthBarIcon.findConfig('assets/data/game/HealthBarIcon/${player.config.name}');

        healthBar.playerIcon = healthBar.playerIcon;

        healthBar.setPosition((FlxG.width - healthBar.border.width) * 0.5, Options.downscroll ? (FlxG.height - healthBar.border.height) - 620.0 : 620.0);

        add(healthBar);

        scoreText = new FlxText(0.0, 0.0, FlxG.width, "Points: 0 | Misses: 0 | Rating: 0.0%", 24);

        scoreText.camera = hudCamera;

        scoreText.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        scoreText.alignment = CENTER;

        scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        scoreText.setPosition((FlxG.width - scoreText.width) * 0.5, Options.downscroll ? 25.0 : (FlxG.height - scoreText.height) - 25.0);

        add(scoreText);

        loadChart(FlxStringUtil.getClassName(this, true));

        loadSong(FlxStringUtil.getClassName(this, true));

        strumLines = new FlxTypedGroup<StrumLine>();

        strumLines.camera = hudCamera;

        add(strumLines);
        
        opponentStrumLine = new StrumLine(this);

        opponentStrumLine.onNoteHit.add(noteHit);

        opponentStrumLine.onNoteHit.add(opponentNoteHit);

        opponentStrumLine.onNoteMiss.add(noteMiss);

        opponentStrumLine.onNoteMiss.add(opponentNoteMiss);

        opponentStrumLine.onGhostTap.add(ghostTap);

        opponentStrumLine.onGhostTap.add(opponentGhostTap);

        opponentStrumLine.automated = true;

        opponentStrumLine.visible = !Options.middlescroll;

        opponentStrumLine.strums.setPosition(Options.middlescroll ? (FlxG.width - opponentStrumLine.strums.width) * 0.5 : 45.0, Options.downscroll ? FlxG.height - opponentStrumLine.strums.height - 15.0 : 15.0);

        strumLines.add(opponentStrumLine);
        
        playerStrumLine = new StrumLine(this);

        playerStrumLine.onNoteHit.add(noteHit);
        
        playerStrumLine.onNoteHit.add(playerNoteHit);

        playerStrumLine.onNoteMiss.add(noteMiss);

        playerStrumLine.onNoteMiss.add(playerNoteMiss);

        playerStrumLine.onGhostTap.add(ghostTap);

        playerStrumLine.onGhostTap.add(playerGhostTap);

        playerStrumLine.strums.setPosition(Options.middlescroll ? (FlxG.width - playerStrumLine.strums.width) * 0.5 : FlxG.width - playerStrumLine.strums.width - 45.0, Options.downscroll ? FlxG.height - playerStrumLine.strums.height - 15.0 : 15.0);

        strumLines.add(playerStrumLine);

        eventSpawner = new EventSpawner(this);

        add(eventSpawner);

        noteSpawner = new NoteSpawner(this);

        add(noteSpawner);

        noteSplashes = new FlxTypedGroup<NoteSplash>();

        noteSplashes.camera = hudCamera;

        add(noteSplashes);

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

        debugInputs = new Map<String, Input>();

        debugInputs["EDITORS:CHARACTEREDITORSTATE"] = new Input([55]);

        debugInputs["MENUS:OPTIONSMENU"] = new Input([56]);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        gameCamera.zoom = gameCameraZoom + (gameCamera.zoom - gameCameraZoom) * Math.exp(-15.0 * elapsed);

        hudCamera.zoom = hudCameraZoom + (hudCamera.zoom - hudCameraZoom) * Math.exp(-15.0 * elapsed);

        if (countdown.finished || countdown.skipped)
        {
            if (Math.abs(instrumental.time - conductor.time) >= 25.0)
                instrumental.time = conductor.time;

            if (instrumental.length < conductor.time)
                endSong();

            if (mainVocals != null)
            {
                if (Math.abs(mainVocals.time - instrumental.time) >= 5.0)
                    mainVocals.time = instrumental.time;
            }

            if (opponentVocals != null)
            {
                if (Math.abs(opponentVocals.time - instrumental.time) >= 5.0)
                    opponentVocals.time = instrumental.time;
            }

            if (playerVocals != null)
            {
                if (Math.abs(playerVocals.time - instrumental.time) >= 5.0)
                    playerVocals.time = instrumental.time;
            }
        }

        if (Inputs.checkStatus(debugInputs["EDITORS:CHARACTEREDITORSTATE"], JUST_PRESSED))
            FlxG.switchState(() -> new CharacterEditorState());

        if (Inputs.checkStatus(debugInputs["MENUS:OPTIONSMENU"], JUST_PRESSED))
            FlxG.switchState(() -> new OptionsMenu());

        if (FlxG.keys.justPressed.R && countdown.tick > 0.0)
            loadGameOverScreen();
        
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
        chart = Chart.build('assets/data/game/levels/${level}/chart');

        TimingUtil.sort(chart.notes);

        if (Options.gameModifiers["shuffle"])
        {
            var shuffledDirections:Array<Int> = new Array<Int>();

            for (i in 0 ... 4)
                shuffledDirections.push(FlxG.random.int(0, 4 - 1, shuffledDirections));

            for (i in 0 ... chart.notes.length)
            {
                var note:LoadedNote = chart.notes[i];

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
                var note:LoadedNote = chart.notes[i];

                note.direction = mirroredDirections[note.direction];
            }
        }

        TimingUtil.sort(chart.events);

        TimingUtil.sort(chart.timeChanges);

        conductor.tempo = chart.tempo;

        conductor.timeChange = {time: 0.0, tempo: chart.tempo, step: 0.0};

        conductor.timeChanges = chart.timeChanges;

        conductor.time = -conductor.crotchet * 5.0;

        chartSpeed = chart.speed;
    }

    public function loadSong(level:String):Void
    {
        instrumental = FlxG.sound.load(Assets.getSound(Paths.ogg('assets/music/game/levels/${level}/Instrumental')));

        if (FileSystem.exists(Paths.ogg('assets/music/game/levels/${level}/Vocals-Main')))
            mainVocals = FlxG.sound.load(Assets.getSound(Paths.ogg('assets/music/game/levels/${level}/Vocals-Main')));

        if (mainVocals == null)
        {
            if (FileSystem.exists(Paths.ogg('assets/music/game/levels/${level}/Vocals-Opponent')))
                opponentVocals = FlxG.sound.load(Assets.getSound(Paths.ogg('assets/music/game/levels/${level}/Vocals-Opponent')));

            if (FileSystem.exists(Paths.ogg('assets/music/game/levels/${level}/Vocals-Player')))
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

    public function noteHit(note:Note):Void
    {
        var strumLine:StrumLine = strumLines.members[note.lane];

        var strum:Strum = strumLine.strums.members[note.direction];

        strum.confirmCount = 0.0;
        
        strum.animation.play(Strum.directions[note.direction].toLowerCase() + "Confirm", true);

        if (!strumLine.automated)
        {       
            if (!note.animation.name.contains("Hold"))
            {
                var _noteHit:FlxSound = FlxG.sound.play(Assets.getSound(Paths.ogg("assets/sounds/game/GameState/noteHit"), false));

                _noteHit.onComplete = _noteHit.kill;

                var judgement:Judgement = Judgement.guage(judgements, Math.abs(conductor.time - note.time));

                points += 500 - Math.ceil(Math.abs(conductor.time - note.time));

                hits++;

                bonus += judgement.bonus;

                healthBar.value += judgement.health;

                scoreText.text = 'Points: ${points} | Misses: ${misses} | Rating: ${StringUtil.appendDecimal(FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2))}%';

                if (judgement.name == "Epic!" || judgement.name == "Sick!")
                {
                    var noteSplash:NoteSplash = noteSplashes.recycle(NoteSplash, () -> new NoteSplash());

                    noteSplash.direction = strum.direction;

                    noteSplash.animation.play('${FlxG.random.getObject(noteSplash.config.frames).prefix} ${NoteSplash.directions[noteSplash.direction].toLowerCase()}', false, FlxG.random.bool());

                    noteSplash.animation.onFinish.add((name:String) -> noteSplash.kill());

                    noteSplash.scale.set(0.7, 0.7);

                    noteSplash.updateHitbox();

                    noteSplash.setPosition(strum.getMidpoint().x - noteSplash.width * 0.5, strum.getMidpoint().y - noteSplash.height * 0.5);
                }
            }
        }

        if (mainVocals != null)
            mainVocals.volume = 1.0;
    }

    public function noteMiss(note:Note):Void
    {
        var _noteMiss:FlxSound = FlxG.sound.play(Assets.getSound(Paths.ogg('assets/sounds/game/GameState/noteMiss${FlxG.random.int(0, 2)}'), false), 0.15);

        _noteMiss.onComplete = _noteMiss.kill;

        points -= 650;

        misses++;

        healthBar.value -= 3.5;

        scoreText.text = 'Points: ${points} | Misses: ${misses} | Rating: ${StringUtil.appendDecimal(FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2))}%';

        if (mainVocals != null)
            mainVocals.volume = 0.0;
    }

    public function opponentNoteHit(note:Note):Void
    {
        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            if (character.skipSing)
                continue;

            character.singCount = 0.0;

            if (note.animation.name.contains("Hold") && character.animation.name == 'Sing${Note.directions[note.direction]}')
                continue;

            if (character.animation.exists('Sing${Note.directions[note.direction]}'))
                character.animation.play('Sing${Note.directions[note.direction]}', true);
        }

        if (opponentVocals != null)
            opponentVocals.volume = 1.0;
    }

    public function opponentNoteMiss(note:Note):Void
    {
        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            if (character.skipSing)
                continue;

            character.singCount = 0.0;

            if (note.animation.name.contains("Hold") && character.animation.name == 'Sing${Note.directions[note.direction]}MISS')
                continue;

            if (character.animation.exists('Sing${Note.directions[note.direction]}MISS'))
                character.animation.play('Sing${Note.directions[note.direction]}MISS', true);
        }

        if (opponentVocals != null)
            opponentVocals.volume = 0.0;
    }

    public function playerNoteHit(note:Note):Void
    {
        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            if (character.skipSing)
                continue;

            character.singCount = 0.0;

            if (note.animation.name.contains("Hold") && character.animation.name == 'Sing${Note.directions[note.direction]}')
                continue;
            
            if (character.animation.exists('Sing${Note.directions[note.direction]}'))
                character.animation.play('Sing${Note.directions[note.direction]}', true);
        }

        if (playerVocals != null)
            playerVocals.volume = 1.0;
    }

    public function playerNoteMiss(note:Note):Void
    {
        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            if (character.skipSing)
                continue;

            character.singCount = 0.0;

            if (note.animation.name.contains("Hold") && character.animation.name == 'Sing${Note.directions[note.direction]}MISS')
                continue;

            if (character.animation.exists('Sing${Note.directions[note.direction]}MISS'))
                character.animation.play('Sing${Note.directions[note.direction]}MISS', true);
        }

        if (playerVocals != null)
            playerVocals.volume = 0.0;
    }

    public function ghostTap(direction:Int):Void
    {
        if (Options.ghostTapping || countdown.tick <= 0.0)
            return;

        var _noteMiss:FlxSound = FlxG.sound.play(Assets.getSound(Paths.ogg('assets/sounds/game/GameState/noteMiss${FlxG.random.int(0, 2)}'), false), 0.15);

        _noteMiss.onComplete = _noteMiss.kill;
        
        points -= 650;

        misses++;

        healthBar.value -= 3.5;

        scoreText.text = 'Points: ${points} | Misses: ${misses} | Rating: ${StringUtil.appendDecimal(FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2))}%';

        if (mainVocals != null)
            mainVocals.volume = 0.0;
    }

    public function opponentGhostTap(direction:Int):Void
    {
        if (Options.ghostTapping || countdown.tick <= 0.0)
            return;

        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[direction]}MISS'))
                character.animation.play('Sing${Note.directions[direction]}MISS', true);
        }

        if (opponentVocals != null)
            opponentVocals.volume = 0.0;
    }

    public function playerGhostTap(direction:Int):Void
    {
        if (Options.ghostTapping || countdown.tick <= 0.0)
            return;

        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[direction]}MISS'))
                character.animation.play('Sing${Note.directions[direction]}MISS', true);
        }

        if (playerVocals != null)
            playerVocals.volume = 0.0;
    }

    public function loadGameOverScreen():Void
    {
        persistentDraw = false;

        instrumental.stop();

        mainVocals?.stop();

        opponentVocals?.stop();

        playerVocals?.stop();

        openSubState(new GameOverScreen(this));
    }
}