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

        background.setPosition(-600.0, -200.0);

        add(background);

        foreground = new FlxSprite(0, 0, "assets/images/stages/stage/foreground.png");

        foreground.scale.set(1.1, 1.1);

        foreground.updateHitbox();

        foreground.setPosition(-650.0, 600.0);
        
        add(foreground);

        curtains = new FlxSprite(0, 0, "assets/images/stages/stage/curtains.png");

        curtains.scale.set(0.9, 0.9);

        curtains.updateHitbox();

        curtains.setPosition(-500.0, -300.0);

        add(curtains);
    }
}