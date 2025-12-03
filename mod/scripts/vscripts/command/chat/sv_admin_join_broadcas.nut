global function ServerChatCommand_Ajb_Init
global function Fire_SetAdminJoinBroadcastEnabled
global function Fire_IsAdminJoinBroadcastEnabled


void function ServerChatCommand_Ajb_Init()
{
    AddCallback_OnClientConnected(OnClientConnected)
    AddCallback_OnClientDisconnected(OnPlayerDisconnected)
    AddChatCommandCallback( "/ajb", ServerChatCommand_Ajb )
}

void function OnClientConnected(entity player)
{
    array<entity> admins = Fire_GetAdminArray()
    if( admins.len() > 1 && Fire_IsPlayerAdmin(player) )
    {
        string message = "在线管理员: "
        foreach(int i,admin in admins)
        {
            message += admin.GetPlayerName() + " "
        }
        Fire_ChatServerPrivateMessage( player, message )
    }
    if(Fire_IsAdminJoinBroadcastEnabled())
        thread ClientConnected(player)
}

void function ClientConnected(entity player)
{
    string ref = CallingCard_GetRef(PlayerCallingCard_GetActive(player))
    string playerName = player.GetPlayerName()
    if( Fire_IsPlayerAdmin(player) )
    {
        Fire_ChatServerBroadcast( "管理员 " + playerName + " 加入游戏" )
        wait 2.0
        SendLargeMessageToAllAlivePlayers( playerName, "管理員加入游戲", 5, "rui/callsigns/" + ref )
    }
}

void function OnPlayerDisconnected(entity player)
{
    if(Fire_IsAdminJoinBroadcastEnabled())
        thread OnClientDisconnected(player)
}

void function OnClientDisconnected(entity player)
{
    string playerName = player.GetPlayerName()
    if( Fire_IsPlayerAdmin(player) )
    {
        Fire_ChatServerBroadcast( "管理员 " + playerName + " 退出游戏" )
    }
}

void function ServerChatCommand_Ajb( entity player, array<string> args )
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage( player, "用法: /ajb < on/off >" )
        Fire_ChatServerPrivateMessage( player, "状态: " + (Fire_IsAdminJoinBroadcastEnabled() ? "启用" : "禁用") )
        return
    }

    string args0 = args[0].tolower()
    bool isAdminJoinBroadcastEnabled = Fire_IsAdminJoinBroadcastEnabled()

    if( Fire_IsAffirmative(args0) && !isAdminJoinBroadcastEnabled )
    {
        Fire_SetAdminJoinBroadcastEnabled(true)
        Fire_ChatServerBroadcast( "已启用管理员加入消息" )
    }
    else if( !Fire_IsAffirmative(args0) && isAdminJoinBroadcastEnabled )
    {
        Fire_SetAdminJoinBroadcastEnabled(false)
        Fire_ChatServerBroadcast( "已禁用管理员加入消息" )
    }
}

void function Fire_SetAdminJoinBroadcastEnabled(bool enabled)
{
    SetConVarBool( "Fire_AdminJoinBroadcastEnabled", enabled )
}

bool function Fire_IsAdminJoinBroadcastEnabled()
{
    return GetConVarBool("Fire_AdminJoinBroadcastEnabled")
}