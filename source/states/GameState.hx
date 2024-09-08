package states;

import haxe.ds.ArraySort;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import flixel.ui.FlxBar;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import core.AssetMan;
import core.Conductor;
import core.Inputs;
import core.Paths;
import core.Rating;
import core.Song;

import events.CameraFollowEvent;
import events.SpeedChangeEvent;

import extendable.State;

import objects.Character;
import objects.Note;
import objects.Strum;
import objects.Strumline;

import stages.Stage;
import stages.Week1;

import tools.formats.charts.FunkFormat;
import tools.formats.charts.PsychFormat;
import tools.formats.charts.StandardFormat;

import tools.formats.charts.StandardFormat.StandardEvent;
import tools.formats.charts.StandardFormat.StandardNote;
import tools.formats.charts.StandardFormat.StandardTimeChange;

class GameState extends State
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

    public var ratings:Array<Rating>;

    public var strumlines:FlxTypedContainer<Strumline>;

    public var opponentStrumline:Strumline;

    public var playerStrumline:Strumline;

    public var song:Song;

    public var songSpeed:Float;

    public var notes:FlxTypedContainer<Note>;

    public var noteIndex:Int;

    public var eventIndex:Int;

    public var instrumental:FlxSound;

    public var mainVocals:FlxSound;

    public var opponentVocals:FlxSound;

    public var playerVocals:FlxSound;

    public var countdownStarted:Bool;

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

        spectator = new Character(0.0, 0.0, Paths.json("assets/characters/GIRLFRIEND"), ARTIFICIAL);

        spectator.skipSing = true;

        spectator.setPosition((FlxG.width - spectator.width) * 0.5, 35.0);

        spectatorMap[spectator.simple.name] = spectator;

        spectatorGroup.add(spectator);

        opponentMap = new Map<String, Character>();

        opponentGroup = new FlxTypedContainer<Character>();

        add(opponentGroup);

        opponent = new Character(0.0, 0.0, Paths.json("assets/characters/BOYFRIEND_PIXEL"), ARTIFICIAL);

        opponent.setPosition(15.0, 50.0);

        opponentMap[opponent.simple.name] = opponent;

        opponentGroup.add(opponent);

        playerMap = new Map<String, Character>();

        playerGroup = new FlxTypedContainer<Character>();

        add(playerGroup);

        player = new Character(0.0, 0.0, Paths.json("assets/characters/BOYFRIEND"), PLAYABLE);

        player.setPosition((FlxG.width - player.width) - 15.0, 385.0);

        playerMap[player.simple.name] = player;

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

        ratings =
        [
            {name: "Epic!", color: FlxColor.MAGENTA, timing: 15.0, bonus: 1.0, score: 500, hits: 0},

            {name: "Sick!", color: FlxColor.CYAN, timing: 45.0, bonus: 1.0, score: 350, hits: 0},

            {name: "Good", color: FlxColor.GREEN, timing: 75.0, bonus: 0.65, score: 250, hits: 0},

            {name: "Bad", color: FlxColor.RED, timing: 125.0, bonus: 0.35, score: 150, hits: 0},

            {name: "Shit", color: FlxColor.subtract(FlxColor.RED, FlxColor.BROWN), timing: Math.POSITIVE_INFINITY, bonus: 0.0, score: 50, hits: 0}
        ];

        strumlines = new FlxTypedContainer<Strumline>();

        strumlines.camera = hudCamera;

        add(strumlines);
        
        opponentStrumline = new Strumline();

        opponentStrumline.lane = 0;
        
        opponentStrumline.spacing = 116.0;

        opponentStrumline.inputs = ["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"];

        opponentStrumline.artificial = true;

        opponentStrumline.noteHit.add(opponentNoteHit);

        opponentStrumline.noteHit.add(noteHit);

        opponentStrumline.noteMiss.add(opponentNoteMiss);

        opponentStrumline.noteMiss.add(noteMiss);

        opponentStrumline.setPosition(45.0, downScroll ? (FlxG.height - opponentStrumline.height) - 15.0 : 15.0);

        strumlines.add(opponentStrumline);
        
        playerStrumline = new Strumline();

        playerStrumline.lane = 1;

        playerStrumline.spacing = 116.0;

        playerStrumline.inputs = ["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"];
        
        playerStrumline.noteHit.add(playerNoteHit);

        playerStrumline.noteHit.add(noteHit);

        playerStrumline.noteMiss.add(playerNoteMiss);

        playerStrumline.noteMiss.add(noteMiss);

        playerStrumline.setPosition((FlxG.width - playerStrumline.width) - 45.0, downScroll ? (FlxG.height - playerStrumline.height) - 15.0 : 15.0);

        strumlines.add(playerStrumline);

        loadSong("Test");

        countdownStarted = false;

        startCountdown();

        songStarted = false;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        gameCamera.zoom = gameCameraZoom + (gameCamera.zoom - gameCameraZoom) * Math.pow(2.0, -elapsed / 0.05);

        hudCamera.zoom = hudCameraZoom + (hudCamera.zoom - hudCameraZoom) * Math.pow(2.0, -elapsed / 0.05);

        for (i in 0 ... strumlines.members.length)
        {
            var strumLine:Strumline = strumlines.members[i];

            for (i in 0 ... notes.members.length)
            {
                var note:Note = notes.members[i];

                if (note.exists && Conductor.current.time > note.time + 166.6 && strumLine.lane == note.lane)
                    strumLine.noteMiss.dispatch(note);
            }

            if (strumLine.artificial)
            {
                for (i in 0 ... notes.members.length)
                {
                    var note:Note = notes.members[i];

                    if (note.exists && Conductor.current.time >= note.time && strumLine.lane == note.lane)
                        strumLine.noteHit.dispatch(note);
                }

                continue;
            }

            for (j in 0 ... strumLine.inputs.length)
            {
                if (Inputs.checkStatus(strumLine.inputs[j], JUST_PRESSED))
                {
                    var strum:Strum = strumLine.members[j];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Press");

                    var note:Note = notes.getFirst((n:Note) -> n.exists && Math.abs(Conductor.current.time - n.time) <= 166.6 && strum.direction == n.direction && strumLine.lane == n.lane && n.length <= 0.0);

                    if (note != null)
                        strumLine.noteHit.dispatch(note);
                }

                if (Inputs.checkStatus(strumLine.inputs[j], PRESSED))
                {
                    var strum:Strum = strumLine.members[j];

                    for (i in 0 ... notes.members.length)
                    {
                        var note:Note = notes.members[i];

                        if (note.exists && Conductor.current.time >= note.time && strum.direction == note.direction && strumLine.lane == note.lane && note.length > 0.0)
                            strumLine.noteHit.dispatch(note);
                    }
                }

                if (Inputs.checkStatus(strumLine.inputs[j], JUST_RELEASED))
                {
                    var strum:Strum = strumLine.members[j];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Static");
                }
            }
        }

        for (i in 0 ... notes.members.length)
        {
            var note:Note = notes.members[i];

            var strumLine:Strumline = strumlines.getFirst((s:Strumline) -> note.lane == s.lane);

            var strum:Strum = strumLine.group.getFirst((s:Strum) -> note.direction == s.direction);

            note.setPosition(strum.getMidpoint().x - note.width * 0.5, strum.y - (Conductor.current.time - note.time) * songSpeed * note.speed * 0.45 * (downScroll ? -1.0 : 1.0));
        }

        while (noteIndex < song.notes.length)
        {
            var n:StandardNote = song.notes[noteIndex];

            if (n.time > Conductor.current.time + FlxG.height / 0.45 / songSpeed / n.speed)
                break;

            for (i in 0 ... notes.members.length)
            {
                var note:Note = notes.members[i];

                if (n.time == note.time && n.direction == note.direction && n.lane == note.lane)
                {
                    note.kill();

                    var j:Int = note.children.length - 1;

                    while (j >= 0.0)
                    {
                        var sustain:Note = note.children[j];

                        note.children.remove(sustain);

                        sustain.kill();

                        j--;
                    }
                }
            }

            var note:Note = notes.recycle(Note, () -> new Note());

            note.time = n.time;

            note.speed = n.speed;

            note.direction = n.direction;

            note.lane = n.lane;

            note.length = 0.0;

            note.animation.play(Note.directions[note.direction].toLowerCase());

            note.scale.set(0.685, 0.685);

            note.updateHitbox();

            note.setPosition((FlxG.width - note.width) * 0.5, (FlxG.height - note.height) * 5);

            notes.add(note);

            for (i in 0 ... Math.round(n.length / (((60 / Conductor.current.timeChanges[0].tempo) * 1000.0) * 0.25)))
            {
                var sustain:Note = notes.recycle(Note, () -> new Note());

                sustain.time = note.time + ((((60 / Conductor.current.timeChanges[0].tempo) * 1000.0) * 0.25) * (i + 1));

                sustain.speed = note.speed;

                sustain.direction = note.direction;
                
                sustain.lane = note.lane;

                sustain.length = (60 / Conductor.current.timeChanges[0].tempo) * 1000.0;

                note.children.push(sustain);

                sustain.parent = note;

                sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldPiece");

                if (i >= Math.round(n.length / (((60 / Conductor.current.timeChanges[0].tempo) * 1000.0) * 0.25)) - 1)
                {
                    sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldTail");
                }

                sustain.flipY = downScroll;

                sustain.scale.set(0.685, 0.685);

                sustain.updateHitbox();

                sustain.setPosition((FlxG.width - sustain.width) * 0.5, (FlxG.height - sustain.height) * 5);

                notes.add(sustain);
            }

            noteIndex++;

            strumlines.getFirst((s:Strumline) -> note.lane == s.lane).noteSpawn.dispatch(note);

            ArraySort.sort(notes.members, (a:Note, b:Note) -> Std.int(a.time - b.time));
        }

        while (eventIndex < song.events.length)
        {
            var e:StandardEvent = song.events[eventIndex];

            if (Conductor.current.time < e.time)
                break;

            switch (e.name:String)
            {
                case "Camera Follow":
                    CameraFollowEvent.dispatch(FlxPoint.get(e.value.x, e.value.y), e.value.duration, e.value.ease);

                case "Speed Change":
                    SpeedChangeEvent.dispatch(e.value.speed, e.value.duration);
            }

            eventIndex++;
        }

        if (countdownStarted)
        {
            Conductor.current.time += 1000.0 * elapsed;

            if (Conductor.current.time >= 0.0 && !songStarted)
                startSong();
        }

        if (songStarted)
        {
            Conductor.current.guage();
            
            if (Math.abs(Conductor.current.time - instrumental.time) > 25.0)
                instrumental.time = Conductor.current.time;

            if (mainVocals != null)
                if (Math.abs(instrumental.time - mainVocals.time) > 5.0)
                    mainVocals.time = instrumental.time;

            if (opponentVocals != null)
                if (Math.abs(instrumental.time - opponentVocals.time) > 5.0)
                    opponentVocals.time = instrumental.time;

            if (playerVocals != null)
                if (Math.abs(instrumental.time - playerVocals.time) > 5.0)
                    playerVocals.time = instrumental.time;
        }

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.resetState();
    }

    override function stepHit():Void
    {
        super.stepHit();
    }

    override function beatHit():Void
    {
        super.beatHit();

        FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/metronome")), 0.5);
    }

    override function sectionHit():Void
    {
        super.sectionHit();

        gameCamera.zoom += 0.035;

        hudCamera.zoom += 0.015;
    }

    public function loadSong(name:String):Void
    {
        song = Song.fromStandard(StandardFormat.build(Paths.json('assets/data/${name}/chart')));

        ArraySort.sort(song.notes, (a:StandardNote, b:StandardNote) -> Std.int(a.time - b.time));

        ArraySort.sort(song.events, (a:StandardEvent, b:StandardEvent) -> Std.int(a.time - b.time));

        ArraySort.sort(song.timeChanges, (a:StandardTimeChange, b:StandardTimeChange) -> Std.int(a.time - b.time));

        Conductor.current.tempo = song.tempo;

        Conductor.current.timeChange = {tempo: Conductor.current.tempo, time: 0.0, step: 0.0, beat: 0.0, section: 0.0};

        Conductor.current.timeChanges = song.timeChanges;

        Conductor.current.time = -Conductor.current.crotchet * 5.0;

        songSpeed = song.speed;

        notes = new FlxTypedContainer<Note>();

        notes.camera = hudCamera;

        add(notes);

        noteIndex = 0;

        eventIndex = 0;

        instrumental = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Instrumental')));

        instrumental.onComplete = endSong;

        if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Main')))
            mainVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Main')));

        if (mainVocals == null)
        {
            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Opponent')))
                opponentVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Opponent')));

            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Player')))
                playerVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Player')));
        }
    }

    public function startCountdown(?finishCallback:()->Void):Void
    {
        var countdownSprite:FlxSprite = new FlxSprite().loadGraphic(AssetMan.graphic(Paths.png("assets/images/countdown")), true, 1000, 500);

        countdownSprite.animation.add("0", [0], 0.0, false);

        countdownSprite.animation.add("1", [1], 0.0, false);

        countdownSprite.animation.add("2", [2], 0.0, false);

        countdownSprite.camera = hudCamera;

        countdownSprite.alpha = 0.0;

        countdownSprite.scale.set(0.85, 0.85);

        countdownSprite.updateHitbox();

        countdownSprite.screenCenter();

        add(countdownSprite);

        new FlxTimer().start(Conductor.current.crotchet * 0.001, function(timer):Void
        {
            switch (timer.elapsedLoops:Int)
            {
                case 1:
                    FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/three")), 0.65);

                case 2:
                {
                    countdownSprite.alpha = 1;

                    countdownSprite.animation.play("0");

                    FlxTween.cancelTweensOf(countdownSprite, ["alpha"]);

                    FlxTween.tween(countdownSprite, {alpha: 0.0}, Conductor.current.crotchet * 0.001, {ease: FlxEase.circInOut});

                    FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/two")), 0.65);
                }

                case 3:
                {
                    countdownSprite.alpha = 1;

                    countdownSprite.animation.play("1");

                    FlxTween.cancelTweensOf(countdownSprite, ["alpha"]);

                    FlxTween.tween(countdownSprite, {alpha: 0.0}, Conductor.current.crotchet * 0.001, {ease: FlxEase.circInOut});

                    FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/one")), 0.65);
                }

                case 4:
                {
                    countdownSprite.alpha = 1;

                    countdownSprite.animation.play("2");

                    FlxTween.cancelTweensOf(countdownSprite, ["alpha"]);

                    FlxTween.tween(countdownSprite, {alpha: 0.0}, Conductor.current.crotchet * 0.001,
                    {
                        ease: FlxEase.circInOut,

                        onComplete: function(tween:FlxTween):Void
                        {
                            remove(countdownSprite, true);

                            countdownSprite.destroy();
                        }
                    });

                    FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/go")), 0.65);
                }

                case 5:
                    if (finishCallback != null)
                        finishCallback();
            }

            if (timer.elapsedLoops < 5.0)
            {
                for (i in 0 ... spectatorGroup.members.length)
                {
                    var character:Character = spectatorGroup.members[i];

                    if (timer.elapsedLoops % character.danceInterval == 0.0)
                        character.dance();
                }

                for (i in 0 ... opponentGroup.members.length)
                {
                    var character:Character = opponentGroup.members[i];

                    if (timer.elapsedLoops % character.danceInterval == 0.0)
                        character.dance();
                }

                for (i in 0 ... playerGroup.members.length)
                {
                    var character:Character = playerGroup.members[i];

                    if (timer.elapsedLoops % character.danceInterval == 0.0)
                        character.dance();
                }
            }
        }, 5);

        countdownStarted = true;
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
        if (mainVocals != null)
            mainVocals.stop();

        if (opponentVocals != null)
            opponentVocals.stop();

        if (playerVocals != null)
            playerVocals.stop();

        FlxG.resetState();
    }

    public function opponentNoteHit(note:Note):Void
    {
        if (opponentVocals != null)
            opponentVocals.volume = 1.0;

        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}'))
                character.animation.play('Sing${Note.directions[note.direction]}', true);
        }
    }

    public function opponentNoteMiss(note:Note):Void
    {
        if (opponentVocals != null)
            opponentVocals.volume = 0.0;

        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}MISS'))
                character.animation.play('Sing${Note.directions[note.direction]}MISS', true);
        }
    }

    public function playerNoteHit(note:Note):Void
    {
        if (playerVocals != null)
            playerVocals.volume = 1.0;

        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}'))
                character.animation.play('Sing${Note.directions[note.direction]}', true);
        }
    }

    public function playerNoteMiss(note:Note):Void
    {
        if (playerVocals != null)
            playerVocals.volume = 0.0;

        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}MISS'))
                character.animation.play('Sing${Note.directions[note.direction]}MISS', true);
        }
    }

    public function noteHit(note:Note):Void
    {
        if (mainVocals != null)
            mainVocals.volume = 1.0;

        var strumLine:Strumline = strumlines.getFirst((s:Strumline) -> note.lane == s.lane);

        var strum:Strum = strumLine.group.getFirst((s:Strum) -> note.direction == s.direction);

        strum.confirmCount = 0.0;
        
        strum.animation.play(Strum.directions[note.direction].toLowerCase() + "Confirm", true);

        if (!strumLine.artificial)
        {
            if (note.length == 0.0)
            {
                score += Rating.guage(ratings, Math.abs(Conductor.current.time - note.time)).score;

                hits++;

                bonus += Rating.guage(ratings, Math.abs(Conductor.current.time - note.time)).bonus;
                
                combo++;

                scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

                health = FlxMath.bound(health + 1.15, 0.0, 100.0);

                FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/snap")), 0.75);
            }
        }

        note.kill();
    }

    public function noteMiss(note:Note):Void
    {
        if (mainVocals != null)
            mainVocals.volume = 0.0;

        var strumLine:Strumline = strumlines.getFirst((s:Strumline) -> note.lane == s.lane);

        if (!strumLine.artificial)
        {
            score -= 650;

            misses++;

            combo = 0;

            scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

            health = FlxMath.bound(health - 2.375, 0.0, 100.0);
        }

        note.kill();
    }
}