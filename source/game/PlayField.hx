package game;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.math.FlxMath;

import flixel.text.FlxText;

import flixel.tweens.FlxTween;

import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

import flixel.addons.display.FlxRadialGauge;

import data.Chart;
import data.PlayStats;

import game.notes.Note;
import game.notes.events.GhostTapEvent;
import game.notes.events.NoteHitEvent;
import game.notes.events.SustainHoldEvent;
import game.notes.NoteSpawner;
import game.notes.Strumline;

import core.AssetCache;
import core.Options;
import core.Paths;

import interfaces.ISequenceHandler;

import music.Conductor;

import util.MacroUtil;

using tools.ObjectHelpers;

class PlayField extends FlxGroup implements ISequenceHandler implements IBeatDispatcher
{
    public var tweens:FlxTweenManager;

    public var timers:FlxTimerManager;

    public var conductor:Conductor;

    public var getSongTime:()->Float;

    public var getSongLength:()->Float;

    public var playStats:PlayStats;

    public var scoreText:FlxText;

    public var healthBar:HealthBar;

    public var timeGauge:FlxRadialGauge;

    public var timeText:FlxText;

    public var noteSpawner:NoteSpawner;

    public var strumlines:FlxTypedGroup<Strumline>;

    public var scrollSpeed:Float;

    public var opponentStrumline:Strumline;

    public var playerStrumline:Strumline;

    public var onUpdateScore:FlxTypedSignal<(playStats:PlayStats)->Void>;

    public function new(sequenceHandler:ISequenceHandler, beatDispatcher:IBeatDispatcher, chart:Chart):Void
    {
        super();

        tweens = sequenceHandler.tweens;

        timers = sequenceHandler.timers;

        conductor = beatDispatcher.conductor;

        playStats = {score: 0, hits: 0, misses: 0, bonus: 0.0}

        scoreText = new FlxText(0.0, 0.0, FlxG.width, "", 20);

        scoreText.antialiasing = true;

        scoreText.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        scoreText.alignment = CENTER;

        scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        scoreText.setPosition((FlxG.width - scoreText.width) * 0.5, Options.downscroll ? 25.0 : (FlxG.height - scoreText.height) - 25.0);

        add(scoreText);

        if (Options.botplay)
            scoreText.kill();

        updateScoreText();

        healthBar = new HealthBar(0.0, 0.0, beatDispatcher);

        healthBar.setPosition(healthBar.getCenterX(),
            Options.downscroll ? (FlxG.height - healthBar.height) - 620.0 : 620.0);

        add(healthBar);

        if (Options.botplay)
            healthBar.kill();

        timeGauge = new FlxRadialGauge(0.0, 0.0);

        timeGauge.active = false;

        timeGauge.antialiasing = true;

        timeGauge.amount = 0.0;

        timeGauge.makeShapeGraphic(CIRCLE, 56, 0, FlxColor.WHITE);

        timeGauge.setPosition(45.0, Options.downscroll ? 32.0 : FlxG.height - timeGauge.height - 32.0);

        add(timeGauge);

        timeText = new FlxText(0.0, 0.0, timeGauge.width, "-:--", 36);

        timeText.antialiasing = true;

        timeText.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        timeText.alignment = CENTER;

        timeText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        timeText.setPosition(timeGauge.getMidpoint().x - timeText.width * 0.5, timeGauge.getMidpoint().y - timeText.height * 0.5);

        add(timeText);

        noteSpawner = new NoteSpawner(beatDispatcher, chart.notes, null);

        add(noteSpawner);

        strumlines = new FlxTypedGroup<Strumline>();

        add(strumlines);

        scrollSpeed = chart.scrollSpeed;

        noteSpawner.strumlines = strumlines;

        var keyCount:Int = chart.keyCount;

        opponentStrumline = new Strumline(this, keyCount);

        opponentStrumline.scrollSpeed = scrollSpeed;

        opponentStrumline.strums.setPosition(160.0 / keyCount, opponentStrumline.downscroll ?
            FlxG.height - opponentStrumline.strums.height - 40.0 : 40.0);

        strumlines.add(opponentStrumline);

        playerStrumline = new Strumline(this, keyCount);

        playerStrumline.scrollSpeed = scrollSpeed;

        playerStrumline.strums.setPosition(FlxG.width - playerStrumline.strums.width - 160.0 / keyCount, playerStrumline.downscroll ?
            FlxG.height - playerStrumline.strums.height - 40.0 : 40.0);

        strumlines.add(playerStrumline);

        for (i in 0 ... strumlines.members.length)
        {
            var strumline:Strumline = strumlines.members[i];

            strumline.botplay = true;
        }

        if (!Options.botplay)
        {
            var playAsWho:Int = Std.parseInt(MacroUtil.sanitizeDefine(MacroUtil.getDefine("PLAY_AS_WHO"))) ?? 1;

            var strumline:Strumline = strumlines.members[playAsWho];

            strumline.botplay = false;
            
            strumline.onNoteHit.add(noteHit);

            strumline.onNoteMiss.add(noteMiss);

            strumline.onSustainHold.add(sustainHold);

            strumline.onGhostTap.add(ghostTap);
        }

        onUpdateScore = new FlxTypedSignal<(playStats:PlayStats)->Void>();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        timeGauge.amount = getSongTime() / getSongLength();
            
        timeText.text = FlxStringUtil.formatTime(getSongTime() * 0.001);
    }

    override function destroy():Void
    {
        super.destroy();

        onUpdateScore = cast FlxDestroyUtil.destroy(onUpdateScore);
    }

    public function stepHit(step:Int):Void
    {

    }

    public function beatHit(beat:Int):Void
    {

    }

    public function measureHit(measure:Int):Void
    {
        
    }

    public function updateScoreText():Void
    {
        if (playStats.isEmpty())
        {
            scoreText.text = "Score: 0 | Misses: 0 | Accuracy: 0%";

            return;
        }

        var score:Int = playStats.score;

        var misses:Int = playStats.misses;

        var accuracy:Float = FlxMath.roundDecimal(playStats.accuracy, 2);

        scoreText.text = 'Score: ${score} | Misses: ${misses} | Accuracy: ${accuracy}%';
    }

    public function noteHit(event:NoteHitEvent):Void
    {
        var rating:Rating = Rating.fromTiming(Math.abs(event.note.time - conductor.time));

        if (rating != Rating.list[0])
            event.playSplash = false;

        if (!event.note.strumline.botplay)
        {
            playStats.score += 500 - Math.ceil(Math.abs(event.note.time - conductor.time));

            playStats.hits++;

            playStats.bonus += rating.bonus;

            onUpdateScore.dispatch(playStats);

            updateScoreText();
        }

        healthBar.value += event.note.hitHealth;
    }

    public function noteMiss(note:Note):Void
    {
        playStats.score -= 500;

        playStats.misses++;

        onUpdateScore.dispatch(playStats);

        healthBar.value -= note.missHealth;

        updateScoreText();
    }

    public function sustainHold(ev:SustainHoldEvent):Void
    {
        if (!ev.note.strumline.botplay)
        {
            playStats.score += Math.floor(250.0 * FlxG.elapsed);

            onUpdateScore.dispatch(playStats);

            updateScoreText();
        }

        healthBar.value += ev.note.hitHealth * 10.0 * FlxG.elapsed;
    }

    public function ghostTap(ev:GhostTapEvent):Void
    {
        if (!ev.ghostTapping)
        {
            playStats.score -= 500;

            playStats.misses++;

            onUpdateScore.dispatch(playStats);

            healthBar.value -= 2.0;

            updateScoreText();
        }
    }

    public function setScrollSpeed(v:Float):Void
    {
        scrollSpeed = v;

        opponentStrumline.scrollSpeed = scrollSpeed;

        playerStrumline.scrollSpeed = scrollSpeed;
    }
}