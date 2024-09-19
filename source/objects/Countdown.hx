package objects;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxContainer;

import flixel.sound.FlxSound;

import flixel.tweens.FlxTween.FlxTweenManager;

import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxTimer;
import flixel.util.FlxTimer.FlxTimerManager;

import core.AssetMan;
import core.Conductor;
import core.Paths;

/**
 * An object representing the countdown you see in `states.GameState`.
 */
class Countdown extends FlxContainer
{
    public var conductor(default, null):Conductor;

    public var timers(default, null):FlxTimerManager;

    public var timer(default, null):FlxTimer;

    public var tweens(default, null):FlxTweenManager;

    public var started(default, null):Bool;

    public var onStart(default, null):FlxSignal;

    public var paused(default, null):Bool;

    public var tick(default, null):Int;

    public var onTick(default, null):FlxTypedSignal<(tick:Int)->Void>;

    public var finished(default, null):Bool;

    public var onFinish(default, null):FlxSignal;

    public var skipped(default, null):Bool;

    public var onSkip(default, null):FlxSignal;

    public var sprite(default, null):FlxSprite;

    public var three(default, null):FlxSound;

    public var two(default, null):FlxSound;

    public var one(default, null):FlxSound;

    public var go(default, null):FlxSound;

    public function new(conductor:Conductor):Void
    {
        super();

        this.conductor = conductor;

        timers = new FlxTimerManager();

        add(timers);

        timer = new FlxTimer(timers);

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

        sprite = new FlxSprite().loadGraphic(AssetMan.graphic(Paths.png("assets/images/countdown")), true, 1000, 500);

        sprite.animation.add("ready", [0], 0.0, false);

        sprite.animation.add("set", [1], 0.0, false);

        sprite.animation.add("go", [2], 0.0, false);

        sprite.alpha = 0.0;

        sprite.scale.set(0.85, 0.85);

        sprite.updateHitbox();

        sprite.screenCenter();

        add(sprite);

        three = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/three")), 0.65);

        two = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/two")), 0.65);

        one = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/one")), 0.65);

        go = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/go")), 0.65);
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
        timer.start(conductor.crotchet * 0.001, (timer:FlxTimer) ->
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
                sprite.alpha = 1;

                tweens.cancelTweensOf(sprite, ["alpha"]);

                tweens.tween(sprite, {alpha: 0.0}, conductor.crotchet * 0.001);
            }
        }, 5);

        started = true;

        onStart.dispatch();
    }

    /**
     * Temporarily pauses `this` `Countdown`.
     * If you want to pause the countdown, it's recommended you use this function instead of `kill`ing the object!
     */
    public function pause():Void
    {
        if (!started || paused)
            return;

        timers.active = false;

        tweens.active = false;

        paused = true;

        three.pause();

        two.pause();

        one.pause();

        go.pause();
    }

    /**
     * Resumes the countdown.
     * If you want to resume the countdown, it's recommended you use this function instead of `revive`ing the object!
     */
    public function resume():Void
    {
        if (!started || !paused)
            return;

        timers.active = true;

        tweens.active = true;

        paused = false;

        three.resume();

        two.resume();

        one.resume();

        go.resume();
    }

    /**
     * Skips `this` `Countdown`. `onSkip` is dispatched.
     * `this` `Countdown` must be unpaused for this function to run!
     */
    public function skip():Void
    {
        if (!started || paused)
            return;

        @:privateAccess
            for (i in 0 ... timers._timers.length)
                timers._timers[i].cancel();

        tweens.cancelTweensOf(sprite);

        skipped = true;

        onSkip.dispatch();

        sprite.alpha = 0.0;

        three.stop();

        two.stop();

        one.stop();

        go.stop();
    }
}