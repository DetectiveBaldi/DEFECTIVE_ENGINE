package menus.options.items;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetCache;
import core.Paths;

using tools.ObjectHelpers;

class BoolOptionItem extends VarOptionItem<Bool>
{
    public var checkbox:FlxSprite;

    public function new(x:Float = 0.0, y:Float = 0.0, title:String, description:String, option:String):Void
    {
        super(x, y, title, description, option);

        checkbox = new FlxSprite();

        checkbox.antialiasing = true;

        checkbox.frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic("menus/options/items/BoolOptionItem/checkbox"),
            Paths.image(Paths.xml("menus/options/items/BoolOptionItem/checkbox")));

        checkbox.scale.set(0.65, 0.65);

        checkbox.updateHitbox();

        checkbox.animation.onFinish.add((name:String) ->
        {
            if (name == "uncheck")
                checkbox.animation.play("idle");
        });

        checkbox.animation.addByPrefix("idle", "Check Box unselected", 24.0, false);

        checkbox.animation.addByPrefix("check", "Check Box selecting animation", 24.0, false);

        checkbox.animation.addByPrefix("uncheck", "Check Box selecting animation", 28.0, false);

        checkbox.animation.play(value ? "check" : "idle");

        checkbox.animation.finish();

        checkbox.setPosition(titleText.x + titleText.width + 10.0, -30.0);

        add(checkbox);

        onToggle.add(() ->
        {
            setValue(!value);
            
            checkbox.animation.play(value ? "check" : "uncheck", true, !value);
        });
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (checkbox.animation.name == "idle")
            checkbox.offset.set(0.0, 5.0);
        else
            checkbox.offset.set(17.0, 70.0);
    }
}