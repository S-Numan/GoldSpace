#include "ECSEntityComponent.as"
#include "ECSSystemCommon.as"


itpol::Pool@ it_pol;

void onInit(CRules@ rules)
{
    @it_pol = @itpol::Pool();
    rules.set("it_pol", @it_pol);

    AddEnemy(rules, Vec2f(0,0), Vec2f(1, 0), 30.0f);
    AddEnemy(rules, Vec2f(0,200), Vec2f(2, 0), 30.0f);

    print("check duplicate adding");

    u32 enemy_id3 = AddEnemy(rules, Vec2f(0,400), Vec2f(4, 0), 30.0f);
    array<u32> com_type_array = 
    {
        SType::POS,
        SType::HEALTH
    };

    print("ByType duplicate test");
    it_pol.AssignByType(enemy_id3, com_type_array);
    
    print("ByID duplicate test");
    SType::IComponent@ com = SType::getStandardComByType(SType::POS);
    u32 enemy_id3_com_id = it_pol.AddComponent(com);
    it_pol.AssignByID(enemy_id3, enemy_id3_com_id);
}

void onTick(CRules@ rules)
{
    itpol::Pool@ it_pol;
    if(!rules.get("it_pol", @it_pol)) { Nu::Error("Failed to get it_pol"); return; }//Get the pool

    u32 q;
    u32 component_count;
    u32 entity_count = it_pol.EntCount();
    for(u16 i = 0; i < entity_count; i++)
    {
        array<SType::IComponent@>@ ent = it_pol.getEnt(i);
        
        u32 POS;
        if(SType::EntityHasType(ent, SType::POS, POS))
        {
            u32 VELOCITY;
            if(SType::EntityHasType(ent, SType::VELOCITY, VELOCITY))
            {
                SType::CPos@ CPos = cast<SType::CPos@>(ent[POS]);
                SType::CVelocity@ CVelocity = cast<SType::CVelocity@>(ent[VELOCITY]);

                CPos.pos += CVelocity.velocity;
                if(isClient())
                {
                    RenderTestImage(CPos.pos);
                }
            }
        }
    }
}

//void onRender(CRules@ rules)
//{

//}







