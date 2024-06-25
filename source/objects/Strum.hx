package objects;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.Conductor;

class Strum extends FlxSprite
{
    public static var directions(default, null):Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public var direction(default, set):Null<Int>;

    @:noCompletion
    function set_direction(direction:Null<Int>):Null<Int>
    {
        if (directions.indexOf(directions[direction]) != -1)
        {
            frames = FlxAtlasFrames.fromTexturePackerXml("assets/images/strums/classic.png", "assets/images/strums/classic.xml");

            animation.addByPrefix(directions[direction].toLowerCase() + "Static", directions[direction].toLowerCase() + "Static0", 24, false);

            animation.addByPrefix(directions[direction].toLowerCase() + "Press", directions[direction].toLowerCase() + "Press0", 24, false);

            animation.addByPrefix(directions[direction].toLowerCase() + "Confirm", directions[direction].toLowerCase() + "Confirm0", 24, false);

            animation.play(directions[direction].toLowerCase() + "Static");

            return this.direction = direction;
        }

        loadGraphic("flixel/images/logo/default.png");

        return this.direction = null;
    }

    public var parent(default, null):StrumLine;

    public var confirmTimer:Float;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        direction = -1;

        confirmTimer = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (StringTools.endsWith(animation.name ?? "", "Confirm"))
        {
            confirmTimer += elapsed;

            if (confirmTimer >= (Conductor.current.crotchet * 0.25) * 0.001)
            {
                confirmTimer = 0.0;
                
                animation.play(directions[direction].toLowerCase() + (parent.artificial ? "Static" : "Press"));
            }
        }
        else
        {
            confirmTimer = 0.0;
        }
    }
}