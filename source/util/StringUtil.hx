package util;

using StringTools;

class StringUtil
{
    public static function setCase(v:String, delimiter:String = " ", strCase:StringCase):String
    {
        switch (strCase:StringCase)
        {
            case CAMEL:
            {
                var split:Array<String> = v.split(delimiter);

                for (i in 0 ... split.length)
                {
                    var s:String = split[i];

                    s = s.substring(0, 1);

                    if (i == 0)
                        split[i] = s.toLowerCase();
                    else
                        split[i] = s.toUpperCase();

                    split[i] += s.substring(1, s.length + 1);
                }

                return split.join("");
            }

            case KEBAB:
                return v.toLowerCase().replace(delimiter, "-");

            case PASCAL:
            {
                var split:Array<String> = v.split(delimiter);

                for (i in 0 ... split.length)
                {
                    var s:String = split[i];

                    split[i] = s.charAt(0).toUpperCase() + s.substring(1, s.length + 1);
                }

                return split.join("");
            }
        }
    }

    public static function parseInt(v:String):Null<Int>
    {
        if (MathUtil.BASE_10.exists(v))
            return MathUtil.BASE_10[v];

        return Std.parseInt(v);
    }
}

enum StringCase
{
    CAMEL;

    KEBAB;

    PASCAL;
}