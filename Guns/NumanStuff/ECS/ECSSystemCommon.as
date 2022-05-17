#include "ECSEntityComponent.as"

namespace itsys//Item system
{
    //Entity watcher

}
//I : The system contains funcdefes for each bit of logic.
//So when you want things to be removed when no health, you give the system a funcdef that handles that.
//sys.addfunc(NoHealthDie(entity)) Something like this? Then in NoHealthDie it checks if that entity has a health component, and kills the ent on it's health reaching 0.

namespace itpol//Item Pool
{
    class Pool
    {
        Pool()
        {
            com_array = array<SType::IComponent@>();
            com_array_open = array<bool>();
            com_array_type = array<u32>();


            ent_array = array<SType::Entity@>();
            ent_array_open = array<bool>();
        }

        array<SType::IComponent@> com_array;
        array<bool> com_array_open;//Stores every position in the com_array that is not being used by an entity, thus free to take by any other entity. When true, that means the position is free to grab.
        array<u32> com_array_type;//Stores the type of every position in the com_array.

        array<SType::Entity@> ent_array;
        array<bool> ent_array_open;//Stores every position in the ent_array that is free for taking.

        //Find open position in the ent array. Returns the ent_array size if no free positions were found.
        u32 getEntID()
        {
            for(u32 i = 0; i < ent_array_open.size(); i++)
            {
                if(ent_array_open[i])
                {
                    return i;
                }
            }

            return ent_array_open.size();
        }

        //Returns id of existing free entity. If no free entity found, makes new entity and returns id of it.
        u32 NewEntity()
        {
            u32 ent_id = getEntID();//Entity id
            if(ent_id == ent_array.size())//No free position found?
            {
                SType::Entity@ ent = SType::Entity();
                ent.id = ent_id;
                ent.components = array<SType::IComponent@>();
                
                ent_array.push_back(ent);//Create and add new entity
                ent_array_open.push_back(false);//Entity is in use.
            }
            else//Free pos found
            {
                if(getEnt(ent_id).components.size() != 0) { Nu::Error("Entity has components, yet is tagged free. ent_id = " + ent_id); }
            }

            return ent_id;
        }

        void RemoveEntity(u32 ent_id)
        {
            if(ent_id >= ent_array.size())
            {
                Nu::Error("Attempted to reach beyond array bounds"); return;
            }

            //Clear components in array as free to use for other entities.
            for(u32 i = 0; i < ent_array[ent_id].components.size(); i++)
            {
                u32 com_id = ent_array[ent_id].components[i].getID();//Fetch position of component in com_array.

                //Temporary, just here to make sure everything is working. TODO, remove.
                if(com_array_type[com_id] != ent_array[ent_id].components[i].getType()) { Nu::Error("type of array being cleared is different. com_type = " + com_array_type[com_id] + " ent_com_type = " + ent_array[ent_id].components[i].getType()); }
                
                com_array_open[com_id] = true;//This component is free for use
            }
            ent_array[ent_id].components.resize(0);

            
            ent_array_open[ent_id] = true;//This entity is free to use.
        }

        //Get entity by id
        SType::Entity@ getEnt(u32 id)
        {
            if(id >= ent_array.size())
            {
                Nu::Error("Attempted to reach beyond array bounds"); return @null;
            }
            return ent_array[id];
        }

        SType::IComponent@ getCom(u32 id)
        {
            if(id >= com_array.size())
            {
                Nu::Error("Attempted to reach beyond array bounds"); return @null;
            }
            return com_array[id];
        }

        //Finds a free component in the com_array with the given type. returns u32_max if none have been found.
        //Return's id of the component.
        u32 getFreeComByType(u32 type)
        {
            for(u32 i = 0; i < com_array.size(); i++)
            {
                if(com_array_open[i] == true && com_array_type[i] == type)//If this position is free, and the type we want.
                {
                    //Found a component for use.
                    return i;
                }
            }
            //No component found.
            return Nu::u32_max();
        }



        
        //Returns bool array that corresponds with component type array.
        //Positions that are true in this array were already found in the pool, positions that are false need to be created.
        //Assigns pre existing component(s) to the given entity(id) with optional parameters. Returns bool array of which components were correctly added.
        //Only meant for use on empty entities
        array<bool> Assign(u32 ent_id, array<u32> com_type_array, array<CBitStream@> default_params = array<CBitStream@>())
        {
            u32 i;
            u32 q;
            
            array<bool> added_array = array<bool>(com_type_array.size(), false);

            SType::Entity@ ent = getEnt(ent_id);


            u32 original_ent_components_size = ent.components.size();
            u32 duplicate_components = 0;
            //Check for duplicates. Set com_type_array to null if duplicate.
            for(i = 0; i < original_ent_components_size; i++)
            {
                for(q = 0; q < com_type_array.size(); q++)
                {
                    if(ent.components[i].getType() == com_type_array[q] && com_type_array[q] != SType::Null)//If duplicate found
                    {
                        com_type_array[q] = SType::Null;//Set to null
                        print("duplicate tallied. TODO, remove this later. It's just to check if this feature works");
                        duplicate_components++;//Tally duplicate component.
                    }
                }
            }
            ent.components.resize(original_ent_components_size + com_type_array.size() - duplicate_components);


            u32 components_added = 0;
            for(i = 0; i < com_type_array.size(); i++)
            {
                if(com_type_array[i] == SType::Nothing) { Nu::Warning("com_type_array[" + i + "] was 0. as in, Nothing."); continue; }
                if(com_type_array[i] == SType::Null) { continue; }

                u32 com_id = getFreeComByType(com_type_array[i]);//Try finding a free component with this type.
                if(com_id == Nu::u32_max()) { continue; }//Skip if no free component was found.
                
                Assign(ent_id, com_id, original_ent_components_size + components_added);//Assign component

                added_array[i] = true;//Component in this position successfully added.
            
                components_added++;//Tally another component added.

                SType::IComponent@ com = getCom(com_id);

                if(default_params.size() <= i || default_params[i] == @null)
                {
                    //Default params do not exist
                    com.Default();
                }
                else
                {
                    //Default param exists.
                    com.Deserialize(default_params[i]);//Add default params.
                }
            }

            return added_array;
        }

        bool Assign(u32 ent_id, u32 com_type, CBitStream@ default_params)
        {
            //Nu::Warning("Uninplemented");

            return Assign(ent_id, array<u32>(1, com_type), array<CBitStream@>(1, default_params))[0];
        }



        //1. ent_id, the position the entity is in the pool
        //2. com_id, the position the component is in the pool.
        //3. com_pos, the position the component goes into the component array in the entity.
        //Assign a specific existing component in pool into a specific position into a specific entity's component array.
        bool Assign(u32 ent_id, u32 com_id, u32 com_pos)
        {
            SType::Entity@ ent = getEnt(ent_id);
            if(ent == @null) { Nu::Error("ent was null"); return false; }
            
            if(com_pos == Nu::u32_max())//If com_pos is equal to u32 max value, that means something should be pushed back onto the end of the array.
            {
                ent.components.resize(com_pos + 1);//Add one to size to allow it to be added.
            }

            return Assign(ent, com_id, com_pos);
        }

        bool Assign(SType::Entity@ ent, u32 com_id, u32 com_pos)
        {
            if(ent.components.size() <= com_pos) { Nu::Error("com_pos out of bounds. com_pos = " + com_pos); return false; }
            if(ent.components[com_pos] != @null) { Nu::Error("com_pos already has component. com_pos = " + com_pos); return false; }

            SType::IComponent@ com = getCom(com_id);
            if(com == @null) { Nu::Error("com was null"); return false; }

            //Check for duplicates.
            for(u32 i = 0; i < ent.components.size(); i++)
            {
                //If duplicate found
                if(ent.components[i] != @null//If the component in the entity is not null
                && ent.components[i].getType() == com.getType())//If it's type is equal to the component to be added
                {//Don't let there be more than 1 type in 
                    print("duplicate found. Type was " + com.getType() + " TODO, remove this message later, this message only exists to check if preventing duplicate adding works.");
                    return false;
                }
            }

            @ent.components[com_pos] = @com;

            com_array_open[com_id] = false;//Component is now in use.
            return true;
        }

        //Pushes component onto the end of the entities component array
        bool Assign(u32 ent_id, u32 com_id)
        {
            return Assign(ent_id, com_id, Nu::u32_max());//Assign component to end.
        }

        //Adds new component to com_array. Returns the component's id.
        u32 AddComponent(SType::IComponent@ com, u32 com_type)
        {
            if(com == @null) { Nu::Error("com was null"); return Nu::u32_max(); }

            u32 com_id = com_array.size();

            com_array.push_back(com);//New component in array
            com_array_open.push_back(true);//This component is free to be used.
            com_array_type.push_back(com_type);//This is the component's type.

            com.setID(com_id);

            return com_id;//Return pos/id
        }
    
    
    }
}








/*
Convert WeaponCommon.as in goldspace to more like ecs? Entity Component system.
1. To be more like components, instead of classes that inherit each other? As in you can remove itemaim from weapon, and the weapon will still work but not have a direction it aims in.
Less overhead in uneeded things. Maybe seperate itemaim into simple aiming, and recoil, and deviation. Keep things the weapon wont use not in the class.
2. To seperate the entities, components, and systems. All the logic is functions. None of them are in a class. 
The system is for holding functions that access or modify components in entities.
Components are for holding data and have no functions. DATA only, no functions to access the data either, that goes in the system.
Entities are for holding components.


https://youtu.be/2rW7ALyHaas
*/