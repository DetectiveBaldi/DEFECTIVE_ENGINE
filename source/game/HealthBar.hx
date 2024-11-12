package game;

import flixel.math.FlxMath;

import flixel.util.FlxColor;

import core.Conductor;

import ui.ProgressBar;

class HealthBar extends ProgressBar
{
    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(conductor:Conductor):Conductor
    {
        this.conductor?.beatHit?.remove(beatHit);

        conductor?.beatHit?.add(beatHit);

        return this.conductor = conductor;
    }

    @:noCompletion
    override function set_fillDirection(fillDirection:ProgressBarFillDirection):ProgressBarFillDirection
    {
        super.set_fillDirection(fillDirection);

        if (opponentIcon != null)
            opponentIcon.flipX = fillDirection == LEFT_TO_RIGHT;

        if (playerIcon != null)
            playerIcon.flipX = !(fillDirection == LEFT_TO_RIGHT);

        return fillDirection;
    }

    public var opponentIcon(default, set):HealthBarIcon;

    @:noCompletion
    function set_opponentIcon(opponentIcon:HealthBarIcon):HealthBarIcon
    {
        this.opponentIcon = opponentIcon;

        var opponentIconHealthBarColor:{r:Int, g:Int, b:Int} = opponentIcon.config.healthBarColor;

        var emptiedSideColor = opponentIconHealthBarColor == null ? FlxColor.RED : FlxColor.fromRGB(opponentIconHealthBarColor.r, opponentIconHealthBarColor.g, opponentIconHealthBarColor.b);

        emptiedSide.color = emptiedSideColor;

        return opponentIcon;
    }

    public var playerIcon(default, set):HealthBarIcon;

    @:noCompletion
    function set_playerIcon(playerIcon:HealthBarIcon):HealthBarIcon
    {
        this.playerIcon = playerIcon;

        var playerIconHealthBarColor:{r:Int, g:Int, b:Int} = playerIcon.config.healthBarColor;

        var filledSideColor = playerIconHealthBarColor == null ? FlxColor.LIME: FlxColor.fromRGB(playerIconHealthBarColor.r, playerIconHealthBarColor.g, playerIconHealthBarColor.b);

        filledSide.color = filledSideColor;

        return playerIcon;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, barWidth:Int = 600, barHeight:Int = 25, fillDirection:ProgressBarFillDirection, conductor:Conductor):Void
    {
        super(x, y, barWidth, barHeight, fillDirection);

        borderSize = 5;

        this.conductor = conductor;

        opponentIcon = new HealthBarIcon(0.0, 0.0, HealthBarIcon.findConfig("assets/data/game/HealthBarIcon/BOYFRIEND_PIXEL"));

        opponentIcon.flipX = fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM;

        opponentIcon.setPosition(border.getMidpoint().x - opponentIcon.height * 0.5, border.getMidpoint().y - opponentIcon.height * 0.5);

        add(opponentIcon);

        playerIcon = new HealthBarIcon(0.0, 0.0, HealthBarIcon.findConfig("assets/data/game/HealthBarIcon/BOYFRIEND"));

        playerIcon.flipX = !(fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM);

        playerIcon.setPosition(border.getMidpoint().x - playerIcon.width * 0.5, border.getMidpoint().y - playerIcon.height * 0.5);
        
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

        conductor?.beatHit?.remove(beatHit);
    }

    public function beatHit(beat:Int):Void
    {
        opponentIcon.scale *= FlxMath.lerp(1.35, 1.05, value / max);

        playerIcon.scale *= FlxMath.lerp(1.05, 1.35, value / max);
    }

    public dynamic function scaleIcons():Void
    {
        opponentIcon.scale.set(FlxMath.lerp(opponentIcon.scale.x, opponentIcon.config.scale?.x ?? 1.0, 0.15), FlxMath.lerp(opponentIcon.scale.y, opponentIcon.config.scale?.y ?? 1.0, 0.15));

        playerIcon.scale.set(FlxMath.lerp(playerIcon.scale.x, playerIcon.config.scale?.x ?? 1.0, 0.15), FlxMath.lerp(playerIcon.scale.y, playerIcon.config.scale?.y ?? 1.0, 0.15));
    }

    public dynamic function positionIcons():Void
    {
        switch (fillDirection:ProgressBarFillDirection)
        {
            case LEFT_TO_RIGHT:
            {
                opponentIcon.setPosition(border.x + border.width * percent * 0.01 - 16.0, border.getMidpoint().y - opponentIcon.height * 0.5);

                playerIcon.setPosition(border.x + border.width * percent * 0.01 - playerIcon.width + 16.0, border.getMidpoint().y - playerIcon.height * 0.5);
            }
            
            case RIGHT_TO_LEFT:
            {
                opponentIcon.setPosition(border.x + border.width * (100.0 - percent) * 0.01 - opponentIcon.width + 16.0, border.getMidpoint().y - opponentIcon.height * 0.5);

                playerIcon.setPosition(border.x + border.width * (100.0 - percent) * 0.01 - 16.0, border.getMidpoint().y - playerIcon.height * 0.5);
            }

            case TOP_TO_BOTTOM:
            {
                opponentIcon.setPosition(border.getMidpoint().x - opponentIcon.width * 0.5, border.y + border.height * percent * 0.01 - 16.0);

                playerIcon.setPosition(border.getMidpoint().x - playerIcon.width * 0.5, border.y + border.height * percent * 0.01 - playerIcon.height + 16.0);
            }

            case BOTTOM_TO_TOP:
            {
                opponentIcon.setPosition(border.getMidpoint().x - opponentIcon.width * 0.5, border.y + border.height * (100.0 - percent) * 0.01 - opponentIcon.height + 16.0);

                playerIcon.setPosition(border.getMidpoint().x - playerIcon.width * 0.5, border.y + border.height * (100.0 - percent) * 0.01 - 16.0);
            }
        }
    }
}