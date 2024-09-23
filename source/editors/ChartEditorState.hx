package editors;

import haxe.ds.ArraySort;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.util.FlxColor;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;

import core.AssetMan;
import core.Paths;

import editors.ChartConverters.FunkConverter;

import extendable.MusicBeatState;

import game.Chart;
import game.Chart.ParsedNote;
import game.Chart.ParsedEvent;
import game.GameState;
import game.notes.Note;

using StringTools;

class ChartEditorState extends MusicBeatState
{
    public var chart:Chart;

    public var instrumental:FlxSound;

    public var mainVocals:FlxSound;

    public var opponentVocals:FlxSound;

    public var playerVocals:FlxSound;

    public var background:FlxSprite;

    public var grid:FlxSprite;

    public var highlight:FlxSprite;

    public var placement:FlxSprite;

    public var notes:FlxTypedContainer<Note>;

    public var selectedNote:Note;

    public var warnings:FlxTypedContainer<FlxText>;

    public var lane:Int;

    public function new(?chart:Chart):Void
    {
        super();

        this.chart = chart;
    }

    override function create():Void
    {
        super.create();

        conductor.active = false;

        FlxG.mouse.visible = true;

        loadSong("Darnell (Bf Mix)");

        background = new FlxSprite(0.0, 0.0, AssetMan.graphic(Paths.png("assets/images/editors/chart/background")));

        background.color = 0xFF1E1E1E;

        background.scrollFactor.set();

        add(background);

        grid = new FlxTiledSprite(FlxGridOverlay.createGrid(96, 96, 384, 192, true, 0xFFE7E6E6, 0xFFD9D5D5), 384, positionFromTime(instrumental.length));

        add(grid);

        highlight = new FlxSprite().makeGraphic(96, 96, FlxColor.WHITE);

        add(highlight);

        placement = new FlxSprite().makeGraphic(384, 16, FlxColor.WHITE);

        add(placement);

        FlxG.camera.follow(placement, LOCKON, 0.5);

        notes = new FlxTypedContainer<Note>();

        add(notes);

        for (i in 0 ... chart.notes.length)
        {
            var parsed:ParsedNote = chart.notes[i];

            var note:Note = new Note();

            note.time = parsed.time;

            note.speed = parsed.speed;

            note.direction = parsed.direction;

            note.lane = parsed.lane;

            note.length = parsed.length;

            note.animation.play(Note.directions[note.direction].toLowerCase());

            note.scale.set(0.615, 0.615);

            note.updateHitbox();

            note.setPosition((grid.x + 96.0 * note.direction) + (48 - note.width * 0.5), positionFromTime(note.time));

            notes.add(note);

            for (j in 0 ... Math.floor(parsed.length / (((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25)))
            {
                var sustain:Note = new Note();

                sustain.parent = note;

                note.children.push(sustain);

                sustain.time = note.time + ((((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25) * (j + 1));

                sustain.speed = note.speed;

                sustain.direction = note.direction;
                
                sustain.lane = note.lane;

                sustain.length = parsed.length;

                sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldPiece");

                if (j >= Math.floor(sustain.length / (((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25)) - 1)
                    sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldTail");

                sustain.scale.set(0.685, 0.685);

                sustain.updateHitbox();

                sustain.setPosition((grid.x + 96.0 * sustain.direction) + (48 - sustain.width * 0.5), positionFromTime(sustain.time));

                notes.add(sustain);
            }
        }

        warnings = new FlxTypedContainer<FlxText>();

        add(warnings);

        lane = 0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor.time < 0.0)
            conductor.time = instrumental.length;

        if (conductor.time > instrumental.length)
            conductor.time = 0.0;

        if (conductor.active && conductor.exists)
        {
            conductor.time += 1000.0 * elapsed;

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
        }

        if (FlxG.keys.anyPressed([W, UP]))
            conductor.time -= (FlxG.keys.pressed.SHIFT ? 5000.0 : 1000.0) * elapsed;

        if (FlxG.keys.anyPressed([S, DOWN]))
            conductor.time += (FlxG.keys.pressed.SHIFT ? 5000.0 : 1000.0) * elapsed;

        if (FlxG.keys.anyPressed([W, UP, S, DOWN]))
        {
            conductor.active = false;

            instrumental.pause();

            if (mainVocals != null)
                mainVocals.pause();

            if (opponentVocals != null)
                opponentVocals.pause();

            if (playerVocals != null)
                playerVocals.pause();
        }

        if (FlxG.keys.justPressed.SPACE)
        {
            conductor.active = !conductor.active;
            
            conductor.active ? instrumental.resume() : instrumental.pause();

            if (mainVocals != null)
                conductor.active ? mainVocals.resume() : mainVocals.pause();

            if (opponentVocals != null)
                conductor.active ? opponentVocals.resume() : opponentVocals.pause();

            if (playerVocals != null)
                conductor.active ? playerVocals.resume() : playerVocals.pause();
        }

        highlight.visible = FlxG.mouse.overlaps(grid);

        highlight.setPosition(grid.x + Math.floor((FlxG.mouse.x - grid.x) / 96.0) * 96.0, FlxG.keys.pressed.SHIFT ? FlxG.mouse.y : grid.y + Math.floor((FlxG.mouse.y - grid.y) / 96.0) * 96.0);

        placement.setPosition(0.0, positionFromTime(conductor.time));

        var i:Int = notes.members.length - 1;

        while (i >= 0.0)
        {
            var note:Note = notes.members[i];

            note.active = note.isOnScreen();

            note.alpha = note.lane == lane ? 1.0 : 0.25;

            i--;
        }

        if (FlxG.mouse.justPressed)
        {
            var overlapped:Bool = false;

            var j:Int = notes.members.length - 1;

            while (j >= 0.0)
            {
                var note:Note = notes.members[j];

                if (note.lane != lane)
                {
                    j--;

                    continue;
                }

                if (note.animation.name.contains("Hold"))
                {
                    j--;

                    continue;
                }

                if (FlxG.mouse.overlaps(note))
                {
                    overlapped = true;

                    if (FlxG.keys.pressed.CONTROL)
                    {
                        if (note == selectedNote)
                            deselectNote(note);
                        else
                            selectNote(note);

                        j--;

                        continue;
                    }
                    else
                    {
                        notes.remove(note, true).destroy();

                        j--;

                        var k:Int = note.children.length - 1;

                        while (k >= 0.0)
                        {
                            notes.remove(note.children[k], true).destroy();

                            k--;

                            j--;
                        }

                        ArraySort.sort(notes.members, (a:Note, b:Note) -> Std.int(a.time - b.time));

                        deselectNote(note);

                        continue;
                    }
                }

                j--;
            }

            if (FlxG.mouse.overlaps(grid))
            {
                if (!overlapped)
                {
                    var note:Note = new Note();

                    note.time = timeFromPosition(highlight.y);

                    note.direction = Math.floor(FlxG.mouse.x / 96.0) % 4;

                    note.lane = lane;

                    note.animation.play(Note.directions[note.direction].toLowerCase());

                    note.scale.set(0.615, 0.615);

                    note.updateHitbox();

                    note.setPosition(highlight.x, highlight.y);

                    notes.add(note);

                    ArraySort.sort(notes.members, (a:Note, b:Note) -> Std.int(a.time - b.time));

                    selectNote(note);
                }
            }
        }

        if (selectedNote != null)
        {
            selectedNote.alpha = Math.sin(FlxG.game.ticks * 0.0025) + 1;

            for (j in 0 ... selectedNote.children.length)
                selectedNote.children[j].alpha = Math.sin(FlxG.game.ticks * 0.0025) + 1;

            if (FlxG.keys.justPressed.E)
            {
                selectedNote.length += (((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25);

                var sustain:Note = new Note();

                sustain.parent = selectedNote;

                selectedNote.children.insert(0, sustain);

                sustain.time = selectedNote.time + (((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25);

                sustain.speed = selectedNote.speed;

                sustain.direction = selectedNote.direction;
                
                sustain.lane = selectedNote.lane;

                sustain.length = selectedNote.length;

                sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldPiece");

                sustain.scale.set(0.685, 0.685);

                sustain.updateHitbox();

                sustain.setPosition((grid.x + 96.0 * sustain.direction) + (48 - sustain.width * 0.5), positionFromTime(sustain.time));

                notes.add(sustain);

                if (selectedNote.children.length > 1)
                {
                    for (j in 0 ... selectedNote.children.length)
                    {
                        if (j < 1)
                            continue;

                        var s:Note = selectedNote.children[j];

                        s.time += (((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25);

                        s.setPosition(s.x, positionFromTime(s.time));
                    }
                }
                else
                    sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldTail");
            }

            if (FlxG.keys.justPressed.Q)
            {
                if (selectedNote.children.length > 0)
                {
                    selectedNote.length -= (((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25);

                    notes.remove(selectedNote.children.shift(), true).destroy();

                    for (j in 0 ... selectedNote.children.length)
                    {
                        var sustain:Note = selectedNote.children[j];

                        sustain.time -= (((60 / conductor.timeChanges[0].tempo) * 1000.0) * 0.25);

                        sustain.setPosition(sustain.x, positionFromTime(sustain.time));
                    }
                }
            }
        }

        if (FlxG.keys.justPressed.PLUS)
        {
            if (lane < 1)
                lane++;
            else
                warn('Invalid lane!');
        }

        if (FlxG.keys.justPressed.MINUS)
        {
            if (lane > 0)
                lane--;
            else
                warn('Invalid lane!');
        }

        var j:Int = warnings.members.length - 1;

        while (j >= 0.0)
        {
            var warning:FlxText = warnings.members[j];

            if (!warning.isOnScreen())
            {
                warnings.remove(warning, true).destroy();

                j--;

                continue;
            }

            j--;
        }

        if (FlxG.keys.justPressed.NUMPADPLUS || FlxG.keys.justPressed.NUMPADMINUS)
        {
            if (selectedNote != null)
                if (selectedNote.lane != lane)
                    deselectNote(selectedNote);
        }

        if (FlxG.keys.justPressed.ENTER)
        {
            chart.notes = [for (i in 0 ... notes.members.length)
            {
                var note:Note = notes.members[i];

                if (!note.animation.name.contains("Hold"))
                    {time: note.time, speed: note.speed, direction: note.direction, lane: note.lane, length: note.length}
            }];
            
            FlxG.switchState(() -> new GameState(chart));
        }
    }

    public function loadSong(name:String):Void
    {
        if (chart == null)
            chart = new FunkConverter(Paths.json('assets/data/songs/${name}/chart'), Paths.json('assets/data/songs/${name}/meta')).build("hard");

        ArraySort.sort(chart.notes, (a:ParsedNote, b:ParsedNote) -> Std.int(a.time - b.time));

        ArraySort.sort(chart.events, (a:ParsedEvent, b:ParsedEvent) -> Std.int(a.time - b.time));

        ArraySort.sort(chart.timeChanges, (a:ParsedTimeChange, b:ParsedTimeChange) -> Std.int(a.time - b.time));

        conductor.tempo = chart.tempo;

        conductor.timeChange = {tempo: conductor.tempo, time: 0.0, step: 0.0, beat: 0.0, section: 0.0};

        conductor.timeChanges = chart.timeChanges;

        instrumental = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Instrumental')), 1.0, true);

        instrumental.play();

        instrumental.pause();

        if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Main')))
        {
            mainVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Main')), 1.0, true);

            mainVocals.play();

            mainVocals.pause();
        }

        if (mainVocals == null)
        {
            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Opponent')))
            {
                opponentVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Opponent')), 1.0, true);

                opponentVocals.play();

                opponentVocals.pause();
            }

            if (Paths.exists(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Player')))
            {
                playerVocals = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ('assets/songs/${name}/Vocals-Player')), 1.0, true);

                playerVocals.play();

                playerVocals.pause();
            }
        }
    }

    public function positionFromTime(time:Float):Float
    {
        return 96.0 * (conductor.timeChange.step + ((time - conductor.timeChange.time) / (conductor.crotchet * 0.25)));
    }

    public function timeFromPosition(position:Float):Float
    {
        return conductor.timeChange.time + (conductor.crotchet * 0.25) * ((position / 96.0) - conductor.timeChange.step);
    }

    public function selectNote(note:Note):Void
    {
        if (selectedNote != null)
            deselectNote(selectedNote);

        selectedNote = note;
    }

    public function deselectNote(note:Note):Void
    {
        selectedNote = null;

        note.alpha = 1.0;

        for (i in 0 ... note.children.length)
            note.children[i].alpha = 1.0;
    }

    public function warn(text:String):FlxText
    {
        var output:FlxText = new FlxText(160.0, 80.0, FlxG.width, text, 24);

        output.scrollFactor.set();

        output.moves = true;

        output.acceleration.set(0.0, 550.0);

		output.velocity.set(-FlxG.random.int(145, 175), -FlxG.random.int(0, 10));

        output.setBorderStyle(SHADOW, FlxColor.BLACK, 3.5);

        warnings.add(output);

        return output;
    }
}