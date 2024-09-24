package game;

import flixel.group.FlxContainer;

import flixel.ui.FlxBar;

import flixel.util.FlxColor;

class HealthBar extends FlxContainer
{
    public var health:Float;

    public var bar:FlxBar;

    public var opponentIcon:HealthIcon;

    public var playerIcon:HealthIcon;

    public var repositionIcons:()->Void;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super();

        health = 50.0;

        bar = new FlxBar(x, y, RIGHT_TO_LEFT, 600, 25, this, "health", 0.0, 100.0, true);

        bar.createFilledBar(FlxColor.RED, FlxColor.LIME, true, FlxColor.BLACK, 5);

        add(bar);

        opponentIcon = new HealthIcon(0.0, 0.0, "assets/data/characters/icons/BOYFRIEND_PIXEL");

        opponentIcon.setPosition(bar.getMidpoint().x - opponentIcon.width * 0.5, bar.getMidpoint().y - opponentIcon.height * 0.5);

        add(opponentIcon);

        playerIcon = new HealthIcon(0.0, 0.0, "assets/data/characters/icons/BOYFRIEND");

        playerIcon.flipX = true;

        playerIcon.setPosition(bar.getMidpoint().x - playerIcon.width * 0.5, bar.getMidpoint().y - playerIcon.height * 0.5);

        add(playerIcon);

        repositionIcons = () ->
        {
            opponentIcon.setPosition(bar.x + bar.width * ((100 - bar.percent) * 0.01) - opponentIcon.width + 16, bar.getMidpoint().y - opponentIcon.height * 0.5);

            playerIcon.setPosition(bar.x + bar.width * ((100 - bar.percent) * 0.01) - 16.0, bar.getMidpoint().y - playerIcon.height * 0.5);
        }
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (repositionIcons != null)
            repositionIcons();
    }
}