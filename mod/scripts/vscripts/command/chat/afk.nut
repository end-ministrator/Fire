global function ServerChatCommand_Afk_Init
global function Fire_SetAntiAFKEnabled
global function Fire_IsAntiAFKEnabled

int AFK_WARN_TIME = 70

void function ServerChatCommand_Afk_Init()
{
    RegisterSignal( "Fire_AntiAFK_Stop" )
    AddCallback_OnPlayerRespawned( OnPlayerRespawned )
    AddChatCommandCallback( "/afk", ServerChatCommand_AntiAFK )
}

void function OnPlayerRespawned( entity player )
{
    if(Fire_IsPlayerAdmin(player))
        return
    if( Fire_IsAntiAFKEnabled() )
        thread AntiAFKMonitor( player )
}

void function AntiAFKMonitor( entity player )
{
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "OnDeath" )
    player.EndSignal( "Fire_AntiAFK_Stop" )

    vector lastOrigin = player.GetOrigin()
    int afkTime = 0
    bool warned = false
    
    while( true )
    {
        wait 1.0
        
        if( !Fire_IsAntiAFKEnabled() )
            break
            
        vector currentOrigin = player.GetOrigin()
        
        if( Distance( currentOrigin, lastOrigin ) < 10.0 )
        {
            afkTime++
            
            if( afkTime >= AFK_WARN_TIME / 2 )
            {
                Fire_ChatServerPrivateMessage( player, "警告：检测到挂机行为，请移动以避免被踢出" )
                warned = true
            }
            
            if ( afkTime >= AFK_WARN_TIME )
            {
                thread Fire_KickPlayer( player, "挂机" )
                break
            }
        }
        else
        {
            afkTime = 0
            lastOrigin = currentOrigin
        }
    }
}

void function ServerChatCommand_AntiAFK( entity player, array<string> args )
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }
    
    if ( args.len() != 1 )
        return
    
    string arg0 = args[0].tolower()
    bool newStatus = Fire_IsAffirmative( arg0 )

    if( newStatus == Fire_IsAntiAFKEnabled() )
        return
    
    Fire_SetAntiAFKEnabled( newStatus )
    
    string statusMessage = newStatus ? "开启" : "关闭"
    Fire_ChatServerBroadcast( "已" + statusMessage + "反挂机" )
}

void function Fire_SetAntiAFKEnabled( bool enabled )
{
    if( Fire_IsAntiAFKEnabled() == enabled )
        return
    
    SetConVarBool( "Fire_AntiAFKEnabled", enabled )
    
    if( enabled )
    {
        foreach( player in GetPlayerArray() )
        {
            if( !IsAlive( player ) )
                continue
            if( Fire_IsPlayerAdmin(player) )
                continue
            thread AntiAFKMonitor( player )
        }
    }
    else
    {
        foreach( player in GetPlayerArray() )
        {
            player.Signal( "Fire_AntiAFK_Stop" )
        }
    }
}

bool function Fire_IsAntiAFKEnabled()
{
    return GetConVarBool("Fire_AntiAFKEnabled")
}