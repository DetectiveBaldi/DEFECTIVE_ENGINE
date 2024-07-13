package objects;

import haxe.Json;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

class Note extends FlxSprite
{
    public static var directions(default, null):Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public var skin(default, set):NoteSkin;

    @:noCompletion
    function set_skin(skin:NoteSkin):NoteSkin
    {
        switch (skin.format.toLowerCase():String)
        {
            case "texturepackerxml":
            {
                frames = FlxAtlasFrames.fromTexturePackerXml(skin.source, skin.xml);
            }

            default:
            {
                frames = FlxAtlasFrames.fromSparrow(skin.source, skin.xml);
            }
        }

        for (i in 0 ... Note.directions.length)
        {
            animation.addByPrefix(Note.directions[i].toLowerCase(), Note.directions[i].toLowerCase() + "0", 24, false);

            animation.addByPrefix(Note.directions[i].toLowerCase() + "HoldPiece", Note.directions[i].toLowerCase() + "HoldPiece0", 24, false);

            animation.addByPrefix(Note.directions[i].toLowerCase() + "HoldTail", Note.directions[i].toLowerCase() + "HoldTail0", 24, false);
        }

        return this.skin = skin;
    }

    public var time:Float;

    public var speed:Float;

    public var direction:Int;

    public var lane:Int;

    public var length:Float;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        skin = cast Json.parse(#if html5 openfl.utils.Assets.getText("assets/images/notes/classic.json") #else sys.io.File.getContent("assets/images/notes/classic.json") #end);

        time = 0.0;

        speed = 1.0;

        direction = -1;

        lane = 0;

        length = 0.0;
    }

    override function destroy():Void
    {
        super.destroy();

        time = 0.0;

        speed = 1.0;

        direction = -1;

        lane = 0;

        length = 0.0;
    }
}

typedef NoteSkin =
{
    var ?format:String;

    var source:String;

    var xml:String;
};