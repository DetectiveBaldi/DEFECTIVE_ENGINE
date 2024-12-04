package menus;

import flixel.FlxSprite;

import flixel.tweens.FlxTween;

import core.Assets;
import core.Paths;

class HeaderOptionItem extends BaseOptionItem
{
    public var gear:FlxSprite;

    public function new(x:Float = 0.0, y:Float = 0.0, name:String, description:String):Void
    {
        super(x, y, name, description);

        gear = new FlxSprite(Assets.graphic(Paths.png("assets/images/menus/HeaderOptionItem/gear")));

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