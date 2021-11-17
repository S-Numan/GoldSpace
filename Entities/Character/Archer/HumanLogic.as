
#include "HumanCommon.as"
#include "ThrowCommon.as"
#include "KnockedCommon.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";

const int FLETCH_COOLDOWN = 45;
const int PICKUP_COOLDOWN = 15;
const int fletch_num_arrows = 1;
const int STAB_DELAY = 12;
const int STAB_TIME = 20;

void onInit(CBlob@ this)
{
	HumanInfo human;
	this.set("humanInfo", @human);

	this.set_f32("gib health", -1.5f);
	this.Tag("player");
	this.Tag("flesh");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	//SetHelp(this, "help self hide", "human", getTranslatedString("Hide    $KEY_S$"), "", 1);
	//SetHelp(this, "help self action2", "human", getTranslatedString("$Grapple$ Grappling hook    $RMB$"), "", 3);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
    this.getCurrentScript().tickIfTag = "alive";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	HumanInfo@ human;
	if (!this.get("humanInfo", @human))
	{
		return;
	}

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

}


void onAddToInventory(CBlob@ this, CBlob@ blob)
{

}