package ui;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxGroup;

import flixel.sound.FlxSound;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenManager;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;

import core.Assets;
import core.Paths;

import music.Conductor;

/**
 * A `flixel.group.FlxGroup` representing the countdown you see in `game.PlayState`.
 */
class Countdown extends FlxGroup
{
    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(_conductor:Conductor):Conductor
    {
        var __conductor:Conductor = conductor;

        conductor = _conductor;

        conductor?.onBeatHit?.add(beatHit);

        __conductor?.onBeatHit?.remove(beatHit);

        return conductor;
    }

    public var started:Bool;

    public var onStart:FlxSignal;

    public var tick:Int;

    public var onTick:FlxTypedSignal<(tick:Int)->Void>;

    public var paused:Bool;

    public var onPause:FlxSignal;

    public var onResume:FlxSignal;

    public var finished:Bool;

    public var onFinish:FlxSignal;

    public var skipped:Bool;

    public var onSkip:FlxSignal;

    public var tweens:FlxTweenManager;

    public var sprite:FlxSprite;

    public var three:FlxSound;

    public var two:FlxSound;

    public var one:FlxSound;

    public var go:FlxSound;

    public function new(_conductor:Conductor):Void
    {
        super();

        conductor = _conductor;

        started = false;

        onStart = new FlxSignal();

        tick = 0;

        onTick = new FlxTypedSignal<(tick:Int)->Void>();

        paused = false;

        onPause = new FlxSignal();

        onResume = new FlxSignal();

        finished = false;

        onFinish = new FlxSignal();

        skipped = false;

        onSkip = new FlxSignal();

        tweens = new FlxTweenManager();

        add(tweens);

        sprite = new FlxSprite().loadGraphic(Assets.getGraphic(Paths.png("assets/images/ui/Countdown/countdown")), true, 1000, 500);

        sprite.antialiasing = true;

        sprite.animation.add("ready", [0], 0.0, false);

        sprite.animation.add("set", [1], 0.0, false);

        sprite.animation.add("go", [2], 0.0, false);

        sprite.alpha = 0.0;

        sprite.scale.set(0.85, 0.85);

        sprite.updateHitbox();

        sprite.screenCenter();

        add(sprite);

        three = FlxG.sound.load(Assets.getSound(Paths.ogg("assets/sounds/ui/Countdown/three")), 0.65);

        two = FlxG.sound.load(Assets.getSound(Paths.ogg("assets/sounds/ui/Countdown/two")), 0.65);

        one = FlxG.sound.load(Assets.getSound(Paths.ogg("assets/sounds/ui/Countdown/one")), 0.65);

        go = FlxG.sound.load(Assets.getSound(Paths.ogg("assets/sounds/ui/Countdown/go")), 0.65);
    }

    override function destroy():Void
    {
        super.destroy();

        onStart = cast FlxDestroyUtil.destroy(onStart);

        onTick = cast FlxDestroyUtil.destroy(onTick);

        onFinish = cast FlxDestroyUtil.destroy(onFinish);

        onSkip = cast FlxDestroyUtil.destroy(onSkip);

        three.destroy();

        two.destroy();

        one.destroy();

        go.destroy();
    }

    public function start():Void
    {
        paused = false;

        tick = 0;

        finished = false;

        skipped = false;

        tweens.forEach((tween:FlxTween) -> tween.cancel());

        sprite.alpha = 0.0;

        three.stop();

        two.stop();

        one.stop();

        go.stop();

        started = true;

        onStart.dispatch();
    }

    public function pause():Void
    {
        if (!started || paused || finished || skipped)
            return;

        tweens.active = false;

        three.pause();

        two.pause();

        one.pause();

        go.pause();

        paused = true;

        onPause.dispatch();
    }

    public function resume():Void
    {
        if (!started || !paused || finished || skipped)
            return;

        tweens.active = true;

        three.resume();

        two.resume();

        one.resume();

        go.resume();

        paused = false;

        onResume.dispatch();
    }

    public function skip():Void
    {
        if (!started || paused || finished || skipped)
            return;

        tweens.forEach((tween:FlxTween) -> tween.cancel());

        sprite.alpha = 0.0;

        three.stop();

        two.stop();

        one.stop();

        go.stop();

        skipped = true;

        onSkip.dispatch();
    }

    public function beatHit(beat:Int):Void
    {
        if (!started || paused || finished || skipped)
            return;

        switch (tick:Int)
        {
            case 0:
                three.play();

            case 1:
            {
                sprite.animation.play("ready");

                two.play();
            }

            case 2:
            {
                sprite.animation.play("set");

                one.play();
            }

            case 3:
            {
                sprite.animation.play("go");

                go.play();
            }

            case 4:
            {
                finished = true;

                onFinish.dispatch();
            }
        }

        if (tick > 0.0)
        {
            tweens.forEach((tween:FlxTween) -> tween.cancel());
            
            sprite.alpha = 1.0;
            
            tweens.tween(sprite, {alpha: 0.0}, conductor.beatLength * 0.001, {ease: FlxEase.circInOut});
        }

        tick++;

        onTick.dispatch(tick);
    }
}