global function ServerChatCommand_Rf_Init
global function ReaperFlyin


void function ServerChatCommand_Rf_Init()
{
    AddChatCommandCallback( "/rf", ServerChatCommand_Rf )
}

void function ServerChatCommand_Rf(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if(args.len() != 2){
        Fire_ChatServerPrivateMessage(player, "用法: /rf < 队伍 > < 数量(不要超过40) >")
        return
    }

    string args0 = args[0]

    if(hasNonDigit(args0)){
        Fire_ChatServerPrivateMessage(player, "队伍必须是数字")
        return
    }

    int team
    int bzd
    try{
        team = int(args0)
        bzd = int(args[1])
    }catch(error){
        Fire_ChatServerPrivateMessage(player, "错误: " + string(error))
        return
    }

    if(team < 2)
    {
        Fire_ChatServerPrivateMessage(player, "队伍必须大于等于2")
        return
    }

    vector origin = player.GetOrigin() + <0, 0, 5000>
    for( int i = 0 ; i < bzd; i++ )
    {
        thread ReaperFlyin(origin,team)
        wait RandomFloatRange( 0.3, 1.0 )
    }
}

entity function ReaperFlyin( vector origin, int team )
{   
    entity node = CreateSuperSpectre( 1, origin, < 0, RandomIntRange( 0, 360 ), 0 > )
    DispatchSpawn( node )
    node.StopPhysics()
    node.Hide()

    waitthread WarpinEffect( DROPSHIP_MODEL, "ds_sspec_dropship_deploy_flyin_01", node.GetOrigin(), node.GetAngles() )

    entity dropship = CreateDropship( team, node.GetOrigin(), node.GetAngles() )
    DispatchSpawn( dropship )
    dropship.SetMaxHealth(50000)
    dropship.SetHealth(dropship.GetMaxHealth())

    entity reaper = CreateSuperSpectre( team, node.GetOrigin(), node.GetAngles() )
    DispatchSpawn( reaper )
    reaper.SetMaxHealth(30000)
    reaper.SetHealth(reaper.GetMaxHealth())
    reaper.AssaultSetFightRadius( 1000 )
	reaper.AssaultSetGoalRadius( 100 )

    thread ReaperFlyin_Ship( dropship, node )
    waitthread ReaperFlyin_Reaper( reaper, node )
    node.Destroy()
    return reaper
}

void function ReaperFlyin_Ship( entity dropship, entity node )
{
	EndSignal( dropship, "OnDeath" )

	waitthread PlayAnimTeleport( dropship, "ds_sspec_dropship_deploy_flyin_01", node, 0 )
	WarpoutEffect( dropship )
	dropship.Destroy()
}

void function ReaperFlyin_Reaper( entity reaper, entity node )
{
	EndSignal( reaper, "OnDeath" )

	PlayAnimTeleport( reaper, "sspec_dropship_deploy_flyin_01", node, 0 )
	PlayAnim( reaper, "sspec_dropship_deploy_release", node, 0 )

	entity mover = CreateOwnedScriptMover( reaper )
	reaper.SetParent( mover, "", false )

	thread PlayAnim( reaper, "sspec_dropship_deploy_fall_idle", mover, 0 )

	vector landPos = OriginToGround( reaper.GetOrigin() + <0,0,1> )
	int index = reaper.LookupSequence( "sspec_dropship_deploy_landing" )
	vector delta = reaper.GetAnimDeltas( index, 0, 1 )
	landPos.z -= delta.z

	float dist = Distance( reaper.GetOrigin(), landPos )
	float fallTime = dist / 850

	mover.NonPhysicsMoveTo( landPos, fallTime, min( fallTime * 0.25, 1.4 ), 0.0 )

    entity effect = PlayFX($"P_ar_titan_droppoint", landPos + < 0, 0, -150 >)
    EffectSetControlPointVector( effect, 1, < 255, 255, 255 > )

	wait fallTime
	PlayAnim( reaper, "sspec_dropship_deploy_landing", mover, 0 )
	reaper.ClearParent()
	mover.Destroy()
    EffectStop(effect)
}