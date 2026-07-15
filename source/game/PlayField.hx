package game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
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
import interfaces.IBeatDispatcher;
import interfaces.ISequenceHandler;
import music.Conductor;
import tools.CompilerTools;

using tools.AlignTools;

class PlayField extends FlxGroup
{
    public var beatDispatcher:IBeatDispatcher;

    public var conductor(get, never):Conductor;

    @:noCompletion
    function get_conductor():Conductor
    {
        return beatDispatcher.conductor;
    }

    public var sequenceHandler:ISequenceHandler;

    public var tweens(get, never):FlxTweenManager;

    @:noCompletion
    function get_tweens():FlxTweenManager
    {
        return sequenceHandler.tweens;
    }

    public var timers(get, never):FlxTimerManager;

    @:noCompletion
    function get_timers():FlxTimerManager
    {
        return sequenceHandler.timers;
    }

    public var chart:Chart;

    public var song:FlxSound;

    public var playStats:PlayStats;

    public var timeGauge:FlxRadialGauge;

    public var timeText:FlxText;

    public var scoreText:FlxText;

    public var scorePopup:ScorePopup;

    public var healthBar:HealthBar;

    public var noteSpawner:NoteSpawner;

    public var strumlines:FlxTypedGroup<Strumline>;

    public var opponentStrumline:Strumline;

    public var playerStrumline:Strumline;

    public function new(beatDispatcher:IBeatDispatcher, sequenceHandler:ISequenceHandler, chart:Chart, song:FlxSound):Void
    {
        super();

        this.beatDispatcher = beatDispatcher;

        this.sequenceHandler = sequenceHandler;

        this.chart = chart;

        this.song = song;

        playStats = {score: 0, combo: 0, hits: 0, misses: 0, bonus: 0.0}

        timeGauge = new FlxRadialGauge();

        timeGauge.active = false;

        timeGauge.antialiasing = true;

        timeGauge.makeShapeGraphic(CIRCLE, 56, 0, FlxColor.WHITE);

        timeGauge.setPosition(timeGauge.getCenterX(), Options.downscroll ? 108.0 : FlxG.height - timeGauge.height - 108.0);

        add(timeGauge);

        timeText = new FlxText(0.0, 0.0, timeGauge.width, "-:--", 36);

        timeText.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        timeText.alignment = CENTER;

        timeText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        timeText.centerTo(timeGauge);

        add(timeText);

        scoreText = new FlxText(0.0, 0.0, FlxG.width, "", 20);

        scoreText.antialiasing = true;

        scoreText.font = Paths.ttf("assets/fonts/VCR OSD Mono");

        scoreText.alignment = CENTER;

        scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);

        scoreText.setPosition(scoreText.getCenterX(), Options.downscroll ? 25.0 : (FlxG.height - scoreText.height) - 25.0);

        add(scoreText);

        scorePopup = new ScorePopup();
        
        add(scorePopup);

        updateScoreText();

        healthBar = new HealthBar(0.0, 0.0, beatDispatcher);

        healthBar.setPosition(healthBar.getCenterX(), Options.downscroll ? (FlxG.height - healthBar.height) - 620.0 : 620.0);

        add(healthBar);

        noteSpawner = new NoteSpawner(beatDispatcher, chart.notes);

        add(noteSpawner);

        strumlines = new FlxTypedGroup<Strumline>();

        add(strumlines);

        strumlines.memberAdded.add(onAddStrumline);

        var keyCount:Int = chart.keyCount;

        opponentStrumline = new Strumline(beatDispatcher, keyCount);

        opponentStrumline.visible = !Options.middlescroll;

        setOppStrumlinePos(keyCount);

        strumlines.add(opponentStrumline);

        playerStrumline = new Strumline(beatDispatcher, keyCount);

        setPlrStrumlinePos(keyCount);

        strumlines.add(playerStrumline);

        var playAsWho:Int = Std.parseInt(CompilerTools.getDefine("PLAY_AS_WHO")) ?? 1;

        var strumline:Strumline = strumlines.members[playAsWho];

        strumline.botplay = Options.botplay;
        
        strumline.onNoteHit.add(noteHit);

        strumline.onNoteMiss.add(noteMiss);

        strumline.onSustainHold.add(sustainHold);

        strumline.onGhostTap.add(ghostTap);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var time:Float = song.time;

        var length:Float = song.length;

        timeGauge.amount = time / length;

        timeText.text = FlxStringUtil.formatTime(time * 0.001);
    }

    public function updateScoreText():Void
    {
        if (playStats.isEmpty())
        {
            scoreText.text = "Score: 0";

            if (!Options.botplay)
                scoreText.text += " | Misses: 0 | Accuracy: N/A";

            return;
        }

        var score:Int = playStats.score;

        var misses:Int = playStats.misses;

        var accuracy:Float = FlxMath.roundDecimal(playStats.accuracy, 2);

        scoreText.text = 'Score: ${score}';

        if (!Options.botplay)
            scoreText.text += ' | Misses: ${misses} | Accuracy: ${accuracy}%';
    }

    public function onAddStrumline(strumline:Strumline):Void
    {
        noteSpawner.strumlines.push(strumline);
        
        strumline.scrollSpeed = chart.scrollSpeed;
    }

    public function noteHit(ev:NoteHitEvent):Void
    {
        var note:Note = ev.note;

        var timeDiff:Float = Math.abs(note.time - conductor.time);

        var rating:Rating = Rating.fromTime(timeDiff);

        if (note.skipHit || rating != Rating.list[0])
            ev.playSplash = false;
        
        playStats.score += 500;

        var strumline:Strumline = note.strumline;

        // Even botplay is usually off by a few ms, so we hide the score difference to match expected behavior.
        if (!strumline.botplay)
        {
            // -5 for every 5 ms away you were from a perfect hit. This rounds down, so for example,
            // a 4 ms difference would result in no decrement, a 13ms difference would result in a 10 decrement, etc.
            playStats.score -= Math.floor(timeDiff / 5.0) * 5;
        }

        playStats.combo++;

        playStats.hits++;

        playStats.bonus += rating.bonus;

        updateScoreText();

        if (!strumline.botplay)
        {
            scorePopup.showRating(rating);

            scorePopup.showCombo(playStats.combo);
        }

        healthBar.value += note.hitHealth;
    }

    public function noteMiss(note:Note):Void
    {
        if (note.skipHit)
            return;
        
        playStats.score -= 500;

        playStats.combo = 0;

        playStats.misses++;

        healthBar.value -= note.missHealth;

        updateScoreText();
    }

    public function sustainHold(ev:SustainHoldEvent):Void
    {
        playStats.score += Math.ceil(250.0 * FlxG.elapsed / 5.0) * 5;

        updateScoreText();

        healthBar.value += ev.note.hitHealth * 10.0 * FlxG.elapsed;
    }

    public function ghostTap(ev:GhostTapEvent):Void
    {
        if (ev.ghostTapping)
            return;

        playStats.score -= 500;

        playStats.misses++;

        healthBar.value -= 2.0;

        updateScoreText();
    }

    public function setOppStrumlinePos(keyCount:Int):Void
    {
        opponentStrumline.strums.setPosition(160.0 / keyCount, opponentStrumline.downscroll ? FlxG.height - opponentStrumline.strums.height - 40.0 : 40.0);
    }

    public function setPlrStrumlinePos(keyCount:Int):Void
    {
        playerStrumline.strums.setPosition(Options.middlescroll ? playerStrumline.strums.getCenterX() : FlxG.width - playerStrumline.strums.width - 160.0 / keyCount,
            playerStrumline.downscroll ? FlxG.height - playerStrumline.strums.height - 40.0 : 40.0);
    }
}