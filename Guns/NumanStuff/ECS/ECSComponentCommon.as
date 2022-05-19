#include "NuLib.as";
#include "ECSSystemCommon.as";


//Could one use CBitStream as a replacement to a Component class? Seems possible.
//Problem is one cannot tell the type of a class. And honestly, there should be structs.
//CBitStream is just DATA right? It's also an engine side class. It should be faster in many ways right?
//Maybe not though, as you'd need to read and write to the cbitstream very often. That might be slow?
//Would require an enum that gives the bit index to every variable in the cbitstream, so it's probably not worth it.

//Might need to init every component type to get their type somehow. Increment?

//Maybe always make sure there is one empty component of every type in the component pool at all times?






funcdef CType::IComponent@ GetComByType(u16);//Type

namespace CType//Common Type
{
    u32 CreateEntity(CRules@ rules, itpol::Pool@ it_pol, array<u16> com_type_array, array<CBitStream@> default_params = array<CBitStream@>())
    {
        u32 ent_id = it_pol.NewEntity();//Create a new entity, and get it's id
        array<CType::IComponent@>@ ent = it_pol.getEnt(ent_id);

        array<bool> added_array = it_pol.AssignByType(ent_id, com_type_array, default_params);//Assign components and their default variables to the entity. Return the components that failed to be assigned.

        for(u16 i = 0; i < added_array.size(); i++)
        {
            if(added_array[i]) { continue; }//If the position is free, there is no need to make anything as it already exists.
            //No component in pool. Need to make a new component.
            
            CType::IComponent@ com = getComByType(rules, com_type_array[i]);

            if(com == @null) { Nu::Warning("a component with the given type " + com_type_array[i] + " was not found."); continue; }

            u32 com_id = it_pol.AddComponent(com);
            u16 com_pos = getFreePosInEntity(ent);

            if(i < default_params.size())//Provided i is within default_params
            {
                it_pol.AssignByID(ent_id, com_type_array[i], com_id, com_pos, default_params[i]);//entity id, component type, component id, position the com should be placed in the entity's component array.
            }
            else
            {
                it_pol.AssignByID(ent_id, com_type_array[i], com_id, com_pos);
            }
        }

        return ent_id;
    }

    CType::IComponent@ getComByType(CRules@ rules, u16 type)
    {
        CType::IComponent@ com;
        
        array<GetComByType@>@ get_com_by_type;
        if(!rules.get("com_by_type", @get_com_by_type)) { Nu::Error("Failed to get get_com_by_type."); return @null; }//Get functions

        for(u16 q = 0; q < get_com_by_type.size(); q++)
        {
            @com = @get_com_by_type[q](type);
            if(com != @null)//If com was found
            {
                com.setType(type);
                return @com;
            }
        }

        return @null;
    }

    //struct
    /*shared class Entity//Holds Components
    {
        u32 id;
        array<CType::IComponent@> components;
    }*/
    
    //1. Entity
    //2. Desired type of component.
    //3. Position of the component in the entity.
    //Gets the pos of the type requested to find. returns true if found, false if not.
    shared bool EntityHasType(array<CType::IComponent@>@ ent, u16 type, u16 &out pos)
    {
        u16 com_count = ent.size();
        for(u16 i = 0; i < com_count; i++)
        {
            if(ent[i] == @null) { continue; }//Skip null component
            if(ent[i].getType() == type)
            {
                pos = i;
                return true;
            }
        }
        return false;
    }
    shared u16 getFreePosInEntity(array<CType::IComponent@>@ ent)
    {
        u16 com_count = ent.size();
        for(u16 i = 0; i < com_count; i++)
        {
            if(ent[i] == @null)
            {
                return i;
            }
        }

        return com_count;
    }

    shared interface IComponent
    {
        void Deserialize(CBitStream@ params);
        void Default();

        u16 getType();
        void setType(u16 _type);
        u32 getID();
        void setID(u32 _id);
    }
    //struct
    shared class Component : IComponent//Holds DATA only.
    {
        u32 id;//Stores it's own id in the pool.
        u16 type;//Stores type of class. The type is currently the hash of the class name.

        //Serialize
        
        void Deserialize(CBitStream@ params)
        {
            
        }
        void Default()
        {
            
        }
        u16 getType()
        {
            return type;
        }
        void setType(u16 _type)
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
        TypeCount
    }
}