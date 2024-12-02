package menus;

import flixel.FlxSprite;

import core.AssetMan;
import core.Paths;

class HeaderOptionItem extends BaseOptionItem
{
    public var gear:FlxSprite;

    public function new(x:Float = 0.0, y:Float = 0.0, name:String, description:String):Void
    {
        super(x, y, name, description);

        gear = new FlxSprite(AssetMan.graphic(Paths.png("assets/images/menus/HeaderOptionItem/gear")));

        gear.active = false;

        gear.antialiasing = true;

        gear.setPosition(-165.0, background.getMidpoint().y - gear.height * 0.5);

        add(gear);
    }
}