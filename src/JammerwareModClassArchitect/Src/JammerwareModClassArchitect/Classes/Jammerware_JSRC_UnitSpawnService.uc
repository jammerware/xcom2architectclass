/*
    Alright. This is easily the craziest-ass thing I'm doing in this mod.

    The problem is that a lot of things happen when a spire is created, and a lot of them (mostly ability condition evaluations)
    require that we know who created the spire almost instantly. I didn't see a particularly clean way to make this happen using
    XComAISpawnManager. Subclassing it is undesirable, 1) because it does a lot of things that have nothing to do with the case
    where the player's action causes the spawn, and 2) it relies on a lot of native and private stuff that would be a huge pain
    to work around just to make the compiler happy. I would also argue that (with respect to Firaxis, since they're probably on
    unimaginable timelines and have to make compromises like this) the XComAISpawnManager is doing way too much. So for my mod,
    I'm pulling the code that strictly deals with creating units into its own stateless service and allowing myself the ability to 
    register the spire to its architect right after it's created. Since I'm just relying on it on this mod to spawn spires, I can
    strip out stuff that (I'm pretty sure) isn't necessary for my case, resulting in cleaner and more maintainable code.

    Yikes? Yikes.
*/
class Jammerware_JSRC_UnitSpawnService extends Object;

public function XComGameState_Unit CreateUnit( 
    XComGameState_Unit OwnerUnit,
	Vector Position, 
	Name CharacterTemplateName, 
	ETeam Team, 
	bool bAddToStartState, 
	optional XComGameState NewGameState)
{
	local XComGameState_Unit NewUnitState;
	local X2CharacterTemplate CharacterTemplate;
	local XComGameStateHistory History;
	local XComGameStateContext_TacticalGameRule StateChangeContainer;
	local X2GameRuleset RuleSet;
	local X2EventManager EventManager;
	local bool NeedsToSubmitGameState;
	local StateObjectReference ItemRef;
	local XComGameState_Item ItemState;

	History = `XCOMHISTORY;

	CharacterTemplate = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(CharacterTemplateName);
	if (CharacterTemplate == None)
	{
		`REDSCREEN("No character template named" @ CharacterTemplateName @ "was found.");
		return none;
	}

	if (bAddToStartState)
	{
		NewGameState = History.GetStartState();

		if(NewGameState == none)
		{
			`assert(false); // attempting to add to start state after the start state has been locked down!
		}
	}

	if( NewGameState == None )
	{		
		StateChangeContainer = XComGameStateContext_TacticalGameRule(class'XComGameStateContext_TacticalGameRule'.static.CreateXComGameStateContext());
		StateChangeContainer.GameRuleType = eGameRule_UnitAdded;
		StateChangeContainer.SetAssociatedPlayTiming(SPT_AfterSequential);
		NewGameState = History.CreateNewGameState(true, StateChangeContainer);
		NeedsToSubmitGameState = true;
	}
	else
	{
		NeedsToSubmitGameState = false;
	}

	NewUnitState = CreateUnitInternal
	(
		OwnerUnit,
		Position, 
		CharacterTemplate, 
		Team, 
		NewGameState
	);

	RuleSet = `XCOMGAME.GameRuleset;
	`assert(RuleSet != none);

	// Trigger that this unit has been spawned
	EventManager = `XEVENTMGR;
	EventManager.TriggerEvent('UnitSpawned', NewUnitState, NewUnitState);

	// make sure any cosmetic units have also been created
	foreach NewUnitState.InventoryItems(ItemRef)
	{
		ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(ItemRef.ObjectID));
		ItemState.CreateCosmeticItemUnit(NewGameState);
	}

	if (NeedsToSubmitGameState)
	{
		// Update the context about the unit we are added
		XComGameStateContext_TacticalGameRule(NewGameState.GetContext()).UnitRef = NewUnitState.GetReference();

		if (!RuleSet.SubmitGameState(NewGameState))
		{
			`log("WARNING! DropUnit could not add NewGameState to the history because the rule set disallowed it!");
		}
	}

	return NewUnitState;
}

private event XComGameState_Unit CreateUnitInternal( 
    XComGameState_Unit OwnerUnit,
	Vector Position, 
	X2CharacterTemplate CharacterTemplate, 
	ETeam Team, 
	XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local XComGameState_Player PlayerState;
	local bool bUsingStartState, bFoundExistingPlayerState;
	local TTile UnitTile;
	local XComGameState_AIGroup NewGroupState;
	local XComGameState_BattleData BattleData;
	local X2TacticalGameRuleset Rules;

	Rules = `TACTICALRULES;
	History = `XCOMHISTORY;

	bUsingStartState = (NewGameState == History.GetStartState());

	// find the player matching the requested team ID... 
	foreach History.IterateByClassType(class'XComGameState_Player', PlayerState)
	{
		if( PlayerState.GetTeam() == Team )
		{
			bFoundExistingPlayerState = true;
			break;
		}
	}

	// ... or create one if it does not yet exist
	if( !bFoundExistingPlayerState )
	{
		PlayerState = class'XComGameState_Player'.static.CreatePlayer(NewGameState, Team);
	}
	
	// create the unit
	UnitTile = `XWORLD.GetTileCoordinatesFromPosition(Position);
	UnitState = CharacterTemplate.CreateInstanceFromTemplate(NewGameState);
	UnitState.PostCreateInit
	(
		NewGameState, 
		CharacterTemplate, 
		PlayerState.ObjectID, 
		UnitTile, 
		Team != eTeam_XCom, 
		bUsingStartState,
		false // perform AI update
	);

	if (!CharacterTemplate.bIsCosmetic)
	{
		NewGroupState = XComGameState_AIGroup(NewGameState.CreateNewStateObject(class'XComGameState_AIGroup'));
		NewGroupState.AddUnitToGroup(UnitState.ObjectID, NewGameState);

		BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
		if( BattleData.UnitActionInitiativeRef.ObjectID == NewGroupState.ObjectID )
		{
			UnitState.SetupActionsForBeginTurn();
		}
		else
		{
			if( BattleData.PlayerTurnOrder.Find('ObjectID', NewGroupState.ObjectID) == INDEX_NONE )
			{
				Rules.AddGroupToInitiativeOrder(NewGroupState, NewGameState);
			}
		}
	}

	return UnitState;
}