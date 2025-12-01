global function ServerChatCommand_Mute_Init
global function Fire_MutePlayer
global function Fire_UnmutePlayer
global function Fire_IsMutePlayer
global function Fire_GetPlayerMuteEndTime

table< string, float > mutedPlayers = {}

void function ServerChatCommand_Mute_Init()
{
    AddChatCommandCallback( "/mute", OnChatCommand_Mute )
    AddChatCommandCallback( "/unmute", OnChatCommand_Unmute )
}

void function OnChatCommand_Mute( entity player, array<string> args )
{
    if ( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }
    
    if ( args.len() < 1 || args.len() > 2 )
    {
        Fire_ChatServerPrivateMessage( player, "用法: /mute <玩家名> [时间(秒)]" )
        Fire_ChatServerPrivateMessage( player, "不指定时间则永久禁言" )
        return
    }
    
    if ( !Fire_IsChatEnabled() )
    {
        Fire_ChatServerPrivateMessage( player, "请先启用聊天" )
        return
    }

    string playerName = args[0]
    entity targetPlayer = GetPlayerByNamePrefix( playerName )
    
    if ( targetPlayer == null )
    {
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + playerName )
        return
    }
    
    if ( !IsValid( targetPlayer ) )
    {
        Fire_ChatServerPrivateMessage( player, "无效玩家: " + playerName )
        return
    }
    
    if ( targetPlayer == player )
    {
        Fire_ChatServerPrivateMessage( player, "你不能禁言自己" )
        return
    }
    
    if ( Fire_IsPlayerAdmin( targetPlayer ) )
    {
        Fire_ChatServerPrivateMessage( player, "你不能禁言管理员" )
        return
    }

    if ( targetPlayer.GetUID() in mutedPlayers ){
        Fire_ChatServerPrivateMessage( player, "玩家已被禁言，请先解除禁言" )
        return
    }
    
    if ( args.len() == 1 )
    {
        Fire_MutePlayer( targetPlayer, 0 )
        Fire_ChatServerPrivateMessage( player, "已永久禁言玩家 " + targetPlayer.GetPlayerName() )
        return
    }
    
    float muteDuration = float( args[1] )
    
    if ( muteDuration <= 0 )
    {
        Fire_ChatServerPrivateMessage( player, "禁言时间必须大于0" )
        return
    }
    
    Fire_MutePlayer( targetPlayer, muteDuration )
    Fire_ChatServerPrivateMessage( player, "已禁言玩家 " + targetPlayer.GetPlayerName() + " " + muteDuration + " 秒" )
}

void function OnChatCommand_Unmute( entity player, array<string> args )
{
    if ( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }

    if ( args.len() != 1 )
    {
        Fire_ChatServerPrivateMessage( player, "用法: /unmute <玩家名>" )
        return
    }

    string playerName = args[0]
    entity targetPlayer = GetPlayerByNamePrefix( playerName )
    
    if ( targetPlayer == null )
    {
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + playerName )
        return
    }
    
    if ( !IsValid( targetPlayer ) )
    {
        Fire_ChatServerPrivateMessage( player, "无效玩家: " + playerName )
        return
    }
    
    string playerUID = GetPlayerUID( targetPlayer )
    
    if ( !( playerUID in mutedPlayers ) ){
        Fire_ChatServerPrivateMessage( player, "玩家未被禁言" )
        return
    }

    Fire_UnmutePlayer( targetPlayer )
    Fire_ChatServerPrivateMessage( targetPlayer, "你已被解除禁言" )
    Fire_ChatServerPrivateMessage( player, "已解除禁言 " + targetPlayer.GetPlayerName() )
}

void function Fire_MutePlayer( entity player, float duration = 0 )
{
    string playerUID = GetPlayerUID( player )
    
    if ( playerUID in mutedPlayers )
        return
    
    if ( duration <= 0 )
    {
        mutedPlayers[ playerUID ] <- 0
        Fire_ChatServerPrivateMessage( player, "你已被永久禁言" )
    }
    else
    {
        mutedPlayers[ playerUID ] <- Time() + duration
        Fire_ChatServerPrivateMessage( player, "你已被禁言 " + duration + " 秒" )
    }
}

void function Fire_UnmutePlayer( entity player )
{
    string playerUID = GetPlayerUID( player )
    
    if ( playerUID in mutedPlayers )
        delete mutedPlayers[ playerUID ]
}

bool function Fire_IsMutePlayer( entity player )
{
    if ( !IsValid( player ) )
        return false
    
    string playerUID = GetPlayerUID( player )
    
    if ( !( playerUID in mutedPlayers ) )
        return false
    
    float muteEndTime = mutedPlayers[ playerUID ]
    
    if ( muteEndTime > 0 && muteEndTime < Time() )
    {
        delete mutedPlayers[ playerUID ]
        return false
    }
    
    return true
}

float function Fire_GetPlayerMuteEndTime( entity player )
{
    if ( !IsValid( player ) )
        return -1.0
    
    string playerUID = GetPlayerUID( player )
    
    if ( !( playerUID in mutedPlayers ) )
        return -1.0
    
    float muteEndTime = mutedPlayers[ playerUID ]
    
    if ( muteEndTime > 0 && muteEndTime < Time() )
    {
        delete mutedPlayers[ playerUID ]
        return -1.0
    }
    
    return muteEndTime
}