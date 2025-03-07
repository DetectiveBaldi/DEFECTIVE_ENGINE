package menus;

import flixel.FlxG;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.Paths;
import core.Assets;

class BoolOptionItem extends VariableOptionItem<Bool>
{
    public var selectable:Bool;

    public var checkbox:FlxSprite;

    public function new(_x:Float = 0.0, _y:Float = 0.0, _title:String, _description:String, _option:String):Void
    {
        super(_x, _y, _title, _description, _option);

        selectable = false;

        checkbox = new FlxSprite();

        checkbox.antialiasing = true;

        checkbox.frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png("assets/images/menus/BoolOptionItem/checkbox")), Paths.xml("assets/images/menus/BoolOptionItem/checkbox"));

        checkbox.animation.addByIndices("check", "checkbox", [0, 1, 2, 3, 4, 5, 6], "", 24.0, false);

        checkbox.animation.addByIndices("uncheck", "checkbox", [6, 5, 4, 3, 2, 1, 0], "", 24.0, false);

        checkbox.animation.play(value ? "check" : "uncheck");

        checkbox.setPosition(-125.0, background.height - checkbox.height - 10.0);

        add(checkbox);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        if ((FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed) && selectable)
        {
            value = !value;

            checkbox.animation.play(value ? "check" : "uncheck");
        }
    }
}