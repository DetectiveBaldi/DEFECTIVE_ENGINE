package game;

import flixel.math.FlxMath;

import flixel.util.FlxColor;

import core.AssetCache;

import music.Conductor;

import ui.ProgressBar;

class HealthBar extends ProgressBar
{
    public var conductor:Conductor;

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

    public var opponentIcon:HealthIcon;

    public var playerIcon:HealthIcon;

    public function new(x:Float = 0.0, y:Float = 0.0, beatDispatcher:IBeatDispatcher):Void
    {
        super(x, y, 600, 25, 5, RIGHT_TO_LEFT);

        conductor = beatDispatcher.conductor;

        conductor.onBeatHit.add(beatHit);

        opponentIcon = new HealthIcon("bf-pixel");

        opponentIcon.flipX = fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM;

        opponentIcon.setPosition(border.getMidpoint().x - opponentIcon.height * 0.5, border.getMidpoint().y - opponentIcon.height * 0.5);

        add(opponentIcon);

        playerIcon = new HealthIcon("bf");

        playerIcon.flipX = !(fillDirection == LEFT_TO_RIGHT || fillDirection == TOP_TO_BOTTOM);

        playerIcon.setPosition(border.getMidpoint().x - playerIcon.width * 0.5, border.getMidpoint().y - playerIcon.height * 0.5);
        
        add(playerIcon);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        updateIconsAnimation();

        scaleIcons(elapsed);
    }

    override function destroy():Void
    {
        super.destroy();

        conductor?.onBeatHit?.remove(beatHit);
    }

    public function beatHit(beat:Int):Void
    {
        opponentIcon.scale *= 1.35 + -0.35 * (value / max);

        opponentIcon.updateHitbox();

        playerIcon.scale *= 1.0 + 0.35 * (value / max);

        playerIcon.updateHitbox();

        positionIcons();
    }

    public function updateIconsAnimation():Void
    {
        playerIcon.animation.curAnim.curFrame = (percent < 20.0) ? 1 : 0;
        
        opponentIcon.animation.curAnim.curFrame = (percent > 80.0) ? 1 : 0;
    }

    public function scaleIcons(elapsed:Float):Void
    {
        var scale:Float = FlxMath.lerp(opponentIcon.width, 150.0, FlxMath.getElapsedLerp(0.15, elapsed));

        opponentIcon.setGraphicSize(scale, scale);

        opponentIcon.updateHitbox();

        scale = FlxMath.lerp(playerIcon.width, 150.0, FlxMath.getElapsedLerp(0.15, elapsed));

        playerIcon.setGraphicSize(scale, scale);

        playerIcon.updateHitbox();

        positionIcons();
    }

    public function positionIcons():Void
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