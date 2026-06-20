package menus.options.items;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

import ui.AtlasText;

class BaseOptionItem extends FlxSpriteGroup
{
    public var busy:Bool;

    public var title:String;

    public var description:String;

    public var titleText:AtlasText;

    public var onToggle:FlxSignal;

    public function new(x:Float = 0.0, y:Float = 0.0, title:String, description:String):Void
    {
        super(x, y);

        busy = false;

        this.title = title;

        this.description = description;

        titleText = new AtlasText(0.0, 0.0, title);

        add(titleText);

        onToggle = new FlxSignal();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (busy)
            return;

        if (FlxG.mouse.justReleased || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
            onToggle.dispatch();
    }

    override function destroy():Void
    {
        super.destroy();
        
        onToggle = cast FlxDestroyUtil.destroy(onToggle);
    }
}