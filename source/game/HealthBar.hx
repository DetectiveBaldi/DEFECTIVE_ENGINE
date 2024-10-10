package game;

import flixel.FlxSprite;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.math.FlxMath;

import flixel.ui.FlxBar;

import flixel.util.FlxColor;

import core.Conductor;

class HealthBar extends FlxTypedContainer<FlxSprite>
{
    public var health:Float;

    public var bar:FlxBar;

    public var fillDirection(default, set):HealthBarFillDirection;

    @:noCompletion
    function set_fillDirection(fillDirection:HealthBarFillDirection):HealthBarFillDirection
    {
        bar.fillDirection = switch (fillDirection:HealthBarFillDirection)
        {
            case LEFT_TO_RIGHT:
                LEFT_TO_RIGHT;
            
            case RIGHT_TO_LEFT:
                RIGHT_TO_LEFT;
        }

        if (opponentIcon != null)
        {
            opponentIcon.flipX = switch (fillDirection:HealthBarFillDirection)
            {
                case LEFT_TO_RIGHT:
                    true;
                
                case RIGHT_TO_LEFT:
                    false;
            }
        }

        if (playerIcon != null)
        {
            playerIcon.flipX = switch (fillDirection:HealthBarFillDirection)
            {
                case LEFT_TO_RIGHT:
                    false;
                
                case RIGHT_TO_LEFT:
                    true;
            }
        }

        return this.fillDirection = fillDirection;
    }

    public var opponentIcon:HealthIcon;

    public var playerIcon:HealthIcon;

    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(conductor:Conductor):Conductor
    {
        if (this.conductor != null)
            this.conductor.beatHit.remove(beatHit);

        if (conductor != null)
            conductor.beatHit.add(beatHit);

        return this.conductor = conductor;
    }

    public function new(fillDirection:HealthBarFillDirection, conductor:Conductor):Void
    {
        super();

        health = 50.0;

        bar = switch (fillDirection:HealthBarFillDirection)
        {
            case RIGHT_TO_LEFT:
                new FlxBar(0.0, 0.0, RIGHT_TO_LEFT, 600, 25, this, "health", 0.0, 100.0, true);
            
            case LEFT_TO_RIGHT:
                new FlxBar(0.0, 0.0, LEFT_TO_RIGHT, 600, 25, this, "health", 0.0, 100.0, true);
        }

        bar.createFilledBar(FlxColor.RED, 0xFF66FF33, true, FlxColor.BLACK, 5);

        add(bar);

        this.fillDirection = fillDirection;

        opponentIcon = new HealthIcon(0.0, 0.0, "assets/data/game/healthIcons/BOYFRIEND_PIXEL");

        opponentIcon.flipX = switch (fillDirection:HealthBarFillDirection)
        {
            case LEFT_TO_RIGHT:
                true;
            
            case RIGHT_TO_LEFT:
                false;
        }

        add(opponentIcon);

        playerIcon = new HealthIcon(0.0, 0.0, "assets/data/game/healthIcons/BOYFRIEND");

        playerIcon.flipX = switch (fillDirection:HealthBarFillDirection)
        {
            case LEFT_TO_RIGHT:
                false;
            
            case RIGHT_TO_LEFT:
                true;
        }

        add(playerIcon);

        this.conductor = conductor;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (scaleIcons != null)
            scaleIcons();

        if (positionIcons != null)
            positionIcons();
    }

    public dynamic function scaleIcons():Void
    {
        opponentIcon.scale.set(FlxMath.lerp(opponentIcon.scale.x, opponentIcon.textureData.scale?.x ?? 1.0, 0.15), FlxMath.lerp(opponentIcon.scale.y, opponentIcon.textureData.scale?.y ?? 1.0, 0.15));

        opponentIcon.updateHitbox();

        playerIcon.scale.set(FlxMath.lerp(playerIcon.scale.x, playerIcon.textureData.scale?.x ?? 1.0, 0.15), FlxMath.lerp(playerIcon.scale.y, playerIcon.textureData.scale?.y ?? 1.0, 0.15));

        playerIcon.updateHitbox();
    }

    public dynamic function positionIcons():Void
    {
        switch (fillDirection:HealthBarFillDirection)
        {
            case LEFT_TO_RIGHT:
            {
                opponentIcon.setPosition(bar.x + bar.width * bar.percent * 0.01 - 16.0, bar.getMidpoint().y - opponentIcon.height * 0.5);

                playerIcon.setPosition(bar.x + bar.width * bar.percent * 0.01 - playerIcon.width + 16, bar.getMidpoint().y - playerIcon.height * 0.5);
            }
            
            case RIGHT_TO_LEFT:
            {
                opponentIcon.setPosition(bar.x + bar.width * (100 - bar.percent) * 0.01 - opponentIcon.width + 16, bar.getMidpoint().y - opponentIcon.height * 0.5);

                playerIcon.setPosition(bar.x + bar.width * (100 - bar.percent) * 0.01 - 16.0, bar.getMidpoint().y - playerIcon.height * 0.5);
            }
        }
    }

    public function beatHit(beat:Int):Void
    {
        opponentIcon.scale *= FlxMath.lerp(1.35, 1.05, health / 100.0);

        opponentIcon.updateHitbox();

        playerIcon.scale *= FlxMath.lerp(1.05, 1.35, health / 100.0);

        playerIcon.updateHitbox();
    }
}

enum abstract HealthBarFillDirection(String) from String to String
{
    var LEFT_TO_RIGHT:HealthBarFillDirection = "LEFT_TO_RIGHT";

    var RIGHT_TO_LEFT:HealthBarFillDirection = "RIGHT_TO_LEFT";
}