package game.notes;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxPoint;

import core.AssetMan;
import core.Paths;

using StringTools;

class NoteSplash extends FlxSprite
{
    public static var textureConfigs:Map<String, NoteSplashTextureConfig> = new Map<String, NoteSplashTextureConfig>();

    public static var directions:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public static function findConfig(path:String):NoteSplashTextureConfig
    {
        return Json.parse(AssetMan.text(Paths.json(path)));
    }

    /**
     * A structure containing texture-related information about `this` `NoteSplash`, such as .png and .xml locations, and animation declarations.
     */
    public var textureConfig(default, set):NoteSplashTextureConfig;

    @:noCompletion
    function set_textureConfig(textureConfig:NoteSplashTextureConfig):NoteSplashTextureConfig
    {
        switch (textureConfig.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(textureConfig.png)), Paths.xml(textureConfig.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(textureConfig.png)), Paths.xml(textureConfig.xml));
        }

        antialiasing = textureConfig.antialiasing ?? true;

        for (i in 0 ... textureConfig.frames.length)
        {
            var _frames:NoteSplashFramesData = textureConfig.frames[i];

            for (j in 0 ... NoteSplash.directions.length)
            {
                animation.addByPrefix
                (
                    '${_frames.prefix} ${NoteSplash.directions[j].toLowerCase()}',
                    
                    '${_frames.prefix} ${NoteSplash.directions[j].toLowerCase()}',
                    
                    _frames.frameRate ?? 24.0,

                    _frames.looped ?? false,

                    _frames.flipX ?? false,

                    _frames.flipY ?? false
                );   
            }
        }

        return this.textureConfig = textureConfig;
    }

    public var direction:Int;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        if (!textureConfigs.exists("classic"))
            textureConfigs.set("classic", findConfig("assets/data/game/notes/NoteSplash/classic"));

        textureConfig = textureConfigs["classic"];

        direction = 0;
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... textureConfig.frames.length)
        {
            var _frames:NoteSplashFramesData = textureConfig.frames[i];

            if ((animation.name ?? "").startsWith(_frames.prefix))
                output.subtract(_frames.offset?.x ?? 0.0, _frames.offset?.y ?? 0.0);
        }

        return output;
    }
}

typedef NoteSplashTextureConfig =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;

    var frames:Array<NoteSplashFramesData>;
};

typedef NoteSplashFramesData =
{   
    var prefix:String;
    
    var ?frameRate:Float;
    
    var ?looped:Bool;
    
    var ?flipX:Bool;
    
    var ?flipY:Bool;

    var ?offset:{?x:Float, ?y:Float};
};