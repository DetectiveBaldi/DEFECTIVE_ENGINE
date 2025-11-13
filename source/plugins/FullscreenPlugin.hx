package plugins;

import flixel.FlxBasic;
import flixel.FlxG;

class FullscreenPlugin extends FlxBasic
{
    public function new():Void
    {
        super();

        visible = false;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.F11)
            FlxG.fullscreen = !FlxG.fullscreen;
    }
}