global function ServerChatCommand_Danmaku_Init
global function SendDanmaku


void function ServerChatCommand_Danmaku_Init()
{
    AddChatCommandCallback( "/danmaku", ServerChatCommand_Danmaku )
}

void function ServerChatCommand_Danmaku( entity player, array<string> args )
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    string msg = ""
    for(int i; i < args.len(); i++)
    {
        msg += args[i] + " "
    }

    thread SendDanmaku( msg )
}

void function SendDanmaku(string msg)
{
    foreach(player in GetPlayerArray())
    {
        if(!IsValid(player) || !IsAlive(player))
            continue 
        thread SendDanmakuToPlayer(player, msg)
    }
}

void function SendDanmakuToPlayer(entity player, string msg)
{
    for(int i = 0; i < 150; i++)
    {
        if(!IsValid(player) || !IsAlive(player))
            continue
        SendHudMessage( player, msg, 1-(float(i+50)/200), 0.25, 255, 104, 154, 1, 0, 0.2, 0 )
        WaitFrame()
    }
}