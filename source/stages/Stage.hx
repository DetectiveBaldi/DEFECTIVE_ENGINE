package stages;

import flixel.FlxSprite;

import flixel.group.FlxContainer;

class Stage extends FlxContainer
{
    public var background(default, null):FlxSprite;

    public var foreground(default, null):FlxSprite;

    public var curtains(default, null):FlxSprite;

    public function new():Void
    {
        super();

        background = new FlxSprite(0, 0, "assets/images/stages/stage/background.png");

        background.screenCenter();

        add(background);

        foreground = new FlxSprite(0, 0, "assets/images/stages/stage/foreground.png");

        foreground.scale.set(1.15, 1.15);

        foreground.updateHitbox();

        foreground.setPosition(background.getMidpoint().x - foreground.width / 2, ((background.y + background.height) - foreground.height) + 175.0);
        
        add(foreground);

        curtains = new FlxSprite(0, 0, "assets/images/stages/stage/curtains.png");

        curtains.scale.set(0.95, 0.95);

        curtains.updateHitbox();

        curtains.setPosition(background.getMidpoint().x - curtains.width / 2, background.y);

        add(curtains);
    }
}