#define SERVER_ONLY

#include "NuLib.as";

array<u16> respawn_times;//How many ticks until each player respawns
//0 is not respawning
//1 is about to respawn upon hitting 0
//anything above will be counted down by 1 every tick.

const u16 respawn_time = 30;//30 ticks is equal to a second


void onInit( CRules@ this )
{
    onRestart(this);

    this.set_f32("gravity_mult", 0.5f);
    this.set_u8("map_type", 0);//0 for space. 1 for underground
    
    LoadMap("SpaceShip1.png");
    
    getMap().SetDayTime(0.004);
}

void onRestart( CRules@ this )
{
    u16 i;
    for(i = 0; i < respawn_times.size(); i++)//For every player's respawn time
    {
        respawn_times[i] = 2;//Make it take a tick or two to respawn.
    }
}

void onTick( CRules@ this )
{
    u16 i;
    
    for(i = 0; i < respawn_times.size(); i++)//For every player's respawn time
    {
        if(respawn_times[i] != 0)//If they are not already respawned
        {
            respawn_times[i]--;//Count down
            if(respawn_times[i] == 0)//If it is time for them to respawn
            {
                CPlayer@ player = getPlayer(i);
                if(player == @null) { Nu::Error("player was null when respawning in rules."); continue; }

                Nu::RespawnPlayer(this, player, "knight");
            }
        }
    }
    
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
    respawn_times.push_back(2);
    player.server_setTeamNum(0);
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
    u16 player_index = getPlayerIndex(player);
    if(player_index >= respawn_times.size()) { Nu::Error("player index was larger than respawn_times size"); return; } 
    
    respawn_times.removeAt(player_index);
}





void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )//Calls when the player's blob dies
{
    u16 player_index = getPlayerIndex(victim);
    if(player_index >= respawn_times.size()) { Nu::Error("player index was larger than respawn_times size"); return; } 

    respawn_times[player_index] = respawn_time;
}

void onSetPlayer( CRules@ this, CBlob@ blob, CPlayer@ player )//Calls when the thing the player controls changes (including when the player's blob dies)
{

}





void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{

}