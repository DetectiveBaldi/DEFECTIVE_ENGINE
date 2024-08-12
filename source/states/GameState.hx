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

import tools.formats.charts.BasicFormat;
import tools.formats.charts.FunkFormat;
import tools.formats.charts.PsychFormat;

import tools.formats.charts.BasicFormat.BasicEvent;
import tools.formats.charts.BasicFormat.BasicNote;
import tools.formats.charts.BasicFormat.BasicTimeChange;

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

    public var pending(default, null):{notes:Array<Note>};

    public var notes(default, null):FlxTypedContainer<Note>;

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

        pending = {notes: new Array<Note>()};

        notes = new FlxTypedContainer<Note>();

        notes.camera = hudCamera;

        add(notes);

        loadSong("Test");

        stage = new Week1();

        for (i in 0 ... stage.members.length)
        {
            add(stage.members[i]);
        }

        spectatorMap = new Map<String, Character>();

        spectatorGroup = new FlxTypedContainer<Character>();

        add(spectatorGroup);

        spectator = new Character(0.0, 0.0, "assets/characters/GIRLFRIEND.json", ARTIFICIAL);

        spectator.skipSing = true;

        spectator.setPosition((FlxG.width - spectator.width) * 0.5, 35.0);

        spectatorMap[spectator.simple.name] = spectator;

        spectatorGroup.add(spectator);

        opponentMap = new Map<String, Character>();

        opponentGroup = new FlxTypedContainer<Character>();

        add(opponentGroup);

        opponent = new Character(0.0, 0.0, "assets/characters/BOYFRIEND_PIXEL.json", ARTIFICIAL);

        opponent.setPosition(15.0, 50.0);

        opponentMap[opponent.simple.name] = opponent;

        opponentGroup.add(opponent);

        playerMap = new Map<String, Character>();

        playerGroup = new FlxTypedContainer<Character>();

        add(playerGroup);

        player = new Character(0.0, 0.0, "assets/characters/BOYFRIEND.json", PLAYABLE);

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

            var note:Note = notes.members.filter((n:Note) -> Conductor.current.time - n.time > 166.6 && strumLine.lane == n.lane)[0];

            if (note != null)
            {
                strumLine.noteMiss.dispatch(note);
            }

            if (strumLine.artificial)
            {
                var note:Note = notes.members.filter((n:Note) -> Conductor.current.time >= n.time && strumLine.lane == n.lane)[0];

                if (note != null)
                {
                    var strum:Strum = strumLine.members.filter((s:Strum) -> note.direction == s.direction)[0];

                    strum.confirmCount = 0.0;

                    strum.animation.play(Strum.directions[note.direction].toLowerCase() + "Confirm", true);

                    strumLine.noteHit.dispatch(note);
                }

                continue;
            }

            for (j in 0 ... binds.length)
            {
                if (Binds.checkStatus(binds[j], JUST_PRESSED))
                {
                    var strum:Strum = strumLine.members[j];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Press");

                    var note:Note = notes.members.filter((n:Note) -> Math.abs(Conductor.current.time - n.time) <= 166.6 && strum.direction == n.direction && strumLine.lane == n.lane && n.length <= 0.0)[0];

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

                    var note:Note = notes.members.filter((n:Note) -> Conductor.current.time >= n.time && strum.direction == n.direction && strumLine.lane == n.lane && n.length > 0.0)[0];

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

            var strumLine:StrumLine = strumLines.members.filter((s:StrumLine) -> note.lane == s.lane)[0];

            var strum:Strum = strumLine.members.filter((s:Strum) -> note.direction == s.direction)[0];

            note.setPosition(strum.getMidpoint().x - note.width * 0.5, strum.y - ((((Conductor.current.time - note.time) * song.speed) * note.speed) * (downScroll ? -1.0 : 1.0)));
        }

        if (pending.notes.length > 0.0)
        {
            var note:Note = pending.notes[0];

            if (note.time - Conductor.current.time <= ((Conductor.current.crotchet * 5.0) / song.speed) / note.speed)
            {
                notes.add(note);

                var strumLine:StrumLine = strumLines.members.filter((s:StrumLine) -> note.lane == s.lane)[0];

                strumLine.noteSpawn.dispatch(note);

                pending.notes.shift();
            }
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

        var metronome:FlxSound = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/metronome"), 0.75).play();
    }

    override function sectionHit():Void
    {
        super.sectionHit();

        gameCamera.zoom += 0.035;

        hudCamera.zoom += 0.015;
    }

    public function loadSong(name:String):Void
    {
        song = Song.fromBasic(BasicFormat.build('assets/data/${name}/chart.json'));

        ArraySort.sort(song.notes, (a:BasicNote, b:BasicNote) -> Std.int(a.time - b.time));

        ArraySort.sort(song.events, (a:BasicEvent, b:BasicEvent) -> Std.int(a.time - b.time));

        ArraySort.sort(song.timeChanges, (a:BasicTimeChange, b:BasicTimeChange) -> Std.int(a.time - b.time));

        Conductor.current.tempo = song.tempo;

        Conductor.current.timeChange = {tempo: Conductor.current.tempo, time: 0.0, step: 0.0, beat: 0.0, section: 0.0};

        Conductor.current.timeChanges = song.timeChanges;

        Conductor.current.time = -Conductor.current.crotchet * 5.0;

        for (i in 0 ... song.notes.length)
        {
            var n:BasicNote = song.notes[i];

            if (pending.notes.length > 0.0)
            {
                var j:Int = pending.notes.length - 1;

                while (j >= 0.0)
                {
                    var note:Note = pending.notes[j];

                    if (n.time == note.time && n.direction == note.direction && n.lane == note.lane)
                    {
                        pending.notes.splice(j, 1);

                        note.destroy();

                        var k:Int = note.tails.length - 1;

                        while (k >= 0.0)
                        {
                            var sustain:Note = note.tails[k];

                            note.tails.splice(k, 1);

                            sustain.destroy();

                            k--;
                        }
                    }

                    j--;
                }
            }

            var note:Note = new Note();

            note.time = n.time;

            note.speed = n.speed;

            note.direction = n.direction;

            note.lane = n.lane;

            note.length = 0.0;

            note.animation.play(Note.directions[note.direction].toLowerCase());

            note.scale.set(0.725, 0.725);

            note.updateHitbox();

            note.setPosition((FlxG.width - note.width) * 0.5, (FlxG.height - note.height) * 5);

            pending.notes.push(note);

            if (n.length > 0)
            {
                for (j in 0 ... Math.round(n.length / (Conductor.current.crotchet * 0.25)))
                {
                    var sustain:Note = new Note();

                    sustain.time = note.time + ((Conductor.current.crotchet * 0.25) * (j + 1));

                    sustain.speed = note.speed;

                    sustain.direction = note.direction;

                    sustain.lane = note.lane;

                    sustain.length = Conductor.current.crotchet * 0.25;

                    note.tails.push(sustain);

                    sustain.parent = note;

                    sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldPiece");

                    if (j >= Math.round(n.length / (Conductor.current.crotchet * 0.25)) - 1)
                    {
                        sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldTail");
                    }

                    sustain.flipX = sustain.flipX;

                    sustain.flipY = downScroll;

                    sustain.scale.set(0.725, 0.725);

                    sustain.updateHitbox();

                    sustain.setPosition((FlxG.width - sustain.width) * 0.5, (FlxG.height - sustain.height) * 5);

                    pending.notes.push(sustain);
                }
            }
        }

        ArraySort.sort(pending.notes, (a:Note, b:Note) -> Std.int(a.time - b.time));

        instrumental = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Instrumental'));

        instrumental.onComplete = endSong;

        if (#if html5 openfl.utils.Assets.exists(Paths.mp3('assets/music/${name}/Vocals-Main')) #else sys.FileSystem.exists(Paths.ogg('assets/music/${name}/Vocals-Main')) #end)
        {
            mainVocals = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Main'));
        }

        if (mainVocals == null)
        {
            if (#if html5 openfl.utils.Assets.exists(Paths.mp3('assets/music/${name}/Vocals-Opponent')) #else sys.FileSystem.exists(Paths.ogg('assets/music/${name}/Vocals-Opponent')) #end)
            {
                opponentVocals = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Opponent'));
            }

            if (#if html5 openfl.utils.Assets.exists(Paths.mp3('assets/music/${name}/Vocals-Player')) #else sys.FileSystem.exists(Paths.ogg('assets/music/${name}/Vocals-Player')) #end)
            {
                playerVocals = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/music/${name}/Vocals-Player'));
            }
        }
    }

    public function startCountdown(?finishCallback:()->Void):Void
    {
        var countdownSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.png("assets/images/countdown"), true, 1000, 500);

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
                    var three:FlxSound = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/three"), 0.65);

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

                    var two:FlxSound = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/two"), 0.65);

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

                    var one:FlxSound = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/one"), 0.65);

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

                    var go:FlxSound = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/go"), 0.65);

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

        var strumLine:StrumLine = strumLines.members.filter((s:StrumLine) -> note.lane == s.lane)[0];

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
                
                ratingPopUp(Math.abs(Conductor.current.time - note.time));

                var snap:FlxSound = FlxG.sound.load(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/snap"), 0.75).play();
            }
        }

        notes.remove(note, true);

        note.destroy();
    }

    public function noteMiss(note:Note):Void
    {
        if (mainVocals != null)
        {
            mainVocals.volume = 0.0;
        }

        var strumLine:StrumLine = strumLines.members.filter((s:StrumLine) -> note.lane == s.lane)[0];

        if (!strumLine.artificial)
        {
            score -= 650;

            misses++;

            combo = 0;

            scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

            scoreTxt.x = (FlxG.width - scoreTxt.width) * 0.5;

            var ratingTxt:FlxText = ratingPopUp(Math.abs(Conductor.current.time - note.time));

            ratingTxt.text = "Miss...";

            ratingTxt.color = FlxColor.subtract(FlxColor.RED, FlxColor.BROWN);

            ratingTxt.screenCenter();
        }

        notes.remove(note, true);

        note.destroy();
    }

    public function ratingPopUp(time:Float):FlxText
    {
        var rating:Rating = Rating.guage(ratings, time);

        var output:FlxText = new FlxText(0.0, 0.0, 0.0, "", 28);

        output.camera = hudCamera;

        output.moves = true;

        output.antialiasing = false;

        output.text = '${rating.name}';

        output.alignment = CENTER;

        output.borderStyle = SHADOW;

        output.borderColor = FlxColor.BLACK;

        output.borderSize = 3.65;

        output.color = rating.color;

        output.velocity.set(FlxG.random.bool() ? FlxG.random.int(0, 75) : FlxG.random.int(-0, -75), FlxG.random.bool() ? FlxG.random.int(0, 10) : FlxG.random.int(-0, -10));

        output.acceleration.set(FlxG.random.bool() ? FlxG.random.int(0, 350) : FlxG.random.int(-0, -350), FlxG.random.bool() ? FlxG.random.int(0, 250) : FlxG.random.int(-0, -250));

        output.screenCenter();

        add(output);

        FlxTween.tween(output, {alpha: 0.0}, (Conductor.current.crotchet * 4.0) * 0.001,
        {
            onComplete: function(tween:FlxTween):Void
            {
                output.destroy();
            }
        });

        return output;
    }
}