package game.events;

import flixel.FlxCamera;

import flixel.tweens.FlxEase;

import game.PlayState;

class CameraZoomEvent
{
    public static function dispatch(game:PlayState, camera:FlxCamera, zoom:Float, duration:Float, ease:String = "linear"):Void
    {
        if (camera == game.hudCamera)
        {
            if (duration > 0.0)
                game.tweens.tween(camera, {zoom: zoom}, duration, {ease: Reflect.getProperty(FlxEase, ease)});
            else
                camera.zoom = zoom;
        }
        else
        {
            if (duration > 0.0)
                game.tweens.tween(game.gameCamera, {zoom: zoom}, duration, {ease: Reflect.getProperty(FlxEase, ease)});
            else
                game.gameCamera.zoom = zoom;
        }
    }
}