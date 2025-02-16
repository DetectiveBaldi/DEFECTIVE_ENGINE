package game.events;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import game.PlayState;

class ScrollSpeedChangeEvent
{
    public static function dispatch(game:PlayState, speed:Float, duration:Float, ease:String):Void
    {
        duration > 0.0 ? FlxTween.tween(game.playField, {scrollSpeed: game.chart.scrollSpeed * speed}, duration, {ease: Reflect.getProperty(FlxEase, ease)}) : game.playField.scrollSpeed = game.chart.scrollSpeed * speed;
    }
}