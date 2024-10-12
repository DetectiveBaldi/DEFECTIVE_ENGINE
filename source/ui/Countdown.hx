package ui;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxContainer;

import flixel.sound.FlxSound;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween.FlxTweenManager;

import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxTimer;
import flixel.util.FlxTimer.FlxTimerManager;

import core.AssetMan;
import core.Conductor;
import core.Paths;

/**
 * A `flixel.group.FlxContainer` representing the countdown you see in `game.GameState`.
 */
class Countdown extends FlxContainer
{
    public var timers:FlxTimerManager;

    public var tweens:FlxTweenManager;

    public var started:Bool;

    public var onStart:FlxSignal;

    public var paused:Bool;

    public var tick:Int;

    public var onTick:FlxTypedSignal<(tick:Int)->Void>;

    public var finished:Bool;

    public var onFinish:FlxSignal;

    public var skipped:Bool;

    public var onSkip:FlxSignal;

    public var sprite:FlxSprite;

    public var three:FlxSound;

    public var two:FlxSound;

    public var one:FlxSound;

    public var go:FlxSound;

    public var conductor:Conductor;

    public function new(conductor:Conductor):Void
    {
        super();

        timers = new FlxTimerManager();

        add(timers);

        tweens = new FlxTweenManager();

        add(tweens);

        started = false;

        onStart = new FlxSignal();

        paused = false;

        tick = 0;

        onTick = new FlxTypedSignal<(tick:Int)->Void>();

        finished = false;

        onFinish = new FlxSignal();

        skipped = false;

        onSkip = new FlxSignal();

        sprite = new FlxSprite().loadGraphic(AssetMan.graphic(Paths.png("assets/images/ui/countdown"), true), true, 1000, 500);

        sprite.antialiasing = true;

        sprite.animation.add("ready", [0], 0.0, false);

        sprite.animation.add("set", [1], 0.0, false);

        sprite.animation.add("go", [2], 0.0, false);

        sprite.alpha = 0.0;

        sprite.scale.set(0.85, 0.85);

        sprite.updateHitbox();

        sprite.screenCenter();

        add(sprite);

        three = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/three"), false), 0.65);

        two = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/two"), false), 0.65);

        one = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/one"), false), 0.65);

        go = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/go"), false), 0.65);

        this.conductor = conductor;
    }

    override function destroy():Void
    {
        super.destroy();

        onStart.destroy();

        onTick.destroy();

        onFinish.destroy();

        onSkip.destroy();

        three.destroy();

        two.destroy();

        one.destroy();

        go.destroy();
    }

    public function start():Void
    {
        if (conductor == null)
            return;
        
        @:privateAccess
        {
            for (i in 0 ... timers._timers.length)
                timers._timers[i].cancel();

            for (i in 0 ... tweens._tweens.length)
                tweens._tweens[i].cancel();
        }

        started = false;

        paused = false;

        tick = 0;

        finished = false;

        skipped = false;

        sprite.alpha = 0.0;

        three.stop();

        two.stop();

        one.stop();

        go.stop();

        new FlxTimer(timers).start(conductor.crotchet * 0.001, (timer:FlxTimer) ->
        {
            switch (timer.elapsedLoops:Int)
            {
                case 1:
                    three.play();

                case 2:
                {
                    sprite.animation.play("ready");

                    two.play();
                }

                case 3:
                {
                    sprite.animation.play("set");

                    one.play();
                }

                case 4:
                {
                    sprite.animation.play("go");

                    go.play();
                }

                case 5:
                {
                    finished = true;

                    onFinish.dispatch();
                }
            }

            tick++;

            onTick.dispatch(tick);

            if (tick > 1.0 && !finished)
            {
                @:privateAccess
                    for (i in 0 ... tweens._tweens.length)
                        tweens._tweens[i].cancel();
                
                sprite.alpha = 1;
                
                tweens.tween(sprite, {alpha: 0.0}, conductor.crotchet * 0.001, {ease: FlxEase.circInOut});
            }
        }, 5);

        started = true;

        onStart.dispatch();
    }

    public function pause():Void
    {
        if (!started || paused || finished || skipped)
            return;

        timers.active = false;

        tweens.active = false;

        paused = true;

        three.pause();

        two.pause();

        one.pause();

        go.pause();
    }

    public function resume():Void
    {
        if (!started || !paused || finished || skipped)
            return;

        timers.active = true;

        tweens.active = true;

        paused = false;

        three.resume();

        two.resume();

        one.resume();

        go.resume();
    }

    public function skip():Void
    {
        if (!started || paused || finished || skipped)
            return;

        @:privateAccess
        {
            for (i in 0 ... timers._timers.length)
                timers._timers[i].cancel();

            for (i in 0 ... tweens._tweens.length)
                tweens._tweens[i].cancel();
        }

        skipped = true;

        onSkip.dispatch();

        sprite.alpha = 0.0;

        three.stop();

        two.stop();

        one.stop();

        go.stop();
    }
}