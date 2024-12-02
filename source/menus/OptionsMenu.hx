package menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.tweens.FlxTween;

import flixel.util.FlxColor;

import flixel.addons.display.FlxBackdrop;

import core.AssetMan;
import core.Paths;

import game.levels.Level1;

class OptionsMenu extends FlxState
{
    public var background:FlxSprite;

    public var backdrop:FlxBackdrop;

    public var gradient:FlxSprite;

    public var cornerCutout:FlxSprite;

    public var gear:FlxSprite;

    public var options:FlxTypedSpriteGroup<BaseOptionItem>;

    public var option(default, set):Int;

    @:noCompletion
    function set_option(_option:Int):Int
    {
        option = _option;

        for (i in 0 ... options.members.length)
        {
            var _option:BaseOptionItem = options.members[i];

            _option.alpha = 0.5;

            if (Std.isOfType(_option, BoolOptionItem))
                cast (_option, BoolOptionItem).enabled = false;

            if (Std.isOfType(_option, KeybindOptionItem))
                cast (_option, KeybindOptionItem).enabled = false;
        }

        var _option:BaseOptionItem = options.members[option];

        _option.alpha = 1.0;

        if (Std.isOfType(_option, BoolOptionItem))
            cast (_option, BoolOptionItem).enabled = true;

        if (Std.isOfType(_option, KeybindOptionItem))
            cast (_option, KeybindOptionItem).enabled = true;

        return option;
    }

    public var descriptor:FlxSprite;

    public var descText:FlxText;

    public var tune:FlxSound;

    override function create():Void
    {
        super.create();

        FlxG.mouse.visible = true;

        background = new FlxSprite(0.0, 0.0, AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/background")));

        background.active = false;

        background.antialiasing = true;

        background.color = background.color.getDarkened(0.25);

        add(background);

        backdrop = new FlxBackdrop(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/backdrop")));

        backdrop.antialiasing = true;

        backdrop.alpha = 0.35;

        backdrop.color = backdrop.color.getDarkened(0.25);

        backdrop.velocity.set(15.0, 15.0);

        add(backdrop);

        gradient = new FlxSprite(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/gradient")));

        gradient.active = false;

        gradient.antialiasing = true;

        gradient.color = gradient.color.getDarkened(0.25);

        add(gradient);

        cornerCutout = new FlxSprite();

        cornerCutout.antialiasing = true;

        cornerCutout.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/cornerCutout")), Paths.xml("assets/images/menus/OptionsMenu/cornerCutout"));

        cornerCutout.animation.addByPrefix("cornerCutout", "cornerCutout", 12.0);

        cornerCutout.animation.play("cornerCutout");

        cornerCutout.scale.set(0.85, 0.85);

        cornerCutout.updateHitbox();

        cornerCutout.setPosition(-125.0, -65.0);

        add(cornerCutout);

        gear = new FlxSprite(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/gear")));

        gear.active = false;

        gear.antialiasing = true;

        gear.setPosition(-gear.width * 0.45, -gear.height * 0.45);

        add(gear);

        FlxTween.angle(gear, 0.0, 360.0, 5.0, {type: LOOPING});

        options = new FlxTypedSpriteGroup<BaseOptionItem>();

        add(options);

        var header:BaseOptionItem = new HeaderOptionItem(0.0, 0.0, "Window Settings", "");

        header.setPosition(FlxG.width - header.width + 165.0, 50.0);

        options.add(header);

        var bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Auto Pause", "If checked, the game will freeze when window focus is lost.", "autoPause");

        bool.onUpdate.add((value:Bool) -> 
        {
            FlxG.autoPause = value;

            FlxG.console.autoPause = value;
        });

        bool.setPosition(FlxG.width - bool.width + 50.0, header.y + header.height);

        options.add(bool);

        var _header:BaseOptionItem = new HeaderOptionItem(0.0, 0.0, "Asset Management Settings", "");

        _header.nameText.size = 36;

        _header.setPosition(FlxG.width - header.width + 165.0, bool.y + bool.height);

        _header.nameText.setPosition(_header.background.getMidpoint().x - _header.nameText.width * 0.5, _header.background.getMidpoint().y - _header.nameText.height * 0.5);

        options.add(_header);

        var _bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "GPU Caching", "If checked, bitmap pixel data is disposed from RAM\nwhere applicable (may require restarting the application).", "gpuCaching");

        _bool.setPosition(FlxG.width - _bool.width + 50.0, _header.y + _header.height);

        options.add(_bool);

        var __bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Sound Streaming", "If checked, audio is loaded progressively\nwhere applicable (may require restarting the application).", "soundStreaming");

        __bool.setPosition(FlxG.width - __bool.width + 50.0, _bool.y + _bool.height);

        options.add(__bool);

        var __header:BaseOptionItem = new HeaderOptionItem(0.0, 0.0, "Keybind Settings", "");

        __header.setPosition(FlxG.width - __header.width + 165.0, __bool.y + __bool.height);

        options.add(__header);

        var keybind:KeybindOptionItem = new KeybindOptionItem(0.0, 0.0, "Left Note", "Keybindings for the first note in the strum line.", "NOTE:LEFT");

        keybind.setPosition(FlxG.width - keybind.width + 100.0, __header.y + __header.height);

        options.add(keybind);

        var _keybind:KeybindOptionItem = new KeybindOptionItem(0.0, 0.0, "Down Note", "Keybindings for the second note in the strum line.", "NOTE:DOWN");

        _keybind.setPosition(FlxG.width - _keybind.width + 100.0, keybind.y + keybind.height);

        options.add(_keybind);

        var __keybind:KeybindOptionItem = new KeybindOptionItem(0.0, 0.0, "Up Note", "Keybindings for the third note in the strum line.", "NOTE:UP");

        __keybind.setPosition(FlxG.width - __keybind.width + 100.0, _keybind.y + _keybind.height);

        options.add(__keybind);

        var ___keybind:KeybindOptionItem = new KeybindOptionItem(0.0, 0.0, "Right Note", "Keybindings for the fourth note in the strum line.", "NOTE:RIGHT");

        ___keybind.setPosition(FlxG.width - ___keybind.width + 100.0, __keybind.y + __keybind.height);

        options.add(___keybind);

        var ___header:BaseOptionItem = new HeaderOptionItem(0.0, 0.0, "Gameplay Settings", "");

        ___header.setPosition(FlxG.width - ___header.width + 165.0, ___keybind.y + ___keybind.height);

        options.add(___header);

        var ___bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Downscroll", "If checked, flips the strum lines' vertical position.", "downscroll");

        ___bool.setPosition(FlxG.width - ___bool.width + 50.0, ___header.y + ___header.height);

        options.add(___bool);

        var ____bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Middlescroll", "If checked, centers the playable strum line and\nhides the opponent's.", "middlescroll");

        ____bool.setPosition(FlxG.width - ____bool.width + 50.0, ___bool.y + ___bool.height);

        options.add(____bool);

        var _____bool:BoolOptionItem = new BoolOptionItem(0.0, 0.0, "Ghost Tapping", "If unchecked, pressing an input with no notes\non screen will cause damage.", "ghostTapping");

        _____bool.setPosition(FlxG.width - _____bool.width + 50.0, ____bool.y + ____bool.height);

        options.add(_____bool);

        option = 0;

        descriptor = new FlxSprite();

        descriptor.antialiasing = true;

        descriptor.color = descriptor.color.getDarkened(0.15);

        descriptor.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png("assets/images/menus/OptionsMenu/descriptor")), Paths.xml("assets/images/menus/OptionsMenu/descriptor"));

        descriptor.animation.addByPrefix("descriptor", "descriptor", 12.0);

        descriptor.animation.play("descriptor");

        descriptor.scale.set(0.85, 0.85);

        descriptor.setPosition(-150.0, 550.0);

        add(descriptor);

        descText = new FlxText(0.0, 0.0, descriptor.width, options.members[option].description, 28);

        descText.antialiasing = true;

        descText.color = FlxColor.BLACK;

        descText.font = Paths.ttf("assets/fonts/Ubuntu Regular");

        descText.alignment = CENTER;

        descText.setPosition(descriptor.getMidpoint().x - descText.width * 0.5, descriptor.getMidpoint().y - descText.height * 0.5 - 25.0);

        add(descText);

        tune = FlxG.sound.load(AssetMan.sound(Paths.ogg("assets/music/menus/OptionsMenu/tune")), 0.0, true);

        tune.fadeIn(1.0, 0.0, 1.0);

        tune.play();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.DOWN)
        {
            FlxG.sound.play(AssetMan.sound(Paths.ogg("assets/sounds/menus/OptionsMenu/scroll"), false), 0.35);

            option = FlxMath.wrap(option + 1, 0, options.members.length - 1);
        }

        if (FlxG.keys.justPressed.UP)
        {
            FlxG.sound.play(AssetMan.sound(Paths.ogg("assets/sounds/menus/OptionsMenu/scroll"), false), 0.35);

            option = FlxMath.wrap(option - 1, 0, options.members.length - 1);
        }

        if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.UP)
            descText.text = options.members[option].description;

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(() -> new Level1());

        var targetY:Float = 0.0;

        for (i in 0 ... option)
            targetY -= (i < options.members.length - 3.0 ? options.members[i].height : 0.0);

        options.y = targetY + (options.y - targetY) * Math.exp(-15.0 * elapsed);
    }
}