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
    public function getPathPrepend(useSharedPath:Bool = false, useCustomPath:Bool = false):String
    {
        var strResult:String = "";

        if (useSharedPath)
        {
            strResult = "game/stages/shared/";

            return strResult;
        }

        if (useCustomPath)
            return "";
        
        strResult = '${Type.getClassName(Type.getClass(this)).replace(".", "/")}/';

        return strResult;
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