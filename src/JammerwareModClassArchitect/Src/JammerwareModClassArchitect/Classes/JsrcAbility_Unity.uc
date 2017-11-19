class JsrcAbility_Unity extends X2Ability;

var name NAME_ABILITY;

public static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(CreateUnity());
    return Templates;
}

private static function X2AbilityTemplate CreateUnity()
{
	return PurePassive(default.NAME_ABILITY, "img:///UILibrary_PerkIcons.UIPerk_aethershift");
}

DefaultProperties
{
    NAME_ABILITY=Jammerware_JSRC_Ability_Unity
}