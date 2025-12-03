global function ServerChatCommand_Fly_Init

void function ServerChatCommand_Fly_Init()
{
    AddChatCommandCallback( "/fly", ServerChatCommand_Fly )
}

void function ServerChatCommand_Fly(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 2){
        Fire_ChatServerPrivateMessage(player, "用法: /fly < name/all/imc/militia > < 高度 >")
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
    if(targets.len() == 0){
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + args0)
        return
    }

    string args1 = args[1]

    if(hasNonDigit(args1)){
        Fire_ChatServerPrivateMessage(player, "高度必须是数字")
        return
    }

    int height = args1.tointeger()

    foreach(target in targets){
        if( !IsValid(target) || !IsAlive(target))
        {
            Fire_ChatServerPrivateMessage(player, "玩家 " + target.GetPlayerName() + " 无效或死亡")
            continue
        }
        thread Fire_Fly( target, height )
    }
}

void function Fire_Fly( entity player, int height )
{
    vector playerOrigin = player.GetOrigin()
    vector destination = < playerOrigin.x, playerOrigin.y, height >

    entity mover = CreateOwnedScriptMover( player )
    player.SetParent( mover )

    mover.NonPhysicsMoveTo( destination, 1.0, 0.4, 0.3 )
    wait 1.1
    player.ClearParent()
}