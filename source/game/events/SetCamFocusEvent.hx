package game.events;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class SetCamFocusEvent
{
    public static function dispatch(game:PlayState, x:Float = 0.0, y:Float = 0.0, charType:String = "", duration:Float,
        ease:String = "linear", skipCameraLock:Bool = false):Void
    {
        if (charType == "")
        {
            if ((game.cameraLock == FOCUS_CAM_CHAR || game.cameraLock == NONE) && !skipCameraLock)
                return;
        }
        else
        {
            if ((game.cameraLock == FOCUS_CAM_POINT || game.cameraLock == NONE) && !skipCameraLock)
                return;

            var char:Character = Reflect.getProperty(game, charType);

            x = char.getMidpoint().x + char.config.cameraPoint.x;

            y = char.getMidpoint().y + char.config.cameraPoint.y;
        }

        if (duration > 0.0)
        {
            game.gameCamera.follow(null, LOCKON, 0.05);

            game.cameraPoint.setPosition(x, y);

            game.tweens.tween(game.gameCamera.scroll, {x: game.cameraPoint.x - game.gameCamera.width * 0.5, y: game.cameraPoint.y - game.gameCamera.height * 0.5}, game.conductor.stepLength * duration * 0.001,
            {
                ease: Reflect.getProperty(FlxEase, ease),

                onComplete: (_tween:FlxTween) -> game.gameCamera.follow(game.cameraPoint, LOCKON, 0.05)
            });
        }
        else
        {
            game.cameraPoint.setPosition(x, y);

            if (duration == 0.0)
                game.gameCamera.snapToTarget();
        }
    }
}