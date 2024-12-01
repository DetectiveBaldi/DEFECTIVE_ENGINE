package game;

import flixel.math.FlxMath;

import flixel.util.FlxColor;

import core.Conductor;

import ui.ProgressBar;

class HealthBar extends ProgressBar
{
    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(_conductor:Conductor):Conductor
    {
        var __conductor:Conductor = conductor;

        conductor = _conductor;

        conductor?.beatHit?.add(beatHit);

        __conductor?.beatHit?.remove(beatHit);

        return conductor;
    }

    @:noCompletion
    override function set_fillDirection(_fillDirection:ProgressBarFillDirection):ProgressBarFillDirection
    {
        super.set_fillDirection(_fillDirection);

        if (opponentIcon != null)
            opponentIcon.flipX = fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM;

        if (playerIcon != null)
            playerIcon.flipX = !(fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM);

        return fillDirection;
    }

    public var opponentIcon(default, set):HealthBarIcon;

    @:noCompletion
    function set_opponentIcon(_opponentIcon:HealthBarIcon):HealthBarIcon
    {
        opponentIcon = _opponentIcon;

        var opponentIconHealthBarColor:String = opponentIcon.config.healthBarColor;

        var emptiedSideColor:FlxColor = opponentIconHealthBarColor == null ? FlxColor.RED : FlxColor.fromString(opponentIconHealthBarColor);

        emptiedSide.color = emptiedSideColor;

        return opponentIcon;
    }

    public var playerIcon(default, set):HealthBarIcon;

    @:noCompletion
    function set_playerIcon(_playerIcon:HealthBarIcon):HealthBarIcon
    {
        playerIcon = _playerIcon;

        var playerIconHealthBarColor:String = playerIcon.config.healthBarColor;

        var filledSideColor:FlxColor = playerIconHealthBarColor == null ? FlxColor.LIME : FlxColor.fromString(playerIconHealthBarColor);

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
            scaleIcons(elapsed);

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
        opponentIcon.scale *= 1.35 + (1.05 - 1.35) * (value / max);

        playerIcon.scale *= 1.05 + (1.35 - 1.05) * (value / max);
    }

    public dynamic function scaleIcons(elapsed:Float):Void
    {
        opponentIcon.scale.set((opponentIcon.config.scale?.x ?? 1.0) + (opponentIcon.scale.x - (opponentIcon.config.scale?.x ?? 1.0)) * Math.exp(-15.0 * elapsed), (opponentIcon.config.scale?.y ?? 1.0) + (opponentIcon.scale.y - (opponentIcon.config.scale?.y ?? 1.0)) * Math.exp(-15.0 * elapsed));

        playerIcon.scale.set((playerIcon.config.scale?.x ?? 1.0) + (playerIcon.scale.x - (playerIcon.config.scale?.x ?? 1.0)) * Math.exp(-15.0 * elapsed), (playerIcon.config.scale?.y ?? 1.0) + (playerIcon.scale.y - (playerIcon.config.scale?.y ?? 1.0)) * Math.exp(-15.0 * elapsed));
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