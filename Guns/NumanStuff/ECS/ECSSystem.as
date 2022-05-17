#include "ECSEntityComponent.as"
#include "ECSSystemCommon.as"


itpol::Pool@ it_pol;

void onInit(CRules@ rules)
{
    @it_pol = @itpol::Pool();
    rules.set("it_pol", @it_pol);

    AddEnemy(rules, 12.0f, 25.0f, 30.0f);
    AddEnemy(rules, 12.0f, 25.0f, 30.0f);

    print("check duplicate adding");

    u32 enemy_id3 = AddEnemy(rules, 12.0f, 25.0f, 30.0f);
    array<u32> com_type_array = 
    {
        SType::POS,
        SType::HEALTH
    };

    it_pol.Assign(enemy_id3, com_type_array);
}

void onTick(CRules@ rules)
{
    
}

//void onRender(CRules@ rules)
//{

//}







