global function ChatCommand_Tp_Init

void function ChatCommand_Tp_Init()
{
    AddChatCommandCallback( "/tp", ChatCommand_Tp )
}

void function ChatCommand_Tp(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player)){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if(args.len() != 2){
        Fire_ChatServerPrivateMessage(player, "用法: /tp <name/all/imc/militia> <name>")
        return
    }

    string args0 = args[0]
    string args1 = args[1]

    array<entity> teleports = []
    switch(args0.tolower()){
        case "all":
            teleports = GetPlayerArray()
            break
        case "imc":
            teleports = GetPlayerArrayOfTeam( TEAM_IMC )
            break
        case "militia":
            teleports = GetPlayerArrayOfTeam( TEAM_MILITIA )
            break
        default:
            teleports = GetPlayersByNamePrefix( args0 )
            break
    }

    if(teleports.len() == 0 ){
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + args0)
        return
    }
       
    entity target = GetPlayerByNamePrefix(args1)
    if( !IsValid(target) || !IsAlive(target) ){
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + args1)
        return
    }

    foreach(teleport in teleports){
        if( !IsValid(teleport) || !IsAlive(teleport) )
        {
            Fire_ChatServerPrivateMessage(player, "玩家 " + target.GetPlayerName() + " 无效或死亡")
            continue
        }
        thread Fire_TeleportPlayerToPlayer(teleport, target)
        Fire_ChatServerPrivateMessage(player, "已传送玩家 " + teleport.GetPlayerName() + " 到 " + target.GetPlayerName())
    }
}

void function Fire_TeleportPlayerToPlayer(entity playerToTeleport, entity destinationPlayer)
{
    playerToTeleport.SetInvulnerable()
    destinationPlayer.SetInvulnerable()

    WaitEndFrame()
    EmitSoundOnEntity(playerToTeleport, "Timeshift_Scr_DeviceShift2Present")

    wait 0.25
    playerToTeleport.SetOrigin(destinationPlayer.GetOrigin())
    playerToTeleport.ClearInvulnerable()
    destinationPlayer.ClearInvulnerable()
}