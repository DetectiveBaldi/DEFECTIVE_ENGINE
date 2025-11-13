package menus.options.items;

import flixel.FlxSprite;

import flixel.tweens.FlxTween;

import core.AssetCache;
import core.Paths;

class HeaderOptionItem extends BaseOptionItem
{
    public var gear:FlxSprite;

    public function new(_x:Float = 0.0, _y:Float = 0.0, _title:String, _description:String):Void
    {
        super(_x, _y, _title, _description);

        gear = new FlxSprite(AssetCache.getGraphic("menus/options/items/HeaderOptionItem/gear"));

        gear.active = false;

        gear.antialiasing = true;

        gear.setPosition(-165.0, background.getMidpoint().y - gear.height * 0.5);

        add(gear);

        FlxTween.angle(gear, 0.0, -360.0, 10.0, {type: LOOPING});
    }

    override function destroy():Void
    {
        super.destroy();

        FlxTween.cancelTweensOf(gear);
    }
}