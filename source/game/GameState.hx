package game;

import haxe.ds.ArraySort;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import flixel.ui.FlxBar;

import flixel.util.FlxColor;

import core.AssetMan;
import core.Inputs;
import core.Paths;

import extendable.MusicBeatState;

import game.Chart.ParsedEvent;
import game.Chart.ParsedNote;
import game.Chart.ParsedTimeChange;
import game.ChartConverters.FunkConverter;
import game.ChartConverters.PsychConverter;
import game.events.CameraFollowEvent;
import game.events.CameraZoomEvent;
import game.events.SpeedChangeEvent;
import game.notes.Note;
import game.notes.NoteSplash;
import game.notes.Strum;
import game.notes.StrumLine;
import game.stages.Stage;
import game.stages.Week1;
import game.timing.Judgement;

import ui.Countdown;

class GameState extends MusicBeatState
{
    public var gameCamera(get, never):FlxCamera;
    
    public dynamic function get_gameCamera():FlxCamera
    {
        return FlxG.camera;
    }

    public var gameCameraTarget:FlxObject;

    public var gameCameraZoom:Float;

    public var hudCamera:FlxCamera;

    public var hudCameraZoom:Float;

    public var stage:Stage<FlxBasic>;

    public var spectatorMap:Map<String, Character>;

    public var spectatorGroup:FlxTypedContainer<Character>;

    public var spectator:Character;

    public var opponentMap:Map<String, Character>;

    public var opponentGroup:FlxTypedContainer<Character>;

    public var opponent:Character;

    public var playerMap:Map<String, Character>;

    public var playerGroup:FlxTypedContainer<Character>;

    public var player:Character;

    public var downScroll:Bool;

    public var score:Int;

    public var hits:Int;

    public var misses:Int;

    public var bonus:Float;

    public var combo:Int;

    public var scoreTxt:FlxText;

    public var health:Float;

    public var healthBar:FlxBar;

    public var judgements:Array<Judgement>;

    public var strumLines:FlxTypedContainer<StrumLine>;

    public var opponentStrumLine:StrumLine;

    public var playerStrumLine:StrumLine;

    public var notes:FlxTypedContainer<Note>;

    public var noteSplashes:FlxTypedContainer<NoteSplash>;

    public var chart:Chart;

    public var chartSpeed:Float;

    public var noteIndex:Int;

    public var eventIndex:Int;

    public var instrumental:FlxSound;

    public var mainVocals:FlxSound;

    public var opponentVocals:FlxSound;

    public var playerVocals:FlxSound;

    public var countdown:Countdown;

    public var songStarted:Bool;

    override function create():Void
    {
        super.create();

        gameCamera.zoom = 0.75;

        gameCameraTarget = new FlxObject();

        gameCameraTarget.screenCenter();

        add(gameCameraTarget);

        gameCamera.follow(gameCameraTarget, LOCKON, 0.05);

        gameCameraZoom = gameCamera.zoom;

        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        hudCameraZoom = hudCamera.zoom;

        stage = new Week1();

        for (i in 0 ... stage.members.length)
            add(stage.members[i]);

        spectatorMap = new Map<String, Character>();

        spectatorGroup = new FlxTypedContainer<Character>();

        add(spectatorGroup);

        spectator = new Character(0.0, 0.0, Paths.json("assets/data/characters/GIRLFRIEND"), ARTIFICIAL, conductor);

        spectator.skipSing = true;

        spectator.setPosition((FlxG.width - spectator.width) * 0.5, 35.0);

        spectatorMap[spectator.data.name] = spectator;

        spectatorGroup.add(spectator);

        opponentMap = new Map<String, Character>();

        opponentGroup = new FlxTypedContainer<Character>();

        add(opponentGroup);

        opponent = new Character(0.0, 0.0, Paths.json("assets/data/characters/BOYFRIEND_PIXEL"), ARTIFICIAL, conductor);

        opponent.setPosition(15.0, 50.0);

        opponentMap[opponent.data.name] = opponent;

        opponentGroup.add(opponent);

        playerMap = new Map<String, Character>();

        playerGroup = new FlxTypedContainer<Character>();

        add(playerGroup);

        player = new Character(0.0, 0.0, Paths.json("assets/data/characters/BOYFRIEND"), PLAYABLE, conductor);

        player.setPosition(FlxG.width - player.width - 15.0, 385.0);

        playerMap[player.data.name] = player;

        playerGroup.add(player);

        downScroll = false;

        score = 0;

        hits = 0;

        misses = 0;

        bonus = 0.0;

        combo = 0;

        scoreTxt = new FlxText(0.0, 0.0, FlxG.width, "Score: 0 | Misses: 0 | Accuracy: 0.0%", 24);

        scoreTxt.camera = hudCamera;

        scoreTxt.antialiasing = false;

        scoreTxt.alignment = CENTER;

        scoreTxt.borderStyle = SHADOW;

        scoreTxt.borderColor = FlxColor.BLACK;

        scoreTxt.borderSize = 5.0;

        scoreTxt.setPosition((FlxG.width - scoreTxt.width) * 0.5, downScroll ? 35.0 : (FlxG.height - scoreTxt.height) - 35.0);

        add(scoreTxt);

        health = 50.0;

        healthBar = new FlxBar(0.0, 0.0, RIGHT_TO_LEFT, 600, 25, this, "health", 0.0, 100.0, true);

        healthBar.camera = hudCamera;

        healthBar.createFilledBar(FlxColor.RED, FlxColor.LIME, true, FlxColor.BLACK, 5);

        healthBar.numDivisions = FlxMath.MAX_VALUE_INT;

        healthBar.setPosition((FlxG.width - healthBar.width) * 0.5, downScroll ? (FlxG.height - healthBar.height) - 620.0 : 620.0);

        add(healthBar);

        judgements =
        [
            {name: "Epic!", color: FlxColor.MAGENTA, timing: 15.0, bonus: 1.0, score: 500, hits: 0},

            {name: "Sick!", color: FlxColor.CYAN, timing: 45.0, bonus: 1.0, score: 350, hits: 0},

            {name: "Good", color: FlxColor.GREEN, timing: 75.0, bonus: 0.65, score: 250, hits: 0},

            {name: "Bad", color: FlxColor.RED, timing: 125.0, bonus: 0.35, score: 150, hits: 0},

            {name: "Shit", color: FlxColor.subtract(FlxColor.RED, FlxColor.BROWN), timing: Math.POSITIVE_INFINITY, bonus: 0.0, score: 50, hits: 0}
        ];

        strumLines = new FlxTypedContainer<StrumLine>();

        strumLines.camera = hudCamera;

        add(strumLines);
        
        opponentStrumLine = new StrumLine(conductor);

        opponentStrumLine.lane = 0;

        opponentStrumLine.artificial = true;

        opponentStrumLine.noteHit.add(opponentNoteHit);

        opponentStrumLine.noteHit.add(noteHit);

        opponentStrumLine.noteMiss.add(opponentNoteMiss);

        opponentStrumLine.noteMiss.add(noteMiss);

        opponentStrumLine.ghostTap.add(opponentGhostTap);

        opponentStrumLine.ghostTap.add(ghostTap);

        opponentStrumLine.setPosition(45.0, downScroll ? FlxG.height - opponentStrumLine.height - 15.0 : 15.0);

        strumLines.add(opponentStrumLine);
        
        playerStrumLine = new StrumLine(conductor);

        playerStrumLine.lane = 1;
        
        playerStrumLine.noteHit.add(playerNoteHit);

        playerStrumLine.noteHit.add(noteHit);

        playerStrumLine.noteMiss.add(playerNoteMiss);

        playerStrumLine.noteMiss.add(noteMiss);

        playerStrumLine.ghostTap.add(playerGhostTap);

        playerStrumLine.ghostTap.add(ghostTap);

        playerStrumLine.setPosition(FlxG.width - playerStrumLine.width - 45.0, downScroll ? FlxG.height - playerStrumLine.height - 15.0 : 15.0);

        strumLines.add(playerStrumLine);

        notes = new FlxTypedContainer<Note>();

        notes.camera = hudCamera;

        add(notes);

        noteSplashes = new FlxTypedContainer<NoteSplash>();

        noteSplashes.camera = hudCamera;

        add(noteSplashes);

        loadSong("Darnell (Bf Mix)");

        countdown = new Countdown(conductor);

        countdown.camera = hudCamera;

        countdown.onTick.add((tick:Int) ->
        {
            if (tick < 5.0)
            {
                for (i in 0 ... spectatorGroup.members.length)
                {
                    var character:Character = spectatorGroup.members[i];

                    if (tick % character.danceInterval == 0.0)
                        character.dance();
                }

                for (i in 0 ... opponentGroup.members.length)
                {
                    var character:Character = opponentGroup.members[i];

                    if (tick % character.danceInterval == 0.0)
                        character.dance();
                }

                for (i in 0 ... playerGroup.members.length)
                {
                    var character:Character = playerGroup.members[i];

                    if (tick % character.danceInterval == 0.0)
                        character.dance();
                }
            }
        });

        countdown.onFinish.add(() ->
        {
            countdown.kill();
        });

        countdown.onSkip.add(() ->
        {
            conductor.time = 0.0;

            countdown.kill();
        });

        countdown.start();

        add(countdown);

        songStarted = false;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        gameCamera.zoom = FlxMath.lerp(gameCamera.zoom, gameCameraZoom, 0.15);

        hudCamera.zoom = FlxMath.lerp(hudCamera.zoom, hudCameraZoom, 0.15);

        for (i in 0 ... strumLines.members.length)
        {
            var strumLine:StrumLine = strumLines.members[i];

            if (strumLine.artificial)
                continue;

            for (j in 0 ... strumLine.inputs.length)
            {
                var input:String = strumLine.inputs[j];

                if (Inputs.checkStatus(input, JUST_PRESSED))
                {
                    var strum:Strum = strumLine.members[j];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Press");

                    var note:Note = notes.getFirst((n:Note) -> Math.abs(conductor.time - n.time) <= 166.6 && strum.direction == n.direction && strumLine.lane == n.lane && n.length == 0.0);

                    if (note == null)
                        strumLine.ghostTap.dispatch(strum.direction);
                    else
                        strumLine.noteHit.dispatch(note);
                }

                if (Inputs.checkStatus(input, PRESSED))
                {
                    var strum:Strum = strumLine.members[j];

                    var note:Note = notes.getFirst((n:Note) -> conductor.time >= n.time && strum.direction == n.direction && strumLine.lane == n.lane && n.length != 0.0);

                    if (note != null)
                        strumLine.noteHit.dispatch(note);
                }

                if (Inputs.checkStatus(input, JUST_RELEASED))
                {
                    var strum:Strum = strumLine.members[j];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Static");
                }
            }
        }

        var i:Int = notes.members.length - 1;

        while (i >= 0.0)
        {
            var note:Note = notes.members[i];

            var strumLine:StrumLine = strumLines.getFirst((s:StrumLine) -> note.lane == s.lane);

            var strum:Strum = strumLine.group.getFirst((s:Strum) -> note.direction == s.direction);

            note.setPosition(strum.getMidpoint().x - note.width * 0.5, strum.y - (conductor.time - note.time) * chartSpeed * note.speed * 0.45 * (downScroll ? -1.0 : 1.0));

            if (strumLine.artificial)
            {
                if (conductor.time >= note.time && strumLine.lane == note.lane)
                {
                    strumLine.noteHit.dispatch(note);

                    i--;

                    continue;
                }
            }
            else
            {
                if (conductor.time > note.time + 166.6 && strumLine.lane == note.lane)
                {
                    strumLine.noteMiss.dispatch(note);
    
                    i--;
    
                    continue;
                }
            }

            i--;
        }

        while (noteIndex < chart.notes.length)
        {
            var n:ParsedNote = chart.notes[noteIndex];

            if (n.time > conductor.time + hudCamera.height / hudCamera.zoom / chartSpeed / n.speed / 0.45)
                break;

            var j:Int = notes.members.length - 1;

            while (j >= 0.0)
            {
                var note:Note = notes.members[j];

                if (n.time == note.time && n.direction == note.direction && n.lane == note.lane && note.length == 0.0)
                {
                    notes.remove(note).destroy();

                    j--;

                    var k:Int = note.children.length - 1;

                    while (k >= 0.0)
                    {
                        notes.remove(note.children[k]).destroy();

                        k--;

                        j--;
                    }

                    continue;
                }

                j--;
            }

            var note:Note = new Note();

            note.time = n.time;

            note.speed = n.speed;

            note.direction = n.direction;

            note.lane = n.lane;

            note.length = 0.0;

            note.animation.play(Note.directions[note.direction].toLowerCase());

            note.scale.set(0.685, 0.685);

            note.updateHitbox();

            note.setPosition((FlxG.width - note.width) * 0.5, hudCamera.height / hudCamera.zoom);

            notes.add(note);

            for (k in 0 ... Math.floor(n.length / (((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25)))
            {
                var sustain:Note = new Note();

                sustain.parent = note;

                note.children.push(sustain);

                sustain.time = note.time + ((((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25) * (k + 1));

                sustain.speed = note.speed;

                sustain.direction = note.direction;
                
                sustain.lane = note.lane;

                sustain.length = (60 / conductor.timeChanges[0].tempo) * 1000.0;

                sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldPiece");

                if (k >= Math.floor(n.length / (((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25)) - 1)
                    sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldTail");

                sustain.flipY = downScroll;

                sustain.scale.set(0.685, 0.685);

                sustain.updateHitbox();

                sustain.setPosition((FlxG.width - sustain.width) * 0.5, hudCamera.height / hudCamera.zoom);

                notes.add(sustain);
            }

            strumLines.getFirst((s:StrumLine) -> note.lane == s.lane).noteSpawn.dispatch(note);

            noteIndex++;
        }

        if (eventIndex < chart.events.length)
        {
            var e:ParsedEvent = chart.events[eventIndex];

            if (conductor.time >= e.time)
            {
                switch (e.name:String)
                {
                    case "Camera Follow":
                        CameraFollowEvent.dispatch(FlxPoint.get(e.value.x, e.value.y), e.value.duration, Reflect.getProperty(FlxEase, e.value.ease));

                    case "Camera Zoom":
                        CameraZoomEvent.dispatch(Reflect.getProperty(this, e.value.camera), e.value.zoom, e.value.duration, Reflect.getProperty(FlxEase, e.value.ease));

                    case "Speed Change":
                        SpeedChangeEvent.dispatch(e.value.speed, e.value.duration, Reflect.getProperty(FlxEase, e.value.ease));
                }

                eventIndex++;
            }
        }

        if (countdown.started)
        {
            conductor.time += 1000.0 * elapsed;

            if (conductor.time >= 0.0 && !songStarted)
                startSong();
        }

        if (songStarted)
        {
            conductor.guage();

            if (Math.abs(conductor.time - instrumental.time) > 25.0)
                instrumental.time = conductor.time;

            if (mainVocals != null)
                if (Math.abs(instrumental.time - mainVocals.time) > 5.0)
                    mainVocals.time = instrumental.time;

            if (opponentVocals != null)
                if (Math.abs(instrumental.time - opponentVocals.time) > 5.0)
                    opponentVocals.time = instrumental.time;

            if (playerVocals != null)
                if (Math.abs(instrumental.time - playerVocals.time) > 5.0)
                    playerVocals.time = instrumental.time;

            if (conductor.time >= instrumental.length)
                endSong();
        }

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.resetState();
    }

    override function stepHit(step:Int):Void
    {
        super.stepHit(step);
    }

    override function sectionHit(section:Int):Void
    {
        super.sectionHit(section);

        gameCamera.zoom += 0.035;

        hudCamera.zoom += 0.015;
    }

    public function loadSong(name:String):Void
    {
        chart = new FunkConverter(Paths.json('assets/data/songs/${name}/chart'), Paths.json('assets/data/songs/${name}/meta')).build("hard");

        ArraySort.sort(chart.notes, (a:ParsedNote, b:ParsedNote) -> Std.int(a.time - b.time));

        ArraySort.sort(chart.events, (a:ParsedEvent, b:ParsedEvent) -> Std.int(a.time - b.time));

        ArraySort.sort(chart.timeChanges, (a:ParsedTimeChange, b:ParsedTimeChange) -> Std.int(a.time - b.time));

        conductor.tempo = chart.tempo;

        conductor.timeChange = {tempo: conductor.tempo, time: 0.0, step: 0.0, beat: 0.0, section: 0.0};

        conductor.timeChanges = chart.timeChanges;

        conductor.time = -conductor.crotchet * 5.0;

        chartSpeed = chart.speed;

        noteIndex = 0;

        eventIndex = 0;

        instrumental = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Instrumental')));

        if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Main')))
            mainVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Main')));

        if (mainVocals == null)
        {
            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Opponent')))
                opponentVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Opponent')));

            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Player')))
                playerVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Player')));
        }
    }

    public function startSong():Void
    {
        instrumental.play();

        if (mainVocals != null)
            mainVocals.play();

        if (opponentVocals != null)
            opponentVocals.play();

        if (playerVocals != null)
            playerVocals.play();

        songStarted = true;
    }

    public function endSong():Void
    {
        FlxG.resetState();
    }

    public function opponentNoteHit(note:Note):Void
    {
        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            character.singCount = 0.0;

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

            character.singCount = 0.0;

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

            character.singCount = 0.0;

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

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}MISS'))
                character.animation.play('Sing${Note.directions[note.direction]}MISS', true);
        }

        if (playerVocals != null)
            playerVocals.volume = 0.0;
    }

    public function noteHit(note:Note):Void
    {
        var strumLine:StrumLine = strumLines.getFirst((s:StrumLine) -> note.lane == s.lane);

        var strum:Strum = strumLine.group.getFirst((s:Strum) -> note.direction == s.direction);

        strum.confirmCount = 0.0;
        
        strum.animation.play(Strum.directions[note.direction].toLowerCase() + "Confirm", true);

        if (!strumLine.artificial)
        {
            if (note.length == 0.0)
            {
                var judgement:Judgement = Judgement.guage(judgements, Math.abs(conductor.time - note.time));

                score += judgement.score;

                hits++;

                bonus += judgement.bonus;
                
                combo++;

                scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

                health = FlxMath.bound(health + 1.15, 0.0, 100.0);

                if (judgement.name == "Epic!" || judgement.name == "Sick!")
                {
                    var noteSplash:NoteSplash = noteSplashes.recycle(NoteSplash, () -> new NoteSplash());

                    noteSplash.direction = strum.direction;

                    noteSplash.animation.onFinish.add((name:String) -> noteSplash.kill());

                    noteSplash.animation.play('${FlxG.random.getObject(noteSplash.textureData.animations).prefix} ${NoteSplash.directions[noteSplash.direction].toLowerCase()}');

                    noteSplash.scale.set(0.685, 0.685);

                    noteSplash.updateHitbox();

                    noteSplash.setPosition(strum.getMidpoint().x - noteSplash.width * 0.5, strum.getMidpoint().y - noteSplash.height * 0.5);
                }

                FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/snap")), 0.75);
            }
        }

        if (mainVocals != null)
            mainVocals.volume = 1.0;

        notes.remove(note, true).destroy();
    }

    public function noteMiss(note:Note):Void
    {
        if (note.length == 0.0)
        {
            score -= 650;

            misses++;

            combo = 0;

            scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

            health = FlxMath.bound(health - 2.375, 0.0, 100.0);
        }

        if (mainVocals != null)
            mainVocals.volume = 0.0;

        notes.remove(note, true).destroy();
    }

    public function ghostTap(direction:Int):Void
    {
        score -= 650;

        misses++;

        combo = 0;

        scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

        health = FlxMath.bound(health - 2.375, 0.0, 100.0);

        if (mainVocals != null)
            mainVocals.volume = 0.0;
    }

    public function opponentGhostTap(direction:Int):Void
    {
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
}