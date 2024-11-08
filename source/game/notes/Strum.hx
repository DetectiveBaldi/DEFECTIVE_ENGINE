package game.notes;

import haxe.Json;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetMan;
import core.Conductor;
import core.Paths;

using StringTools;

class Strum extends FlxSprite
{
    public static var textureConfigs:Map<String, StrumTextureConfig> = new Map<String, StrumTextureConfig>();

    public static var directions:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    
    public static function findConfig(path:String):StrumTextureConfig
    {
        return Json.parse(AssetMan.text(Paths.json(path)));
    }

    public var conductor:Conductor;

    public var parent:StrumLine;

    /**
     * A structure containing texture-related information about `this` `Strum`, such as .png and .xml locations.
     */
    public var textureConfig(default, set):StrumTextureConfig;

    @:noCompletion
    function set_textureConfig(textureConfig:StrumTextureConfig):StrumTextureConfig
    {
        switch (textureConfig.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(textureConfig.png)), Paths.xml(textureConfig.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(textureConfig.png)), Paths.xml(textureConfig.xml));
        }

        for (i in 0 ... Strum.directions.length)
        {
            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Static", Strum.directions[i].toLowerCase() + "Static0", 24.0, false);

            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Press", Strum.directions[i].toLowerCase() + "Press0", 24.0, false);
            
            animation.addByPrefix(Strum.directions[i].toLowerCase() + "Confirm", Strum.directions[i].toLowerCase() + "Confirm0", 24.0, false);
        }

        antialiasing = textureConfig.antialiasing ?? true;

        return this.textureConfig = textureConfig;
    }

    public var direction:Int;

    public var confirmCount:Float;

    public function new(conductor:Conductor, x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        this.conductor = conductor;
        
        if (!textureConfigs.exists("classic"))
            textureConfigs.set("classic", findConfig("assets/data/game/notes/Strum/classic"));
        
        textureConfig = textureConfigs["classic"];

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

                animation.play(directions[direction].toLowerCase() + (parent.artificial ? "Static" : "Press"));
            }
        }
        else
            confirmCount = 0.0;
    }
}

typedef StrumTextureConfig =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;
};