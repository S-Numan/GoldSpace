#include "ECSComponentCommon.as"

//CBitStream params, or casting. Decide on one.

namespace EnT
{
    //Return's the entity's id.
    u32 AddEnemy(CRules@ rules, itpol::Pool@ it_pol, Vec2f pos, Vec2f velocity, f32 health)
    {
        array<u16> com_type_array = 
        {
            SType::POS,
            SType::VELOCITY,
            //SType::IMAGE,
            SType::HEALTH
        };
        
        //Default params option 1.
        //Make pos in array @null when you don't want default parameters. Don't input it into CreateEntity if you don't want default params at all.
        array<CBitStream@> default_params = array<CBitStream@>(com_type_array.size());
        for(u16 i = 0; i < default_params.size(); i++){
            @default_params[i] = @CBitStream();
        }
        default_params[0].write_Vec2f(pos);
        
        default_params[1].write_Vec2f(velocity);

        //@default_params[2] = @null;

        default_params[2].write_f32(health);


        u32 ent_id = CType::CreateEntity(rules, it_pol, com_type_array, default_params
        );
    
        /*
        //Default params option 2.
        array<CType::IComponent@>@ ent = @it_pol.getEnt(ent_id);
        cast<SType::CPos@>(ent[0]).pos = pos;
        cast<SType::CVelocity@>(ent[1]).velocity = velocity;
        //cast<SType::CImage@>(ent[2]).image = image;
        cast<SType::CHealth@>(ent[3]).health = health;
        */

        return ent_id;
    }
}