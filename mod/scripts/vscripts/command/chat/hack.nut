global function ServerChatCommand_Hack_Init

const int PLAYER_TEAM = 2
const int HACK_TEAM = 3

entity HACK_PLAYER = null

void function ServerChatCommand_Hack_Init()
{
    AddCallback_OnClientConnected( OnClientConnected )
    AddCallback_OnPlayerRespawned( OnPlayerRespawned )
    AddCallback_OnClientDisconnected( OnPlayerDisconnected )
    AddChatCommandCallback( "/hack", ServerChatCommand_Hack )
}

void function OnClientConnected( entity player )
{
    if( HACK_PLAYER == null )
        return
    int team = ( player == HACK_PLAYER ) ? HACK_TEAM : PLAYER_TEAM
    SetTeam( player, team )
}

void function OnPlayerRespawned( entity player )
{
    if( HACK_PLAYER == null )
        return

    if(player == HACK_PLAYER)
    {
        thread EnemyBossBounty( player )
    }else
    {
        thread GiveAntiCheatWeapon( player )
        EndlessStimBegin( player, 0.8 )
    }
}

void function OnPlayerDisconnected( entity player )
{
    if ( player != HACK_PLAYER )
        return
        
    HACK_PLAYER = null
    thread StopHackMode()
}

void function ServerChatCommand_Hack( entity player, array<string> args )
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }

    if( args.len() != 1 )
    {
        Fire_ChatServerPrivateMessage( player, "用法: /hack < 玩家名/end >" )
        return
    }

    if( args[0] == "stop" || args[0] == "end" || args[0] == "cancel" || args[0] == "off" || args[0] == "close" || args[0] == "exit" )
    {
        thread StopHackMode()
        return
    }

    if( HACK_PLAYER != null )
        return

    entity target = GetPlayerByNamePrefix( args[0] )
    if( !IsValid( target ) )
    {
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + args[0] )
        return
    }

    thread StartHackMode( target )
}

void function StartHackMode( entity target )
{
    HACK_PLAYER = target
    SetTeam( target, HACK_TEAM )

    thread EnemyBossBounty( target )

    foreach( p in GetPlayerArray() )
    {
        if( !IsValid( p ) || p == HACK_PLAYER )
            continue
            
        SetTeam( p, PLAYER_TEAM )
        if( IsAlive( p ) && !target.IsTitan() )
        {
            EndlessStimBegin( p, 0.8 )
            thread GiveAntiCheatWeapon( p )
        }
    }

    BroadcastHackInfo()
    
    wait 2.0
    thread CoopGeneratorUnderattackAlarm()

    SendHackAnnouncements()
    
    wait 10.0
    SendKillAnnouncements()
}

void function StopHackMode()
{
    if( HACK_PLAYER == null )
        return
        
    HACK_PLAYER = null
    Fire_Balance( 2 )
    wait 0.2
    foreach( p in GetPlayerArray() )
    {
        if( !IsValid( p ) || !IsAlive( p ) )
            continue
        if( p.IsTitan() )
            continue
            
        EndlessStimEnd( p )
        p.SetMaxHealth( 100 )
        p.SetHealth( p.GetMaxHealth() )
        Loadouts_TryGivePilotLoadout( p )
    }
}

void function BroadcastHackInfo()
{
    string hackName = HACK_PLAYER.GetPlayerName()
    string hackUID = HACK_PLAYER.GetUID()

    Fire_ChatServerBroadcast( "|=======================[外挂]=======================|" )
    Fire_ChatServerBroadcast( "| Name: " + hackName + " | UID: " + hackUID )
    Fire_ChatServerBroadcast( "|==================================================|" )
}

void function SendHackAnnouncements()
{
    string hackName = HACK_PLAYER.GetPlayerName()
    
    SendAnnouncementMessageToAllAlivePlayers( "外掛: " + hackName, "", <255, 0, 0>, 1, 1 )
    SendLargeMessageToAllAlivePlayers( "外掛: " + hackName, " ", 10, "rui/callsigns/callsign_30_col" )
    SendPopUpMessageToAllAlivePlayers( "外掛: " + hackName )
    SendInfoMessageToAllAlivePlayers( "外掛: " + hackName )
}

void function SendKillAnnouncements()
{
    string hackName = HACK_PLAYER.GetPlayerName()
    
    SendAnnouncementMessageToAllAlivePlayers( "擊殺: " + hackName, "", <255, 0, 0>, 1, 1 )
    SendLargeMessageToAllAlivePlayers( "擊殺: " + hackName, " ", 10, "rui/callsigns/callsign_30_col" )
    SendPopUpMessageToAllAlivePlayers( "擊殺: " + hackName )
    SendInfoMessageToAllAlivePlayers( "擊殺: " + hackName )
}

void function CoopGeneratorUnderattackAlarm()
{
    while( HACK_PLAYER != null )
    {
        EmitSoundToAllPlayers( "coop_generator_underattack_alarm" )
        wait 3.0
    }
}

void function EnemyBossBounty(entity player)
{
    player.EndSignal( "OnDestroy" )
    while( HACK_PLAYER != null || !IsValid(player) )
	{
		if(!Hightlight_HasEnemyHighlight( player, "enemy_boss_bounty" ))
			Highlight_SetEnemyHighlight( player, "enemy_boss_bounty" )
		WaitFrame()
	}
}

void function GiveAntiCheatWeapon(entity player)
{
    player.SetModel($"models/humans/heroes/mlt_hero_jack.mdl")
    player.SetMaxHealth(90000)
    player.SetHealth(player.GetMaxHealth())

    TakeWeaponsForArray(player, player.GetMainWeapons())
    player.TakeOffhandWeapon(OFFHAND_MELEE)
    //player.TakeOffhandWeapon(OFFHAND_SPECIAL)
    //player.TakeOffhandWeapon(OFFHAND_ANTIRODEO)
    player.TakeOffhandWeapon(OFFHAND_ORDNANCE)

    player.GiveWeapon("mp_titanweapon_sticky_40mm", ["gunship_gunner", "splasher_rounds", "fast_reloaD"])
    player.GiveWeapon("mp_titanweapon_predator_cannon", ["Smart_Core"])
    player.GiveWeapon("mp_titanweapon_xo16_vanguard", ["arc_rounds_with_battle_rifle", "rapid_reload", "fd_vanguard_utility_2"])

    player.GiveOffhandWeapon("melee_titan_punch_fighter", OFFHAND_MELEE)
    //player.GiveOffhandWeapon("mp_ability_heal", OFFHAND_SPECIAL)
    //player.GiveOffhandWeapon("mp_ability_holopilot_nova", OFFHAND_ANTIRODEO)
    player.GiveOffhandWeapon("mp_titanability_electric_smoke", OFFHAND_ORDNANCE)
}