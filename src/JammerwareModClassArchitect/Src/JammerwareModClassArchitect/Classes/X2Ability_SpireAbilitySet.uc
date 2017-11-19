class X2Ability_SpireAbilitySet extends X2Ability
	config(JammerwareModClassArchitect);

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// COLONEL!
	Templates.AddItem(class'X2Ability_TransmatNetwork'.static.CreateSpireTransmatNetwork());

	return Templates;
}