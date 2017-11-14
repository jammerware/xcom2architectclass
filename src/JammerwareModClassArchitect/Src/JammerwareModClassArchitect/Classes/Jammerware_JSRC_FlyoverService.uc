class Jammerware_JSRC_FlyoverService extends Object;

var float DelaySec;
var EWidgetColor eColor;
var string FlyoverText;
var string FlyoverIcon;
var name TargetPlayAnimation;

public function VisualizeFlyover(XComGameState VisualizeGameState, XComGameState_Unit UnitState, out VisualizationActionMetadata VisualizationParent)
{
	local VisualizationActionMetadata ActionMetadata, EmptyTrack;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local X2Action_PlayAnimation PlayAnimation;
	local X2Action_TimedWait TimedWait;

	// if a visualization parent was passed in, tell the empty track to use the parent's last action as its last action
	EmptyTrack.LastActionAdded = VisualizationParent.LastActionAdded;

	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObjectRef = UnitState.GetReference();
	ActionMetadata.StateObject_OldState = UnitState;
	ActionMetadata.StateObject_NewState = UnitState;
	ActionMetadata.VisualizeActor = UnitState.GetVisualizer();

	if (DelaySec > 0)
	{
		TimedWait = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		TimedWait.DelayTimeSec = DelaySec;
	}

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(none, FlyoverText, '', self.eColor, FlyoverIcon, `DEFAULTFLYOVERLOOKATTIME, true);

	// set the flyover as the last action added so that other animations in the visualization sequence don't have to wait
	// TODO: class level var this?
	VisualizationParent.LastActionAdded = ActionMetadata.LastActionAdded;

	// second pass to trigger the animation on each target
	if (TargetPlayAnimation != 'None')
	{
		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObjectRef = UnitState.GetReference();
		ActionMetadata.StateObject_OldState = UnitState;
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor = UnitState.GetVisualizer();

		PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), , SoundAndFlyOver));
		PlayAnimation.Params.AnimName = TargetPlayAnimation;
	}
}

DefaultProperties
{
	DelaySec=0.2
	eColor=eColor_Good
}