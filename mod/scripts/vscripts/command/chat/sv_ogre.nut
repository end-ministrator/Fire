untyped
global function ServerChatCommand_Ogre_Init
global function Fire_DropNukeTitan

void function ServerChatCommand_Ogre_Init()
{
    AddChatCommandCallback( "/ogre", ServerChatCommand_Ogre )
}

void function ServerChatCommand_Ogre(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player))
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if(args.len() != 1)
    {
        Fire_ChatServerPrivateMessage(player, "用法: /ogre < 玩家名称/all >")
        return
    }

    string args0 = args[0]
    array<entity> targets

    switch(args0.tolower())
    {
        case "all":
            targets = GetPlayerArray()
            break
        default:
            targets = GetPlayersByNamePrefix(args0)
            break
    }

    if(targets.len() == 0)
    {
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + args[0])
        return
    }

    foreach(target in targets)
    {
        if( !IsValid(target) || !IsAlive(target))
        {
            Fire_ChatServerPrivateMessage(player, "玩家 " + target.GetPlayerName() + " 无效或死亡")
            continue
        }
        thread Fire_DropNukeTitan( target.GetOrigin(), target )
    }
}

void function Fire_DropNukeTitan( vector origin, entity player )
{
    try{
        PlayImpactFXTable( origin, player, "exp_sonar_pulse" )

	    entity titan = CreateOgre( TEAM_UNASSIGNED, origin, < 0, RandomInt( 360 ), 0 > )
	    titan.EndSignal( "OnDestroy" )

	    SetTeam( titan, player.GetTeam() )
	    DispatchSpawn( titan )

	    titan.kv.script_hotdrop = "4"
    
	    thread PlayersTitanHotdrops( titan, origin, < 0, RandomInt( 360 ), 0 >, player, "at_hotdrop_drop_2knee_turbo" )
        Remote_CallFunction_Replay( player, "ServerCallback_ReplacementTitanSpawnpoint", origin.x, origin.y, origin.z, Time() + GetHotDropImpactTime( titan, "at_hotdrop_drop_2knee_turbo" ) )

	    DoomTitan( titan )
	    titan.SetBossPlayer( player )

	    entity soul = titan.GetTitanSoul()
	    soul.soul.nukeAttacker = player

	    NPC_SetNuclearPayload( titan )

	    titan.WaitSignal( "ClearDisableTitanfall" )
	    titan.ClearBossPlayer()

	    titan.s.OrbitalStrikeKillStreak <- true
	    thread TitanEjectPlayer( titan, true )
    }catch( ex ){
	}
}