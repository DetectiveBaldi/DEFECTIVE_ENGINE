package stages;

import flixel.FlxSprite;

import core.Paths;

class Week1 extends Stage
{
    public var background(default, null):FlxSprite;

    public var foreground(default, null):FlxSprite;

    public var curtains(default, null):FlxSprite;

    public function new():Void
    {
        super();

        background = new FlxSprite(0, 0, Paths.png("assets/images/stages/week1/background"));

        background.screenCenter();

        add(background);

        foreground = new FlxSprite(0, 0, Paths.png("assets/images/stages/week1/foreground"));

        foreground.scale.set(1.15, 1.15);

        foreground.updateHitbox();

        foreground.setPosition(background.getMidpoint().x - foreground.width * 0.5, ((background.height * 0.75) - foreground.height) + 175.0);
        
        add(foreground);

        curtains = new FlxSprite(0, 0, Paths.png("assets/images/stages/week1/curtains"));

        curtains.scale.set(0.95, 0.95);

        curtains.updateHitbox();

        curtains.setPosition(background.getMidpoint().x - curtains.width * 0.5, background.getMidpoint().y - curtains.height * 0.5);

        add(curtains);
    }
}