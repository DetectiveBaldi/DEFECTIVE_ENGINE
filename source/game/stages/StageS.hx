package game.stages;

import flixel.FlxSprite;

class StageS extends Stage
{
    public var background:FlxSprite;

    public var foreground:FlxSprite;

    public var curtains:FlxSprite;

    public function new():Void
    {
        super();

        background = getSprite("background", false, false, 1.0, 1.0);

        background.visible = true;

        background.antialiasing = true;

        add(background);

        foreground = getSprite("foreground");

        foreground.visible = true;

        foreground.antialiasing = true;

        foreground.setPosition(background.getMidpoint().x - foreground.width * 0.5, background.height - foreground.height);
        
        add(foreground);

        curtains = getSprite("curtains", false, false, 0.95, 0.95);

        curtains.visible = true;

        curtains.antialiasing = true;

        curtains.scale.set(0.95, 0.95);

        curtains.updateHitbox();

        curtains.setPosition(background.getMidpoint().x - curtains.width * 0.5, background.getMidpoint().y - curtains.height * 0.5);

        add(curtains);
    }
}