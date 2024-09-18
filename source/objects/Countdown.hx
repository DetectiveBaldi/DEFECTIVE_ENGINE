package objects;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxContainer;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxTimer;
import flixel.util.FlxTimer.FlxTimerManager;

import core.AssetMan;
import core.Conductor;
import core.Paths;

class Countdown extends FlxContainer
{
    public var conductor(default, null):Conductor;

    public var timers(default, null):FlxTimerManager;

    public var timer(default, null):FlxTimer;

    public var started(default, null):Bool;

    public var onStart(default, null):FlxSignal;

    public var tick(default, null):Int;

    public var onTick(default, null):FlxTypedSignal<(tick:Int)->Void>;

    public var finished(default, null):Bool;

    public var onFinish(default, null):FlxSignal;

    public var sprite(default, null):FlxSprite;

    public function new(conductor:Conductor):Void
    {
        super();

        this.conductor = conductor;

        timers = new FlxTimerManager();

        add(timers);

        timer = new FlxTimer(timers);

        started = false;

        onStart = new FlxSignal();

        tick = 0;

        onTick = new FlxTypedSignal<(tick:Int)->Void>();

        finished = false;

        onFinish = new FlxSignal();

        sprite = new FlxSprite().loadGraphic(AssetMan.graphic(Paths.png("assets/images/countdown")), true, 1000, 500);

        sprite.animation.add("0", [0], 0.0, false);

        sprite.animation.add("1", [1], 0.0, false);

        sprite.animation.add("2", [2], 0.0, false);

        sprite.alpha = 0.0;

        sprite.scale.set(0.85, 0.85);

        sprite.updateHitbox();

        sprite.screenCenter();

        add(sprite);
    }

    public function start():Void
    {
        timer.start(conductor.crotchet * 0.001, (timer:FlxTimer) ->
        {
            switch (timer.elapsedLoops:Int)
            {
                case 1:
                    FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/three")), 0.65);

                case 2:
                {
                    sprite.alpha = 1;

                    sprite.animation.play("0");

                    FlxTween.cancelTweensOf(sprite, ["alpha"]);

                    FlxTween.tween(sprite, {alpha: 0.0}, conductor.crotchet * 0.001, {ease: FlxEase.circInOut});

                    FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/two")), 0.65);
                }

                case 3:
                {
                    sprite.alpha = 1;

                    sprite.animation.play("1");

                    FlxTween.cancelTweensOf(sprite, ["alpha"]);

                    FlxTween.tween(sprite, {alpha: 0.0}, conductor.crotchet * 0.001, {ease: FlxEase.circInOut});

                    FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/one")), 0.65);
                }

                case 4:
                {
                    sprite.alpha = 1;

                    sprite.animation.play("2");

                    FlxTween.cancelTweensOf(sprite, ["alpha"]);

                    FlxTween.tween(sprite, {alpha: 0.0}, conductor.crotchet * 0.001,
                    {
                        ease: FlxEase.circInOut,

                        onComplete: function(tween:FlxTween):Void
                        {
                            remove(sprite, true);

                            sprite.destroy();
                        }
                    });

                    FlxG.sound.play(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/go")), 0.65);
                }

                case 5:
                {
                    finished = true;

                    onFinish.dispatch();
                }
            }

            tick++;

            onTick.dispatch(tick);
        }, 5);

        started = true;

        onStart.dispatch();
    }

    public function pause():Void
    {
        timer.active = false;
    }

    public function resume():Void
    {
        timer.active = true;
    }
}