package objects;

import haxe.Json;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.Conductor;
import core.Paths;

class Strum extends FlxSprite
{
    public static var directions(default, null):Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public var skin(default, set):StrumSkin;

    @:noCompletion
    function set_skin(skin:StrumSkin):StrumSkin
    {
        switch (skin.format ?? "".toLowerCase():String)
        {
            case "texturepackerxml":
            {
                frames = FlxAtlasFrames.fromTexturePackerXml(Paths.png(skin.png), Paths.xml(skin.xml));
            }

            default:
            {
                frames = FlxAtlasFrames.fromSparrow(Paths.png(skin.png), Paths.xml(skin.xml));
            }
        }

        for (i in 0 ... Strum.directions.length)
        {
            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Static", Strum.directions[i].toLowerCase() + "Static0", 24, false);

            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Press", Strum.directions[i].toLowerCase() + "Press0", 24, false);

            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Confirm", Strum.directions[i].toLowerCase() + "Confirm0", 24, false);
        }

        return this.skin = skin;
    }

    public var direction:Int;

    public var parent:StrumLine;

    public var confirmCount:Float;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);
        
        skin = Json.parse(#if html5 openfl.utils.Assets.getText("assets/images/strums/classic.json") #else sys.io.File.getContent("assets/images/strums/classic.json") #end);

        direction = -1;

        confirmCount = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (StringTools.endsWith(animation.name ?? "", "Confirm"))
        {
            confirmCount += elapsed;

            if (confirmCount >= (Conductor.current.crotchet * 0.25) * 0.001)
            {
                confirmCount = 0.0;

                animation.play(directions[direction].toLowerCase() + (parent.artificial ? "Static" : "Press"));
            }
        }
        else
        {
            confirmCount = 0.0;
        }
    }

    override function destroy():Void
    {
        super.destroy();

        @:bypassAccessor
        {
            skin = null;
        }

        direction = -1;

        parent = null;

        confirmCount = 0.0;
    }
}

typedef StrumSkin =
{
    var ?format:String;

    var png:String;

    var xml:String;
};