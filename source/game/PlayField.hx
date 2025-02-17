package game;

import flixel.FlxG;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

import flixel.addons.display.FlxRadialGauge;

import data.Chart;
import data.PlayStats;

import game.notes.Note;
import game.notes.events.GhostTapEvent;
import game.notes.events.NoteHitEvent;
import game.notes.NoteSpawner;
import game.notes.Strumline;

import core.Options;
import core.Paths;

import music.Conductor;

import util.StringUtil;

class PlayField extends FlxGroup
{
    public var conductor:Conductor;

    public var chart:Chart;

    public var instrumental:FlxSound;

    public var playStats:PlayStats;

    public var statsText:FlxText;

    public var healthBar:HealthBar;

    public var timeGauge:FlxRadialGauge;

    public var timeText:FlxText;

    public var scrollSpeed(default, set):Float;

    @:noCompletion
    function set_scrollSpeed(_scrollSpeed:Float):Float
    {
        scrollSpeed = _scrollSpeed;

        for (i in 0 ... strumlines.members.length)
            strumlines.members[i].scrollSpeed = scrollSpeed;

        return scrollSpeed;
    }

    public var strumlines:FlxTypedGroup<Strumline>;

    public var opponentStrumline:Strumline;

    public var playerStrumline:Strumline;

    public var noteSpawner:NoteSpawner;

    public function new(_conductor:Conductor, _chart:Chart, _instrumental:FlxSound):Void
    {
        super();

        conductor = _conductor;

        chart = _chart;

        instrumental = _instrumental;

        playStats = {score: 0, hits: 0, misses: 0, bonus: 0.0}

        statsText = new FlxText(0.0, 0.0, FlxG.width, "Points: 0 | Misses: 0 | Rating: 0.0%", 24);

        statsText.antialiasing = true;

        statsText.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        statsText.alignment = CENTER;

        statsText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        statsText.setPosition((FlxG.width - statsText.width) * 0.5, Options.downscroll ? 25.0 : (FlxG.height - statsText.height) - 25.0);

        add(statsText);

        healthBar = new HealthBar(0.0, 0.0, 600, 25, RIGHT_TO_LEFT, conductor);

        healthBar.setPosition((FlxG.width - healthBar.border.width) * 0.5, Options.downscroll ? (FlxG.height - healthBar.border.height) - 620.0 : 620.0);

        add(healthBar);

        timeGauge = new FlxRadialGauge(0.0, 0.0);

        timeGauge.active = false;

        timeGauge.antialiasing = true;

        timeGauge.amount = 0.0;

        timeGauge.makeShapeGraphic(CIRCLE, 56, 0, FlxColor.WHITE);

        timeGauge.setPosition(45.0, Options.downscroll ? 32.0 : FlxG.height - timeGauge.height - 32.0);

        add(timeGauge);

        timeText = new FlxText(0.0, 0.0, FlxG.width, "-:--", 36);

        timeText.antialiasing = true;

        timeText.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        timeText.alignment = CENTER;

        timeText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        timeText.setPosition(timeGauge.getMidpoint().x - timeText.width * 0.5, timeGauge.getMidpoint().y - timeText.height * 0.5);

        add(timeText);

        strumlines = new FlxTypedGroup<Strumline>();

        strumlines.memberAdded.add((strumline:Strumline) ->
        {
            strumline.onNoteHit.add(noteHit);

            strumline.onNoteMiss.add(noteMiss);

            strumline.onGhostTap.add(ghostTap);
        });

        strumlines.memberRemoved.add((strumline:Strumline) ->
        {
            strumline.onNoteHit.remove(noteHit);

            strumline.onNoteMiss.remove(noteMiss);

            strumline.onGhostTap.remove(ghostTap);
        });

        add(strumlines);

        opponentStrumline = new Strumline(conductor);

        opponentStrumline.visible = !Options.middlescroll;

        opponentStrumline.automated = true;

        opponentStrumline.removeKeyboardListeners();

        opponentStrumline.strums.setPosition(Options.middlescroll ? (FlxG.width - opponentStrumline.strums.width) * 0.5 : 45.0, Options.downscroll ? FlxG.height - opponentStrumline.strums.height - 15.0 : 15.0);

        strumlines.add(opponentStrumline);

        playerStrumline = new Strumline(conductor);

        playerStrumline.strums.setPosition(Options.middlescroll ? (FlxG.width - playerStrumline.strums.width) * 0.5 : FlxG.width - playerStrumline.strums.width - 45.0, Options.downscroll ? FlxG.height - playerStrumline.strums.height - 15.0 : 15.0);

        strumlines.add(playerStrumline);

        scrollSpeed = chart.scrollSpeed;

        noteSpawner = new NoteSpawner(conductor, chart, strumlines);

        add(noteSpawner);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor.time > 0.0)
        {
            timeGauge.amount = conductor.time / instrumental.length;
            
            timeText.text = FlxStringUtil.formatTime(conductor.time * 0.001);
        }
    }

    public function updateStatsText():Void
    {
        var score:Int = playStats.score;

        var misses:Int = playStats.misses;

        var rating:Float = playStats.rating;

        if (Math.isNaN(rating))
            rating = 0.0;

        statsText.text = 'Score: ${score} | Misses: ${misses} | Rating: ${StringUtil.appendDecimal(FlxMath.roundDecimal(rating, 2))}%';
    }

    public function noteHit(event:NoteHitEvent):Void
    {
        var ratings:Array<Rating> = Rating.list;

        var rating:Rating = Rating.compute(ratings, Math.abs(event.note.time - conductor.time));

        if (rating != ratings[0])
            event.showPop = false;

        if (!event.note.strumline.automated)
        {
            playStats.score += 500 - Math.ceil(Math.abs(event.note.time - conductor.time));

            playStats.hits++;

            playStats.bonus += rating.bonus;

            updateStatsText();

            healthBar.value += rating.health;
        }
    }

    public function noteMiss(note:Note):Void
    {
        playStats.score -= 500;

        playStats.misses++;

        updateStatsText();

        healthBar.value -= 1.5;
    }

    public function ghostTap(event:GhostTapEvent):Void
    {
        if (event.penalize)
        {
            playStats.score -= 500;

            playStats.misses++;

            updateStatsText();

            healthBar.value -= 1.5;
        }
    }
}