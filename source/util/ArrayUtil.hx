package util;

class ArrayUtil
{
    public static function getFirst<T>(arr:Array<T>, func:(T)->Bool):T
    {
        var output:Null<T> = null;

        for (i in 0 ... arr.length)
        {
            var t:T = arr[i];

            if (func(t))
            {
                output = t;

                break;
            }
        }

        return output;
    }

    public static function getLast<T>(arr:Array<T>, func:(T)->Bool):T
    {
        var output:Null<T> = null;

        var i:Int = arr.length - 1;

        while (i >=  0.0)
        {
            var t:T = arr[i];

            if (func(t))
            {
                output = t;

                break;
            }

            i--;
        }

        return output;
    }
}