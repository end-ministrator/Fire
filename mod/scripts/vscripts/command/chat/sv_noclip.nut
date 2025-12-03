global function ServerChatCommand_Noclip_Init
global function Fire_Noclip

void function ServerChatCommand_Noclip_Init()
{
    AddChatCommandCallback( "/noclip", ServerChatCommand_Noclip )
}

void function ServerChatCommand_Noclip(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage(player, "用法：/noclip < name/all/imc/militia >")
        return
    }

    string args0 = args[0]
    array<entity> targets

    switch(args0.tolower()){
        case "all":
            targets = GetPlayerArray()
            break
        case "imc":
            targets = GetPlayerArrayOfTeam( TEAM_IMC )
            break
        case "militia":
            targets = GetPlayerArrayOfTeam( TEAM_MILITIA )
            break
        default:
            targets = GetPlayersByNamePrefix( args0 )
            break
    }
    if(targets.len() == 0)
    {
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + args0 )
        return
    }

    foreach(target in targets)
    {
        if( !IsValid(target) || !IsAlive(target) )
        {
            Fire_ChatServerPrivateMessage(player, "玩家 " + target.GetPlayerName() + " 无效或死亡")
            continue
        }
        if( player.GetParent() )
		    continue
	    if( player.IsNoclipping() )
        {
            player.SetPhysics( MOVETYPE_WALK )
            Fire_ChatServerPrivateMessage(player, "已关闭玩家 " + target.GetPlayerName() + " 的穿墙模式")
        }
	    else
        {
            player.SetPhysics( MOVETYPE_NOCLIP )
            Fire_ChatServerPrivateMessage(player, "已设置玩家 " + target.GetPlayerName() + " 为穿墙模式")
        }
    }
}

void function Fire_Noclip( entity player )
{
	if( player.GetParent() )
		return
	if( player.IsNoclipping() )
    {
        player.SetPhysics( MOVETYPE_WALK )
    }else
    {
        player.SetPhysics( MOVETYPE_NOCLIP )
    }
}