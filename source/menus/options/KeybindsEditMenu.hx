package menus.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.typeLimit.NextState;

import flixel.addons.display.FlxBackdrop;

import core.AssetCache;
import core.Paths;
import core.SaveManager;
import menus.options.items.BaseOptionItem;
import menus.options.items.BoolOptionItem;
import menus.options.items.HeaderOptionItem;
import menus.options.items.KeybindOptionItem;
import menus.options.items.NumOptionItem;

using tools.AlignTools;

class KeybindsEditMenu extends FlxSubState
{
    public static var selectedIndex:Int = 0;

    public var background:FlxBackdrop;

    public var optionItems:FlxTypedSpriteGroup<BaseOptionItem>;

    public var descBox:FlxSprite;

    public var descText:FlxText;

    public var tune:FlxSound;

    public function new():Void
    {
        super(FlxColor.BLACK);
    }

    override function create():Void
    {
        super.create();

        _bgSprite.alpha = 0.5;

        background = new FlxBackdrop(AssetCache.getGraphic("menus/options/OptionsMenu/bg-overlay"));

        background.velocity.set(10.0, 10.0);

        background.alpha = 0.35;

        background.screenCenter();

        add(background);

        optionItems = new FlxTypedSpriteGroup<BaseOptionItem>();

        add(optionItems);

        var item:HeaderOptionItem = new HeaderOptionItem(0.0, 0.0, "Notes");

        addOptionItem(item);

        var item:BaseOptionItem = new BaseOptionItem(0.0, 0.0, "Press to edit...", "");

        item.onToggle.add(() -> openSubState(new NoteKeybindsEditMenu()));

        addOptionItem(item);

        var item:HeaderOptionItem = new HeaderOptionItem(0.0, 0.0, "UI");

        addOptionItem(item);

        var item:KeybindOptionItem = new KeybindOptionItem(0.0, 0.0, "Left", "ui left");

        addOptionItem(item);

        item = new KeybindOptionItem(0.0, 0.0, "Right", "ui right");

        addOptionItem(item);

        item = new KeybindOptionItem(0.0, 0.0, "Up", "ui up");

        addOptionItem(item);

        item = new KeybindOptionItem(0.0, 0.0, "Down", "ui down");

        addOptionItem(item);

        item = new KeybindOptionItem(0.0, 0.0, "Back", "ui back");

        addOptionItem(item);

        item = new KeybindOptionItem(0.0, 0.0, "Accept", "ui accept");

        addOptionItem(item);

        var item:HeaderOptionItem = new HeaderOptionItem(0.0, 0.0, "Volume");

        addOptionItem(item);

        var item:KeybindOptionItem = new KeybindOptionItem(0.0, 0.0, "Up", "volume up");

        item.onUpdate.add((value:Array<Int>) -> FlxG.sound.volumeUpKeys = value.copy());

        addOptionItem(item);

        item = new KeybindOptionItem(0.0, 0.0, "Down", "volume down");

        item.onUpdate.add((value:Array<Int>) -> FlxG.sound.volumeDownKeys = value.copy());

        addOptionItem(item);

        item = new KeybindOptionItem(0.0, 0.0, "Mute", "volume mute");

        item.onUpdate.add((value:Array<Int>) -> FlxG.sound.muteKeys = value.copy());

        addOptionItem(item);
        
        var item:HeaderOptionItem = new HeaderOptionItem(0.0, 0.0, "Editors");

        addOptionItem(item);

        var item:KeybindOptionItem = new KeybindOptionItem(0.0, 0.0, "Character", "editors character");

        addOptionItem(item);

        changeSelected(0);

        descBox = new FlxSprite();

        descBox.frame = FlxG.bitmap.whitePixel;

        descBox.alpha = 0.5;

        descBox.color = FlxColor.BLACK;

        add(descBox);

        descText = new FlxText(0.0, 0.0, 0.0, 32);

        descText.setFormat(Paths.font(Paths.ttf("VCR OSD Mono")), 32, FlxColor.WHITE, CENTER);
        
        add(descText);

        tune = FlxG.sound.load(AssetCache.getMusic("menus/options/OptionsMenu/tune-edit"), 0.0, true);

        tune.fadeIn(1.0, 0.0, 1.0);

        tune.play();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.mouse.wheel == -1.0 || FlxG.keys.justPressed.DOWN)
            changeSelected(1);

        if (FlxG.mouse.wheel == 1.0 || FlxG.keys.justPressed.UP)
            changeSelected(-1);

        var y:Float = 0.0;

        for (i in 0 ... selectedIndex)
        {
            if (i < 2.0)
                continue;
            
            y -= 85.0;
        }

        optionItems.y = FlxMath.lerp(optionItems.y, y, FlxMath.getElapsedLerp(0.15, elapsed));

        for (i in 0 ... optionItems.members.length)
        {
            var isSelected:Bool = selectedIndex == i;

            var item:BaseOptionItem = optionItems.members[i];

            item.x = FlxMath.lerp(item.x, item.type == HEADER ? item.getCenterX() : isSelected ? 125.0 : 50.0, FlxMath.getElapsedLerp(0.15, elapsed));

            if (item.status != LOCKED)
                item.status = isSelected ? ENABLED : DEFAULT;
        }

        var item:BaseOptionItem = optionItems.members[selectedIndex];

        descText.text = item.description;

        descBox.visible = descText.text != "";

        descText.visible = descBox.visible;

        descText.setPosition(descText.getCenterX(), FlxG.height - descText.height - 50.0);

        descBox.setGraphicSize(descText.width + 25.0, descText.height + 25.0);

        descBox.updateHitbox();

        descBox.centerTo(descText);

        if (FlxG.keys.justPressed.ESCAPE && item.status != LOCKED)
            close();
    }

    override function close():Void
    {
        super.close();

        SaveManager.saveOptions();

        tune.stop();

        playCancelSound();
    }

    public function addOptionItem(item:BaseOptionItem):Void
    {
        item.y = 25.0 + (85.0 * optionItems.members.length);

        optionItems.add(item);
    }

    public function changeSelected(value:Int):Int
    {
        var item:BaseOptionItem = optionItems.members[selectedIndex];

        if (item.status == LOCKED)
            return -1;

        playScrollSound();

        if (value == 0.0)
        {
            item.status = ENABLED;

            return -1;
        }

        item.status = DEFAULT;

        selectedIndex = FlxMath.wrap(selectedIndex + value, 0, optionItems.members.length - 1);

        SaveManager.saveOptions();

        var item:BaseOptionItem = optionItems.members[selectedIndex];

        while (item.type == HEADER)
        {
            selectedIndex = FlxMath.wrap(selectedIndex + value, 0, optionItems.members.length - 1);

            item = optionItems.members[selectedIndex];
        }

        item.status = ENABLED;

        return value;
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