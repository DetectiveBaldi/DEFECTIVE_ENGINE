package game.notes;

import haxe.Json;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.Assets;
import core.Paths;

import music.Conductor;

using StringTools;

class Strum extends FlxSprite
{
    public static var configs:Map<String, StrumConfig> = new Map<String, StrumConfig>();

    public static var directions:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    
    public static function findConfig(path:String):StrumConfig
    {
        if (configs.exists(path))
            return configs[path];

        configs[path] = Json.parse(Assets.getText(Paths.json(path)));

        return configs[path];
    }

    public var conductor:Conductor;

    public var parent:StrumLine;
    
    public var config(default, set):StrumConfig;

    @:noCompletion
    function set_config(_config:StrumConfig):StrumConfig
    {
        config = _config;

        switch (config.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png(config.png)), Paths.xml(config.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(Assets.getGraphic(Paths.png(config.png)), Paths.xml(config.xml));
        }

        for (i in 0 ... Strum.directions.length)
        {
            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Static", Strum.directions[i].toLowerCase() + "Static0", 24.0, false);

            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Press", Strum.directions[i].toLowerCase() + "Press0", 24.0, false);
            
            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Confirm", Strum.directions[i].toLowerCase() + "Confirm0", 24.0, false);
        }

        antialiasing = config.antialiasing ?? true;

        return config;
    }

    public var direction:Int;

    public var confirmCount:Float;

    public function new(conductor:Conductor, x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        this.conductor = conductor;
        
        config = findConfig("assets/data/game/notes/Strum/classic");

        direction = 0;

        confirmCount = 0.0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor == null)
            return;

        if ((animation.name ?? "").endsWith("Confirm"))
        {
            confirmCount += elapsed;

            if (confirmCount >= (conductor.crotchet * 0.25) * 0.001)
            {
                confirmCount = 0.0;

                animation.play(directions[direction].toLowerCase() + (parent.automated ? "Static" : "Press"));
            }
        }
        else
            confirmCount = 0.0;
    }
}

typedef StrumConfig =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;
};