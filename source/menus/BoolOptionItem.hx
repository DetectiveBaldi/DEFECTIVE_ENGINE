package menus;

import flixel.FlxG;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.Paths;
import core.AssetMan;

class BoolOptionItem extends BaseOptionItem<Bool>
{
    public var enabled:Bool;

    public var checkbox:FlxSprite;

    public function new(x:Float = 0.0, y:Float = 0.0, name:String, description:String, option:String):Void
    {
        super(x, y, name, description, option);

        enabled = true;

        checkbox = new FlxSprite();

        checkbox.antialiasing = true;

        checkbox.color = checkbox.color.getDarkened(0.25);

        checkbox.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png("assets/images/menus/BoolOptionItem/checkbox")), Paths.xml("assets/images/menus/BoolOptionItem/checkbox"));

        checkbox.animation.addByIndices("check", "checkbox", [0, 1, 2, 3, 4, 5, 6], "", 24.0, false);

        checkbox.animation.addByIndices("uncheck", "checkbox", [6, 5, 4, 3, 2, 1, 0], "", 24.0, false);

        checkbox.animation.play(value ? "check" : "uncheck");

        checkbox.setPosition(-125.0, background.height - checkbox.height - 10.0);

        insert(0, checkbox);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        if ((FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed) && enabled)
            set(!value);
    }

    override function set(value:Bool):Bool
    {
        super.set(value);

        checkbox.animation.play(value ? "check" : "uncheck");

        return value;
    }
}