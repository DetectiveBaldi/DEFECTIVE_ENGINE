package menus;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

import core.AssetCache;
import core.Paths;
import game.PlayState;

import ui.AtlasText;

class PauseMenu extends FlxSubState
{
    public static var selectedIndex:Int = 0;

    public var game:PlayState;

    public var items:FlxTypedSpriteGroup<AtlasText>;

    public function new(game:PlayState):Void
    {
        super(FlxColor.BLACK);

        this.game = game;
    }

    override function create():Void
    {
        super.create();

        _bgSprite.alpha = 0.5;

        items = new FlxTypedSpriteGroup<AtlasText>();

        add(items);

        addItem("Resume");

        addItem("Restart");

        playScrollSound();
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

        selectedIndex = FlxMath.wrap(selectedIndex, 0, items.members.length - 1);

        for (i in 0 ... items.members.length)
        {
            var isSelected:Bool = selectedIndex == i;

            var item:AtlasText = items.members[i];

            var lerp:Float = FlxMath.getElapsedLerp(0.15, elapsed);

            item.setPosition(FlxMath.lerp(item.x, 90.0 + (90 * i) + (isSelected ? 45.0 : 0.0), lerp), FlxMath.lerp(item.y, 320.0 + (120.0 * i), lerp));

            item.alpha = isSelected ? 1.0 : 0.5;
        }

        if (FlxG.keys.justPressed.ENTER)
        {
            var item:AtlasText = items.members[selectedIndex];

            switch (item.text:String)
            {
                case "Resume":
                    pressResume();

                case "Restart":
                    pressRestart();
            }
        }
    }

    public function addItem(text:String):AtlasText
    {
        var item:AtlasText = new AtlasText(45.0, 160.0, text);

        item.font = BOLD;

        items.add(item);

        return item;
    }

    public function pressResume():Void
    {
        game.resume();
    }

    public function pressRestart():Void
    {
        selectedIndex = 0;

        FlxG.resetState();
    }

    public function playScrollSound():Void
    {
        var scrollSound:FlxSound = FlxG.sound.play(AssetCache.getSound("ui/scroll"));

        scrollSound.onComplete = scrollSound.kill;
    }
}