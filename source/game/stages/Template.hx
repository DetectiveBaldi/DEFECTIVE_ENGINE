package game.stages;

import flixel.FlxSprite;

import core.Assets;
import core.Paths;

class Template extends Stage
{
    public var background:FlxSprite;

    public var foreground:FlxSprite;

    public var curtains:FlxSprite;

    public function new():Void
    {
        super();

        background = new FlxSprite(0, 0, Assets.graphic(Paths.png("assets/images/game/stages/Template/background")));

        background.active = false;

        background.antialiasing = true;

        add(background);

        foreground = new FlxSprite(0, 0, Assets.graphic(Paths.png("assets/images/game/stages/Template/foreground")));

        foreground.active = false;

        foreground.antialiasing = true;

        foreground.scale.set(1.15, 1.15);

        foreground.updateHitbox();

        foreground.setPosition(background.getMidpoint().x - foreground.width * 0.5, background.height - foreground.height);
        
        add(foreground);

        curtains = new FlxSprite(0, 0, Assets.graphic(Paths.png("assets/images/game/stages/Template/curtains")));

        curtains.active = false;

        curtains.antialiasing = true;

        curtains.scale.set(0.95, 0.95);

        curtains.updateHitbox();

        curtains.setPosition(background.getMidpoint().x - curtains.width * 0.5, background.getMidpoint().y - curtains.height * 0.5);

        add(curtains);
    }
}