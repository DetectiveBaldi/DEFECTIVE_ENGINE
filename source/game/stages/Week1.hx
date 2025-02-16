package game.stages;

import flixel.FlxSprite;

import flixel.group.FlxGroup;

import core.Assets;
import core.Paths;

class Week1 extends FlxGroup
{
    public var background:FlxSprite;

    public var foreground:FlxSprite;

    public var curtains:FlxSprite;

    public function new():Void
    {
        super();

        background = new FlxSprite(0, 0, Assets.getGraphic(Paths.png("assets/images/game/stages/Week1/background")));

        background.active = false;

        background.antialiasing = true;

        add(background);

        foreground = new FlxSprite(0, 0, Assets.getGraphic(Paths.png("assets/images/game/stages/Week1/foreground")));

        foreground.active = false;

        foreground.antialiasing = true;

        foreground.scale.set(1.15, 1.15);

        foreground.updateHitbox();

        foreground.setPosition(background.getMidpoint().x - foreground.width * 0.5, background.height - foreground.height);
        
        add(foreground);

        curtains = new FlxSprite(0, 0, Assets.getGraphic(Paths.png("assets/images/game/stages/Week1/curtains")));

        curtains.active = false;

        curtains.antialiasing = true;

        curtains.scale.set(0.95, 0.95);

        curtains.updateHitbox();

        curtains.setPosition(background.getMidpoint().x - curtains.width * 0.5, background.getMidpoint().y - curtains.height * 0.5);

        add(curtains);
    }
}