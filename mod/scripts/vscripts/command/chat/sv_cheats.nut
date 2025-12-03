global function ServerChatCommand_Cheats_Init
global function Fire_SetCheatsEnabled
global function Fire_IsCheatsEnabled

void function ServerChatCommand_Cheats_Init()
{
    AddChatCommandCallback( "/cheats", ServerChatCommand_Cheats )
}

void function ServerChatCommand_Cheats(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage(player, "用法: /cheats < on/off >")
        return
    }

    string args0 = args[0]
    bool cheats = Fire_IsCheatsEnabled()

    if( Fire_IsAffirmative( args0 ) && !cheats )
    {
        Fire_SetCheatsEnabled(true)
    }
    else if( Fire_IsNegative( args0 ) && cheats)
    {
        Fire_SetCheatsEnabled(false)
    }
    string message = Fire_IsCheatsEnabled() ? "开启" : "关闭"
    Fire_ChatServerPrivateMessage( player, "已" + message + "作弊" )
}

void function Fire_SetCheatsEnabled(bool enabled)
{
    SetConVarBool( "sv_cheats", enabled )
}

bool function Fire_IsCheatsEnabled()
{
    return GetConVarBool( "sv_cheats" )
}