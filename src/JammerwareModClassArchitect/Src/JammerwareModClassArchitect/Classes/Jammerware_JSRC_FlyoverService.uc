class Jammerware_JSRC_FlyoverService extends Object;

var X2AbilityTemplate AbilityTemplate;

public function VisualizeFlyovers(XComGameState VisualizeGameState)
{
    local XComGameState_Unit UnitState;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateHistory History;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local X2Action_TimedWait TimedWait;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
        `LOG("JSRC: visualizing flyover for" @ UnitState.GetMyTemplateName());

		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor = UnitState.GetVisualizer();

		if (self.AbilityTemplate == none)
		{
			`REDSCREEN("JSRC: The flyover service was used without having an ability template set. This is undesirable.");
			return;
		}

		TimedWait = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		TimedWait.DelayTimeSec = 0.2;

		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Good, AbilityTemplate.IconImage, `DEFAULTFLYOVERLOOKATTIME);
	}
}