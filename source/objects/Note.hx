package objects;

import haxe.Json;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetMan;
import core.Paths;

class Note extends FlxSprite
{
    public static var directions(default, null):Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public var skin(default, set):NoteSkin;

    @:noCompletion
    function set_skin(skin:NoteSkin):NoteSkin
    {
        switch (skin.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(skin.png)), Paths.xml(skin.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(skin.png)), Paths.xml(skin.xml));
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

    public var parent:Note;

    public var children:Array<Note>;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        skin = Json.parse(AssetMan.text(Paths.json("assets/images/notes/classic")));

        time = 0.0;

        speed = 1.0;

        direction = -1;

        lane = 0;

        length = 0.0;

        children = new Array<Note>();
    }
}

typedef NoteSkin =
{
    var format:String;

    var png:String;

    var xml:String;
};