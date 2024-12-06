package game.notes;

import haxe.Json;

import flixel.FlxCamera;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.math.FlxPoint;

import core.Assets;
import core.Paths;

using StringTools;

class NoteSplash extends FlxSprite
{
    public static var configs:Map<String, NoteSplashConfig> = new Map<String, NoteSplashConfig>();

    public static var directions:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public static function findConfig(path:String):NoteSplashConfig
    {
        if (configs.exists(path))
            return configs[path];

        configs[path] = Json.parse(Assets.getText(Paths.json(path)));

        return configs[path];
    }
    
    public var config(default, set):NoteSplashConfig;

    @:noCompletion
        function set_config(_config:NoteSplashConfig):NoteSplashConfig
        {
            config = _config;

            switch (config.format ?? "".toLowerCase():String)
            {
                case "sparrow":
                    frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png(config.png)), Paths.xml(config.xml));
                
                case "texturepackerxml":
                    frames = FlxAtlasFrames.fromTexturePackerXml(Assets.getGraphic(Paths.png(config.png)), Paths.xml(config.xml));
            }

            antialiasing = config.antialiasing ?? true;

            for (i in 0 ... config.frames.length)
            {
                var _frames:NoteSplashFramesData = config.frames[i];

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

            return config;
        }

    public var direction:Int;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        config = findConfig("assets/data/game/notes/NoteSplash/classic");

        direction = 0;
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... config.frames.length)
        {
            var _frames:NoteSplashFramesData = config.frames[i];

            if ((animation.name ?? "").startsWith(_frames.prefix))
                output.subtract(_frames.offset?.x ?? 0.0, _frames.offset?.y ?? 0.0);
        }

        return output;
    }
}

typedef NoteSplashConfig =
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