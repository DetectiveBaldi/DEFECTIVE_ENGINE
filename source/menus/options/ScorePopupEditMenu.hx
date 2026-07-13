package menus.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.typeLimit.NextState;

import flixel.addons.display.FlxBackdrop;

import core.AssetCache;
import core.Paths;
import core.Options;
import core.SaveManager;
import game.Rating;
import game.ScorePopup;
import game.stages.StageS;

using tools.AlignTools;

class ScorePopupEditMenu extends FlxSubState
{
    public var background:FlxBackdrop;

    public var scorePopup:ScorePopup;

    public var ratingSprites(get, never):FlxSpriteGroup;

    @:noCompletion
    function get_ratingSprites():FlxSpriteGroup
    {
        return scorePopup.ratingSprites;
    }

    public var comboSprites(get, never):FlxSpriteGroup;
    
    @:noCompletion
    function get_comboSprites():FlxSpriteGroup
    {
        return scorePopup.comboSprites;
    }

    public var ratingStartPos:FlxPoint;

    public var comboStartPos:FlxPoint;

    public var dragOffset:FlxPoint;

    public var holdTime:Float;

    public var tipBox:FlxSprite;

    public var tipText:FlxText;

    public var tune:FlxSound;

    public function new():Void
    {
        super(FlxColor.BLACK);
    }

    override function create():Void
    {
        super.create();

        _bgSprite.alpha = 0.5;

        background = new FlxBackdrop(AssetCache.getGraphic("menus/options/OptionsMenu/bg-overlay"));

        background.velocity.set(10.0, 10.0);

        background.alpha = 0.35;

        background.screenCenter();

        add(background);

        scorePopup = new ScorePopup();

        scorePopup.active = false;

        scorePopup.showRating(Rating.list[0]);

        scorePopup.showCombo(1000);

        add(scorePopup);

        ratingStartPos = FlxPoint.get(scorePopup.ratingSprites.x - Options.ratingPopupOffset.x, scorePopup.ratingSprites.y - Options.ratingPopupOffset.y);

        comboStartPos = FlxPoint.get(scorePopup.comboSprites.x - Options.comboPopupOffset.x, scorePopup.comboSprites.y - Options.comboPopupOffset.y);

        dragOffset = FlxPoint.get();

        holdTime = 0.0;

        tipBox = new FlxSprite();

        tipBox.frame = FlxG.bitmap.whitePixel;

        tipBox.alpha = 0.5;

        tipBox.color = FlxColor.BLACK;

        add(tipBox);

        tipText = new FlxText(0.0, 0.0, 0.0, "", 32);

        tipText.setFormat(Paths.font(Paths.ttf("VCR OSD Mono")), 32, FlxColor.WHITE, CENTER);
        
        add(tipText);

        setTip("Use your mouse to drag items around.\nHold BACK to reset all offsets.");

        tune = FlxG.sound.load(AssetCache.getMusic("menus/options/OptionsMenu/tune-edit"), 0.0, true);

        tune.fadeIn(1.0, 0.0, 1.0);

        tune.play();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.mouse.pressed)
        {
            var draggable:FlxSpriteGroup = FlxG.mouse.overlaps(comboSprites) ? comboSprites : FlxG.mouse.overlaps(ratingSprites) ? ratingSprites : null;

            if (draggable != null)
            {
                if (FlxG.mouse.justPressed)
                {
                    dragOffset.x = FlxG.mouse.x - draggable.x;

                    dragOffset.y = FlxG.mouse.y - draggable.y;
                }

                if (FlxG.mouse.justMoved)
                {
                    draggable.setPosition(FlxG.mouse.x - dragOffset.x, FlxG.mouse.y - dragOffset.y);

                    Options.ratingPopupOffset.x = ratingSprites.x - ratingStartPos.x;

                    Options.ratingPopupOffset.y = ratingSprites.y - ratingStartPos.y;

                    Options.comboPopupOffset.x = comboSprites.x - comboStartPos.x;

                    Options.comboPopupOffset.y = comboSprites.y - comboStartPos.y;
                }
            }
        }

        if (Options.keysPressed("ui back"))
        {
            if (Options.keysJustPressed("ui back"))
                holdTime = 0.0;
            
            holdTime += elapsed;

            if (holdTime >= 1.0)
            {
                var periods:Int = Math.floor(holdTime * 4000.0 / 1000.0) % 4;

                var tip:String = "";

                for (i in 0 ... periods)
                    tip += ".";

                setTip(tip);

                if (holdTime >= 3.0)
                {
                    ratingSprites.setPosition(ratingSprites.x - Options.ratingPopupOffset.x, ratingSprites.y - Options.ratingPopupOffset.y);

                    comboSprites.setPosition(comboSprites.x - Options.comboPopupOffset.x, comboSprites.y - Options.comboPopupOffset.y);

                    Options.ratingPopupOffset.x = 0.0;

                    Options.ratingPopupOffset.y = 0.0;

                    Options.comboPopupOffset.x = 0.0;

                    Options.comboPopupOffset.y = 0.0;
                    
                    holdTime = 0.0;

                    setTip("Use your mouse to drag items around.\nHold BACK to reset all offsets.");

                    playCancelSound();
                }
            }
        }

        if (Options.keysJustReleased("ui back") && holdTime < 1.0)
            close();
    }

    override function close():Void
    {
        super.close();

        SaveManager.saveOptions();

        ratingStartPos = FlxDestroyUtil.put(ratingStartPos);

        comboStartPos = FlxDestroyUtil.put(comboStartPos);

        dragOffset = FlxDestroyUtil.put(dragOffset);

        tune.stop();

        playCancelSound();
    }

    public function setTip(text:String):Void
    {
        tipText.text = text;

        tipBox.visible = tipText.text != "";

        tipText.visible = tipBox.visible;

        tipText.setPosition(tipText.getCenterX(), FlxG.height - tipText.height - 50.0);

        tipBox.setGraphicSize(tipText.width + 25.0, tipText.height + 25.0);

        tipBox.updateHitbox();

        tipBox.centerTo(tipText);
    }

    public function playCancelSound():Void
    {
        var cancelSound:FlxSound = FlxG.sound.play(AssetCache.getSound("ui/cancel"));

        cancelSound.onComplete = cancelSound.kill;
    }

    public function playScrollSound():Void
    {
        var scrollSound:FlxSound = FlxG.sound.play(AssetCache.getSound("ui/scroll"));

        scrollSound.onComplete = scrollSound.kill;
    }
}