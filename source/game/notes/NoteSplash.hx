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
    public static var directions:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    /**
     * A structure containing texture-related information about this `NoteSplash`, such as .png and .xml locations, and animation declarations.
     */
    public var textureData(default, set):NoteSplashTextureData;

    @:noCompletion
    function set_textureData(textureData:NoteSplashTextureData):NoteSplashTextureData
    {
        switch (textureData.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(textureData.png), true), Paths.xml(textureData.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(textureData.png), true), Paths.xml(textureData.xml));
        }

        antialiasing = textureData.antialiasing ?? true;

        for (i in 0 ... textureData.animations.length)
        {
            for (j in 0 ... NoteSplash.directions.length)
            {
                animation.addByPrefix
                (
                    '${textureData.animations[i].prefix} ${NoteSplash.directions[j].toLowerCase()}',
                    
                    '${textureData.animations[i].prefix} ${NoteSplash.directions[j].toLowerCase()}',
                    
                    textureData.animations[i].frameRate ?? 24.0,

                    textureData.animations[i].looped ?? false,

                    textureData.animations[i].flipX ?? false,

                    textureData.animations[i].flipY ?? false
                );   
            }
        }

        return this.textureData = textureData;
    }

    public var direction:Int;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        textureData = Json.parse(AssetMan.text(Paths.json("assets/data/game/notes/noteSplashes/classic")));

        direction = -1;
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... textureData.animations.length)
            if (animation.name?.startsWith(textureData.animations[i].prefix))
                output.subtract(textureData.animations[i].offsets?.x ?? 0.0, textureData.animations[i].offsets?.y ?? 0.0);

        return output;
    }
}

typedef NoteSplashTextureData =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Null<Bool>;

    var animations:Array<{?offsets:Null<{?x:Null<Float>, ?y:Null<Float>}>, prefix:String, ?frameRate:Null<Float>, ?looped:Null<Bool>, ?flipX:Null<Bool>, ?flipY:Null<Bool>}>;
}