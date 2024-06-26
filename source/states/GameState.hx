package states;

import haxe.ds.ArraySort;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import core.Binds;
import core.Conductor;
import core.Rating;
import core.Song;

import extendable.State;

import objects.Character;
import objects.Note;
import objects.Strum;
import objects.StrumLine;

import stages.Stage;

import tools.formats.BaseFormat;

class GameState extends State
{
    public var gameCamera(get, never):FlxCamera;

    @:noCompletion
    function get_gameCamera():FlxCamera
    {
        return FlxG.camera;
    }

    public var hudCamera(default, null):FlxCamera;

    public var binds(default, null):Array<String>;

    public var ratings(default, null):Array<Rating>;

    public var downScroll(default, set):Bool;

    @:noCompletion
    function set_downScroll(downScroll:Bool):Bool
    {
        if (scoreTxt != null)
        {
            FlxTween.cancelTweensOf(scoreTxt, ["y"]);

            FlxTween.tween(scoreTxt, {y: downScroll ? 35.0 : (FlxG.height - scoreTxt.height) - 35.0}, Conductor.current.crotchet * 0.001 ?? 1.0,
            {
                ease: FlxEase.circInOut
            });
        }

        if (opponentStrums != null)
        {
            FlxTween.cancelTweensOf(opponentStrums, ["y"]);

            FlxTween.tween(opponentStrums, {y: downScroll ? (FlxG.height - opponentStrums.height) - 15.0 : 15.0}, Conductor.current.crotchet * 0.001 ?? 1.0,
            {
                ease: FlxEase.circInOut
            });
        }

        if (playerStrums != null)
        {
            FlxTween.cancelTweensOf(playerStrums, ["y"]);

            FlxTween.tween(playerStrums, {y: downScroll ? (FlxG.height - playerStrums.height) - 15.0 : 15.0}, Conductor.current.crotchet * 0.001 ?? 1.0,
            {
                ease: FlxEase.circInOut
            });
        }

        return this.downScroll = downScroll;
    }

    public var scoreTxt(default, null):FlxBitmapText;

    public var score(default, null):Int;

    public var hits(default, null):Int;

    public var misses(default, null):Int;

    public var bonus(default, null):Float;

    public var combo(default, null):Int;

    public var strumLines(default, null):FlxTypedContainer<StrumLine>;

    public var opponentStrums(default, null):StrumLine;

    public var playerStrums(default, null):StrumLine;

    public var notes(default, null):FlxTypedContainer<Note>;

    public var song(default, null):Song;

    public var instrumental(default, null):FlxSound;

    public var mainVocals(default, null):FlxSound;

    public var opponentVocals(default, null):FlxSound;

    public var playerVocals(default, null):FlxSound;

    public var opponent(default, null):Character;

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

        gameCamera.bgColor = FlxColor.GRAY;

        gameCamera.zoom = 0.75;

        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        scoreTxt = new FlxBitmapText(0.0, 0.0, "", FlxBitmapFont.getDefaultFont());

        scoreTxt.camera = hudCamera;

        scoreTxt.antialiasing = false;

        scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: 0%';

        scoreTxt.alignment = CENTER;

        scoreTxt.borderStyle = OUTLINE;

        scoreTxt.borderColor = FlxColor.BLACK;

        scoreTxt.borderSize = 1.15;

        scoreTxt.scale.set(3.5, 3.5);

        scoreTxt.updateHitbox();

        scoreTxt.setPosition((FlxG.width - scoreTxt.width) / 2, downScroll ? 35.0 : (FlxG.height - scoreTxt.height) - 35.0);

        add(scoreTxt);

        score = 0;

        hits = 0;

        misses = 0;

        bonus = 0.0;

        combo = 0;

        binds = ["NOTE:LEFT", "NOTE:DOWN", "NOTE:UP", "NOTE:RIGHT"];

        ratings =
        [
            new Rating("Epic!", FlxColor.MAGENTA, 15.0, 1, 500, 0),

            new Rating("Sick!", FlxColor.CYAN, 45.0, 1, 350, 0),

            new Rating("Good", FlxColor.GREEN, 75.0, 0.65, 250, 0),

            new Rating("Bad", FlxColor.RED, 125.0, 0.35, 150, 0),

            new Rating("Shit", FlxColor.subtract(FlxColor.RED, FlxColor.BROWN), Math.POSITIVE_INFINITY, 0, 50, 0)
        ];

        strumLines = new FlxTypedContainer<StrumLine>();

        strumLines.camera = hudCamera;

        add(strumLines);
        
        opponentStrums = new StrumLine();

        opponentStrums.lane = 0;

        opponentStrums.artificial = true;

        opponentStrums.noteHit.add(opponentNoteHit);

        opponentStrums.noteMiss.add(opponentNoteMiss);

        opponentStrums.setPosition(45.0, downScroll ? (FlxG.height - opponentStrums.height) - 15.0 : 15.0);

        strumLines.add(opponentStrums);
        
        playerStrums = new StrumLine();

        playerStrums.lane = 1;

        playerStrums.noteHit.add(playerNoteHit);

        playerStrums.noteMiss.add(playerNoteMiss);

        playerStrums.setPosition((FlxG.width - playerStrums.width) - 45.0, downScroll ? (FlxG.height - playerStrums.height) - 15.0 : 15.0);

        strumLines.add(playerStrums);

        notes = new FlxTypedContainer<Note>();

        notes.camera = hudCamera;

        add(notes);

        loadSong("...");

        add(new Stage());

        opponent = new Character(0.0, 0.0, "assets/characters/DAD.json");

        opponent.setPosition(15.0, 50.0);

        add(opponent);

        player = new Character(0.0, 0.0, "assets/characters/BOYFRIEND.json", PLAYABLE);

        player.setPosition((FlxG.width - player.width) - 15.0, 405.0);

        add(player);

        startCountdown();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

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
            Conductor.current.calculate();
            
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
        
        gameCamera.zoom = 0.75 + (gameCamera.zoom - 0.75) * Math.pow(2.0, -elapsed / 0.05);

        hudCamera.zoom = 1.0 + (hudCamera.zoom - 1.0) * Math.pow(2.0, -elapsed / 0.05);

        for (strumLine in strumLines)
        {
            if (strumLine.artificial)
            {
                continue;
            }

            for (i in 0 ... binds.length)
            {
                if (Binds.checkStatus(binds[i], JUST_PRESSED))
                {
                    var strum:Strum = strumLine.members[i];
    
                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Press");
    
                    var note:Note = notes.members.filter(function(note:Note):Bool {return strum.direction == note.direction && note.lane == strumLine.lane && Math.abs(Conductor.current.time - note.time) <= 166.6;})[0];
    
                    if (note != null)
                    {
                        strum.confirmTimer = 0.0;
    
                        strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Confirm", true);
    
                        strumLine.noteHit.dispatch(note);
                    }
                }
    
                if (Binds.checkStatus(binds[i], JUST_RELEASED))
                {
                    var strum:Strum = strumLine.members[i];
    
                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Static");
                }
            }
        }

        while (song.notes[0] != null && song.notes[0].time - Conductor.current.time <= (Conductor.current.crotchet * 5) / song.notes[0].speed)
        {
            var note:Note = new Note();

            note.time = song.notes[0].time;

            note.speed = song.notes[0].speed;

            note.direction = song.notes[0].direction;

            note.lane = song.notes[0].lane;

            note.scale.set(0.725, 0.725);

            note.updateHitbox();

            notes.add(note);

            song.notes.shift();

            var strumLine:StrumLine = strumLines.members.filter(function(strumLine:StrumLine):Bool {return strumLine.lane == note.lane;})[0];

            strumLine.noteSpawn.dispatch(note);
        }

        for (note in notes)
        {
            var strumLine:StrumLine = strumLines.members.filter(function(strumLine:StrumLine):Bool {return strumLine.lane == note.lane;})[0];

            var strum:Strum = strumLine.members[note.direction];
            
            note.setPosition(strum.getMidpoint().x - note.width * 0.5, strum.y - ((((Conductor.current.time - note.time) * song.speed) * note.speed) * (downScroll ? -1.0 : 1.0)));

            if (strumLine.artificial)
            {
                if (Conductor.current.time - note.time >= 0.0)
                {
                    strum.confirmTimer = 0.0;

                    strum.animation.play(Strum.directions[note.direction].toLowerCase() + "Confirm", true);

                    strumLine.noteHit.dispatch(note);
                }

                continue;
            }

            if (Conductor.current.time - note.time > 166.6)
            {
                strumLine.noteMiss.dispatch(note);
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

        var metronome:FlxSound = FlxG.sound.load("assets/sounds/metronome.ogg", 0.75).play();
    }

    override function sectionHit():Void
    {
        super.sectionHit();

        gameCamera.zoom += 0.035;

        hudCamera.zoom += 0.015;
    }

    public function loadSong(name:String):Void
    {
        song = Song.fromSimple(BaseFormat.build('assets/data/${name}/chart.json'));

        ArraySort.sort(song.notes, function(a:SimpleNote, b:SimpleNote):Int {return Std.int(a.time - b.time);});

        ArraySort.sort(song.events, function(a:SimpleEvent, b:SimpleEvent):Int {return Std.int(a.time - b.time);});

        ArraySort.sort(song.timeChanges, function(a:SimpleTimeChange, b:SimpleTimeChange):Int {return Std.int(a.time - b.time);});

        Conductor.current.tempo = song.tempo;

        Conductor.current.time = -Conductor.current.crotchet * 5.0;

        Conductor.current.timeChange = {time: 0.0, tempo: song.tempo};

        Conductor.current.timeChanges = song.timeChanges;

        instrumental = FlxG.sound.load('assets/music/${name}/Instrumental.ogg');

        instrumental.onComplete = endSong;

        #if html5
            if (openfl.utils.Assets.exists('assets/music/${name}/Vocals-Main.ogg'))
        #else
            if (sys.FileSystem.exists('assets/music/${name}/Vocals-Main.ogg'))
        #end
            {
                mainVocals = FlxG.sound.load('assets/music/${name}/Vocals-Main.ogg');
            }

        if (mainVocals == null)
        {
            #if html5
                if (openfl.utils.Assets.exists('assets/music/${name}/Vocals-Opponent.ogg'))
            #else
                if (sys.FileSystem.exists('assets/music/${name}/Vocals-Opponent.ogg'))
            #end
                {
                    opponentVocals = FlxG.sound.load('assets/music/${name}/Vocals-Opponent.ogg');
                }

            #if html5
                if (openfl.utils.Assets.exists('assets/music/${name}/Vocals-Player.ogg'))
            #else
                if (sys.FileSystem.exists('assets/music/${name}/Vocals-Player.ogg'))
            #end
                {
                    playerVocals = FlxG.sound.load('assets/music/${name}/Vocals-Player.ogg');
                }
        }
    }

    public function startCountdown(?finishCallback:()->Void):Void
    {
        var countdownSprite:FlxSprite = new FlxSprite().loadGraphic("assets/images/countdown.png", true, 1000, 500);

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
            switch (timer.elapsedLoops)
            {
                case 1:
                {
                    var three:FlxSound = FlxG.sound.load("assets/sounds/three.ogg", 0.65);

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

                    var two:FlxSound = FlxG.sound.load("assets/sounds/two.ogg", 0.65);

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

                    var one:FlxSound = FlxG.sound.load("assets/sounds/one.ogg", 0.65);

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

                    var go:FlxSound = FlxG.sound.load("assets/sounds/go.ogg", 0.65);

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
            
            if (timer.elapsedLoops % 2 == 0)
            {
                opponent.dance();

                player.dance();
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
        notes.remove(note, true);

        note.destroy();

        if (mainVocals != null)
        {
            mainVocals.volume = 1.0;
        }

        if (opponentVocals != null)
        {
            opponentVocals.volume = 1.0;
        }

        opponent.singTimer = 0.0;

        opponent.animation.play('Sing${Note.directions[note.direction]}', true);
    }

    public function opponentNoteMiss(note:Note):Void
    {
        notes.remove(note, true);

        note.destroy();

        if (mainVocals != null)
        {
            mainVocals.volume = 0.0;
        }

        if (opponentVocals != null)
        {
            opponentVocals.volume = 0.0;
        }

        opponent.singTimer = 0.0;

        if (opponent.animation.exists('Sing${Note.directions[note.direction]}MISS'))
        {
            opponent.animation.play('Sing${Note.directions[note.direction]}MISS', true);
        }
    }

    public function playerNoteHit(note:Note):Void
    {
        score += Rating.calculate(ratings, Math.abs(Conductor.current.time - note.time)).score;

        hits++;

        bonus += Rating.calculate(ratings, Math.abs(Conductor.current.time - note.time)).bonus;
        
        combo++;

        scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

        scoreTxt.x = (FlxG.width - scoreTxt.width) * 0.5;

        if (!playerStrums.artificial)
        {
            displayRating(note);
        }

        notes.remove(note, true);

        note.destroy();

        if (mainVocals != null)
        {
            mainVocals.volume = 1.0;
        }

        if (playerVocals != null)
        {
            playerVocals.volume = 1.0;
        }

        player.singTimer = 0.0;

        player.animation.play('Sing${Note.directions[note.direction]}', true);

        if (!playerStrums.artificial)
        {
            var snap:FlxSound = FlxG.sound.load("assets/sounds/snap.ogg", 0.75).play();
        }
    }

    public function playerNoteMiss(note:Note):Void
    {
        score -= 75;

        misses++;

        combo = 0;

        scoreTxt.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${FlxMath.roundDecimal((bonus / (hits + misses)) * 100, 2)}%';

        scoreTxt.x = (FlxG.width - scoreTxt.width) * 0.5;

        if (!playerStrums.artificial)
        {
            var ratingTxt:FlxBitmapText = displayRating(note);

            ratingTxt.text = "Miss...";

            ratingTxt.color = FlxColor.subtract(FlxColor.RED, FlxColor.BROWN);

            ratingTxt.screenCenter();
        }

        notes.remove(note, true);

        note.destroy();

        if (mainVocals != null)
        {
            mainVocals.volume = 0.0;
        }

        if (playerVocals != null)
        {
            playerVocals.volume = 0.0;
        }

        player.singTimer = 0.0;

        if (player.animation.exists('Sing${Note.directions[note.direction]}MISS'))
        {
            player.animation.play('Sing${Note.directions[note.direction]}MISS', true);
        }
    }

    public function displayRating(note:Note):FlxBitmapText
    {
        var rating:Rating = Rating.calculate(ratings, Math.abs(Conductor.current.time - note.time));

        var output:FlxBitmapText = new FlxBitmapText(0.0, 0.0, "", FlxBitmapFont.getDefaultFont());

        output.camera = hudCamera;

        output.antialiasing = false;

        output.text = '${rating.name}\n(${Math.round(Math.abs(Conductor.current.time - note.time))})';

        output.alignment = CENTER;

        output.color = rating.color;

        output.velocity.set(FlxG.random.bool() ? FlxG.random.int(0, 75) : FlxG.random.int(-0, -75), FlxG.random.bool() ? FlxG.random.int(0, 10) : FlxG.random.int(-0, -10));

        output.acceleration.set(FlxG.random.bool() ? FlxG.random.int(0, 350) : FlxG.random.int(-0, -350), FlxG.random.bool() ? FlxG.random.int(0, 250) : FlxG.random.int(-0, -250));

        output.scale.set(5.0, 5.0);

        output.updateHitbox();

        output.screenCenter();

        add(output);

        FlxTween.tween(output, {alpha: 0.0}, (Conductor.current.crotchet * 4) * 0.001,
        {
            onComplete: function(tween:FlxTween):Void
            {
                output.destroy();
            }
        });

        return output;
    }
}