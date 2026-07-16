package menus;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import core.AssetCache;
import core.Options;
import core.Paths;
import game.PlayState;
import interfaces.ISequenceHandler;
import menus.options.OptionsMenu;

import ui.AtlasText;

class PauseMenu extends FlxSubState implements ISequenceHandler
{
    public static var selectedIndex:Int = 0;

    public var game:PlayState;

    public var tweens:FlxTweenManager;

    public var timers:FlxTimerManager;

    public var optionItems:FlxTypedSpriteGroup<AtlasText>;

    public function new(game:PlayState):Void
    {
        super(FlxColor.BLACK);

        this.game = game;
    }

    override function create():Void
    {
        super.create();

        _bgSprite.alpha = 0.5;

        tweens = new FlxTweenManager();

        add(tweens);

        timers = new FlxTimerManager();

        add(timers);

        optionItems = new FlxTypedSpriteGroup<AtlasText>();

        add(optionItems);

        addOptionItem("Resume");

        addOptionItem("Restart");

        addOptionItem("Options");

        changeSelected(0);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.mouse.wheel == -1.0 || Options.keysJustPressed("ui down"))
            changeSelected(1);

        if (FlxG.mouse.wheel == 1.0 || Options.keysJustPressed("ui up"))
            changeSelected(-1);

        if (Options.keysJustPressed("ui accept"))
        {
            var item:AtlasText = optionItems.members[selectedIndex];

            selectedIndex = 0;

            switch (item.text:String)
            {
                case "Resume":
                    pressResume();

                case "Restart":
                    pressRestart();

                case "Options":
                    pressOptions();
            }
        }

        if (Options.keysJustPressed("ui back"))
            pressResume();
    }

    public function addOptionItem(text:String):AtlasText
    {
        var item:AtlasText = new AtlasText(110.0, 30.0 + optionItems.members.length * 70.0, text);

        item.font = BOLD;

        optionItems.add(item);

        return item;
    }

    public function changeSelected(value:Int):Int
    {
        selectedIndex = FlxMath.wrap(selectedIndex + value, 0, optionItems.members.length - 1);

        for (i in 0 ... optionItems.members.length)
        {
            var isSelected:Bool = selectedIndex == i;

            var item:AtlasText = optionItems.members[i];

            item.alpha = isSelected ? 1.0 : 0.65;

            var range:Float = FlxMath.remapToRange((i - selectedIndex), 0.0, 1.0, 0.0, 1.35);

            var x:Float = 120.0 + range * 35.0;

            var y:Float = camera.height * 0.4 + range * 100.0;

            tweens.cancelTweensOf(item);

            tweens.tween(item, {x: x, y: y}, 0.35, {ease: FlxEase.quartOut});
        }

        playScrollSound();
        
        return value;
    }

    public function pressResume():Void
    {
        game.resume();
    }

    public function pressRestart():Void
    {
        FlxG.resetState();
    }

    public function pressOptions():Void
    {
        FlxG.switchState(() -> new OptionsMenu(() -> PlayState.getClassFromLevel()));
    }

    public function playScrollSound():Void
    {
        var scrollSound:FlxSound = FlxG.sound.play(AssetCache.getSound("ui/scroll"));

        scrollSound.onComplete = scrollSound.kill;
    }
}