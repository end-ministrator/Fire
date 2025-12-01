global function ServerChatCommand_Chat_Init
global function Fire_SetChatEnabled
global function Fire_IsChatEnabled

void function ServerChatCommand_Chat_Init()
{
    AddChatCommandCallback( "/chat", OnChatCommand_Chat )
}

void function OnChatCommand_Chat( entity player, array<string> args )
{
    if ( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }

    if ( args.len() != 1 )
    {
        Fire_ChatServerPrivateMessage( player, "用法: /chat < on/off >" )
        Fire_ChatServerPrivateMessage( player, "当前状态: " + ( Fire_IsChatEnabled() ? "启用" : "禁用" ) )
        return
    }

    string commandArg = args[0].tolower()
    bool isChatCurrentlyEnabled = Fire_IsChatEnabled()
    bool isEnableCommand = Fire_IsAffirmative( commandArg )

    if ( isEnableCommand && !isChatCurrentlyEnabled )
    {
        Fire_SetChatEnabled( true )
        Fire_ChatServerBroadcast( "已启用聊天" )
    }
    else if ( !isEnableCommand && isChatCurrentlyEnabled )
    {
        Fire_SetChatEnabled( false )
        Fire_ChatServerBroadcast( "已禁用聊天" )
    }
    else{
        string currentState = isChatCurrentlyEnabled ? "启用" : "禁用"
        Fire_ChatServerPrivateMessage( player, "聊天已经 " + currentState + "，无需更改" )
    }
}

void function Fire_SetChatEnabled( bool enabled )
{
    SetConVarBool( "Fire_ChatEnabled", enabled )
}

bool function Fire_IsChatEnabled()
{
    return GetConVarBool( "Fire_ChatEnabled" )
}