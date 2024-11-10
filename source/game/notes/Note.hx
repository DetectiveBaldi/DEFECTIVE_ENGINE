package game.notes;

import haxe.Json;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetMan;
import core.Paths;

class Note extends FlxSprite
{
    public static var configs:Map<String, NoteConfig> = new Map<String, NoteConfig>();

    public static var directions:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public static function findConfig(path:String):NoteConfig
    {
        if (configs.exists(path))
            return configs[path];

        configs[path] = Json.parse(AssetMan.text(Paths.json(path)));

        return configs[path];
    }
    
    public var config(default, set):NoteConfig;
    
    @:noCompletion
    function set_config(config:NoteConfig):NoteConfig
    {
        switch (config.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(config.png)), Paths.xml(config.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(config.png)), Paths.xml(config.xml));
        }

        for (i in 0 ... Note.directions.length)
        {
            animation.addByPrefix(Note.directions[i].toLowerCase(), Note.directions[i].toLowerCase() + "0", 24.0, false);

            animation.addByPrefix(Note.directions[i].toLowerCase() + "HoldPiece", Note.directions[i].toLowerCase() + "HoldPiece0", 24.0, false);
            
            animation.addByPrefix(Note.directions[i].toLowerCase() + "HoldTail", Note.directions[i].toLowerCase() + "HoldTail0", 24.0, false);
        }

        antialiasing = config.antialiasing ?? true;

        return this.config = config;
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

        if (!configs.exists("classic"))
            configs.set("classic", findConfig("assets/data/game/notes/Note/classic"));

        config = configs["classic"];

        time = 0.0;

        speed = 1.0;

        direction = 0;

        lane = 0;

        length = 0.0;
    }
}

typedef NoteConfig =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;
};