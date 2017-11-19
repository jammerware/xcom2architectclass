class X2Ability_SpireAbilitySet extends X2Ability
	config(JammerwareModClassArchitect);

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// LIEUTENANT
	Templates.AddItem(class'X2Ability_TargetingArray'.static.CreateSpireTargetingArray());
	Templates.AddItem(class'X2Ability_TargetingArray'.static.CreateSpireTargetingArrayTriggered());

	// COLONEL!
	Templates.AddItem(class'X2Ability_TransmatNetwork'.static.CreateSpireTransmatNetwork());

	return Templates;
}