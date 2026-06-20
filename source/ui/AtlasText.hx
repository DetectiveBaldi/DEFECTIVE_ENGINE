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

// This class uses images to render a sequence of characters, rather than a .ttf or .otf file.
// If you need to change the font, assign `font` and then call `setFont` and `setText`.
// If you need to change the text, assign `text` and call `setText`.
class AtlasText extends FlxSpriteGroup
{
    public static var fonts:Map<String, AtlasTextFontData> = new Map<String, AtlasTextFontData>();

    public var font:String;

    public var fontData(get, never):AtlasTextFontData;

    @:noCompletion
    function get_fontData():AtlasTextFontData
    {
        return fonts[font];
    }

    public var maxHeight(get, never):Float;

    @:noCompletion
    function get_maxHeight():Float
    {
        return fontData.maxHeight;
    }

    public var text:String;

    public function new(x:Float = 0.0, y:Float = 0.0, text:String):Void
    {
        super(x, y);

        this.text = text;

        font = "default";

        setFont();

        setText();
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

    // Adds the new font if necessary
    public function setFont():Void
    {
        fonts[font] ??= new AtlasTextFontData(font);
    }

    public function setText():Void
    {
        // No font, we can't render anything.
        if (fontData == null)
            return;

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

        var xx:Float = x;

        var yy:Float = y;

        var splitText:Array<String> = textToRender.split("");

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
                    var sprite:FlxSprite = recycle(FlxSprite, () -> new FlxSprite());

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
}

class AtlasTextFontData
{
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

    public var maxHeight:Float;

    public var forceCase:FlxInputTextCase;

    public function new(name:String):Void
    {
        atlas = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic(Paths.font(Paths.png(name))), Paths.font(Paths.xml(name)));

        atlas.parent.incrementUseCount();

        maxHeight = 0.0;

        var hasUpperCase:Bool = false;

        var hasLowerCase:Bool = false;

        for (i in 0 ... atlas.frames.length)
        {
            var frame:FlxFrame = atlas.frames[i];

            maxHeight = Math.max(maxHeight, frame.frame.height);

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