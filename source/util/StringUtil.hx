package util;

using StringTools;

class StringUtil
{
    /**
     * Converts a `Float` to a `String` and appends ".0" if it is not already present.
     * @param float The `Float` to convert and modify.
     * @return `String`
     */
    public static function appendDecimal(float:Float):String
    {
        var output:String = Std.string(float);

        return output.contains(".") ? output : '${output}.0';
    }
}