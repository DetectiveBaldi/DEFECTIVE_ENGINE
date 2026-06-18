package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxInputText;

import core.AssetCache;
import core.Paths;

using StringTools;

class AtlasText extends FlxSpriteGroup
{
    public static var fonts:Map<String, AtlasTextFont> = new Map<String, AtlasTextFont>();

    public var font:AtlasTextFont;

    public var maxHeight(get, never):Float;

    @:noCompletion
    function get_maxHeight():Float
    {
        return font.maxHeight;
    }

    public var text(default, set):String;

    @:noCompletion
    function set_text(v:String):String
    {
        text = v;

        if (font.forceCase != ALL_CASES)
        {
            if (font.forceCase == UPPER_CASE)
                text = text.toUpperCase();
            else
                text = text.toLowerCase();
        }

        for (i in 0 ... members.length)
        {
            var sprite:FlxSprite = members[i];

            sprite.kill();
        }

        var xx:Float = 0.0;

        var yy:Float = 0.0;

        var splitText:Array<String> = text.split("");

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

                    if (sprite.frames != font.atlas)
                        sprite.frames = font.atlas;

                    sprite.animation.addByPrefix(char, AtlasTextFont.getAnimationPrefix(char), 24.0, true);

                    sprite.animation.play(char);

                    sprite.updateHitbox();

                    sprite.setPosition(xx, yy + maxHeight - sprite.height);

                    xx += sprite.width;
                }
            }
        }

        return text;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, ffont:String, ttext:String):Void
    {
        super(x, y);

        if (!fonts.exists(ffont))
            fonts[ffont] = new AtlasTextFont(ffont);

        font = fonts[ffont];

        text = ttext;
    }
}

class AtlasTextFont
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
}
