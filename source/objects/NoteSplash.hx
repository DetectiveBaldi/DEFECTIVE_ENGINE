package objects;

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
    public static var directions(default, null):Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    public var skin(default, set):NoteSplashSkin;

    @:noCompletion
    function set_skin(skin:NoteSplashSkin):NoteSplashSkin
    {
        switch (skin.format ?? "".toLowerCase():String)
        {
            case "sparrow":
                frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(skin.png)), Paths.xml(skin.xml));
            
            case "texturepackerxml":
                frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(skin.png)), Paths.xml(skin.xml));
        }

        for (i in 0 ... skin.animations.length)
        {
            for (j in 0 ... NoteSplash.directions.length)
            {
                animation.addByPrefix
                (
                    '${skin.animations[i].prefix} ${NoteSplash.directions[j].toLowerCase()}',
                    
                    '${skin.animations[i].prefix} ${NoteSplash.directions[j].toLowerCase()}',
                    
                    skin.animations[i].frameRate ?? 24.0,

                    skin.animations[i].flipX ?? false,

                    skin.animations[i].flipY ?? false
                );   
            }
        }

        return this.skin = skin;
    }

    public var direction:Int;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        skin = Json.parse(AssetMan.text(Paths.json("assets/images/noteSplashes/classic")));

        direction = -1;
    }

    override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
    {
        var output:FlxPoint = super.getScreenPosition(result, camera);

        for (i in 0 ... skin.animations.length)
            if ((animation.name ?? "").contains(skin.animations[i].prefix))
                output.subtract(skin.animations[i].offsets?.x ?? 0.0, skin.animations[i].offsets?.y ?? 0.0);

        return output;
    }
}

typedef NoteSplashSkin =
{
    var format:String;

    var png:String;

    var xml:String;

    var animations:Array<{?offsets:{?x:Float, ?y:Float}, prefix:String, ?frameRate:Float, ?looped:Bool, ?flipX:Bool, ?flipY:Bool}>;
}