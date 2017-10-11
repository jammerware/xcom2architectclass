class X2Effect_LightningRodDamage extends X2Effect_ApplyWeaponDamage;

// TODO: this is extending apply weapon damage for logging right now. should we do something like check if the ability source is
// a spire and then go get its runner's gun?

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local Damageable kNewTargetDamageableState;
	local int iDamage, iMitigated, NewRupture, NewShred, TotalToKill; 
	local XComGameState_Unit TargetUnit, SourceUnit;
	local XComGameState_Item SourceWeapon;
	local array<X2WeaponUpgradeTemplate> WeaponUpgradeTemplates;
	local X2WeaponUpgradeTemplate WeaponUpgradeTemplate;
	local array<Name> AppliedDamageTypes;
	local int bAmmoBypassesShields, bFullyImmune;
	local bool bDoesDamageIgnoreShields;
	local XComGameStateHistory History;
	local StateObjectReference EffectRef;
	local XComGameState_Effect EffectState;
	local array<DamageModifierInfo> SpecialDamageMessages;
	local DamageResult ZeroDamageResult;

    `LOG("JSRC: lightning rod damage applied to " @ XComGameState_Unit(kNewTargetState).GetMyTemplate().DataName);

	kNewTargetDamageableState = Damageable(kNewTargetState);
	if( kNewTargetDamageableState != none )
	{
		AppliedDamageTypes = DamageTypes;
		iDamage = CalculateDamageAmount(ApplyEffectParameters, iMitigated, NewRupture, NewShred, AppliedDamageTypes, bAmmoBypassesShields, bFullyImmune, SpecialDamageMessages, NewGameState);
		bDoesDamageIgnoreShields = (bAmmoBypassesShields > 0) || bBypassShields;

		if ((iDamage == 0) && (iMitigated == 0) && (NewRupture == 0) && (NewShred == 0))
		{
            `LOG("JSRC: no damage :(");
			// No damage is being dealt
			if (SpecialDamageMessages.Length > 0 || bFullyImmune != 0)
			{
				TargetUnit = XComGameState_Unit(kNewTargetState);
				if (TargetUnit != none)
				{
					ZeroDamageResult.bImmuneToAllDamage = bFullyImmune != 0;
					ZeroDamageResult.Context = NewGameState.GetContext();
					ZeroDamageResult.SourceEffect = ApplyEffectParameters;
					ZeroDamageResult.SpecialDamageFactors = SpecialDamageMessages;
					TargetUnit.DamageResults.AddItem(ZeroDamageResult);
				}
			}
			return;
		}

		if (bAllowFreeKill)
		{
			//  check to see if the damage ought to kill them and if not, roll for a free kill
			TargetUnit = XComGameState_Unit(kNewTargetState);
			if (TargetUnit != none)
			{
				TotalToKill = TargetUnit.GetCurrentStat(eStat_HP) + TargetUnit.GetCurrentStat(eStat_ShieldHP);
				if (TotalToKill > iDamage)
				{
					History = `XCOMHISTORY;
					//  check weapon upgrades for a free kill
					SourceWeapon = XComGameState_Item(History.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
					if (SourceWeapon != none)
					{
						WeaponUpgradeTemplates = SourceWeapon.GetMyWeaponUpgradeTemplates();
						foreach WeaponUpgradeTemplates(WeaponUpgradeTemplate)
						{
							if (WeaponUpgradeTemplate.FreeKillFn != none && WeaponUpgradeTemplate.FreeKillFn(WeaponUpgradeTemplate, TargetUnit))
							{
								TargetUnit.TakeEffectDamage(self, TotalToKill, 0, NewShred, ApplyEffectParameters, NewGameState, false, false, true, AppliedDamageTypes, SpecialDamageMessages);
								if (TargetUnit.IsAlive())
								{
									`RedScreen("Somehow free kill upgrade failed to kill the target! -jbouscher @gameplay");
								}
								else
								{
									TargetUnit.DamageResults[TargetUnit.DamageResults.Length - 1].bFreeKill = true;
								}
								return;
							}
						}
					}
					//  check source unit effects for a free kill
					SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
					if (SourceUnit == none)
						SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

					foreach SourceUnit.AffectedByEffects(EffectRef)
					{
						EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
						if (EffectState != none)
						{
							if (EffectState.GetX2Effect().FreeKillOnDamage(SourceUnit, TargetUnit, NewGameState, TotalToKill, ApplyEffectParameters))
							{
								TargetUnit.TakeEffectDamage(self, TotalToKill, 0, NewShred, ApplyEffectParameters, NewGameState, false, false, true, AppliedDamageTypes, SpecialDamageMessages);
								if (TargetUnit.IsAlive())
								{
									`RedScreen("Somehow free kill effect failed to kill the target! -jbouscher @gameplay");
								}
								else
								{
									TargetUnit.DamageResults[TargetUnit.DamageResults.Length - 1].bFreeKill = true;
									TargetUnit.DamageResults[TargetUnit.DamageResults.Length - 1].FreeKillAbilityName = EffectState.ApplyEffectParameters.AbilityInputContext.AbilityTemplateName;
								}
								return;
							}
						}
					}
				}
			}
		}
		
		if (NewRupture > 0)
		{
			kNewTargetDamageableState.AddRupturedValue(NewRupture);
		}

		kNewTargetDamageableState.TakeEffectDamage(self, iDamage, iMitigated, NewShred, ApplyEffectParameters, NewGameState, false, true, bDoesDamageIgnoreShields, AppliedDamageTypes, SpecialDamageMessages);
	}
}

simulated function int CalculateDamageAmount(const out EffectAppliedData ApplyEffectParameters, out int ArmorMitigation, out int NewRupture, out int NewShred, out array<Name> AppliedDamageTypes, out int bAmmoIgnoresShields, out int bFullyImmune, out array<DamageModifierInfo> SpecialDamageMessages, optional XComGameState NewGameState)
{
	local int TotalDamage, WeaponDamage, DamageSpread, ArmorPiercing, EffectDmg, CritDamage;

	local XComGameStateHistory History;
	local XComGameState_Unit kSourceUnit;
	local Damageable kTarget;
	local XComGameState_Unit TargetUnit;
	local XComGameState_Item kSourceItem, LoadedAmmo;
	local XComGameState_Ability kAbility;
	local XComGameState_Effect EffectState;
	local StateObjectReference EffectRef;
	local X2Effect_Persistent EffectTemplate;
	local WeaponDamageValue BaseDamageValue, ExtraDamageValue, BonusEffectDamageValue, AmmoDamageValue, UpgradeTemplateBonusDamage, UpgradeDamageValue;
	local X2AmmoTemplate AmmoTemplate;
	local int RuptureCap, RuptureAmount, OriginalMitigation, UnconditionalShred;
	local int EnvironmentDamage, TargetBaseDmgMod;
	local XComDestructibleActor kDestructibleActorTarget;
	local array<X2WeaponUpgradeTemplate> WeaponUpgradeTemplates;
	local X2WeaponUpgradeTemplate WeaponUpgradeTemplate;
	local DamageModifierInfo ModifierInfo;
	local bool bWasImmune, bHadAnyDamage;

	ArmorMitigation = 0;
	NewRupture = 0;
	NewShred = 0;
	EnvironmentDamage = 0;
	bAmmoIgnoresShields = 0;    // FALSE
	bWasImmune = true;			//	as soon as we check any damage we aren't immune to, this will be set false
	bHadAnyDamage = false;

	//Cheats can force the damage to a specific value
	if (`CHEATMGR != none && `CHEATMGR.NextShotDamageRigged )
	{
		`CHEATMGR.NextShotDamageRigged = false;
		return `CHEATMGR.NextShotDamage;
	}

	History = `XCOMHISTORY;
	kSourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));	
	kTarget = Damageable(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	kDestructibleActorTarget = XComDestructibleActor(History.GetVisualizer(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	kAbility = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (kAbility != none && kAbility.SourceAmmo.ObjectID > 0)
		kSourceItem = XComGameState_Item(History.GetGameStateForObjectID(kAbility.SourceAmmo.ObjectID));		
	else
		kSourceItem = XComGameState_Item(History.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));		

	if( bAlwaysKillsCivilians )
	{
		TargetUnit = XComGameState_Unit(kTarget);

		if( (TargetUnit != none) && (TargetUnit.GetTeam() == eTeam_Neutral) )
		{
			// Return the amount of health the civlian has so that it will be euthanized
			return TargetUnit.GetCurrentStat(eStat_HP) + TargetUnit.GetCurrentStat(eStat_ShieldHP);
		}
	}

	`log("===" $ GetFuncName() $ "===", true, 'XCom_HitRolls');

	if (kSourceItem != none)
	{
		`log("Attacker ID:" @ kSourceUnit.ObjectID @ "With Item ID:" @ kSourceItem.ObjectID @ "Target ID:" @ ApplyEffectParameters.TargetStateObjectRef.ObjectID, true, 'XCom_HitRolls');
		if (!bIgnoreBaseDamage)
		{
			kSourceItem.GetBaseWeaponDamageValue(XComGameState_BaseObject(kTarget), BaseDamageValue);
			EnvironmentDamage += kSourceItem.GetItemEnvironmentDamage();
			if (BaseDamageValue.Damage > 0) bHadAnyDamage = true;

			bWasImmune = bWasImmune && ModifyDamageValue(BaseDamageValue, kTarget, AppliedDamageTypes);
		}
		if (DamageTag != '')
		{
            `LOG("JSRC: damage tag" @ DamageTag);
			kSourceItem.GetWeaponDamageValue(XComGameState_BaseObject(kTarget), DamageTag, ExtraDamageValue);
            `LOG("JSRC: damage extra" @ ExtraDamageValue.Damage);
			if (ExtraDamageValue.Damage > 0) bHadAnyDamage = true;

			bWasImmune = bWasImmune && ModifyDamageValue(ExtraDamageValue, kTarget, AppliedDamageTypes);
		}
		if (kSourceItem.HasLoadedAmmo() && !bIgnoreBaseDamage)
		{
			LoadedAmmo = XComGameState_Item(History.GetGameStateForObjectID(kSourceItem.LoadedAmmo.ObjectID));
			AmmoTemplate = X2AmmoTemplate(LoadedAmmo.GetMyTemplate());
			if (AmmoTemplate != none)
			{
				AmmoTemplate.GetTotalDamageModifier(LoadedAmmo, kSourceUnit, XComGameState_BaseObject(kTarget), AmmoDamageValue);
				if (AmmoTemplate.bBypassShields)
				{
					bAmmoIgnoresShields = 1;  // TRUE
				}
			}
			else
			{
				LoadedAmmo.GetBaseWeaponDamageValue(XComGameState_BaseObject(kTarget), AmmoDamageValue);
				EnvironmentDamage += LoadedAmmo.GetItemEnvironmentDamage();
			}
			if (AmmoDamageValue.Damage > 0) bHadAnyDamage = true;
			bWasImmune = bWasImmune && ModifyDamageValue(AmmoDamageValue, kTarget, AppliedDamageTypes);
		}
		if (bAllowWeaponUpgrade)
		{
			WeaponUpgradeTemplates = kSourceItem.GetMyWeaponUpgradeTemplates();
			foreach WeaponUpgradeTemplates(WeaponUpgradeTemplate)
			{
				if (WeaponUpgradeTemplate.BonusDamage.Tag == DamageTag)
				{
					UpgradeTemplateBonusDamage = WeaponUpgradeTemplate.BonusDamage;

					if (UpgradeTemplateBonusDamage.Damage > 0) bHadAnyDamage = true;
					bWasImmune = bWasImmune && ModifyDamageValue(UpgradeTemplateBonusDamage, kTarget, AppliedDamageTypes);

					UpgradeDamageValue.Damage += UpgradeTemplateBonusDamage.Damage;
					UpgradeDamageValue.Spread += UpgradeTemplateBonusDamage.Spread;
					UpgradeDamageValue.Crit += UpgradeTemplateBonusDamage.Crit;
					UpgradeDamageValue.Pierce += UpgradeTemplateBonusDamage.Pierce;
					UpgradeDamageValue.Rupture += UpgradeTemplateBonusDamage.Rupture;
					UpgradeDamageValue.Shred += UpgradeTemplateBonusDamage.Shred;
					//  ignores PlusOne as there is no good way to add them up
				}
			}
		}
	}

	// non targeted objects take the environmental damage amount
	if( kDestructibleActorTarget != None && !kDestructibleActorTarget.IsTargetable() )
	{
		return EnvironmentDamage;
	}

	BonusEffectDamageValue = GetBonusEffectDamageValue(kAbility, kSourceUnit, kSourceItem, ApplyEffectParameters.TargetStateObjectRef);
	if (BonusEffectDamageValue.Damage > 0 || BonusEffectDamageValue.Crit > 0 || BonusEffectDamageValue.Pierce > 0 || BonusEffectDamageValue.PlusOne > 0 ||
		BonusEffectDamageValue.Rupture > 0 || BonusEffectDamageValue.Shred > 0 || BonusEffectDamageValue.Spread > 0)
	{
		bWasImmune = bWasImmune && ModifyDamageValue(BonusEffectDamageValue, kTarget, AppliedDamageTypes);
		bHadAnyDamage = true;
	}

	WeaponDamage = BaseDamageValue.Damage + ExtraDamageValue.Damage + BonusEffectDamageValue.Damage + AmmoDamageValue.Damage + UpgradeDamageValue.Damage;
	DamageSpread = BaseDamageValue.Spread + ExtraDamageValue.Spread + BonusEffectDamageValue.Spread + AmmoDamageValue.Spread + UpgradeDamageValue.Spread;
	CritDamage = BaseDamageValue.Crit + ExtraDamageValue.Crit + BonusEffectDamageValue.Crit + AmmoDamageValue.Crit + UpgradeDamageValue.Crit;
	ArmorPiercing = BaseDamageValue.Pierce + ExtraDamageValue.Pierce + BonusEffectDamageValue.Pierce + AmmoDamageValue.Pierce + UpgradeDamageValue.Pierce;
	NewRupture = BaseDamageValue.Rupture + ExtraDamageValue.Rupture + BonusEffectDamageValue.Rupture + AmmoDamageValue.Rupture + UpgradeDamageValue.Rupture;
	NewShred = BaseDamageValue.Shred + ExtraDamageValue.Shred + BonusEffectDamageValue.Shred + AmmoDamageValue.Shred + UpgradeDamageValue.Shred;
	RuptureCap = WeaponDamage;

    `LOG("JSRC: base damage value" @ BaseDamagevalue.Damage);
    `LOG("JSRC: weapon damage" @ BaseDamagevalue.Damage);

	`log(`ShowVar(bIgnoreBaseDamage) @ `ShowVar(DamageTag), true, 'XCom_HitRolls');
	`log("Weapon damage:" @ WeaponDamage @ "Potential spread:" @ DamageSpread, true, 'XCom_HitRolls');

	if (DamageSpread > 0)
	{
		WeaponDamage += DamageSpread;                          //  set to max damage based on spread
		WeaponDamage -= `SYNC_RAND(DamageSpread * 2 + 1);      //  multiply spread by 2 to get full range off base damage, add 1 as rand returns 0:x-1, not 0:x
	}
	`log("Damage with spread:" @ WeaponDamage, true, 'XCom_HitRolls');
	if (PlusOneDamage(BaseDamageValue.PlusOne))
	{
		WeaponDamage++;
		`log("Rolled for PlusOne off BaseDamage, succeeded. Damage:" @ WeaponDamage, true, 'XCom_HitRolls');
	}
	if (PlusOneDamage(ExtraDamageValue.PlusOne))
	{
		WeaponDamage++;
		`log("Rolled for PlusOne off ExtraDamage, succeeded. Damage:" @ WeaponDamage, true, 'XCom_HitRolls');
	}
	if (PlusOneDamage(BonusEffectDamageValue.PlusOne))
	{
		WeaponDamage++;
		`log("Rolled for PlusOne off BonusEffectDamage, succeeded. Damage:" @ WeaponDamage, true, 'XCom_HitRolls');
	}
	if (PlusOneDamage(AmmoDamageValue.PlusOne))
	{
		WeaponDamage++;
		`log("Rolled for PlusOne off AmmoDamage, succeeded. Damage:" @ WeaponDamage, true, 'XCom_HitRolls');
	}

	if (ApplyEffectParameters.AbilityResultContext.HitResult == eHit_Crit)
	{
		WeaponDamage += CritDamage;
		`log("CRIT! Adjusted damage:" @ WeaponDamage, true, 'XCom_HitRolls');
	}
	else if (ApplyEffectParameters.AbilityResultContext.HitResult == eHit_Graze)
	{
		WeaponDamage *= GRAZE_DMG_MULT;
		`log("GRAZE! Adjusted damage:" @ WeaponDamage, true, 'XCom_HitRolls');
	}

	RuptureAmount = min(kTarget.GetRupturedValue() + NewRupture, RuptureCap);
	if (RuptureAmount != 0)
	{
		WeaponDamage += RuptureAmount;
		`log("Target is ruptured, increases damage by" @ RuptureAmount $", new damage:" @ WeaponDamage, true, 'XCom_HitRolls');
	}

	if( kSourceUnit != none)
	{
		//  allow target effects that modify only the base damage
		TargetUnit = XComGameState_Unit(kTarget);
		if (TargetUnit != none)
		{
			foreach TargetUnit.AffectedByEffects(EffectRef)
			{
				EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
				EffectTemplate = EffectState.GetX2Effect();
				EffectDmg = EffectTemplate.GetBaseDefendingDamageModifier(EffectState, kSourceUnit, kTarget, kAbility, ApplyEffectParameters, WeaponDamage, self, NewGameState);
				if (EffectDmg != 0)
				{
					TargetBaseDmgMod += EffectDmg;
					`log("Defender effect" @ EffectTemplate.EffectName @ "adjusting base damage by" @ EffectDmg, true, 'XCom_HitRolls');

					if (EffectTemplate.bDisplayInSpecialDamageMessageUI)
					{
						ModifierInfo.Value = EffectDmg;
						ModifierInfo.SourceEffectRef = EffectState.ApplyEffectParameters.EffectRef;
						ModifierInfo.SourceID = EffectRef.ObjectID;
						SpecialDamageMessages.AddItem(ModifierInfo);
					}
				}
			}
			if (TargetBaseDmgMod != 0)
			{
				WeaponDamage += TargetBaseDmgMod;
				`log("Total base damage after defender effect mods:" @ WeaponDamage, true, 'XCom_HitRolls');
			}			
		}

		//  Allow attacker effects to modify damage output before applying final bonuses and reductions
		foreach kSourceUnit.AffectedByEffects(EffectRef)
		{
			ModifierInfo.Value = 0;

			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
			EffectTemplate = EffectState.GetX2Effect();
			EffectDmg = EffectTemplate.GetAttackingDamageModifier(EffectState, kSourceUnit, kTarget, kAbility, ApplyEffectParameters, WeaponDamage, NewGameState);
			if (EffectDmg != 0)
			{
				WeaponDamage += EffectDmg;
				`log("Attacker effect" @ EffectTemplate.EffectName @ "adjusting damage by" @ EffectDmg $ ", new damage:" @ WeaponDamage, true, 'XCom_HitRolls');				

				ModifierInfo.Value += EffectDmg;
			}
			EffectDmg = EffectTemplate.GetExtraArmorPiercing(EffectState, kSourceUnit, kTarget, kAbility, ApplyEffectParameters);
			if (EffectDmg != 0)
			{
				ArmorPiercing += EffectDmg;
				`log("Attacker effect" @ EffectTemplate.EffectName @ "adjusting armor piercing by" @ EffectDmg $ ", new pierce:" @ ArmorPiercing, true, 'XCom_HitRolls');				

				ModifierInfo.Value += EffectDmg;
			}
			EffectDmg = EffectTemplate.GetExtraShredValue(EffectState, kSourceUnit, kTarget, kAbility, ApplyEffectParameters);
			if (EffectDmg != 0)
			{
				NewShred += EffectDmg;
				`log("Attacker effect" @ EffectTemplate.EffectName @ "adjust new shred value by" @ EffectDmg $ ", new shred:" @ NewShred, true, 'XCom_HitRolls');

				ModifierInfo.Value += EffectDmg;
			}

			if( ModifierInfo.Value != 0 && EffectTemplate.bDisplayInSpecialDamageMessageUI )
			{
				ModifierInfo.SourceEffectRef = EffectState.ApplyEffectParameters.EffectRef;
				ModifierInfo.SourceID = EffectRef.ObjectID;
				SpecialDamageMessages.AddItem(ModifierInfo);
			}
		}

		// run through the effects again for any conditional shred.  A second loop as it is possibly dependent on shred outcome of the unconditional first loop.
		UnconditionalShred = NewShred;
		foreach kSourceUnit.AffectedByEffects(EffectRef)
		{
			ModifierInfo.Value = 0;
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
			EffectTemplate = EffectState.GetX2Effect();

			EffectDmg = EffectTemplate.GetConditionalExtraShredValue(UnconditionalShred, EffectState, kSourceUnit, kTarget, kAbility, ApplyEffectParameters);
			if (EffectDmg != 0)
			{
				NewShred += EffectDmg;
				`log("Attacker effect" @ EffectTemplate.EffectName @ "adjust new shred value by" @ EffectDmg $ ", new shred:" @ NewShred, true, 'XCom_HitRolls');

				ModifierInfo.Value += EffectDmg;
			}

			if( ModifierInfo.Value != 0 && EffectTemplate.bDisplayInSpecialDamageMessageUI )
			{
				ModifierInfo.SourceEffectRef = EffectState.ApplyEffectParameters.EffectRef;
				ModifierInfo.SourceID = EffectRef.ObjectID;
				SpecialDamageMessages.AddItem(ModifierInfo);
			}
		}

		//  If this is a unit, apply any effects that modify damage
		TargetUnit = XComGameState_Unit(kTarget);
		if (TargetUnit != none)
		{
			foreach TargetUnit.AffectedByEffects(EffectRef)
			{
				EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
				EffectTemplate = EffectState.GetX2Effect();
				EffectDmg = EffectTemplate.GetDefendingDamageModifier(EffectState, kSourceUnit, kTarget, kAbility, ApplyEffectParameters, WeaponDamage, self, NewGameState);
				if (EffectDmg != 0)
				{
					WeaponDamage += EffectDmg;
					`log("Defender effect" @ EffectTemplate.EffectName @ "adjusting damage by" @ EffectDmg $ ", new damage:" @ WeaponDamage, true, 'XCom_HitRolls');				

					if( EffectTemplate.bDisplayInSpecialDamageMessageUI )
					{
						ModifierInfo.Value = EffectDmg;
						ModifierInfo.SourceEffectRef = EffectState.ApplyEffectParameters.EffectRef;
						ModifierInfo.SourceID = EffectRef.ObjectID;
						SpecialDamageMessages.AddItem(ModifierInfo);
					}
				}
			}
		}

		if (kTarget != none && !bIgnoreArmor)
		{
			ArmorMitigation = kTarget.GetArmorMitigation(ApplyEffectParameters.AbilityResultContext.ArmorMitigation);
			if (ArmorMitigation != 0)
			{				
				OriginalMitigation = ArmorMitigation;
				ArmorPiercing += kSourceUnit.GetCurrentStat(eStat_ArmorPiercing);				
				`log("Armor mitigation! Target armor mitigation value:" @ ArmorMitigation @ "Attacker armor piercing value:" @ ArmorPiercing, true, 'XCom_HitRolls');
				ArmorMitigation -= ArmorPiercing;				
				if (ArmorMitigation < 0)
					ArmorMitigation = 0;
				if (ArmorMitigation >= WeaponDamage)
					ArmorMitigation = WeaponDamage - 1;
				if (ArmorMitigation < 0)    //  WeaponDamage could have been 0
					ArmorMitigation = 0;    
				`log("  Final mitigation value:" @ ArmorMitigation, true, 'XCom_HitRolls');
			}
		}
	}
	//Shred can only shred as much as the maximum armor mitigation
	NewShred = Min(NewShred, OriginalMitigation);
	
	if (`SecondWaveEnabled('ExplosiveFalloff'))
	{
		ApplyFalloff( WeaponDamage, kTarget, kSourceItem, kAbility, NewGameState );
	}

	TotalDamage = WeaponDamage - ArmorMitigation;

	if ((WeaponDamage > 0 && TotalDamage < 0) || (WeaponDamage < 0 && TotalDamage > 0))
	{
		// Do not allow the damage reduction to invert the damage amount (i.e. heal instead of hurt, or vice-versa).
		TotalDamage = 0;
	}
	`log("Total Damage:" @ TotalDamage, true, 'XCom_HitRolls');
	`log("Shred from this attack:" @ NewShred, NewShred > 0, 'XCom_HitRolls');

	// Set the effect's damage
	bFullyImmune = (bWasImmune && bHadAnyDamage) ? 1 : 0;
	`log("FULLY IMMUNE", bFullyImmune == 1, 'XCom_HitRolls');

	return TotalDamage;
}