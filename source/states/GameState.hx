package states;

import haxe.ds.ArraySort;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import core.AssetManager;
import core.Binds;
import core.Conductor;
import core.Paths;
import core.Rating;
import core.Song;

import extendable.State;

import objects.Character;
import objects.Note;
import objects.Strum;
import objects.StrumLine;

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

    public var gameCameraZoom(default, null):Float;

    public var hudCamera(default, null):FlxCamera;

    public var hudCameraZoom(default, null):Float;

    public var binds(default, null):Array<String>;

    public var ratings(default, null):Array<Rating>;

    public var downScroll(default, null):Bool;

    public var scoreTxt(default, null):FlxText;

    public var score(default, null):Int;

    public var hits(default, null):Int;

    public var misses(default, null):Int;

    public var bonus(default, null):Float;

    public var combo(default, null):Int;

    public var strumLines(default, null):FlxTypedContainer<StrumLine>;

    public var opponentStrums(default, null):StrumLine;

    public var playerStrums(default, null):StrumLine;

    public var notes(default, null):FlxTypedContainer<Note>;

    public var noteIndex(default, null):Int;

    public var song(default, null):Song;

    public var instrumental(default, null):FlxSound;

    public var mainVocals(default, null):FlxSound;

    public var opponentVocals(default, null):FlxSound;

    public var playerVocals(default, null):FlxSound;

    public var stage(default, null):Stage<FlxBasic>;

    public var spectatorMap(default, null):Map<String, Character>;

    public var spectatorGroup(default, null):FlxTypedContainer<Character>;

    public var spectator(default, null):Character;

    public var opponentMap(default, null):Map<String, Character>;

    public var opponentGroup(default, null):FlxTypedContainer<Character>;

    public var opponent(default, null):Character;

    public var playerMap(default, null):Map<String, Character>;

    public var playerGroup(default, null):FlxTypedContainer<Character>;

    public var player(default, null):Character;

    public var countdownStarted(default, null):Bool;

    public var songStarted(default, null):Bool;

    public function new():Void
    {
        super();
    }

    override function create():Void
    {
        super.create();

        gameCamera.zoom = 0.75;

        gameCameraZoom = gameCamera.zoom;

        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        hudCameraZoom = hudCamera.zoom;

        binds = ["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"];

        ratings =
        [
            {name: "Epic!", color: FlxColor.MAGENTA, timing: 15.0, bonus: 1.0, score: 500, hits: 0},

            {name: "Sick!", color: FlxColor.CYAN, timing: 45.0, bonus: 1.0, score: 350, hits: 0},

            {name: "Good", color: FlxColor.GREEN, timing: 75.0, bonus: 0.65, score: 250, hits: 0},

            {name: "Bad", color: FlxColor.RED, timing: 125.0, bonus: 0.35, score: 150, hits: 0},

            {name: "Shit", color: FlxColor.subtract(FlxColor.RED, FlxColor.BROWN), timing: Math.POSITIVE_INFINITY, bonus: 0.0, score: 50, hits: 0}
        ];

        downScroll = false;

        scoreTxt = new FlxText(0.0, 0.0, 0.0, "", 24);

        scoreTxt.camera = hudCamera;

        scoreTxt.antialiasing = false;

        scoreTxt.text = 'Score: 0 | Misses: 0 | Accuracy: 0%';

        scoreTxt.alignment = CENTER;

        scoreTxt.borderStyle = SHADOW;

        scoreTxt.borderColor = FlxColor.BLACK;

        scoreTxt.borderSize = 5.0;

        scoreTxt.setPosition((FlxG.width - scoreTxt.width) * 0.5, downScroll ? 35.0 : (FlxG.height - scoreTxt.height) - 35.0);

        add(scoreTxt);

        score = 0;

        hits = 0;

        misses = 0;

        bonus = 0.0;

        combo = 0;

        strumLines = new FlxTypedContainer<StrumLine>();

        strumLines.camera = hudCamera;

        add(strumLines);
        
        opponentStrums = new StrumLine();

        opponentStrums.lane = 0;

        opponentStrums.noteHit.add(opponentNoteHit);

        opponentStrums.noteHit.add(noteHit);

        opponentStrums.noteMiss.add(opponentNoteMiss);

        opponentStrums.noteMiss.add(noteMiss);

        opponentStrums.artificial = true;

        opponentStrums.setPosition(45.0, downScroll ? (FlxG.height - opponentStrums.height) - 15.0 : 15.0);

        strumLines.add(opponentStrums);
        
        playerStrums = new StrumLine();

        playerStrums.lane = 1;

        playerStrums.noteHit.add(playerNoteHit);

        playerStrums.noteHit.add(noteHit);

        playerStrums.noteMiss.add(playerNoteMiss);

        playerStrums.noteMiss.add(noteMiss);

        playerStrums.setPosition((FlxG.width - playerStrums.width) - 45.0, downScroll ? (FlxG.height - playerStrums.height) - 15.0 : 15.0);

        strumLines.add(playerStrums);

        notes = new FlxTypedContainer<Note>();

        notes.camera = hudCamera;

        add(notes);

        noteIndex = 0;

        loadSong("Test");

        stage = new Week1();

        for (i in 0 ... stage.members.length)
        {
            add(stage.members[i]);
        }

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

        countdownStarted = false;

        startCountdown();

        songStarted = false;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        gameCamera.zoom = gameCameraZoom + (gameCamera.zoom - gameCameraZoom) * Math.pow(2.0, -elapsed / 0.05);

        hudCamera.zoom = hudCameraZoom + (hudCamera.zoom - hudCameraZoom) * Math.pow(2.0, -elapsed / 0.05);

        if (countdownStarted)
        {
            Conductor.current.time += 1000.0 * elapsed;

            if (Conductor.current.time >= 0.0 && !songStarted)
            {
                startSong();
            }
        }

        if (songStarted)
        {
            Conductor.current.guage();
            
            if (Math.abs(Conductor.current.time - instrumental.time) > 25.0)
            {
                instrumental.time = Conductor.current.time;
            }

            if (mainVocals != null && Math.abs(instrumental.time - mainVocals.time) > 5.0)
            {
                mainVocals.time = instrumental.time;
            }

            if (opponentVocals != null && Math.abs(instrumental.time - opponentVocals.time) > 5.0)
            {
                opponentVocals.time = instrumental.time;
            }

            if (playerVocals != null && Math.abs(instrumental.time - playerVocals.time) > 5.0)
            {
                playerVocals.time = instrumental.time;
            }
        }

        for (i in 0 ... strumLines.members.length)
        {
            var strumLine:StrumLine = strumLines.members[i];

            for (i in 0 ... notes.members.length)
            {
                var note:Note = notes.members[i];

                if (note.alive && Conductor.current.time - note.time > 166.6 && strumLine.lane == note.lane)
                {
                    strumLine.noteMiss.dispatch(note);
                }
            }

            if (strumLine.artificial)
            {
                for (i in 0 ... notes.members.length)
                {
                    var note:Note = notes.members[i];

                    if (note.alive && Conductor.current.time >= note.time && strumLine.lane == note.lane)
                    {
                        var strum:Strum = strumLine.group.getFirst((s:Strum) -> note.direction == s.direction);

                        strum.confirmCount = 0.0;

                        strum.animation.play(Strum.directions[note.direction].toLowerCase() + "Confirm", true);

                        strumLine.noteHit.dispatch(note);
                    }
                }

                continue;
            }

            for (j in 0 ... binds.length)
            {
                if (Binds.checkStatus(binds[j], JUST_PRESSED))
                {
                    var strum:Strum = strumLine.members[j];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Press");

                    var note:Note = notes.getFirst((n:Note) -> n.alive && Math.abs(Conductor.current.time - n.time) <= 166.6 && strum.direction == n.direction && strumLine.lane == n.lane && n.length <= 0.0);

                    if (note != null)
                    {
                        strum.confirmCount = 0.0;

                        strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Confirm");

                        strumLine.noteHit.dispatch(note);
                    }
                }

                if (Binds.checkStatus(binds[j], PRESSED))
                {
                    var strum:Strum = strumLine.members[j];

                    var note:Note = notes.getFirst((n:Note) -> n.alive && Conductor.current.time >= n.time && strum.direction == n.direction && strumLine.lane == n.lane && n.length > 0.0);

                    if (note != null)
                    {
                        strum.confirmCount = 0.0;

                        strum.animation.play(Strum.directions[note.direction].toLowerCase() + "Confirm", true);

                        strumLine.noteHit.dispatch(note);
                    }
                }

                if (Binds.checkStatus(binds[j], JUST_RELEASED))
                {
                    var strum:Strum = strumLine.members[j];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Static");
                }
            }
        }

        for (i in 0 ... notes.members.length)
        {
            var note:Note = notes.members[i];

            var strumLine:StrumLine = strumLines.getFirst((s:StrumLine) -> note.lane == s.lane);

            var strum:Strum = strumLine.group.getFirst((s:Strum) -> note.direction == s.direction);

            note.setPosition(strum.getMidpoint().x - note.width * 0.5, strum.y - ((((Conductor.current.time - note.time) * song.speed) * note.speed) * (downScroll ? -1.0 : 1.0)));
        }

        while (noteIndex < song.notes.length)
        {
            var n:StandardNote = song.notes[noteIndex];

            if (n.time - Conductor.current.time > (FlxG.height / song.speed) / n.speed)
            {
                break;
            }

            if (notes.members.length > 0.0)
            {
                var i:Int = notes.members.length - 1;

                while (i >= 0.0)
                {
                    var note:Note = notes.members[i];

                    if (n.time == note.time && n.direction == note.direction && n.lane == note.lane)
                    {
                        note.kill();

                        var j:Int = note.children.length - 1;
                        
                        while (j >= 0.0)
                        {
                            var sustain:Note = note.children[j];

                            note.kill();

                            j--;
                        }
                    }

                    i--;
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

            noteIndex++;

            if (n.length > 0)
            {
                for (i in 0 ... Math.round(n.length / (Conductor.current.crotchet * 0.25)))
                {
                    var sustain:Note = notes.recycle(Note, () -> new Note());

                    sustain.time = note.time + ((Conductor.current.crotchet * 0.25) * (i + 1));

                    sustain.speed = note.speed;

                    sustain.direction = note.direction;

                    sustain.lane = note.lane;

                    sustain.length = Conductor.current.crotchet * 0.25;

                    note.children.push(sustain);

                    sustain.parent = note;

                    sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldPiece");

                    if (i >= Math.round(n.length / (Conductor.current.crotchet * 0.25)) - 1)
                    {
                        sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldTail");
                    }

                    sustain.flipX = sustain.flipX;

                    sustain.flipY = downScroll;

                    sustain.scale.set(0.685, 0.685);

                    sustain.updateHitbox();

                    sustain.setPosition((FlxG.width - sustain.width) * 0.5, (FlxG.height - sustain.height) * 5);

                    notes.add(sustain);
                }
            }

            var strumLine:StrumLine = strumLines.getFirst((s:StrumLine) -> note.lane == s.lane);

            strumLine.noteSpawn.dispatch(note);

            ArraySort.sort(notes.members, (a:Note, b:Note) -> Std.int(a.time - b.time));
        }

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.resetState();
        }
    }

    override function stepHit():Void
    {
        super.stepHit();
    }

    override function beatHit():Void
    {
        super.beatHit();

        var metronome:FlxSound = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/metronome")), 0.75).play();
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

        instrumental = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Instrumental')));

        instrumental.onComplete = endSong;

        if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Main')))
        {
            mainVocals = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Main')));
        }

        if (mainVocals == null)
        {
            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Opponent')))
            {
                opponentVocals = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Opponent')));
            }

            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Player')))
            {
                playerVocals = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Player')));
            }
        }
    }

    public function startCountdown(?finishCallback:()->Void):Void
    {
        var countdownSprite:FlxSprite = new FlxSprite().loadGraphic(AssetManager.graphic(Paths.png("assets/images/countdown")), true, 1000, 500);

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
                {
                    var three:FlxSound = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/three")), 0.65);

                    three.play();
                }

                case 2:
                {
                    countdownSprite.animation.play("0");

                    FlxTween.cancelTweensOf(countdownSprite, ["alpha"]);

                    countdownSprite.alpha = 1;

                    FlxTween.tween(countdownSprite, {alpha: 0.0}, Conductor.current.crotchet * 0.001,
                    {
                        ease: FlxEase.circInOut
                    });

                    var two:FlxSound = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/two")), 0.65);

                    two.play();
                }

                case 3:
                {
                    countdownSprite.animation.play("1");

                    FlxTween.cancelTweensOf(countdownSprite, ["alpha"]);

                    countdownSprite.alpha = 1;

                    FlxTween.tween(countdownSprite, {alpha: 0.0}, Conductor.current.crotchet * 0.001,
                    {
                        ease: FlxEase.circInOut
                    });

                    var one:FlxSound = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/one")), 0.65);

                    one.play();
                }

                case 4:
                {
                    countdownSprite.animation.play("2");

                    FlxTween.cancelTweensOf(countdownSprite, ["alpha"]);

                    countdownSprite.alpha = 1;

                    FlxTween.tween(countdownSprite, {alpha: 0.0}, Conductor.current.crotchet * 0.001,
                    {
                        ease: FlxEase.circInOut,

                        onComplete: function(tween:FlxTween):Void
                        {
                            remove(countdownSprite, true);

                            countdownSprite.destroy();
                        }
                    });

                    var go:FlxSound = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/go")), 0.65);

                    go.play();
                }

                case 5:
                {
                    if (finishCallback != null)
                    {
                        finishCallback();
                    }
                }
            }

            if (timer.elapsedLoops < 5.0)
            {
                for (i in 0 ... spectatorGroup.members.length)
                {
                    var character:Character = spectatorGroup.members[i];

                    if (timer.elapsedLoops % character.danceInterval == 0.0)
                    {
                        character.dance();
                    }
                }

                for (i in 0 ... opponentGroup.members.length)
                {
                    var character:Character = opponentGroup.members[i];

                    if (timer.elapsedLoops % character.danceInterval == 0.0)
                    {
                        character.dance();
                    }
                }

                for (i in 0 ... playerGroup.members.length)
                {
                    var character:Character = playerGroup.members[i];

                    if (timer.elapsedLoops % character.danceInterval == 0.0)
                    {
                        character.dance();
                    }
                }
            }
        }, 5);

        countdownStarted = true;
    }

    public function startSong():Void
    {
        instrumental.play();

        if (mainVocals != null)
        {
            mainVocals.play();
        }

        if (opponentVocals != null)
        {
            opponentVocals.play();
        }

        if (playerVocals != null)
        {
            playerVocals.play();
        }

        songStarted = true;
    }

    public function endSong():Void
    {
        if (mainVocals != null)
        {
            mainVocals.stop();
        }

        if (opponentVocals != null)
        {
            opponentVocals.stop();
        }

        if (playerVocals != null)
        {
            playerVocals.stop();
        }

        FlxG.resetState();
    }

    public function opponentNoteHit(note:Note):Void
    {
        if (opponentVocals != null)
        {
            opponentVocals.volume = 1.0;
        }

        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}'))
            {
                character.animation.play('Sing${Note.directions[note.direction]}', true);
            }
        }
    }

    public function opponentNoteMiss(note:Note):Void
    {
        if (opponentVocals != null)
        {
            opponentVocals.volume = 0.0;
        }

        for (i in 0 ... opponentGroup.members.length)
        {
            var character:Character = opponentGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}MISS'))
            {
                character.animation.play('Sing${Note.directions[note.direction]}MISS', true);
            }
        }
    }

    public function playerNoteHit(note:Note):Void
    {
        if (playerVocals != null)
        {
            playerVocals.volume = 1.0;
        }

        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}'))
            {
                character.animation.play('Sing${Note.directions[note.direction]}', true);
            }
        }
    }

    public function playerNoteMiss(note:Note):Void
    {
        if (playerVocals != null)
        {
            playerVocals.volume = 0.0;
        }

        for (i in 0 ... playerGroup.members.length)
        {
            var character:Character = playerGroup.members[i];

            character.singCount = 0.0;

            if (character.animation.exists('Sing${Note.directions[note.direction]}MISS'))
            {
                character.animation.play('Sing${Note.directions[note.direction]}MISS', true);
            }
        }
    }

    public function noteHit(note:Note):Void
    {
        if (mainVocals != null)
        {
            mainVocals.volume = 1.0;
        }

        var strumLine:StrumLine = strumLines.getFirst((s:StrumLine) -> note.lane == s.lane);

        if (!strumLine.artificial)
        {
            if (note.length == 0.0)
            {
                score += Rating.guage(ratings, Math.abs(Conductor.current.time - note.time)).score;

                hits++;

                bonus += Rating.guage(ratings, Math.abs(Conductor.current.time - note.time)).bonus;
                
                combo++;

                scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

                scoreTxt.x = (FlxG.width - scoreTxt.width) * 0.5;

                var snap:FlxSound = FlxG.sound.load(AssetManager.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/snap")), 0.75).play();
            }
        }

        note.kill();
    }

    public function noteMiss(note:Note):Void
    {
        if (mainVocals != null)
        {
            mainVocals.volume = 0.0;
        }

        var strumLine:StrumLine = strumLines.getFirst((s:StrumLine) -> note.lane == s.lane);

        if (!strumLine.artificial)
        {
            score -= 650;

            misses++;

            combo = 0;

            scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

            scoreTxt.x = (FlxG.width - scoreTxt.width) * 0.5;
        }

        note.kill();
    }
}