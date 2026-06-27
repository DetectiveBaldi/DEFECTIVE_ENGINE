package data;

import haxe.Json;

import openfl.utils.Assets;

import core.AssetCache;
import core.Paths;
import data.LevelData;
import data.chart.converters.FNFChartConverter;
import data.chart.converters.LeatherChartConverter;
import data.chart.converters.Psych0_3_2ChartConverter;
import data.chart.converters.PsychChartConverter;

using StringTools;

class ChartBuilder
{
    public static function buildFromLevel(level:LevelData):Chart
    {
        var difficulty:String = level.difficulty;

        var prefix:String = Paths.data('game/levels/${level.name}');

        var suffix:String = "";

        if (difficulty != "Normal")
            suffix = '-${difficulty}';

        var metadataFilePath:String = '${prefix}/metadata.json';

        if (Paths.exists(metadataFilePath))
        {
            var chartFilePath:String = '${prefix}/chart.json';
            
            return FNFChartCoverter.buildFromFiles(chartFilePath, metadataFilePath, difficulty);
        }
        else
        {
            var chartFilePath:String = '${prefix}/chart${suffix}.json';

            var data:Dynamic = Json.parse(Assets.getText(chartFilePath));

            if (Reflect.hasField(data, "song"))
            {
                var eventsFilePath:String = '${prefix}/events${suffix}.json';

                if (!Paths.exists(eventsFilePath))
                    eventsFilePath = '${prefix}/events${suffix}.json';

                if (Reflect.hasField(data.song, "song"))
                {
                    if (Reflect.hasField(data.song, "keyCount"))
                        return LeatherChartConverter.buildFromFiles(chartFilePath, eventsFilePath);
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