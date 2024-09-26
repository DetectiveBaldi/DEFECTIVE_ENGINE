package game.events;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;

import game.GameState;

class SpeedChangeEvent
{
    public static function dispatch(game:GameState, speed:Float, duration:Float, ease:String):Void
    {
        if (duration > 0.0)
            FlxTween.tween(game, {songSpeed: game.chart.speed * speed}, duration, {ease: Reflect.getProperty(FlxEase, ease)});
        else
            game.chartSpeed = game.chart.speed * speed;
    }
}