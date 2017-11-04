class Jammerware_JSRC_IconColorService extends object
    config(JammerwareRunnerClass);

var config string SPIRE_ABILITY_ICON_COLOR;

public static function string GetSpireAbilityIconColor()
{
    if (default.SPIRE_ABILITY_ICON_COLOR == "")
    {
        return class'UIUtilities_Colors'.const.PERK_HTML_COLOR;
    }

    return default.SPIRE_ABILITY_ICON_COLOR;
}