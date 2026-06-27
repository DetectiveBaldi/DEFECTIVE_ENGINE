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
import editors.KeybindsEditorSubState;
import menus.options.items.BaseOptionItem;
import menus.options.items.BoolOptionItem;
import menus.options.items.NumberOptionItem;

using tools.ObjectHelpers;

class OptionsMenu extends FlxState
{
    public static var selectedIndex:Int = 0;

    public var nextState:NextState;

    public var background:FlxSprite;

    public var bgOverlay:FlxBackdrop;

    public var optionItems:FlxTypedSpriteGroup<BaseOptionItem>;

    public var descBox:FlxSprite;

    public var descText:FlxText;

    public var tune:FlxSound;

    public function new(nextState:NextState):Void
    {
        super();

        this.nextState = nextState;
    }

    override function create():Void
    {
        super.create();

        FlxG.mouse.visible = true;

        background = new FlxSprite(0.0, 0.0, AssetCache.getGraphic("menus/options/OptionsMenu/background"));

        background.screenCenter();

        add(background);

        bgOverlay = new FlxBackdrop(AssetCache.getGraphic("menus/options/OptionsMenu/bg-overlay"));

        bgOverlay.velocity.set(10.0, 10.0);

        bgOverlay.alpha = 0.35;

        bgOverlay.screenCenter();

        add(bgOverlay);

        optionItems = new FlxTypedSpriteGroup<BaseOptionItem>();

        add(optionItems);

        var item:BaseOptionItem = new BaseOptionItem(0.0, 0.0, "Open Keybinds...", "");

        item.onToggle.add( () -> openSubState(new KeybindsEditorSubState()) );

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Auto Pause", "If checked, the game will freeze when window focus is lost.", "autoPause");

        item.onUpdate.add((value:Bool) -> 
        {
            FlxG.autoPause = value;

            FlxG.console.autoPause = FlxG.autoPause;
        });

        addOptionItem(item);

        var item:IntOptionItem = new IntOptionItem(0.0, 0.0, "Frame Rate", "How often the game ticks each second.", "frameRate", 30, 240);

        item.onUpdate.add((value:Int) ->
        {
            if (value > FlxG.updateFramerate)
            {
                FlxG.updateFramerate = value;

                FlxG.drawFramerate = value;
            }
            else
            {
                FlxG.drawFramerate = value;

                FlxG.updateFramerate = value;
            }
        });

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Flashing Lights", "If unchecked, limits the use of screen flashing effects.", "flashingLights");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Shaders", "If unchecked, shaders and screen filters are disabled.", "shaders");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "GPU Caching", "If checked, bitmap pixel data is disposed from RAM\nwhere possible.", "gpuCaching");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Sound Streaming", "If checked, audio is loaded progressively where applicable.", "soundStreaming");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Downscroll", "If checked, flips the strumlines' vertical position.", "downscroll");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Ghost Tapping", "If unchecked, pressing an input with no notes on screen\nwill cause damage.", "ghostTapping");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Botplay", "If checked, note inputs will be processed automatically.", "botplay");

        addOptionItem(item);

        descBox = new FlxSprite();

        descBox.frame = FlxG.bitmap.whitePixel;

        descBox.alpha = 0.5;

        descBox.color = FlxColor.BLACK;

        add(descBox);

        descText = new FlxText(0.0, 0.0, 0.0, "", 32);

        descText.setFormat(Paths.font(Paths.ttf("VCR OSD Mono")), 32, FlxColor.WHITE, CENTER);
        
        add(descText);

        tune = FlxG.sound.load(AssetCache.getMusic("menus/options/OptionsMenu/tune"), 0.0, true);

        tune.fadeIn(1.0, 0.0, 1.0);

        tune.play();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.mouse.wheel == -1 || FlxG.keys.justPressed.DOWN)
        {
            selectedIndex++;

            playScrollSound();
        }

        if (FlxG.mouse.wheel == 1 || FlxG.keys.justPressed.UP)
        {
            selectedIndex--;

            playScrollSound();
        }

        selectedIndex = FlxMath.wrap(selectedIndex, 0, optionItems.members.length - 1);

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

            item.x = FlxMath.lerp(item.x, isSelected ? 125.0 : 50.0, FlxMath.getElapsedLerp(0.15, elapsed));

            item.enabled = isSelected;
        }

        var item:BaseOptionItem = optionItems.members[selectedIndex];

        descText.text = item.description;

        descBox.visible = descText.text != "";

        descText.visible = descBox.visible;

        descText.setPosition(descText.getCenterX(), FlxG.height - 96.0);

        descBox.setGraphicSize(descText.width + 25.0, descText.height + 25.0);

        descBox.updateHitbox();

        descBox.centerTo(descText);

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(nextState);
    }

    override function openSubState(subState:FlxSubState):Void
    {
        super.openSubState(subState);

        tune.pause();
    }

    override function closeSubState():Void
    {
        super.closeSubState();

        tune.resume();
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.mouse.visible = false;
    }

    public function addOptionItem(item:BaseOptionItem):Void
    {
        item.y = 25.0 + (85.0 * optionItems.members.length);

        optionItems.add(item);
    }

    public function playScrollSound():Void
    {
        var scrollSound:FlxSound = FlxG.sound.play(AssetCache.getSound("ui/scroll"));

        scrollSound.onComplete = scrollSound.kill;
    }
}