class Jammerware_JSRC_FlyoverService extends Object;

var string FlyoverText;
var string FlyoverIcon;
var EWidgetColor eColor;

public function VisualizeFlyovers(XComGameState VisualizeGameState)
{
    local XComGameState_Unit UnitState;
	local VisualizationActionMetadata ActionMetadata;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local X2Action_TimedWait TimedWait;

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		ActionMetadata.StateObject_OldState = UnitState;
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor = UnitState.GetVisualizer();

		TimedWait = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		TimedWait.DelayTimeSec = 0.2;

		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, FlyoverText, '', self.eColor, FlyoverIcon, `DEFAULTFLYOVERLOOKATTIME, true);
	}
}

DefaultProperties
{
	eColor=eColor_Good
}