package game.notes;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetMan;
import core.Paths;

class Note extends FlxSprite
{
    public static var directions:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public var parent:Note;

    public var children:Array<Note>;

    /**
     * A structure containing texture-related information about this `Note`, such as .png and .xml locations.
     */
    public var textureData(default, set):NoteTextureData;
    
    @:noCompletion
    function set_textureData(textureData:NoteTextureData):NoteTextureData
    {
        switch (textureData.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(textureData.png), true), Paths.xml(textureData.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(textureData.png), true), Paths.xml(textureData.xml));
        }

        for (i in 0 ... Note.directions.length)
        {
            animation.addByPrefix(Note.directions[i].toLowerCase(), Note.directions[i].toLowerCase() + "0", 24.0, false);

            animation.addByPrefix(Note.directions[i].toLowerCase() + "HoldPiece", Note.directions[i].toLowerCase() + "HoldPiece0", 24.0, false);
            
            animation.addByPrefix(Note.directions[i].toLowerCase() + "HoldTail", Note.directions[i].toLowerCase() + "HoldTail0", 24.0, false);
        }

        antialiasing = textureData.antialiasing ?? true;

        return this.textureData = textureData;
    }

    public var time:Float;

    public var speed:Float;

    public var direction:Int;

    public var lane:Int;

    public var length:Float;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        active = false;

        children = new Array<Note>();

        textureData = Json.parse(AssetMan.text(Paths.json("assets/data/game/notes/classic")));

        time = 0.0;

        speed = 1.0;

        direction = -1;

        lane = 0;

        length = 0.0;
    }

    override function isOnScreen(?camera:FlxCamera):Bool
    {
        if (super.isOnScreen(camera))
            return true;

        for (i in 0 ... children.length)
        {
            var sustain:Note = children[i];

            if (sustain.exists && sustain.visible)
                if (sustain.isOnScreen(camera))
                    return true;
        }

        return false;
    }
}

typedef NoteTextureData =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Null<Bool>;
};