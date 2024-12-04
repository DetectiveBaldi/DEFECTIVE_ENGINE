package game.events;

import flixel.FlxCamera;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import game.GameState;

class CameraZoomEvent
{
    public static function spawn(game:GameState, camera:String, zoom:Float, duration:Float, ease:String):Void
    {
        var _camera:FlxCamera = Reflect.getProperty(game, camera);

        if (duration > 0.0)
            FlxTween.tween(camera, {zoom: zoom}, duration, {ease: Reflect.getProperty(FlxEase, ease)});
        else
            _camera.zoom = zoom;
    }
}