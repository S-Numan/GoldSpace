#include "ECSComponentCommon.as"
#include "ECSComponentStandard.as"
#include "ECSSystemCommon.as"
#include "ECSEntityStandard.as"

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







