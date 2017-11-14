class JsrcAbilityTemplate extends X2AbilityTemplate;

function XComGameState_Ability CreateInstanceFromTemplate(XComGameState NewGameState)
{
	local JsrcGameState_Ability Ability;	
	Ability = JsrcGameState_Ability(NewGameState.CreateNewStateObject(class'JsrcGameState_Ability', self));
	return Ability;
}