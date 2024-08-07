package stages;

import flixel.FlxBasic;

class Stage<T:FlxBasic>
{
    public var members(default, null):Array<T>;

    public function new():Void
    {
        members = new Array<T>();
    }
}