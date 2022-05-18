#include "ECSComponentCommon.as"

funcdef void SystemFuncs(itpol::Pool@);//Pool

namespace itsys//Item system
{
    //Entity watcher
    /*shared class System
    {
        System()
        {
            
        }
    }*/
}
//I : The system contains funcdefes for each bit of logic.
//So when you want things to be removed when no health, you give the system a funcdef that handles that.
//sys.addfunc(NoHealthDie(entity)) Something like this? Then in NoHealthDie it checks if that entity has a health component, and kills the ent on it's health reaching 0.
//Probably doesn't work between modules. Thus, cannot use.

//How about, each script that implements it's own components also implements the system logic adjacent to them. In which they get the pool themselves and do ent logic themselves too.
//Makes components not do logic in order? So that's not good. Also might be slow with having to recheck for types constantly in each file.






//Maybe require components that require other components to hold an array that contains the id of the component needed.
//And not allow the component to be added if the required component isn't in the entity. (optional? E.G if an entity has an image but no POS component, the image just draws at 0,0? Somehow?)

//Consider somehow making getting components via id's only. Somehow. Like a seperate array of handles that contains every in order by their id (don't do this. just an example).

//Perhaps re-add the Entity class, and clean up things that involve it?

namespace itpol//Item Pool
{
    shared class Pool
    {
        Pool()
        {
            com_array = array<array<CType::IComponent@>>();
            com_array_ent = array<array<u32>>();


            ent_array = array<array<CType::IComponent@>@>(1, @null);//First entity is null, should never be used.
            ent_array_open = array<bool>(1, false);//First entity is in use.
        }

        array<array<CType::IComponent@>> com_array;
        array<array<u32>> com_array_ent;//Stores every position in the com_array that is not being used by an entity, thus free to take by any other entity. When true, that means the position is free to grab.

        array<array<CType::IComponent@>@> ent_array;
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
                array<CType::IComponent@>@ ent = array<CType::IComponent@>();
                
                ent_array.push_back(@ent);//Create and add new entity
                ent_array_open.push_back(false);//Entity is in use.
            }
            else//Free pos found
            {
                if(getEnt(ent_id).size() != 0) { Nu::Error("Entity has components, yet is tagged free. ent_id = " + ent_id); }
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
            for(u16 i = 0; i < ent_array[ent_id].size(); i++)
            {
                u16 com_type = ent_array[ent_id][i].getType();
                u32 com_id = ent_array[ent_id][i].getID();//Fetch position of component in com_array.

                com_array_ent[com_type][com_id] = 0;//This component is free for use
            }
            ent_array[ent_id].resize(0);

            
            ent_array_open[ent_id] = true;//This entity is free to use.
        }

        //Get entity by id
        array<CType::IComponent@>@ getEnt(u32 id)
        {
            if(id >= ent_array.size())
            {
                Nu::Error("Attempted to reach beyond array bounds"); return @null;
            }
            if(id == 0) { Nu::Error("Attempted to get ent 0. End 0 is reserved. Do not try getting or setting it."); return @null; }
            
            return @ent_array[id];
        }

        u32 EntCount()
        {
            return ent_array.size();
        }

        CType::IComponent@ getCom(u16 type, u32 id, bool print_error = true)
        {
            if(type >= com_array.size())
            {
                if(print_error) { Nu::Error("Attempted to reach beyond array bounds. type is " + type + " Array size is " + com_array.size()); } return @null;
            }
            if(id >= com_array[type].size())
            {
                if(print_error) { Nu::Error("Attempted to reach beyond array bounds. id is " + id + " Array size is " + com_array[type].size()); } return @null;
            }
            return com_array[type][id];
        }

        //Returns id of entity using this component. Returns 0 if this component is free.
        u32 getComEnt(u16 type, u32 id, bool print_error = true)
        {
            if(type >= com_array_ent.size())
            {
                if(print_error) { Nu::Error("Attempted to reach beyond array bounds. type is " + type + " Array size is " + com_array_ent.size()); } return 0;
            }
            if(id >= com_array_ent[type].size())
            {
                if(print_error) { Nu::Error("Attempted to reach beyond array bounds. id is " + id + " Array size is " + com_array_ent[type].size()); } return 0;
            }
            return com_array_ent[type][id];
        }


        u16 getComTypeCount(u16 type)
        {
            if(type >= com_array.size())
            {
                return 0;
            }
            return com_array[type].size();
        }

        u32 TotalComCount()
        {
            u32 q;
            u32 com_count = 0;
            for(u16 i = 0; i < com_array.size(); i++)//For every type
            {
                for(q = 0; q < com_array[i].size(); q++)//For every id of this type
                {
                    com_count++;//Add one to the com_count.
                }
                //Replacing com_count++ with com_count += com_array[i].size() . this might be a good idea.
            }

            return com_count;
        }

        //Finds a free component in the com_array with the given type. returns u32_max if none have been found.
        //Return's id of the component.
        u32 getFreeComByType(u32 type)
        {
            u32 id;
            if(com_array.size() <= type) { return Nu::u32_max(); }//If the type doesn't exist.

            for(u16 id = 0; id < com_array[type].size(); id++)//For every id of this type
            {
                if(com_array_ent[type][id] == 0)//If this position is free
                {
                    //Found a component for use.
                    return id;//Return its id
                }
            }
            //No component found.
            return Nu::u32_max();
        }



        
        //Returns bool array that corresponds with component type array.
        //Positions that are true in this array were already found in the pool, positions that are false need to be created.
        //Assigns pre existing component(s) to the given entity(id) with optional parameters. Returns bool array of which components were correctly added.
        array<bool> AssignByType(u32 ent_id, array<u16> com_type_array, array<CBitStream@> default_params = array<CBitStream@>())
        {
            u16 i;
            u32 q;
            
            array<bool> added_array = array<bool>(com_type_array.size(), false);

            array<CType::IComponent@>@ ent = getEnt(ent_id);


            u32 original_ent_components_size = ent.size();
            u32 duplicate_components = 0;
            //Check for duplicates. Set com_type_array to null if duplicate.
            for(q = 0; q < original_ent_components_size; q++)
            {
                for(i = 0; i < com_type_array.size(); i++)
                {
                    if(ent[q].getType() == com_type_array[i] && com_type_array[i] != CType::Null)//If duplicate found
                    {
                        com_type_array[i] = CType::Null;//Set to null
                        //print("duplicate tallied. TODO, remove this later. It's just to check if this feature works");
                        duplicate_components++;//Tally duplicate component.
                    }
                }
            }
            ent.resize(original_ent_components_size + com_type_array.size() - duplicate_components);


            u32 components_added = 0;
            for(i = 0; i < com_type_array.size(); i++)
            {
                if(com_type_array[i] == CType::Nothing) { Nu::Warning("com_type_array[" + i + "] was 0. as in, Nothing."); continue; }
                if(com_type_array[i] == CType::Null) { continue; }

                u32 com_id = getFreeComByType(com_type_array[i]);//Try finding a free component with this type.
                if(com_id == Nu::u32_max()) { continue; }//Skip if no free component was found.
                
                if(i < default_params.size())//Provided i is within default_params
                {
                    AssignByID(ent_id, com_type_array[i], com_id, original_ent_components_size + components_added, default_params[i]);//Assign component
                }
                else//i not within default_params
                {
                    AssignByID(ent_id, com_type_array[i], com_id, original_ent_components_size + components_added);//Assign component, no default_params
                }


                added_array[i] = true;//Component in this position successfully added.
            
                components_added++;//Tally another component added.
            }

            return added_array;
        }

        bool AssignByType(u32 ent_id, u16 com_type, CBitStream@ default_params = @null)
        {
            //Nu::Warning("Uninplemented");

            return AssignByType(ent_id, array<u16>(1, com_type), array<CBitStream@>(1, default_params))[0];
        }

        void UnassignByType(u32 ent_id, u16 com_type)
        {
            UnassignByType(getEnt(ent_id), com_type);
        }

        void UnassignByType(array<CType::IComponent@>@ ent, u16 com_type)
        {
            u16 com_pos;

            if(CType::EntityHasType(ent, com_type, com_pos))//If the entity has this type
            {
                //ent[com_pos] = @null;
                //TODO, reimplement the entity class. Check and skip every @null component. don't use removeAt, use the above ^
                com_array_ent[ent[com_pos].getType()][ent[com_pos].getID()] = 0;//component is now free for use by any other entity.
                
                ent.removeAt(com_pos);
            }
        }


        //1. ent_id, the position the entity is in the pool
        //2. com_id, the position the component is in the pool.
        //3. com_pos, the position the component goes into the component array in the entity.
        //Assign a specific existing component in pool into a specific position into a specific entity's component array.
        bool AssignByID(u32 ent_id, u16 com_type, u32 com_id, u32 com_pos, CBitStream@ params = @null)
        {
            array<CType::IComponent@>@ ent = getEnt(ent_id);
            if(ent == @null) { Nu::Error("ent was null"); return false; }
            
            if(com_pos == Nu::u32_max())//If com_pos is equal to u32 max value, that means something should be pushed back onto the end of the array.
            {
                com_pos = ent.size();//com_pos is the size of the components array
                ent.resize(com_pos + 1);//Add one to size to allow it to be added.
            }

            return AssignByID(ent, ent_id, com_type, com_id, com_pos, params);
        }

        bool AssignByID(array<CType::IComponent@>@ ent, u32 ent_id, u16 com_type, u32 com_id, u32 com_pos, CBitStream@ params = @null)
        {
            if(ent.size() <= com_pos) { Nu::Error("com_pos out of bounds. com_pos = " + com_pos); return false; }
            if(ent[com_pos] != @null) { Nu::Error("com_pos already has component. com_pos = " + com_pos); return false; }

            CType::IComponent@ com = getCom(com_type, com_id);
            if(com == @null) { Nu::Error("com was null"); return false; }

            //Check for duplicates.
            for(u32 i = 0; i < ent.size(); i++)
            {
                //If duplicate found
                if(ent[i] != @null//If the component in the entity is not null
                && ent[i].getType() == com.getType())//If it's type is equal to the component to be added
                {//Don't let there be more than 1 type in 
                    //print("duplicate found. Type was " + com.getType() + " TODO, remove this message later, this message only exists to check if preventing duplicate adding works.");
                    return false;
                }
            }

            //Assign default parameters, if given.
            if(params != @null)
            {
                params.ResetBitIndex();
                com.Deserialize(params);
            }
            else//No default parameters? Just default the values inside.
            {
                com.Default();
            }

            @ent[com_pos] = @com;

            com_array_ent[com.getType()][com_id] = ent_id;//Component is now in use.
            return true;
        }

        //Pushes component onto the end of the entities component array
        bool AssignByID(u32 ent_id, u16 com_type, u32 com_id, CBitStream@ params = @null)
        {
            return AssignByID(ent_id, com_type, com_id, Nu::u32_max(), params);//Assign component to end.
        }

        //Adds new component to com_array. Returns the component's id.
        u32 AddComponent(CType::IComponent@ com)
        {
            if(com == @null) { Nu::Error("com was null"); return Nu::u32_max(); }

            u16 type = com.getType();

            u16 com_array_size = com_array.size();

            //Add new type arrays to com_array if it does not have them and needs them.
            if(com_array_size <= type)//If the com_array does not have this type
            {
                com_array.resize(type + 1);//Resize it to fit this type in
                com_array_ent.resize(type + 1);//Resize the open com array too
                for(u16 i = com_array_size; i < type + 1; i++)//For every newly made array position that can hold a type.
                {
                    com_array[i] = array<CType::IComponent@>();//Give this position an empty array to start with.
                    com_array_ent[i] = array<u32>();//This too
                }
            }

            u32 com_id = com_array[type].size();

            com_array[type].push_back(com);//New component in type array
            com_array_ent[type].push_back(0);//This component is free to be used.

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