package game.stages;

import flixel.FlxBasic;

class Stage<T:FlxBasic>
{
    public var members:Array<T>;

    public function new():Void
    {
        members = new Array<T>();
    }
}