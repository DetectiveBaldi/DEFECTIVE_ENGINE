package menus.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.typeLimit.NextState;

import flixel.addons.display.FlxBackdrop;

import core.AssetCache;
import core.Paths;
import menus.options.items.BaseOptionItem;
import menus.options.items.BoolOptionItem;
import menus.options.items.NumberOptionItem;
import ui.AtlasText;

class OptionsMenu extends FlxState
{
    public static var selectedIndex:Int = 0;

    public var nextState:NextState;

    public var background:FlxSprite;

    public var bgOverlay:FlxBackdrop;

    public var optionItems:FlxTypedSpriteGroup<BaseOptionItem>;

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

        background = new FlxSprite(0.0, 0.0, AssetCache.getGraphic(Paths.image(Paths.png("menus/options/OptionsMenu/background"))));

        background.screenCenter();

        add(background);

        bgOverlay = new FlxBackdrop(AssetCache.getGraphic(Paths.image(Paths.png("menus/options/OptionsMenu/bg-overlay"))));

        bgOverlay.velocity.set(10.0, 10.0);

        bgOverlay.alpha = 0.35;

        bgOverlay.screenCenter();

        add(bgOverlay);

        optionItems = new FlxTypedSpriteGroup<BaseOptionItem>();

        add(optionItems);

        var item:BaseOptionItem = new BaseOptionItem(0.0, 0.0, "Open Keybinds...", "");

        item.onToggle.add( () -> openSubState(new KeybindsMenu()) );

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Auto Pause", "If checked, the game will freeze when window focus is lost.", "autoPause");

        item.onUpdate.add((value:Bool) -> 
        {
            FlxG.autoPause = value;

            FlxG.console.autoPause = FlxG.autoPause;
        });

        addOptionItem(item);

        var item:IntOptionItem = new IntOptionItem(0.0, 0.0, "Frame Rate", "How often the game ticks each second.", "frameRate", 60, 240, 1);

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

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "GPU Caching", "If checked, bitmap pixel data is disposed\nfrom RAM where possible.", "gpuCaching");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Sound Streaming", "If checked, audio is loaded progressively\nwhere suitable.", "soundStreaming");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Flashing Lights", "If unchecked, limits the use of screen flashing effects.", "flashingLights");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Shaders", "If unchecked, shaders and screen filters are disabled.", "shaders");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Downscroll", "If checked, flips the strumlines' vertical position.", "downscroll");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Ghost Tapping", "If unchecked, pressing an input with\nno notes on screen will cause damage.", "ghostTapping");

        addOptionItem(item);

        var item:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Botplay", "If checked, inputs will be processed automatically.", "botplay");

        addOptionItem(item);

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
            if (i < 4.0)
                continue;
            
            y -= 85.0;
        }

        optionItems.y = FlxMath.lerp(optionItems.y, y, FlxMath.getElapsedLerp(0.15, elapsed));

        for (i in 0 ... optionItems.members.length)
        {
            var isSelected:Bool = selectedIndex == i;

            var item:BaseOptionItem = optionItems.members[i];

            item.busy = !isSelected;

            item.x = FlxMath.lerp(item.x, isSelected ? 100.0 : 50.0, FlxMath.getElapsedLerp(0.15, elapsed));
        }

        if (FlxG.keys.justPressed.SPACE)
        {
            for (i in 0 ... optionItems.members.length)
            {
                var item:BaseOptionItem = optionItems.members[i];

                item.titleText.text = Std.string(FlxG.random.int(1000000, 10000000));
            }
        }

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
        var scrollSound:FlxSound = FlxG.sound.play(AssetCache.getSound("menus/scroll"));

        scrollSound.onComplete = scrollSound.kill;
    }
}