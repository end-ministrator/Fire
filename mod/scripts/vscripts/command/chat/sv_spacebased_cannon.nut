global function SpacebasedCannon_Init

bool Test = false

void function SpacebasedCannon_Init()
{
    RegisterWeaponDamageSource( "SpacebasedCannon", "Space-based Cannon" )
    
    AddChatCommandCallback("/sbc", ServerChatCommand_Spacebased_Cannon)
    if(Test)
        AddChatCommandCallback("/sbc_test_fx", ServerChatCommand_TestFX)
}

void function ServerChatCommand_TestFX(entity player, array<string> args)
{
    vector playerOrigin = player.GetOrigin()
    vector offset = <0, 100, 0>
    
    array<asset> fxList = [
        $"ar_rocket_strike_small_friend",
        $"ar_rocket_strike_small_foe", 
        $"ar_rocket_strike_large_friend",
        $"ar_rocket_strike_large_foe",
        $"wpn_orbital_beam"
    ]
    
    foreach( fx in fxList )
    {
        PlayFX( fx, playerOrigin + offset )
        offset.y += 500
    }
}

void function ServerChatCommand_Spacebased_Cannon(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin(player) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage(player, "用法: /sbc <name>")
        return
    }
    entity target = GetPlayerByNamePrefix(args[0])
    if( !IsValid(target) ){
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + args[0])
        return
    }
    if( target == player && !Test ){
        Fire_ChatServerPrivateMessage(player, "你无法锁定自己")
        return
    }
    if( target.GetTeam() == player.GetTeam() && !Test ){
        Fire_ChatServerPrivateMessage(player, "你无法锁定队友")
        return
    }
    thread SpacebasedCannon( target )
}

void function SpacebasedCannon(entity target)
{
    if( !IsValid(target) )
        return

    BroadcastStartInfo(target)
    wait 1.0

    ExecuteCountdown()
    
    vector targetOrigin = target.GetOrigin()

    entity fx = CreateTargetFX(targetOrigin)
    
    if(!Test)
    {
        entity reaper = CreateAndSpawnReaper(target.GetTeam(), targetOrigin)
        thread WaitUntilReaperGround(reaper)
    
        wait 0.1
    
        ExecuteExplosion(target, targetOrigin)
    
        if( IsValid(reaper) )
            reaper.Destroy()
    }
        
    wait 0.5
    StopFX(fx)
}

void function BroadcastStartInfo(entity target)
{
    array<string> messages = [
        "|==================[天基炮]==================|",
        " 目标: " + target.GetPlayerName(), 
        "|=========================================|"
    ]
    
    foreach( message in messages )
    {
        Fire_ChatServerBroadcast(message)
    }
}

void function ExecuteCountdown()
{
    for( int i = 3; i > 0; i-- ) 
    {
        Fire_ChatServerBroadcast("倒计时：" + i.tostring())
        wait 1.0
    }
}

entity function CreateTargetFX(vector origin)
{
    entity fx = PlayFX($"P_ar_titan_droppoint", origin)
    EffectSetControlPointVector( fx, 1, < 255, 255, 255 > )
    return fx
}

entity function CreateAndSpawnReaper(int targetTeam, vector targetOrigin)
{
    entity reaper = CreateSuperSpectre(targetTeam, targetOrigin + < 0, 0, 3000 >, <0, 0, 0>)
    DispatchSpawn(reaper)
    thread SuperSpectre_WarpFall(reaper)
    return reaper
}

void function ExecuteExplosion(entity target, vector origin)
{
    Explosion(
        origin,                             // 爆炸中心点
        target,                             // 爆炸发起者
        target,                             // 伤害施加者
        9999,                               // 基础伤害
        9999,                               // 对重甲伤害
        200,                                // 内圈半径
        200,                                // 外圈半径
        SF_ENVEXPLOSION_NOSOUND_FOR_ALLIES, // 爆炸标记
        origin,                             // 抛射物原点
        0,                                  // 冲击力
        damageTypes.explosive,              // 伤害类型
        eDamageSourceId.SpacebasedCannon,   // 伤害来源
        ARC_CANNON_FX_TABLE                 // 特效表
    )
}

void function WaitUntilReaperGround(entity ent)
{
    if( !IsValid(ent) )
        return
        
    while( ent.IsOnGround() )
    {
        WaitFrame()
    }
}