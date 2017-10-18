class Jammerware_DebugUtils extends Object;

static function LogUnitAffectedByEffects(XComGameState_Unit Unit)
{
    local int LoopIndex;

    `LOG("JSRC - Unit" @ Unit.GetMyTemplate().DataName @ "affected by...");
    for (LoopIndex = 0; LoopIndex < Unit.AffectedByEffectNames.Length; LoopIndex++)
    {
        `LOG(" - " @ Unit.AffectedByEffectNames[LoopIndex]);
    }
}

static function LogUnitAbilities(XComGameState_Unit Unit)
{
    local int LoopIndex;
    local XComGameState_Ability AbilityState;
    local XComGameStateHistory History;

    History = `XCOMHISTORY;

    `LOG("JSRC - Unit" @ Unit.GetMyTemplate().DataName @ "has" @ Unit.Abilities.Length @ " abilities...");
    for (LoopIndex = 0; LoopIndex < Unit.Abilities.Length; LoopIndex++)
    {
        AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(Unit.Abilities[LoopIndex].ObjectID));
        `LOG(" - " @ AbilityState.GetMyTemplate().DataName);
    }
}

static function LogUnitFValue(XComGameState_Unit Unit, name UnitValueName)
{
    local UnitValue UnitValue;
    Unit.GetUnitValue(UnitValueName, UnitValue);

    `LOG("JSRC: Unit " @ GetUnitLogName(Unit) @ "has value for" @ UnitValueName @ ":" @ UnitValue.fValue);
}

static function LogUnitLocation(XComGameState_Unit Unit)
{
    `LOG("JSRC: unit" @ Unit.GetMyTemplateName() @ Unit.GetReference().ObjectID @ "is located at" @ `XWORLD.GetPositionFromTileCoordinates(Unit.TileLocation));
}

static function string GetUnitLogName(XComGameState_Unit Unit)
{
    return Unit.GetMyTemplateName() @ "(" @ Unit.GetReference().ObjectID @ ")";
}

static function LogUnitInventoryAbilities(XComGameState_Unit Unit)
{
    local array<XComGameState_Item> CurrentInventory;
    local XComGameState_Item InventoryItem;
    local AbilitySetupData Data, EmptyData;
    local X2AbilityTemplateManager AbilityTemplateMan;
    local X2AbilityTemplate AbilityTemplate;
    local X2EquipmentTemplate EquipmentTemplate;
    local name AbilityName;

    //  Gather abilities from the unit's inventory
    AbilityTemplateMan = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	CurrentInventory = Unit.GetAllInventoryItems();

	foreach CurrentInventory(InventoryItem)
	{
		if (InventoryItem.bMergedOut || InventoryItem.InventorySlot == eInvSlot_Unknown)
			continue;
		EquipmentTemplate = X2EquipmentTemplate(InventoryItem.GetMyTemplate());
		if (EquipmentTemplate != none)
		{
			foreach EquipmentTemplate.Abilities(AbilityName)
			{
				AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(AbilityName);
				if( AbilityTemplate != none && AbilityTemplate.ConditionsEverValidForUnit(Unit, false) )
				{
					Data = EmptyData;
					Data.TemplateName = AbilityName;
					Data.Template = AbilityTemplate;
					Data.SourceWeaponRef = InventoryItem.GetReference();
                    `LOG("JSRC: inited ability" @ Data.TemplateName);
				}
			}
		}
	}
}