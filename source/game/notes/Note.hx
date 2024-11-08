package game.notes;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetMan;
import core.Paths;

class Note extends FlxSprite
{
    public static var textureConfigs:Map<String, NoteTextureConfig> = new Map<String, NoteTextureConfig>();

    public static var directions:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public static function findConfig(path:String):NoteTextureConfig
    {
        return Json.parse(AssetMan.text(Paths.json(path)));
    }

    /**
     * A structure containing texture-related information about `this` `Note`, such as .png and .xml locations.
     */
    public var textureConfig(default, set):NoteTextureConfig;
    
    @:noCompletion
    function set_textureConfig(textureConfig:NoteTextureConfig):NoteTextureConfig
    {
        switch (textureConfig.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(textureConfig.png)), Paths.xml(textureConfig.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(textureConfig.png)), Paths.xml(textureConfig.xml));
        }

        for (i in 0 ... Note.directions.length)
        {
            animation.addByPrefix(Note.directions[i].toLowerCase(), Note.directions[i].toLowerCase() + "0", 24.0, false);

            animation.addByPrefix(Note.directions[i].toLowerCase() + "HoldPiece", Note.directions[i].toLowerCase() + "HoldPiece0", 24.0, false);
            
            animation.addByPrefix(Note.directions[i].toLowerCase() + "HoldTail", Note.directions[i].toLowerCase() + "HoldTail0", 24.0, false);
        }

        antialiasing = textureConfig.antialiasing ?? true;

        return this.textureConfig = textureConfig;
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

        if (!textureConfigs.exists("classic"))
            textureConfigs.set("classic", findConfig("assets/data/game/notes/Note/classic"));

        textureConfig = textureConfigs["classic"];

        time = 0.0;

        speed = 1.0;

        direction = 0;

        lane = 0;

        length = 0.0;
    }
}

typedef NoteTextureConfig =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;
};