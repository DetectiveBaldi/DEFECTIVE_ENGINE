package menus.options.items;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.sound.FlxSound;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

import core.AssetCache;
import core.Paths;
import ui.AtlasText;

class BaseOptionItem extends FlxSpriteGroup
{
    public var type:OptionItemType;

    public var status:OptionItemStatus;

    public var title:String;

    public var description:String;

    public var titleText:AtlasText;

    public var onToggle:FlxSignal;

    public function new(x:Float = 0.0, y:Float = 0.0, title:String, description:String):Void
    {
        super(x, y);

        type = BASE;

        status = DEFAULT;

        this.title = title;

        this.description = description;

        titleText = new AtlasText(0.0, 0.0, title);

        add(titleText);

        onToggle = new FlxSignal();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (((FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera)) || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && status == ENABLED)
            toggle();
    }

    override function destroy():Void
    {
        super.destroy();
        
        onToggle = cast FlxDestroyUtil.destroy(onToggle);
    }

    public function toggle():Void
    {
        onToggle.dispatch();
    }

    public function playCancelSound():Void
    {
        var cancelSound:FlxSound = FlxG.sound.play(AssetCache.getSound("ui/cancel"));

        cancelSound.onComplete = cancelSound.kill;
    }

    public function playScrollSound():Void
    {
        var scrollSound:FlxSound = FlxG.sound.play(AssetCache.getSound("ui/scroll"));

        scrollSound.onComplete = scrollSound.kill;
    }
}

enum OptionItemStatus
{
    /**
     * No special behavior.
     */
    DEFAULT;

    /**
     * `this` item is doing some basic behavior that can be overriden through menu interactions.
     */
    ENABLED;

    /**
     * `this` item is doing some more complex behavior that can not be overriden.
     */
    LOCKED;
}

enum OptionItemType
{
    BASE;

    BOOL;

    HEADER;

    KEYBIND;

    INT;

    FLOAT;

    VAR;
}