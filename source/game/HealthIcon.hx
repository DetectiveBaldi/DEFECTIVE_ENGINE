package game;

import haxe.Json;

import flixel.FlxSprite;

import core.AssetMan;
import core.Paths;

class HealthIcon extends FlxSprite
{
    public var textureData(default, set):HealthIconTextureData;

    @:noCompletion
    function set_textureData(textureData:HealthIconTextureData):HealthIconTextureData
    {
        loadGraphic(AssetMan.graphic(Paths.png(textureData.png), true));

        antialiasing = textureData.antialiasing ?? true;

        scale.set(textureData.scale?.x ?? 1.0, textureData.scale?.y ?? 1.0);

        updateHitbox();

        return this.textureData = textureData;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, path:String):Void
    {
        super(x, y);

        active = false;

        textureData = Json.parse(AssetMan.text(Paths.json(path)));
    }
}

typedef HealthIconTextureData =
{
    var png:String;

    var ?antialiasing:Null<Bool>;

    var ?scale:{?x:Null<Float>, ?y:Null<Float>};
}