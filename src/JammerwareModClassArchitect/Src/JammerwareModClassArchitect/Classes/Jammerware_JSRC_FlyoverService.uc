class Jammerware_JSRC_FlyoverService extends Object;

var EWidgetColor eColor;
var string FlyoverText;
var string FlyoverIcon;
var float PerUnitDelaySec;
var name TargetPlayAnimation;

public function VisualizeFlyovers(XComGameState VisualizeGameState)
{
	local VisualizationActionMetadata ActionMetadata, EmptyTrack;
	local XComGameState_Unit UnitStateIterator;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local X2Action_PlayAnimation PlayAnimation;
	local X2Action_TimedWait TimedWait;

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitStateIterator)
	{
		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObjectRef = UnitStateIterator.GetReference();
		ActionMetadata.StateObject_OldState = UnitStateIterator;
		ActionMetadata.StateObject_NewState = UnitStateIterator;
		ActionMetadata.VisualizeActor = UnitStateIterator.GetVisualizer();

		if (PerUnitDelaySec > 0)
		{
			TimedWait = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
			TimedWait.DelayTimeSec = PerUnitDelaySec;
		}

		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, FlyoverText, '', self.eColor, FlyoverIcon, `DEFAULTFLYOVERLOOKATTIME, true);
	}

	// second pass to trigger the animation on each target
	// we assign all of these as the child of the last flyover so they don't block each other
	if (TargetPlayAnimation != 'None')
	{
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitStateIterator)
		{
			ActionMetadata = EmptyTrack;
			ActionMetadata.StateObjectRef = UnitStateIterator.GetReference();
			ActionMetadata.StateObject_OldState = UnitStateIterator;
			ActionMetadata.StateObject_NewState = UnitStateIterator;
			ActionMetadata.VisualizeActor = UnitStateIterator.GetVisualizer();

			PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), , SoundAndFlyOver));
			PlayAnimation.Params.AnimName = TargetPlayAnimation;
		}
	}
}

DefaultProperties
{
	eColor=eColor_Good
	PerUnitDelaySec=0.2
}