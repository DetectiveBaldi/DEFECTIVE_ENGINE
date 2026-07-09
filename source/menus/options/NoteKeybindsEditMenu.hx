package menus.options;

import haxe.io.Path;

import openfl.events.Event;
import openfl.net.FileFilter;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import flixel.addons.display.FlxBackdrop;

import core.AssetCache;
import core.Options;
import core.Paths;
import core.SaveManager;
import data.KeyParams;
import game.notes.Strum;
import game.notes.Strumline;
import interfaces.ISequenceHandler;
import tools.AlignTools;
import ui.EventButton;

using StringTools;

using flixel.util.FlxArrayUtil;

using tools.AlignTools;
using util.ArrayUtil;

class NoteKeybindsEditMenu extends FlxSubState implements ISequenceHandler
{
    public var tweens:FlxTweenManager;

    public var timers:FlxTimerManager;

    public var background:FlxBackdrop;

    public var fileFilter:FileFilter;

    #if sys
    public var file:openfl.filesystem.File;
    #else
    public var fileRef:openfl.net.FileReference;
    #end

    public var state:EditingState;

    public var button:EventButton;

    public var strumline:Strumline;

    public var keyCount(get, never):Int;

    @:noCompletion
    function get_keyCount():Int
    {
        return strumline.keyCount;
    }

    public var hoverStrum:Strum;

    public var strumIndex(get, never):Int;

    @:noCompletion
    function get_strumIndex():Int
    {
        return hoverStrum.direction;
    }

    public var keybinds:Array<Array<Int>>;

    public var keyIndex:Int;

    public var holdTime:Float;

    public var tipBox:FlxSprite;

    public var tipText:FlxText;

    public var resetTipTimer:FlxTimer;

    public function new():Void
    {
        super(FlxColor.BLACK);
    }

    override function create():Void
    {
        super.create();

        _bgSprite.alpha = 0.5;

        tweens = new FlxTweenManager();

        add(tweens);

        timers = new FlxTimerManager();

        add(timers);

        background = new FlxBackdrop(AssetCache.getGraphic("menus/options/OptionsMenu/bg-overlay"));

        background.velocity.set(10.0, 10.0);

        background.alpha = 0.35;

        background.screenCenter();

        add(background);

        fileFilter = new FileFilter("Open", "*.json");

        #if sys
        file = new openfl.filesystem.File('${Sys.getCwd()}${Paths.data("")}data/KeyParams/');
        #else
        fileRef = new openfl.net.FileReference();
        #end

        button = new EventButton();

        button.onToggle.add(startFileBrowsing);

        button.setPosition(button.getCenterX(), 450.0);

        add(button);

        strumline = new Strumline(null, 4);

        strumline.strums.setPosition(strumline.strums.getCenterX(), 40.0);

        strumline.botplay = true;

        add(strumline);

        keybinds = new Array<Array<Int>>();

        getKeybinds();

        keyIndex = 0;

        holdTime = 0.0;

        tipBox = new FlxSprite();

        tipBox.frame = FlxG.bitmap.whitePixel;

        tipBox.alpha = 0.5;

        tipBox.color = FlxColor.BLACK;

        add(tipBox);

        tipText = new FlxText(0.0, 0.0, 0.0, "", 32);

        tipText.setFormat(Paths.font(Paths.ttf("VCR OSD Mono")), 32, FlxColor.WHITE, CENTER);
        
        add(tipText);

        resetTipTimer = new FlxTimer(timers);

        setState(SELECTING_STRUM);
        
        playScrollSound();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        switch (state:EditingState)
        {
            case SELECTING_STRUM:
            {
                hoverStrum = strumline.strums.members.last((strum:Strum) -> FlxG.mouse.overlaps(strum, camera));

                for (i in 0 ... strumline.strums.members.length)
                {
                    var strum:Strum = strumline.strums.members[i];

                    if (strum.direction == -1.0)
                        continue;

                    var isSelected:Bool = hoverStrum == strum;

                    var animToPlay:String =  strumline.convertDirectionToAnim(strum.direction).toLowerCase();

                    if (isSelected)
                        animToPlay += "Press";
                    else
                        animToPlay += "Static";

                    if (strum.animation.name != animToPlay)
                        strum.animation.play(animToPlay);
                }

                if (FlxG.mouse.justPressed && hoverStrum != null)
                {
                    playScrollSound();

                    setState(SELECTING_BIND);
                }

                if (FlxG.keys.justPressed.ESCAPE)
                    close();
            }

            case SELECTING_BIND:
            {
                if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
                {
                    keyIndex = FlxMath.wrap(keyIndex + 1, 0, keybinds[strumIndex].length - 1);

                    setTip('You are editing the ${keyIndex == 0 ? "MAIN" : "SECONDARY"} bind (Currently "${FlxKey.toStringMap[keybinds[strumIndex][keyIndex]]}").\nPress UP or DOWN to change, or ENTER to confirm.');

                    playScrollSound();
                }

                if (FlxG.keys.justPressed.ENTER)
                {
                    playScrollSound();

                    setState(SELECTING_KEY);
                }

                if (FlxG.keys.justPressed.ESCAPE)
                {
                    playCancelSound();

                    setState(SELECTING_STRUM);
                }
            }

            case SELECTING_KEY:
            {
                var key:Int = FlxG.keys.firstPressed();

                if (key != -1.0)
                    holdTime += elapsed;

                var heldList:Array<FlxInput<FlxKey>> = FlxG.keys.getIsDown();

                if (heldList.length > 1.0)
                {
                    holdTime = 0.0;

                    setTip("Operation canceled. Don't hold more than 1 key!");

                    playCancelSound();

                    setState(SELECTING_STRUM, true);
                }

                if (FlxG.keys.pressed.BACKSPACE)
                {
                    if (holdTime >= 3.0)
                    {
                        var newKey:Int = strumline.keyParams.controls[strumIndex][keyIndex];

                        var flatten:Array<Int> = keybinds.flatten2DArray();

                        holdTime = 0.0;

                        if (newKey != -1.0 && flatten.contains(newKey))
                        {
                            setTip("Operation canceled. Resetting this bind would result\nin a double bind.");

                            playCancelSound();
                        }
                        else
                        {
                            var oldKey:Int = keybinds[strumIndex][keyIndex];

                            keybinds[strumIndex][keyIndex] = newKey;

                            setKeybinds();

                            setTip('Reset bind to default, from "${FlxKey.toStringMap[oldKey]}" to "${FlxKey.toStringMap[keybinds[strumIndex][keyIndex]]}".');

                            playCancelSound();
                        }

                        setState(SELECTING_STRUM, true);
                    }
                }

                if (FlxG.keys.pressed.ESCAPE)
                {
                    if (holdTime >= 3.0)
                    {
                        var oldKey:Int = keybinds[strumIndex][keyIndex];

                        keybinds[strumIndex][keyIndex] = -1;

                        setKeybinds();

                        holdTime = 0.0;

                        setTip('Deleted old bind "${FlxKey.toStringMap[oldKey]}".');

                        playCancelSound();

                        setState(SELECTING_STRUM, true);
                    }
                }

                if (FlxG.keys.pressed.BACKSPACE || FlxG.keys.pressed.ESCAPE)
                {
                    if (holdTime >= 1.0)
                    {
                        var periods:Int = 1 + Math.floor(holdTime * 3000.0 / 1000.0) % 3;

                        var tip:String = "";

                        for (i in 0 ... periods)
                            tip += ".";

                        setTip(tip);
                    }
                }

                var key:Int = -1;

                var firstJustPressed:Int = FlxG.keys.firstJustPressed();

                if (firstJustPressed != -1.0 && firstJustPressed != FlxKey.BACKSPACE && firstJustPressed != FlxKey.ESCAPE)
                    key = firstJustPressed;

                var firstJustReleased:Int = FlxG.keys.firstJustReleased();

                if (firstJustReleased != 1.0 && firstJustReleased == FlxKey.BACKSPACE || firstJustReleased == FlxKey.ESCAPE)
                   key = firstJustReleased;

                if (key != -1.0)
                {
                    var flatten:Array<Int> = keybinds.flatten2DArray();

                    holdTime = 0.0;

                    if (flatten.contains(key))
                    {
                        setTip("Operation canceled. This key is already in use\nsomewhere else!");

                        playCancelSound();
                    }
                    else
                    {
                        var oldKey:Int = keybinds[strumIndex][keyIndex];

                        keybinds[strumIndex][keyIndex] = key;

                        setKeybinds();

                        var tip:String = 'Changed bind from "${FlxKey.toStringMap[oldKey]}" to "${FlxKey.toStringMap[key]}".';

                        if (oldKey == -1.0)
                            tip = 'Set new bind "${FlxKey.toStringMap[key]}".';

                        setTip(tip);

                        playScrollSound();
                    }

                    setState(SELECTING_STRUM, true);
                }
            }
        }

        for (i in 0 ... strumline.strums.members.length)
        {
            var strum:Strum = strumline.strums.members[i];

            var isSelected:Bool = hoverStrum == strum;

            var strumScale:Float = strumline.keyParams.strumScale;

            if (isSelected)
                strumScale *= 1.1;

            var scaleFactor:Float = FlxMath.lerp(strum.scale.x, strumScale, FlxMath.getElapsedLerp(0.15, elapsed));

            strum.scale.set(scaleFactor, scaleFactor);
        }
    }

    override function close():Void
    {
        super.close();

        playCancelSound();
    }

    public function setState(v:EditingState, runResetTimer:Bool = false):Void
    {
        state = v;

        resetTipTimer.cancel();

        var resetTip:String = "Click a strum to edit its keybinds.\nClick the button to select a key config.";

        if (runResetTimer)
            resetTipTimer.start(3.0, (_) -> setTip(resetTip));

        switch (state:EditingState)
        {
            case SELECTING_STRUM:
            {
                if (button.y != 450.0)
                {
                    tweens.cancelTweensOf(button);

                    tweens.tween(button, { y: 450.0 }, 0.5, {ease: FlxEase.cubeOut});
                }
            
                button.enabled = true;

                hoverStrum?.animation.play('${strumline.convertDirectionToAnim(hoverStrum.direction).toLowerCase()}Static');

                if (!runResetTimer)
                    setTip(resetTip);
            }

            case SELECTING_BIND:
            {
                tweens.cancelTweensOf(button);

                tweens.tween(button, {y: FlxG.height}, 0.5, {ease: FlxEase.cubeIn});

                button.enabled = false;

                hoverStrum.animation.play('${strumline.convertDirectionToAnim(hoverStrum.direction).toLowerCase()}Confirm');

                keyIndex = 0;

                setTip('You are editing the MAIN bind (Currently "${FlxKey.toStringMap[keybinds[strumIndex][0]]}").\nPress UP or DOWN to change, or ENTER to confirm.');
            }

            case SELECTING_KEY:
                setTip("Press a key to update this bind. Hold BACKSPACE to\nreset this bind, or ESCAPE to delete it.");
        }
    }

    public function startFileBrowsing():Void
    {
        #if sys
        file.addEventListener(Event.SELECT, onSelectFile);

        file.browseForOpen("Open", [fileFilter]);
        #else
        fileRef.addEventListener(Event.SELECT, onSelectFile);
        
        fileRef.browse([fileFilter]);
        #end
    }

    public function onSelectFile(_:Event):Void
    {
        var name:String = #if sys file.name #else fileRef.name #end ;

        var path:Path = new Path(name);

        setKeyCount(Std.parseInt(path.file.replace("k", "")));

        setState(SELECTING_STRUM);

        playScrollSound();
    }

    public function setKeyCount(keyCount:Int):Void
    {
        strumline.setKeyCount(keyCount);

        strumline.getKeysToCheck();

        strumline.regenStrums();

        strumline.strums.x = strumline.strums.getCenterX();

        getKeybinds();
    }

    public function getKeybinds():Array<Array<Int>>
    {
        keybinds.resize(0);

        var controls:Array<Array<Int>> = Options.noteKeybinds.exists(keyCount) ?
            Options.noteKeybinds[keyCount] : strumline.keyParams.controls;

        for (i in 0 ... controls.length)
        {
            var control:Array<Int> = controls[i];

            var copy:Array<Int> = control.copy();

            keybinds.push(copy);
        }

        return keybinds;
    }

    public function setKeybinds():Void
    {
        var controls:Array<Array<Int>> = Options.noteKeybinds[keyCount] ??= new Array<Array<Int>>();

        controls.resize(0);

        for (i in 0 ... keybinds.length)
        {
            var keys:Array<Int> = keybinds[i];

            controls.push(keys.copy());
        }

        Options.noteKeybinds = Options.noteKeybinds;

        SaveManager.saveOptions();

        getKeybinds();
    }

    public function setTip(text:String):Void
    {
        tipText.text = text;

        tipBox.visible = tipText.text != "";

        tipText.visible = tipBox.visible;

        tipText.setPosition(tipText.getCenterX(), FlxG.height - 96.0);

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

enum EditingState
{
    SELECTING_STRUM;

    SELECTING_BIND;

    SELECTING_KEY;
}