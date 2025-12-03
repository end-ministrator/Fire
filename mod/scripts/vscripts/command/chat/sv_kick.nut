global function ServerChatCommand_Kick_Init
global function Fire_KickPlayer

bool debug = false

void function ServerChatCommand_Kick_Init()
{
    AddChatCommandCallback( "/kick", ServerChatCommand_Kick )
}

void function ServerChatCommand_Kick(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if(args.len() < 1 || args.len() > 2){
        Fire_ChatServerPrivateMessage( player, "用法: /kick < 玩家名称 > [ 原因 ]" )
        return
    }

    string args0 = args[0]
    entity target = GetPlayerByNamePrefix( args0 )

    if( target == null ){
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + args0 )
        return
    }
    if( !IsValid( target ) ){
        Fire_ChatServerPrivateMessage( player, "无效玩家: " + args0 )
        return
    }
    
    string reason = args.len() == 2 ? args[1] : ""

    Fire_KickPlayer( target, reason )
}

void function Fire_KickPlayer( entity player, string reason )
{
    string playerName = player.GetPlayerName()
    string playerUID = GetPlayerUID(player)

    if(!debug)
        NSDisconnectPlayer( player, reason )

    Fire_ChatServerBroadcast( "|==================[KICK]==================|")
    Fire_ChatServerBroadcast( " 玩家: " + playerName + " (" + playerUID + ")" )
    if( reason != "" )
        Fire_ChatServerBroadcast( " 原因: " + reason )
    Fire_ChatServerBroadcast( "|========================================|" )
}