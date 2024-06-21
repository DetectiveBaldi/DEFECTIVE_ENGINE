package objects;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

class Note extends FlxSprite
{
    public static var directions(default, null):Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public var time:Float;

    public var speed:Float;

    public var direction(default, set):Null<Int>;

    @:noCompletion
    function set_direction(direction:Null<Int>):Null<Int>
    {
        if (directions.indexOf(directions[direction]) != -1)
        {
            frames = FlxAtlasFrames.fromTexturePackerXml("assets/images/notes/classic.png", "assets/images/notes/classic.xml");

            animation.addByPrefix(directions[direction].toLowerCase(), directions[direction].toLowerCase() + "0", 24, false);

            animation.addByPrefix(directions[direction].toLowerCase() + "HoldPiece", directions[direction].toLowerCase() + "HoldPiece0", 24, false);

            animation.addByPrefix(directions[direction].toLowerCase() + "HoldEnd", directions[direction].toLowerCase() + "HoldEnd0", 24, false);

            animation.play(directions[direction].toLowerCase());

            return this.direction = direction;
        }

        loadGraphic("flixel/images/logo/default.png");

        return this.direction = null;
    }

    public var lane:Int;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        time = 0.0;

        speed = 1.0;

        direction = -1;

        lane = 0;
    }
}