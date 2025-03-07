package util;

class ArrayUtil
{
    public static function oldest<T>(arr:Array<T>, func:(T)->Bool = null):T
    {
        var output:T = null;

        if (func == null)
            output = arr[0];
        else
        {
            for (i in 0 ... arr.length)
            {
                var t:T = arr[i];

                if (func(t))
                {
                    output = t;

                    break;
                }
            }
        }

        return output;
    }

    public static function newest<T>(arr:Array<T>, func:(T)->Bool = null):T
    {
        var output:T = null;

        if (func == null)
            output = arr[arr.length - 1];
        else
        {
            var i:Int = arr.length - 1;

            while (i >= 0.0)
            {
                var t:T = arr[i];

                if (func(t))
                {
                    output = t;

                    break;
                }

                i--;
            }
        }

        return output;
    }
}