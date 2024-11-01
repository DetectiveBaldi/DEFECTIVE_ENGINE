package game.stages;

import flixel.FlxBasic;
import flixel.FlxSprite;

import core.AssetMan;
import core.Paths;

class Week1 extends Stage<FlxBasic>
{
    public var background:FlxSprite;

    public var foreground:FlxSprite;

    public var curtains:FlxSprite;

    public function new():Void
    {
        super();

        background = new FlxSprite(0, 0, AssetMan.graphic(Paths.png("assets/images/game/stages/Week1/background")));

        background.antialiasing = true;

        members.push(background);

        foreground = new FlxSprite(0, 0, AssetMan.graphic(Paths.png("assets/images/game/stages/Week1/foreground")));

        foreground.antialiasing = true;

        foreground.scale.set(1.15, 1.15);

        foreground.updateHitbox();

        foreground.setPosition(background.getMidpoint().x - foreground.width * 0.5, background.height - foreground.height);
        
        members.push(foreground);

        curtains = new FlxSprite(0, 0, AssetMan.graphic(Paths.png("assets/images/game/stages/Week1/curtains")));

        curtains.antialiasing = true;

        curtains.scale.set(0.95, 0.95);

        curtains.updateHitbox();

        curtains.setPosition(background.getMidpoint().x - curtains.width * 0.5, background.getMidpoint().y - curtains.height * 0.5);

        members.push(curtains);
    }
}