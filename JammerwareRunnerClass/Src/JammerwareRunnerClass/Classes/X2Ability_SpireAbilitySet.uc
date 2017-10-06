class X2Ability_SpireAbilitySet extends X2Ability
	config(JammerwareRunnerClass);

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.Length = 0;

	// CORPORAL!
	//Templates.AddItem(AddShelter());
	//Templates.AddItem(AddQuicksilver());

	return Templates;
}

//static function X2AbilityTemplate AddShelter()
//{
//	local X2AbilityTemplate Template;
//	local X2AbilityTrigger_EventListener Trigger;
//	local X2Effect_Shelter ShelterEffect;
//
//	`CREATE_X2ABILITY_TEMPLATE(Template, 'Jammerware_JSRC_Ability_Shelter');
//
//	Template.AbilityToHitCalc = default.DeadEye;
//	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
//	Template.AbilityTargetStyle = default.SelfTarget;
//	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
//	Template.Hostility = eHostility_Neutral;
//
//	Trigger = new class'X2AbilityTrigger_EventListener';
//	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
//	Trigger.ListenerData.EventID = 'ObjectMoved';
//	Trigger.ListenerData.Filter = eFilter_Unit;
//	Trigger.ListenerData.EventFn = ShelterTriggerListener;
//	Template.AbilityTriggers.AddItem(Trigger);
//
//	ShelterEffect = new class'X2Effect_Shelter';
//	ShelterEffect.BuildPersistentEffect(1, true, false);
//	// TODO: localize
//	ShelterEffect.SetDisplayInfo(ePerkBuff_Bonus, "Shelter", "Contact with a spire has granted this soldier an energy shield.", "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);
//	ShelterEffect.AddPersistentStatChange(eStat_ShieldHP, 1);
//	ShelterEffect.EffectRemovedVisualizationFn = OnShieldRemoved_BuildVisualization;
//	Template.AddShooterEffect(ShelterEffect);
//
//	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
//	
//	return Template;
//}