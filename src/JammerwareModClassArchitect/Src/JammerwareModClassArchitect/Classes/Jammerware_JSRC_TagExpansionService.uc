class Jammerware_JSRC_TagExpansionService extends object;

public function string ExpandAbilityTag(string Input)
{
    // this is ugly, but it's how they do it ¯\_(ツ)_/¯
    switch(Input)
    {
        case "FieldReloadAmount_Conv": return string(class'X2Item_SpireGun'.default.SPIREGUN_CONVENTIONAL_FIELDRELOADAMMO);
        case "FieldReloadAmount_Mag": return string(class'X2Item_SpireGun'.default.SPIREGUN_MAGNETIC_FIELDRELOADAMMO);
        case "FieldReloadAmount_Beam": return string(class'X2Item_SpireGun'.default.SPIREGUN_BEAM_FIELDRELOADAMMO);
        case "HeadstoneCooldown": return string(class'JsrcAbility_Headstone'.default.HEADSTONE_COOLDOWN);
        case "QuicksilverCharges_Conv": return string(class'X2Item_SpireGun'.default.SPIREGUN_CONVENTIONAL_QUICKSILVERCHARGESBONUS);
        case "QuicksilverCharges_Mag": return string(class'X2Item_SpireGun'.default.SPIREGUN_MAGNETIC_QUICKSILVERCHARGESBONUS);
        case "QuicksilverCharges_Beam": return string(class'X2Item_SpireGun'.default.SPIREGUN_BEAM_QUICKSILVERCHARGESBONUS);
        case "QuicksilverCooldownWithSoul": return string(class'JsrcAbility_Quicksilver'.default.COOLDOWN_SOUL_QUICKSILVER);
        case "KineticBlastCooldownWithSoul": return string(class'JsrcAbility_KineticRigging'.default.COOLDOWN_SOUL_KINETIC_BLAST);
        case "ReclaimCooldown": return string(class'JsrcAbility_Reclaim'.default.RECLAIM_COOLDOWN);
        case "RelayedShotCooldown": return string(class'JsrcAbility_RelayedShot'.default.COOLDOWN_RELAYED_SHOT);
        case "ShelterShieldAmount_Conv": return string(class'X2Item_SpireGun'.default.SPIREGUN_CONVENTIONAL_SHELTERSHIELDBONUS);
        case "ShelterShieldAmount_Mag": return string(class'X2Item_SpireGun'.default.SPIREGUN_MAGNETIC_SHELTERSHIELDBONUS);
        case "ShelterShieldAmount_Beam": return string(class'X2Item_SpireGun'.default.SPIREGUN_BEAM_SHELTERSHIELDBONUS);
        case "ShelterShieldDuration": return string(class'JsrcAbility_Shelter'.default.SHELTER_DURATION);
        case "SpawnSpireCooldown": return string(class'JsrcAbility_SpawnSpire'.default.COOLDOWN_SPAWN_SPIRE);
        case "SpawnSpireRange": return string(class'JsrcAbility_SpawnSpire'.default.TILERANGE_SPAWN_SPIRE);
        case "TargetingArrayAccuracy_Conv": return string(class'X2Item_SpireGun'.default.SPIREGUN_CONVENTIONAL_TARGETINGARRAYACCURACYBONUS);
        case "TargetingArrayAccuracy_Mag": return string(class'X2Item_SpireGun'.default.SPIREGUN_MAGNETIC_TARGETINGARRAYACCURACYBONUS);
        case "TargetingArrayAccuracy_Beam": return string(class'X2Item_SpireGun'.default.SPIREGUN_BEAM_TARGETINGARRAYACCURACYBONUS);
        case "TransmatLinkCooldown": return string(class'JsrcAbility_TransmatLink'.default.COOLDOWN_TRANSMAT_LINK);
    }

    return "";
}