#include "NuLib.as";
#include "ECSSystemCommon.as";


//Could one use CBitStream as a replacement to a Component class? Seems possible.
//Problem is one cannot tell the type of a class. And honestly, there should be structs.
//CBitStream is just DATA right? It's also an engine side class. It should be faster in many ways right?
//Maybe not though, as you'd need to read and write to the cbitstream very often. That might be slow?
//Would require an enum that gives the bit index to every variable in the cbitstream, so it's probably not worth it.

//Might need to init every component type to get their type somehow. Increment?

//Maybe always make sure there is one empty component of every type in the component pool at all times?

//CBitStream should be the optional params for every component? As in when making a component, you give a function an enum, and a cbitstream that contains the specific details for the component being made.
//Like, CBitstream params; params.write_f32(5);//x params.write_f32(10);//y AssignComponent(Type::POS, params); This makes it easy to assign initial params for any component.








//Return's the entity's id.
u32 AddEnemy(CRules@ rules, Vec2f pos, Vec2f velocity, f32 health)
{
    /*array<u32> com_type_array = 
    {
        Type::POS,
        Type::HEALTH,
        Type::SOUND
    };

    array<bool> added_array;//Stores which components already exist and were given to this entity
    added_array = it_pol.Assign(ent_id, com_type_array);
    
    for(u16 i = 0; i < added_array.size(); i++)
    {
        if(added_array){//Added to this entity?
            continue;//Then stop here
        }
        //Component was not added to the entity
        
        Component@ com = getStandardComByType(com_type_array[i]);
        com.type = com_type_array[i];
        com.id = it_pol.getComID();
        it_pol.Assign(ent_id, com);
    }*/

    array<u32> com_type_array = 
    {
        SType::POS,
        SType::VELOCITY,
        SType::HEALTH
    };
    //Make pos in array @null when you don't want default parameters.
    
    array<CBitStream@> default_params = array<CBitStream@>(com_type_array.size());
    for(u16 i = 0; i < default_params.size(); i++){
        @default_params[i] = @CBitStream();
    }
    default_params[0].write_Vec2f(pos);
    
    default_params[1].write_Vec2f(velocity);

    default_params[2].write_f32(health);


    return SType::CreateEntity(rules, com_type_array, default_params);
}

namespace SType//Standard Type
{
    shared u32 CreateEntity(CRules@ rules, array<u32> com_type_array, array<CBitStream@> default_params)
    {
        itpol::Pool@ it_pol;
        if(!rules.get("it_pol", @it_pol)) { Nu::Error("Failed to get it_pol"); return Nu::u32_max(); }//Get the pool

        u32 ent_id = it_pol.NewEntity();//Create a new entity, and get it's id

        array<bool> added_array = it_pol.AssignByType(ent_id, com_type_array, default_params);//Assign components and their default variables to the entity. Return the components that failed to be assigned.

        for(u16 i = 0; i < added_array.size(); i++)
        {
            if(added_array[i]) { continue; }//If the position is free, there is no need to make anything as it already exists.
            //No component in pool. Need to make a new component.
            SType::IComponent@ com = SType::getStandardComByType(com_type_array[i]);

            u32 com_id = it_pol.AddComponent(com);

            it_pol.AssignByID(ent_id, com_id, i, default_params[i]);//entity id, component id, position the com should be placed in the entity's component array.
        }

        return ent_id;
    }

    //struct
    /*shared class Entity//Holds Components
    {
        u32 id;
        array<SType::IComponent@> components;
    }*/
    
    //Returns the pos of the type requested to find. returns true if found, false if not.
    shared bool EntityHasType(array<SType::IComponent@>@ ent, u32 type, u32 &out pos)
    {
        u32 com_count = ent.size();
        for(u16 i = 0; i < com_count; i++)
        {
            if(ent[i].getType() == type)
            {
                pos = i;
                return true;
            }
        }
        return false;
    }
    shared interface IComponent
    {
        void Deserialize(CBitStream@ params);
        void Default();

        u32 getType();
        void setType(u32 _type);
        u32 getID();
        void setID(u32 _id);
    }
    //struct
    shared class Component : IComponent//Holds DATA only.
    {
        u32 id;//Stores it's own id in the pool.
        u32 type;//Stores type of class. The type is currently the hash of the class name.

        //Serialize
        
        void Deserialize(CBitStream@ params)
        {
            
        }
        void Default()
        {
            
        }
        u32 getType()
        {
            return type;
        }
        void setType(u32 _type)
        {
            type = _type;
        }
        u32 getID()
        {
            return id;
        }
        void setID(u32 _id)
        {
            id = _id;
        }
    }

    shared enum ComponentType
    {
        Nothing = 0,
        Null = 1,
        POS,
        VELOCITY,
        HEALTH,
        TypeCount
    }

    shared IComponent@ getStandardComByType(u32 type)
    {
        Component@ com;
        switch(type)
        {
            case POS:
                @com = CPos();
            break;
            case VELOCITY:
                @com = CVelocity();
            break;
            case HEALTH:
                @com = CHealth();
            break;

            default:
                Nu::Error("Could not find type");
        }
        if(com != @null)
        {
            com.setType(type);
            com.Default();
        }
        return com;
    }

    shared class CPos : Component
    {
        void Deserialize(CBitStream@ params) override
        {
            if(!params.saferead_Vec2f(pos)) { Nu::Error("Failed saferead on type " + type); }
        }
        void Default() override
        {
            pos = Vec2f(0, 0);
            old_pos = Vec2f(0, 0);
        }

        Vec2f pos;
        Vec2f old_pos;
    }

    shared class CVelocity : Component
    {
        void Deserialize(CBitStream@ params) override
        {
            if(!params.saferead_Vec2f(velocity)) { Nu::Error("Failed saferead on type " + type); }
        }
        void Default() override
        {
            velocity = Vec2f(0.0f, 0.0f);
            old_velocity = Vec2f(0.0f, 0.0f);
        }

        Vec2f velocity;
        Vec2f old_velocity;
    }

    shared class CHealth : Component
    {
        void Deserialize(CBitStream@ params) override
        {
            if(!params.saferead_f32(health)) { Nu::Error("Failed saferead on type " + type); }
        }
        void Default() override
        {
            health = 0.0f;
        }
        f32 health;
    }
}