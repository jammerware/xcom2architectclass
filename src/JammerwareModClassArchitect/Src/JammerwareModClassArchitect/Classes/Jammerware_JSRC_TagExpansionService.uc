class Jammerware_JSRC_TagExpansionService extends object;

public function string ExpandAbilityTag(string Input)
{
    // this is ugly, but it's how they do it ¯\_(ツ)_/¯
    switch(Input)
    {
        case "FieldReloadAmount_Conv": return string(class'X2Item_SpireGun'.default.SPIREGUN_CONVENTIONAL_FIELDRELOADAMMO);
        case "FieldReloadAmount_Mag": return string(class'X2Item_SpireGun'.default.SPIREGUN_MAGNETIC_FIELDRELOADAMMO);
        case "FieldReloadAmount_Beam": return string(class'X2Item_SpireGun'.default.SPIREGUN_BEAM_FIELDRELOADAMMO);
        case "HeadstoneCooldown": return string(class'X2Ability_RunnerAbilitySet'.default.HEADSTONE_COOLDOWN);
        case "QuicksilverCharges_Conv": return string(class'X2Item_SpireGun'.default.SPIREGUN_CONVENTIONAL_QUICKSILVERCHARGESBONUS);
        case "QuicksilverCharges_Mag": return string(class'X2Item_SpireGun'.default.SPIREGUN_MAGNETIC_QUICKSILVERCHARGESBONUS);
        case "QuicksilverCharges_Beam": return string(class'X2Item_SpireGun'.default.SPIREGUN_BEAM_QUICKSILVERCHARGESBONUS);
        case "QuicksilverCooldownWithSoul": return string(class'X2Ability_SpireAbilitySet'.default.COOLDOWN_SOUL_QUICKSILVER);
        case "KineticBlastCooldownWithSoul": return string(class'X2Ability_KineticBlast'.default.SOUL_COOLDOWN_KINETIC_BLAST);
        case "ReclaimCooldown": return string(class'X2Ability_RunnerAbilitySet'.default.RECLAIM_COOLDOWN);
        case "RelayedShotCooldown": return string(class'X2Ability_RelayedShot'.default.COOLDOWN_RELAYED_SHOT);
        case "ShelterShieldAmount_Conv": return string(class'X2Item_SpireGun'.default.SPIREGUN_CONVENTIONAL_SHELTERSHIELDBONUS);
        case "ShelterShieldAmount_Mag": return string(class'X2Item_SpireGun'.default.SPIREGUN_MAGNETIC_SHELTERSHIELDBONUS);
        case "ShelterShieldAmount_Beam": return string(class'X2Item_SpireGun'.default.SPIREGUN_BEAM_SHELTERSHIELDBONUS);
        case "ShelterShieldDuration": return string(class'X2Ability_SpireAbilitySet'.default.SHELTER_DURATION);
        case "SpawnSpireCooldown": return string(class'X2Ability_SpawnSpire'.default.SPAWNSPIRE_COOLDOWN);
        case "TargetingArrayAccuracy_Conv": return string(class'X2Item_SpireGun'.default.SPIREGUN_CONVENTIONAL_TARGETINGARRAYACCURACYBONUS);
        case "TargetingArrayAccuracy_Mag": return string(class'X2Item_SpireGun'.default.SPIREGUN_MAGNETIC_TARGETINGARRAYACCURACYBONUS);
        case "TargetingArrayAccuracy_Beam": return string(class'X2Item_SpireGun'.default.SPIREGUN_BEAM_TARGETINGARRAYACCURACYBONUS);
        case "TransmatLinkCooldown": return string(class'X2Ability_TransmatLink'.default.COOLDOWN_TRANSMAT_LINK);
    }

    return "";
}