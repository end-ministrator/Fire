global function ServerChatCommand_Cb_Init
global function Fire_KillAllBoss
global function CreateAsh
global function CreateViper
global function CreateRichter
global function CreateSlone
global function CreateKane
global function CreateBlisk

array<entity> bosss = []

void function ServerChatCommand_Cb_Init()
{
    RegisterSignal( "AshEnteredPhaseShift" )
    RegisterSignal( "DoCore" )
    AddChatCommandCallback( "/cb",  ServerChatCommand_CreateBoss )
    AddChatCommandCallback( "/kab",  ServerChatCommand_KillAllBoss )
}

void function ServerChatCommand_CreateBoss(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if ( args.len() != 1 ){
        Fire_ChatServerPrivateMessage(player, "用法: /cb < ash/viper/richter/slone/kane/blisk/all >")
        return
    }

    string bossName = args[0].tolower()
    vector playerOrigin = player.GetOrigin()
    vector playerAngles = player.GetAngles()

    if(bossName == "ash"){
        thread CreateAsh(playerOrigin, playerAngles)
    }

    if(bossName == "viper"){
        thread CreateViper(playerOrigin, playerAngles)
    }

    if(bossName == "richter"){
        thread CreateRichter(playerOrigin, playerAngles)
    }

    if(bossName == "slone"){
        thread CreateSlone(playerOrigin, playerAngles)
    }

    if(bossName == "kane"){
        thread CreateKane(playerOrigin, playerAngles)
    }

    if(bossName == "blisk"){
        thread CreateBlisk(playerOrigin, playerAngles)
    }

    if(bossName == "all"){
        thread CreateAsh(playerOrigin, playerAngles)
        thread CreateViper(playerOrigin, playerAngles)
        thread CreateRichter(playerOrigin, playerAngles)
        thread CreateSlone(playerOrigin, playerAngles)
        thread CreateKane(playerOrigin, playerAngles)
    }
    Fire_ChatServerPrivateMessage(player, "创建成功")
}

void function ServerChatCommand_KillAllBoss(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    Fire_KillAllBoss()
}

void function Fire_KillAllBoss()
{
    foreach( boss in bosss )
    {
        if(IsValid(boss))
        {
            boss.Die()
        }
    }
    bosss = []
}

void function CreateAsh(vector origin, vector angles)
{
    entity ash = CreateNPCTitan("npc_titan_stryder_leadwall", 2, origin, < 0, angles.y, 0 >)
	SetSpawnOption_AISettings( ash, "npc_titan_stryder_leadwall_boss_fd" )
    DispatchSpawn( ash )

	entity mover = CreateScriptMover(ash.GetOrigin(), ash.GetAngles())

    ash.TakeWeaponNow( ash.GetActiveWeapon().GetWeaponClassName() )
    ash.GiveWeapon("mp_titanweapon_leadwall", ["ash"])
    ash.SetActiveWeaponByName( "mp_titanweapon_leadwall" )

    ash.SetMaxHealth( 90000 )
	ash.SetHealth(ash.GetMaxHealth())

    ash.SetInvulnerable()
    thread PlayAnim(ash,"lt_boomtown_boss_intro",mover)
    ash.WaitSignal("AshEnteredPhaseShift")
    PhaseShift( ash, 0, 1.0 )
    ash.ClearInvulnerable()

    bosss.append(ash)
}

void function CreateViper(vector origin, vector angles)
{
    entity viper = CreateNPCTitan("npc_titan_stryder", 2, origin, < 0, angles.y, 0 >)
	SetSpawnOption_AISettings( viper, "npc_titan_stryder_sniper_boss_fd" )
    DispatchSpawn( viper )

	entity mover = CreateScriptMover(viper.GetOrigin(), viper.GetAngles())

    viper.TakeWeaponNow( viper.GetActiveWeapon().GetWeaponClassName() )
	viper.GiveWeapon("mp_titanweapon_sniper", ["BossTitanViperAgro", "burn_mod_titan_sniper"])
	viper.SetActiveWeaponByName( "mp_titanweapon_sniper" )
	viper.TakeOffhandWeapon( OFFHAND_ANTIRODEO )
	viper.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_ANTIRODEO, ["viper"] )

    viper.SetMaxHealth( 90000 )
	viper.SetHealth(viper.GetMaxHealth())

    viper.SetInvulnerable()
    PlayAnim(viper,"lt_s2s_boss_intro",mover)
    viper.ClearInvulnerable()

    bosss.append(viper)
}

void function CreateRichter(vector origin, vector angles)
{
    entity richter = CreateNPCTitan("npc_titan_atlas_tracker", 2, origin, < 0, angles.y, 0 >)
	SetSpawnOption_AISettings( richter, "npc_titan_atlas_tracker_boss_fd" )
    DispatchSpawn( richter )

	entity mover = CreateScriptMover(richter.GetOrigin(), richter.GetAngles())

    richter.TakeWeaponNow( richter.GetActiveWeapon().GetWeaponClassName() )
	richter.GiveWeapon("mp_titanweapon_sticky_40mm", ["richter"])
	richter.SetActiveWeaponByName( "mp_titanweapon_sticky_40mm" )

    richter.SetMaxHealth( 90000 )
	richter.SetHealth(richter.GetMaxHealth())

    richter.SetInvulnerable()
    thread EmitSoundOnEntity( richter, "diag_sp_bossFight_BN676_01_01_imc_richter" )
    PlayAnim(richter,"mt_richter_taunt_mt",mover)
    richter.ClearInvulnerable()

    bosss.append(richter)
}

void function CreateSlone(vector origin, vector angles)
{
    entity slone = CreateNPCTitan("npc_titan_atlas_stickybomb", 2, origin, < 0, angles.y, 0 >)
	SetSpawnOption_AISettings( slone, "npc_titan_atlas_stickybomb_boss_fd" )
    DispatchSpawn( slone )

	entity mover = CreateScriptMover(slone.GetOrigin(), slone.GetAngles())

	slone.TakeWeaponNow( slone.GetActiveWeapon().GetWeaponClassName() )
	slone.GiveWeapon("mp_titanweapon_particle_accelerator", ["slone"])
	slone.SetActiveWeaponByName( "mp_titanweapon_particle_accelerator" )

    slone.SetMaxHealth( 90000 )
	slone.SetHealth(slone.GetMaxHealth())

    slone.SetInvulnerable()
    PlayAnim(slone,"mt_injectore_room_slone",mover)
    slone.ClearInvulnerable()

    bosss.append(slone)
}

void function CreateKane(vector origin, vector angles)
{
    entity kane = CreateNPCTitan("npc_titan_ogre_meteor", 2, origin, < 0, angles.y, 0 >)
	SetSpawnOption_AISettings( kane, "npc_titan_ogre_meteor_boss_fd" )
    DispatchSpawn( kane )

	entity mover = CreateScriptMover(kane.GetOrigin(), kane.GetAngles())

    kane.TakeWeaponNow( kane.GetActiveWeapon().GetWeaponClassName() )
	kane.GiveWeapon("mp_titanweapon_meteor", ["pas_scorch_weapon", "fd_wpn_upgrade_2", "kane"])
	kane.SetActiveWeaponByName( "mp_titanweapon_meteor" )
	kane.TakeOffhandWeapon( OFFHAND_ORDNANCE )
	kane.GiveOffhandWeapon("mp_titanweapon_flame_wall", OFFHAND_ORDNANCE, ["dev_mod_low_recharge", "burn_mod_titan_flame_wall"])

    kane.SetMaxHealth( 90000 )
	kane.SetHealth(kane.GetMaxHealth())

    kane.SetInvulnerable()
    thread EmitSoundOnEntity( kane, "diag_sp_kaneArena_SE163_03_01_imc_kane" )
    PlayAnim(kane,"ht_Kane_boss_intro_ht",mover)
    kane.ClearInvulnerable()

    bosss.append(kane)
}

void function CreateBlisk(vector origin, vector angles)
{
    entity blisk = CreateNPCTitan("npc_titan_ogre_minigun", 2, origin, < 0, angles.y, 0 >)
	SetSpawnOption_AISettings( blisk, "npc_titan_ogre_minigun_boss_fd" )
    DispatchSpawn( blisk )

	entity mover = CreateScriptMover(blisk.GetOrigin(), blisk.GetAngles())

    blisk.TakeWeaponNow( blisk.GetActiveWeapon().GetWeaponClassName() )
	blisk.GiveWeapon("mp_titanweapon_predator_cannon", ["blisk"])
	blisk.SetActiveWeaponByName( "mp_titanweapon_predator_cannon" )

    blisk.SetMaxHealth( 90000 )
	blisk.SetHealth(blisk.GetMaxHealth())

    blisk.SetInvulnerable()
    PlayAnim(blisk,"ht_injectore_room_blisk",mover)
    blisk.ClearInvulnerable()

    bosss.append(blisk)
}