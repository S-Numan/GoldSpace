#include "ECSComponentCommon.as"
#include "ECSComponent.as"
#include "ECSSystemCommon.as"
#include "ECSEntities.as"

itpol::Pool@ it_pol;
void onInit(CRules@ rules)
{
    onInitSystem(rules);

    EnT::AddEnemy(rules, it_pol, Vec2f(0,10), Vec2f(1, 0), 30.0f);
    EnT::AddEnemy(rules, it_pol, Vec2f(0,200), Vec2f(2, 0), 30.0f);

    print("check duplicate adding");

    u32 enemy_id3 = EnT::AddEnemy(rules, it_pol, Vec2f(0,400), Vec2f(4, 0), 30.0f);
    array<u16> com_type_array = 
    {
        SType::POS,
        SType::HEALTH
    };

    print("ByType duplicate test");
    it_pol.AssignByType(enemy_id3, com_type_array);
    
    print("ByID duplicate test");
    CType::IComponent@ com = CType::getComByType(rules, SType::POS);
    u32 enemy_id3_com_id = it_pol.AddComponent(com);
    it_pol.AssignByID(enemy_id3, com.getType(), enemy_id3_com_id);
}


array<SystemFuncs@>@ sys_move;
array<SystemFuncs@>@ sys_render;

void onInitSystem(CRules@ rules)
{
    @it_pol = itpol::Pool();
    rules.set("it_pol", @it_pol);


    array<GetComByType@>@ get_com_by_type = array<GetComByType@>@();
    rules.set("com_by_type", @get_com_by_type);

    get_com_by_type.push_back(SType::getStandardComByType);



    @sys_move = array<SystemFuncs@>@();
    rules.set("sys_move", @sys_move);
    sys_move.push_back(SType::OldPosIsNewPos);
    sys_move.push_back(SType::ApplyVelocity);

    @sys_render = array<SystemFuncs@>@();
    rules.set("sys_render", @sys_render);
    sys_render.push_back(SType::RenderImage);



}

void onTickSystem(CRules@ rules)
{
    u16 i;
    for(i = 0; i < sys_move.size(); i++)
    {
        sys_move[i](@it_pol);
    }
}

void onTick(CRules@ rules)
{
    //itpol::Pool@ it_pol;
    //if(!rules.get("it_pol", @it_pol)) { Nu::Error("Failed to get it_pol"); return; }//Get the pool

    onTickSystem(rules);

    //u32 q;
    /*
    u32 entity_count = it_pol.EntCount();
    for(u16 i = 0; i < entity_count; i++)
    {
        array<CType::IComponent@>@ ent = it_pol.getEnt(i);
        
        u16 POS;
        if(SType::EntityHasType(ent, SType::POS, POS))
        {
            u16 VELOCITY;
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
    */
    //Loop through components, and check if their entities have x components. Loop through the top components first.
    //EG loop through velocity component, check if their entity has a POS component, apply velocity.
    //Don't loop through pos and check for velocity. Loop through the editors first. The components that mess with other components.
    //Remember to only do logic if ent_array_open[ent_id]/com_array_open[com_id] are false.

}

void onRenderSystem(CRules@ rules)
{
    u16 i;
    for(i = 0; i < sys_render.size(); i++)
    {
        sys_render[i](@it_pol);
    }
}

void onRender(CRules@ rules)
{
    onRenderSystem(rules);
}







