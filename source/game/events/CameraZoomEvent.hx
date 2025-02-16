package game.events;

import flixel.FlxCamera;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;

import game.PlayState;

class CameraZoomEvent
{
    public static function dispatch(game:PlayState, camera:String, zoom:Float, duration:Float, ease:String):Void
    {
        var _zoom:Float = Reflect.getProperty(game, camera + "TargetZoom");

        if (duration > 0.0)
            FlxTween.num(_zoom, zoom, duration, {ease: Reflect.getProperty(FlxEase, ease)}, (value:Float) -> Reflect.setProperty(game, camera + "TargetZoom", value));
        else
            Reflect.setProperty(game, camera + "TargetZoom", zoom);
    }
}