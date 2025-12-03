global function ServerChatCommand_Fold_Init
global function FoldWeapon
global function HudMsgSend
global function PlayFinishBeepSound

global function EmitSoundToAllPlayers
global function StopSoundToAllPlayers

bool FoldWeaponStop = false

const array<string> FOLD_WEAPON_SOUNDS = [
    "diag_sp_sculptorRing_SK151_02_01_imc_facilityPA",
    "diag_sp_sculptorRing_SK151_03_01_imc_facilityPA",
    "diag_sp_sculptorRing_SK151_04_01_imc_facilityPA",
    "diag_sp_injectorRoom_SK161_01_01_imc_facilityPA",
    "diag_sp_injectorRoom_SK161_11_01_imc_facilityPA",
    "diag_sp_injectorRoom_SK161_12_01_imc_facilityPA",
    "diag_sp_injectorRoom_SK161_13_01_imc_facilityPA",
    "diag_sp_injectorRoom_SK161_14a_01_imc_facilityPA",
    "diag_sp_injectorRoom_SK161_16_01_imc_facilityPA",
    "coop_generator_underattack_alarm"
]

void function ServerChatCommand_Fold_Init()
{
	FlagInit("Fold_FoldWeaponStart")
	FlagInit("Fold_FoldWeaponStop")
	FlagInit("Fold_CoopGeneratorUnderattackAlarmStop")

	RegisterWeaponDamageSource("FoldWeapon", "Fold Weapon")
	AddChatCommandCallback("/fold", ServerChatCommand_Fold)
}

void function ServerChatCommand_Fold(entity player, array<string> args)
{
	if(!Fire_IsPlayerAdmin(player)){
		Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
		return
	}
	if(args.len() != 1){
		Fire_ChatServerPrivateMessage(player, "用法: /fold <start/stop>")
		return
	}

	string arg0 = args[0].tolower()
	if(arg0 != "start" && arg0 != "stop")
		return

	array<string> msg = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]

	PlayFinishBeepSound(player)
	msg.append("Fold Weapon")
	HudMsgSend(msg, player)

	wait 1.0
	PlayFinishBeepSound(player)
	msg.append("Fold Weapon System v1.1")
	HudMsgSend(msg, player)

	wait 1.0
	if(arg0 == "start" && !Flag("Fold_FoldWeaponStart"))
	{
		PlayFinishBeepSound(player)
		msg.append("Fold Weapon Start")
		HudMsgSend(msg, player)

		wait 1.5
		thread FoldWeapon(player)
	}
	else if(arg0 == "stop" && Flag("Fold_FoldWeaponStart") && !FoldWeaponStop)
	{
		PlayFinishBeepSound(player)
		msg.append("Fold Weapon Stop")
		HudMsgSend(msg, player)

		wait 1.5
		FlagSet("Fold_FoldWeaponStop")
		FlagSet("Fold_CoopGeneratorUnderattackAlarmStop")

		FlagClear("Fold_FoldWeaponStart")
		FlagClear("Fold_FoldWeaponStop")
		FlagClear("Fold_CoopGeneratorUnderattackAlarmStop")

		foreach(sound in FOLD_WEAPON_SOUNDS)
			StopSoundToAllPlayers(sound)
		wait 0.2
		EmitSoundToAllPlayers("diag_sp_uplinkDown_BE351_25_01_imc_facilityPA")
	}
}

void function FoldWeapon(entity owner)
{
	FlagEnd("Fold_FoldWeaponStop")
	FlagSet("Fold_FoldWeaponStart")

	int team = owner.GetTeam()
	array<float> delays = [0.0, 5.0, 5.0, 10.0, 10.0, 10.0, 10.0, 10.0, 15.0]

	for(int i = 0; i < 9; i++) 
	{
		wait delays[i]
		EmitSoundToAllPlayers(FOLD_WEAPON_SOUNDS[i])
	}
	wait 0.1
	thread CoopGeneratorUnderattackAlarm()
	EmitSoundToAllPlayers(FOLD_WEAPON_SOUNDS[8])

	wait 15.0
	EmitSoundToAllPlayers(FOLD_WEAPON_SOUNDS[9])

	FoldWeaponStop = true

	wait 10.0
	FlagSet("Fold_CoopGeneratorUnderattackAlarmStop")

	foreach(player in GetPlayerArray())
		thread FoldPlayerEffects(player, owner)

	wait 3.0
	SetWinner(team)
	SetGameState(eGameState.Postmatch)
}

void function CoopGeneratorUnderattackAlarm()
{
	FlagEnd("Fold_CoopGeneratorUnderattackAlarmStop")

	SendLargeMessageToAllAlivePlayers("摺疊時空武器", "", 10, "rui/callsigns/callsign_76_col")
	while(true)
	{
		EmitSoundToAllPlayers("coop_generator_underattack_alarm")
		wait 3.0
	}
}

void function FoldPlayerEffects(entity player, entity owner)
{
	if(IsAlive(player))
	{
		Remote_CallFunction_NonReplay(player, "ServerCallback_PlayScreenFXWarpJump")
		for (int i = 4; i > 0; i--)
			EmitSoundOnEntity(player, "haven_scr_carrierwarpout")
	}

	if(!IsAlive(player) || !IsAlive(owner))
		return

	thread NukeExplode(player, owner)
}

void function EmitSoundToAllPlayers(string sound)
{
	foreach(player in GetPlayerArray())
		EmitSoundOnEntity(player, sound)
}

void function StopSoundToAllPlayers(string sound)
{
	foreach(player in GetPlayerArray())
		StopSoundOnEntity(player, sound)
}

void function NukeExplode(entity player, entity owner)
{
	player.EndSignal("OnDestroy")

	StopSoundOnEntity(player, "titan_cockpit_missile_close_warning")
	EmitSoundOnEntityOnlyToPlayer(player, player, "goblin_dropship_explode_OLD")
	thread FakeShellShock_Threaded(player, 3)
	ScreenFadeToColor(player, 192, 192, 192, 64, 0.1, 3)
	thread NukeFX(player)
	StatusEffect_AddTimed(player, eStatusEffect.emp, 1.0, 3.0, 0.0)
	wait 2

	StopSoundOnEntity(player, "goblin_dropship_explode_OLD")
	if(IsAlive(player))
		player.Die(owner, owner, { damageSourceId = eDamageSourceId.FoldWeapon })
	foreach(string snd in [
		"death.pinkmist",
		"titan_nuclear_death_explode",
		"bt_beacon_controlroom_dish_explosion"
	]){
		EmitSoundOnEntityOnlyToPlayer(player, player, snd)
	}
	ScreenFadeToColor(player, 192, 192, 192, 255, 0.2, 4)
}

void function FakeShellShock_Threaded(entity victim, float duration)
{
	victim.EndSignal("OnDestroy")

	StatusEffect_AddTimed(victim, eStatusEffect.move_slow, 0.25, duration, 0.25)
	StatusEffect_AddTimed(victim, eStatusEffect.turn_slow, 0.25, duration, 0.25)
	AddCinematicFlag(victim, CE_FLAG_EXECUTION)
	AddCinematicFlag(victim, CE_FLAG_HIDE_MAIN_HUD)

	OnThreadEnd(function(): (victim)
	{
		if(!IsValid(victim))
			return
		RemoveCinematicFlag(victim, CE_FLAG_EXECUTION)
		RemoveCinematicFlag(victim, CE_FLAG_HIDE_MAIN_HUD)
	})

	wait duration
}

void function NukeFX(entity player)
{
	player.EndSignal("OnDestroy")

	float endTime = Time() + 2.2
	float bloomScale = 1.0
	float sunScale = -1.0
	while(Time() < endTime)
	{
		Remote_CallFunction_Replay(player, "ServerCallback_ScreenShake", 200, 100, 0.5)
		Remote_CallFunction_NonReplay(player, "ServerCallback_SetMapSettings", bloomScale, false, 1.0, 1.0, 1.0, 0, 0, sunScale, 1.0)
		bloomScale *= 1.5
		sunScale *= 2.0
		WaitFrame()
	}
	Remote_CallFunction_NonReplay(player, "ServerCallback_ResetMapSettings")
}

void function SendNuclearWarn(string msg)
{
	foreach(player in GetPlayerArray())
	{
		if(!IsValid(player))
			continue
		SendHudMessageWithPriority(player, 90.01, msg, -1, 0.3, <255, 0, 0>, <0, 2, 0>)
	}
}

void function PlayBeepSound(entity owner)
{
	EmitSoundOnEntity(owner, "hud_boost_card_radar_jammer_redtextbeep_1p")
}

void function HudMsgSend(array<string> a, entity owner, bool isRed = false)
{
	if(!IsValid(owner))
		return

	string msg = ""
	int start = max(0, a.len() - 10).tointeger()
	for(int i = start; i < a.len(); i++)
	{
		msg += "                " + a[i] + "\n"
	}

	if(isRed)
	{
		SendHudMessageWithPriority(owner, 90.01, msg, 0, 0.3, <255, 0, 0>, <0, 1, 0>)
		return
	}
	SendHudMessageWithPriority(owner, 90.01, msg, 0, 0.3, <235, 235, 235>, <0, 2, 0>)
}

void function PlayFinishBeepSound(entity owner)
{
	EmitSoundOnEntity(owner, "Wilds_Scr_HelmetHUDText_Finish")
}