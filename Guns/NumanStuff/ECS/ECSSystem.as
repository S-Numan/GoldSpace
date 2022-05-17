#include "ECSEntityComponent.as"
#include "ECSSystemCommon.as"


itpol::Pool@ it_pool;

void onInit(CRules@ rules)
{
    @it_pool = @itpol::Pool();
    rules.set("it_pool", @it_pool);
}

void onTick(CRules@ rules)
{
    
}

//void onRender(CRules@ rules)
//{

//}







