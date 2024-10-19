package game;

import flixel.FlxSprite;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.math.FlxMath;

import flixel.ui.FlxBar;

import flixel.util.FlxColor;

import core.Conductor;

class HealthBar extends FlxTypedContainer<FlxSprite>
{
    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(conductor:Conductor):Conductor
    {
        this.conductor?.beatHit.remove(beatHit);

        conductor?.beatHit.add(beatHit);

        return this.conductor = conductor;
    }
    
    public var bar:FlxBar;

    public var percent(get, set):Float;

    @:noCompletion
    function get_percent():Float
    {
        return bar.percent;
    }

    @:noCompletion
    function set_percent(percent:Float):Float
    {
        bar.percent = percent;

        return percent;
    }

    public var value(get, set):Float;

    @:noCompletion
    function get_value():Float
    {
        return bar.value;
    }

    @:noCompletion
    function set_value(value:Float):Float
    {
        bar.value = value;

        return value;
    }

    public var min(get, set):Float;

    @:noCompletion
    function get_min():Float
    {
        return bar.min;
    }

    @:noCompletion
    function set_min(min:Float):Float
    {
        setRange(min, max);

        return min;
    }

    public var max(get, set):Float;

    @:noCompletion
    function get_max():Float
    {
        return bar.max;
    }

    @:noCompletion
    function set_max(max:Float):Float
    {
        setRange(min, max);
        
        return max;
    }

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

            case TOP_TO_BOTTOM:
                TOP_TO_BOTTOM;

            case BOTTOM_TO_TOP:
                BOTTOM_TO_TOP;
        }

        if (opponentIcon != null)
            opponentIcon.flipX = fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM;

        if (playerIcon != null)
            playerIcon.flipX = !(fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM);

        return this.fillDirection = fillDirection;
    }

    public var opponentIcon:HealthIcon;

    public var playerIcon:HealthIcon;

    public function new(conductor:Conductor, x:Float = 0.0, y:Float = 0.0, fillDirection:HealthBarFillDirection, width:Int = 600, height:Int = 25):Void
    {
        super();

        this.conductor = conductor;

        bar = new FlxBar(x, y, switch (fillDirection:HealthBarFillDirection)
        {
            case RIGHT_TO_LEFT: RIGHT_TO_LEFT;
            
            case LEFT_TO_RIGHT: LEFT_TO_RIGHT;

            case BOTTOM_TO_TOP: BOTTOM_TO_TOP;
            
            case TOP_TO_BOTTOM: TOP_TO_BOTTOM;
        }, width, height, null, null, 0.0, 100.0, true);

        bar.createFilledBar(FlxColor.RED, 0xFF66FF33, true, FlxColor.BLACK, 5);

        add(bar);

        value = 50.0;

        this.fillDirection = fillDirection;

        opponentIcon = new HealthIcon(0.0, 0.0, "assets/data/game/healthIcons/BOYFRIEND_PIXEL");

        opponentIcon.flipX = fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM;

        add(opponentIcon);

        playerIcon = new HealthIcon(0.0, 0.0, "assets/data/game/healthIcons/BOYFRIEND");

        playerIcon.flipX = !(fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM);

        add(playerIcon);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (scaleIcons != null)
            scaleIcons();

        if (positionIcons != null)
            positionIcons();
    }

    override function destroy():Void
    {
        super.destroy();

        conductor?.beatHit.remove(beatHit);
    }

    public function beatHit(beat:Int):Void
    {
        opponentIcon.scale *= FlxMath.lerp(1.35, 1.05, value / bar.max);

        opponentIcon.updateHitbox();

        playerIcon.scale *= FlxMath.lerp(1.05, 1.35, value / bar.max);

        playerIcon.updateHitbox();
    }

    public function setRange(min:Float, max:Float):Void
    {
        bar.setRange(min, max);
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
                opponentIcon.setPosition(bar.x + bar.width * percent * 0.01 - 16.0, bar.getMidpoint().y - opponentIcon.height * 0.5);

                playerIcon.setPosition(bar.x + bar.width * percent * 0.01 - playerIcon.width + 16.0, bar.getMidpoint().y - playerIcon.height * 0.5);
            }
            
            case RIGHT_TO_LEFT:
            {
                opponentIcon.setPosition(bar.x + bar.width * (100.0 - percent) * 0.01 - opponentIcon.width + 16.0, bar.getMidpoint().y - opponentIcon.height * 0.5);

                playerIcon.setPosition(bar.x + bar.width * (100.0 - percent) * 0.01 - 16.0, bar.getMidpoint().y - playerIcon.height * 0.5);
            }

            case TOP_TO_BOTTOM:
            {
                opponentIcon.setPosition(bar.getMidpoint().x - opponentIcon.width * 0.5, bar.y + bar.height * percent * 0.01 - 16.0);

                playerIcon.setPosition(bar.getMidpoint().x - playerIcon.width * 0.5, bar.y + bar.height * percent * 0.01 - playerIcon.height + 16.0);
            }

            case BOTTOM_TO_TOP:
            {
                opponentIcon.setPosition(bar.getMidpoint().x - opponentIcon.width * 0.5, bar.y + bar.height * (100.0 - percent) * 0.01 - opponentIcon.height + 16.0);

                playerIcon.setPosition(bar.getMidpoint().x - playerIcon.width * 0.5, bar.y + bar.height * (100.0 - percent) * 0.01 - 16.0);
            }
        }
    }
}

enum abstract HealthBarFillDirection(String) from String to String
{
    var LEFT_TO_RIGHT:HealthBarFillDirection = "LEFT_TO_RIGHT";

    var RIGHT_TO_LEFT:HealthBarFillDirection = "RIGHT_TO_LEFT";

    var TOP_TO_BOTTOM:HealthBarFillDirection = "TOP_TO_BOTTOM";

    var BOTTOM_TO_TOP:HealthBarFillDirection = "BOTTOM_TO_TOP";
}