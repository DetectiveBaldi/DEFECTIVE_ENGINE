package data;

import haxe.Json;

import openfl.utils.Assets;

import core.AssetCache;
import core.Paths;

import data.chart.converters.FNFChartConverter;
import data.chart.converters.LeatherChartConverter;
import data.chart.converters.Psych0_3_2ChartConverter;
import data.chart.converters.PsychChartConverter;

import util.MacroUtil;

using StringTools;

// Difficulties aren't fully supported. They are available for Funkin' charts, though.
class ChartBuilder
{
    public static function buildFromFolder(path:String):Chart
    {
        var difficulty:String = MacroUtil.sanitizeDefine(MacroUtil.getDefine("DIFFICULTY")).toLowerCase();

        var metadataFilePath:String = '${path}/metadata.json';

        if (Paths.exists(metadataFilePath))
        {
            var chartFilePath:String = '${path}/chart.json';
            
            return FNFChartCoverter.buildFromFiles(chartFilePath, metadataFilePath, difficulty);
        }
        else
        {
            var chartFilePath:String = '${path}/chart';

            if (difficulty != "")
                chartFilePath += '-${difficulty}';

            chartFilePath += ".json";

            var data:Dynamic = Json.parse(Assets.getText(chartFilePath));

            if (Reflect.hasField(data, "song"))
            {
                var eventsFilePath:String = '${path}/events.json';

                if (Reflect.hasField(data.song, "song"))
                {
                    if (Reflect.hasField(data.song, "keyCount"))
                    {
                        if (difficulty != "")
                            eventsFilePath = '${eventsFilePath.split(".")[0]}-${difficulty}.json';

                        return LeatherChartConverter.buildFromFiles(chartFilePath, eventsFilePath);
                    }
                    else
                        return Psych0_3_2ChartConverter.buildFromFiles(chartFilePath, eventsFilePath);
                }
                else
                    return PsychChartConverter.buildFromFiles(chartFilePath, eventsFilePath);
            }
            else
                return Chart.build(data);
        }
    }
}