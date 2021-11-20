#include "WeaponCommon.as";

void onInit(CRules@ this)
{

}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    it::onNewPlayerJoin(@this, @player);    
}