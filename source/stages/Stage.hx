package stages;

import flixel.FlxSprite;

import flixel.group.FlxContainer;

import core.Paths;

class Stage extends FlxContainer
{
    public var background(default, null):FlxSprite;

    public var foreground(default, null):FlxSprite;

    public var curtains(default, null):FlxSprite;

    public function new():Void
    {
        super();

        background = new FlxSprite(0, 0, Paths.png("assets/images/stages/stage/background"));

        background.screenCenter();

        add(background);

        foreground = new FlxSprite(0, 0, Paths.png("assets/images/stages/stage/foreground"));

        foreground.scale.set(1.15, 1.15);

        foreground.updateHitbox();

        foreground.setPosition(background.getMidpoint().x - foreground.width * 0.5, ((background.y + background.height) - foreground.height) + 175.0);
        
        add(foreground);

        curtains = new FlxSprite(0, 0, Paths.png("assets/images/stages/stage/curtains"));

        curtains.scale.set(0.95, 0.95);

        curtains.updateHitbox();

        curtains.setPosition(background.getMidpoint().x - curtains.width * 0.5, background.y);

        add(curtains);
    }
}