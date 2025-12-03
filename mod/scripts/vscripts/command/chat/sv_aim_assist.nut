global function ServerChatCommand_Aa_Init
global function Fire_SetAimAssistEnabled
global function Fire_IsAimAssistEnabled

void function ServerChatCommand_Aa_Init()
{
    AddChatCommandCallback( "/aa",  ServerChatCommand_Aa )
    AddCallback_OnPlayerRespawned( OnPlayerRespawned )
}

void function ServerChatCommand_Aa(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage(player, "用法: /aa < on/off >")
        Fire_ChatServerPrivateMessage(player, "状态: " + (Fire_IsAimAssistEnabled() ? "启用" : "禁用"))
        return
    }

    string args0 = args[0].tolower()
    bool isThirdPersonEnabled = Fire_IsAimAssistEnabled()
    if( Fire_IsAffirmative(args0) && !isThirdPersonEnabled )
    {
        Fire_SetAimAssistEnabled(true)
        Fire_ChatServerBroadcast( "已启用辅助瞄准" )
    }
    else if( !Fire_IsAffirmative(args0) && isThirdPersonEnabled )
    {
        Fire_SetAimAssistEnabled(false)
        Fire_ChatServerBroadcast( "已禁用辅助瞄准" )
    }
}

void function OnPlayerRespawned( entity player )
{
	player.SetAimAssistAllowed( Fire_IsAimAssistEnabled() )
}

void function Fire_SetAimAssistEnabled(bool enabled)
{
    SetConVarBool( "Fire_AimAssisEnabled", enabled )
    foreach(player in GetPlayerArray())
    {
        if(!IsValid(player))
            continue
        player.SetAimAssistAllowed( enabled )
    }
}

bool function Fire_IsAimAssistEnabled()
{
    return GetConVarBool("Fire_AimAssisEnabled")
}