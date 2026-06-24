package game.stages;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.group.FlxGroup;

import flixel.util.FlxAxes;

import flixel.addons.display.FlxBackdrop;

import core.AssetCache;
import core.Paths;

using StringTools;

class Stage extends FlxGroup
{
    public var params:StageParams;

    public var zoom(get, set):Float;

    @:noCompletion
    function get_zoom():Float
    {
        return params.zoom;
    }

    function set_zoom(v:Float):Float
    {
        params.zoom = v;

        return v;
    }

    public function new(param:StageParams):Void
    {
        super();

        params = param;
    }

    public function getPathPrepend(useSharedPath:Bool = false, useCustomPath:Bool = false):String
    {
        var result:String = "";

        if (useSharedPath)
        {
            result = "game/stages/shared/";

            return result;
        }

        if (useCustomPath)
            return "";
        
        result = '${Type.getClassName(Type.getClass(this)).replace(".", "/")}/';

        return result;
    }

    public function getSprite(file:String, useSharedPath:Bool = false, useCustomPath:Bool = false,
        scaleX:Float = 1.15, scaleY:Float = 1.15):FlxSprite
    {
        file = '${getPathPrepend(useSharedPath, useCustomPath)}${file}';

        var newSprite:FlxSprite = new FlxSprite(0.0, 0.0, AssetCache.getGraphic(file));

        newSprite.active = false;

        newSprite.visible = false;

        newSprite.scale.set(scaleX, scaleY);

        newSprite.updateHitbox();

        newSprite.screenCenter();

        add(newSprite);

        return newSprite;
    }

    public function getAtlasSprite(file:String, useSharedPath:Bool = false, useCustomPath:Bool = false,
        scaleX:Float = 1.15, scaleY:Float = 1.15):FlxSprite
    {
        file = '${getPathPrepend(useSharedPath, useCustomPath)}${file}';

        var newSprite = new FlxSprite();

        newSprite.active = false;

        newSprite.visible = false;

        newSprite.frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic(file), Paths.image(Paths.xml(file)));

        newSprite.scale.set(scaleX, scaleY);

        newSprite.updateHitbox();

        newSprite.screenCenter();

        add(newSprite);

        return newSprite;
    }

    public function getBackdrop(file:String, useSharedPath:Bool = false, useCustomPath:Bool = false,
        axes:FlxAxes = XY, scaleX:Float = 1.15, scaleY:Float = 1.15):FlxBackdrop
    {
        file = '${getPathPrepend(useSharedPath, useCustomPath)}${file}';

        var newBackdrop:FlxBackdrop = new FlxBackdrop(AssetCache.getGraphic(file), axes);

        newBackdrop.active = false;

        newBackdrop.visible = false;

        newBackdrop.scale.set(scaleX, scaleY);

        newBackdrop.updateHitbox();

        newBackdrop.screenCenter();

        add(newBackdrop);

        return newBackdrop;
    }
}

typedef StageParams =
{
    var zoom:Float;
}