package game.events;

import flixel.FlxG;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;

import game.GameState;

class SpeedChangeEvent
{
    public static function dispatch(speed:Float, duration:Float, ease:String):Void
    {
        if (Type.getClass(FlxG.state) != GameState)
            return;

        var game:GameState = cast (FlxG.state, GameState);

        var _ease:EaseFunction = Reflect.getProperty(FlxEase, ease);

        if (duration > 0.0)
            FlxTween.tween(game, {songSpeed: game.chart.speed * speed}, duration, {ease: _ease});
        else
            game.chartSpeed = game.chart.speed * speed;
    }
}