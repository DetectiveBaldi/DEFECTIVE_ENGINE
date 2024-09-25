package game;

import flixel.group.FlxContainer;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import flixel.ui.FlxBar;

import flixel.util.FlxColor;

import core.Conductor;

class HealthBar extends FlxContainer
{
    public var health:Float;

    public var bar:FlxBar;

    public var opponentIcon:HealthIcon;

    public var playerIcon:HealthIcon;

    public var conductor(default, set):Conductor;

    public dynamic function set_conductor(conductor:Conductor):Conductor
    {
        if (this.conductor != null)
            this.conductor.beatHit.remove(beatHit);

        conductor.beatHit.add(beatHit);

        return this.conductor = conductor;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, conductor:Conductor):Void
    {
        super();

        health = 50.0;

        bar = new FlxBar(x, y, RIGHT_TO_LEFT, 600, 25, this, "health", 0.0, 100.0, true);

        bar.createFilledBar(FlxColor.RED, 0xFF66FF33, true, FlxColor.BLACK, 5);

        add(bar);

        opponentIcon = new HealthIcon(0.0, 0.0, "assets/data/characters/icons/BOYFRIEND_PIXEL");

        opponentIcon.setPosition(bar.getMidpoint().x - opponentIcon.width * 0.5, bar.getMidpoint().y - opponentIcon.height * 0.5);

        add(opponentIcon);

        playerIcon = new HealthIcon(0.0, 0.0, "assets/data/characters/icons/BOYFRIEND");

        playerIcon.flipX = true;

        playerIcon.setPosition(bar.getMidpoint().x - playerIcon.width * 0.5, bar.getMidpoint().y - playerIcon.height * 0.5);

        add(playerIcon);

        this.conductor = conductor;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (scaleIcons != null)
            scaleIcons(elapsed);

        if (positionIcons != null)
            positionIcons();
    }

    public dynamic function scaleIcons(elapsed:Float):Void
    {
        var opponentScale:FlxPoint = FlxPoint.get(FlxMath.lerp(opponentIcon.scale.x, opponentIcon.textureData.scale?.x ?? 1.0, 0.15), FlxMath.lerp(opponentIcon.scale.x, opponentIcon.textureData.scale?.y ?? 1.0, 0.15));

        opponentIcon.scale.copyFrom(opponentScale);

        opponentScale.put();

        var playerScale:FlxPoint = FlxPoint.get(FlxMath.lerp(playerIcon.scale.x, playerIcon.textureData.scale?.x ?? 1.0, 0.15), FlxMath.lerp(playerIcon.scale.y, playerIcon.textureData.scale?.y ?? 1.0, 0.15));

        playerIcon.scale.copyFrom(playerScale);

        playerScale.put();
    }

    public dynamic function positionIcons():Void
    {
        opponentIcon.setPosition(bar.x + bar.width * ((100 - bar.percent) * 0.01) - opponentIcon.width + 16, bar.getMidpoint().y - opponentIcon.height * 0.5);

        playerIcon.setPosition(bar.x + bar.width * ((100 - bar.percent) * 0.01) - 16.0, bar.getMidpoint().y - playerIcon.height * 0.5);
    }

    public function beatHit(beat:Int):Void
    {
        opponentIcon.scale *= FlxMath.lerp(1.35, 1.05, health / 100.0);

        playerIcon.scale *= FlxMath.lerp(1.05, 1.35, health / 100.0);
    }
}