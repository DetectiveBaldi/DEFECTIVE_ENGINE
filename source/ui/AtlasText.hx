package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxInputText;
import flixel.util.FlxDestroyUtil;

import core.AssetCache;
import core.Paths;

using StringTools;

/**
 * This class uses `flixel.FlxSprite`s to display a sequence of characters, rather than a `flixel.text.FlxText`.
 */
class AtlasText extends FlxSpriteGroup
{
    var _needsRegen:Bool;

    public var text(default, set):String;

    @:noCompletion
    function set_text(v:String):String
    {
        var lastText:String = text;

        text = v;

        if (text != lastText)
            regenerate();

        return text;
    }

    public var font(default, set):AtlasTextFont;

    @:noCompletion
    function set_font(v:AtlasTextFont)
    {
        var lastFont:AtlasTextFont = font;

        font = v;

        if (font != lastFont)
            regenerate();

        return font;
    }

    public var fontData(get, never):AtlasTextFontData;

    @:noCompletion
    function get_fontData():AtlasTextFontData
    {
        return font == null ? AtlasTextFontData.DEFAULT_FONT : font == DEFAULT ? AtlasTextFontData.DEFAULT_FONT : AtlasTextFontData.BOLD_FONT;
    }

    public var minWidth(get, never):Float;

    @:noCompletion
    function get_minWidth():Float
    {
        return fontData.minWidth;
    }

    public var maxWidth(get, never):Float;

    @:noCompletion
    function get_maxWidth():Float
    {
        return fontData.maxWidth;
    }

    public var minHeight(get, never):Float;

    @:noCompletion
    function get_minHeight():Float
    {
        return fontData.minHeight;
    }

    public var maxHeight(get, never):Float;

    @:noCompletion
    function get_maxHeight():Float
    {
        return fontData.maxHeight;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, text:String):Void
    {
        super(x, y);

        _needsRegen = false;

        this.text = text;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        for (i in 0 ... members.length)
        {
            var char:FlxSprite = members[i];

            char.active = char.isOnScreen();
        }
    }

    function regenerate():Void
    {
        var textToRender:String = text;

        if (fontData.forceCase != ALL_CASES)
        {
            if (fontData.forceCase == UPPER_CASE)
                textToRender = text.toUpperCase();
            else
                textToRender = text.toLowerCase();
        }

        for (i in 0 ... members.length)
        {
            var char:FlxSprite = members[i];

            char.kill();
        }

        if (textToRender == "")
            return;

        var xx:Float = x;

        var yy:Float = y;

        var splitText:Array<String> = textToRender.split("");

        var maxHeight:Float = fontData.maxHeight;

        for (i in 0 ... splitText.length)
        {
            var char:String = splitText[i];

            switch (char:String)
            {
                case " ":
                    xx += 40.0;
                
                case "\n":
                {
                    xx = 0;

                    yy += maxHeight;
                }

                default:
                {
                    var sprite:FlxSprite = recycle(null, spriteFactory);

                    sprite.antialiasing = true;

                    sprite.frames = fontData.atlas;

                    sprite.animation.addByPrefix(char, AtlasTextFontData.getAnimationPrefix(char), 24.0, true);

                    sprite.animation.play(char);

                    sprite.updateHitbox();

                    sprite.setPosition(xx, yy + maxHeight - sprite.height);

                    xx += sprite.width;
                }
            }
        }
    }

    public function spriteFactory():FlxSprite
    {
        return new FlxSprite();
    }
}

class AtlasTextFontData
{
    static var _DEFAULT_FONT:AtlasTextFontData;

    public static var DEFAULT_FONT(get, never):AtlasTextFontData;

    @:noCompletion
    public static function get_DEFAULT_FONT():AtlasTextFontData
    {
        if (_DEFAULT_FONT == null)
            _DEFAULT_FONT = new AtlasTextFontData("default");

        return _DEFAULT_FONT;
    }

    static var _BOLD_FONT:AtlasTextFontData;

    public static var BOLD_FONT(get, never):AtlasTextFontData;

    @:noCompletion
    public static function get_BOLD_FONT():AtlasTextFontData
    {
        if (_BOLD_FONT == null)
            _BOLD_FONT = new AtlasTextFontData("bold");

        return _BOLD_FONT;
    }

    public static var upperCaseChars:EReg = ~/^[A-Z]\d+$/;

    public static var lowerCaseChars:EReg = ~/^[a-z]\d+$/;

    public static function getAnimationPrefix(char:String):String
    {
        return switch (char)
        {
            case '&': '-andpersand-';

            case "😠": '-angry faic-';

            case "'": '-apostraphie-';

            case "\\": '-back slash-';

            case ",": '-comma-';

            case '-': '-dash-';

            case '↓': '-down arrow-';
            
            case "”": '-end quote-';

            case "!": '-exclamation point-';

            case "/": '-forward slash-';

            case '>': '-greater than-';

            case '♥' | '♡': '-heart-';
            
            case '←': '-left arrow-';

            case '<': '-less than-';

            case "*": '-multiply x-';

            case '.': '-period-';

            case "?": '-question mark-';

            case '→': '-right arrow-';

            case "“": '-start quote-';

            case '↑': '-up arrow-';

            default: char;
        }
    }

    public var atlas:FlxAtlasFrames;

    public var minWidth:Float;

    public var maxWidth:Float;

    public var minHeight:Float;

    public var maxHeight:Float;

    public var forceCase:FlxInputTextCase;

    public function new(name:String):Void
    {
        atlas = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic(Paths.font(Paths.png(name))), Paths.font(Paths.xml(name)));

        atlas.parent.incrementUseCount();

        minWidth = 0.0;

        maxWidth = 0.0;

        minHeight = 0.0;

        maxHeight = 0.0;

        var hasUpperCase:Bool = false;

        var hasLowerCase:Bool = false;

        for (i in 0 ... atlas.frames.length)
        {
            var frame:FlxFrame = atlas.frames[i];

            var frameWidth:Float = frame.frame.width;

            var frameHeight:Float = frame.frame.height;

            minWidth = Math.min(minWidth, frameWidth);

            maxWidth = Math.max(maxWidth, frameWidth);

            minHeight = Math.min(minHeight, frameHeight);

            maxHeight = Math.max(maxHeight, frameHeight);

            if (!upperCaseChars.match(frame.name) && !lowerCaseChars.match(frame.name))
                continue;

            if (frame.name == frame.name.toUpperCase())
                hasUpperCase = true;

            if (frame.name == frame.name.toLowerCase())
                hasLowerCase = true;
        }

        if (hasUpperCase && hasLowerCase)
            forceCase = ALL_CASES;
        else
        {
            if (hasUpperCase)
                forceCase = UPPER_CASE;
            else
                forceCase = LOWER_CASE;
        }
    }

    public function destroy():Void
    {
        atlas = FlxDestroyUtil.destroy(atlas);
    }
}

enum AtlasTextFont
{
    DEFAULT;

    BOLD;
}