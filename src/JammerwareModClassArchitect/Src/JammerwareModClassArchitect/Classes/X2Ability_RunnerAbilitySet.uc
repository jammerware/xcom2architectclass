class X2Ability_RunnerAbilitySet extends X2Ability
	config(JammerwareModClassArchitect);

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// MAJOR!
	Templates.AddItem(class'X2Ability_TransmatLink'.static.CreateTransmatLink());

	return Templates;
}