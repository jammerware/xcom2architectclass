class X2EventListenerTemplate_LoadPerks extends X2EventListenerTemplate;

var ETeam ListenForTeam;
var array<PerkRegistration> PerksToRegister;

public function AddPerkToRegister(name Ability, optional name SoldierClassName, optional name CharacterGroupName)
{
    local PerkRegistration Registration;

    Registration.Ability = Ability;
    Registration.CharacterGroupName = CharacterGroupName;
    Registration.SoldierClassName = SoldierClassName;

    PerksToRegister.AddItem(Registration);
}

DefaultProperties
{
    ListenForTeam=eTeam_All
	RegisterInTactical=true
}