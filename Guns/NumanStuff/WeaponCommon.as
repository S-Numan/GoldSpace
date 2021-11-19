#include "NuLib.as";
#include "ModiVars.as";
#include "WeaponModifiers.as";

//Change clip to mag. It's shorter and more accurate based on the logic.

//Sync on change value, or every tick?
//Syncing every tick: 
//Easier
//Syncing on value change:
//More annoying to program.
//Can be used improperly, syncing things more than once or not at all
//Happens sooner, thus less delay for other clients?
//More optimized?
//
//I think I prefer syncing every tick. Less a pain to program on all sides.

//Change debug_color to a CONSOLECOLOUR::SCOLOR




namespace it
{
            
    enum RarityTypes
    {
        Undefined = 0,
        Common = 1,
        Uncommon,
        Rare,
        Legendary,
        Cursed,
        Divine,
        Joke,


        RarityCount
    }

    enum WeaponTypes
    {
        SubmachineGun = 1,
        MachineGun,
        AssaultGun,
        Shotgun,
        MarksmanGun,
        Launcher,
        Special,
        Throwable,
        Melee,
        Close,
        Dual,//Should this be it's own gun type? as in, when you have a pair of guns both are "dual" type guns? Like a single weapon? Or should I keep weapons seperate and have dual weilding be a feature of sorts?
        Pistol,
        Misc,
        Dev,//Developer weapons. For testing purposes.

        //Secondary
        //SecPistol,
        //SecSubmachine,
        //SecShotgun,
        //SecMelee,
        //SecMisc,




        WeaponTypeCount
    }

    enum DamageTypes
    {
        Sharp = 1,
        Blunt,
        Heat,

        DamageTypeCount
    }

    interface IModiStore
    {
        void Init();
        void AfterInit();
        bool Tick(CControls@ controls);
        
        void Serialize(CBitStream@ bs);

        array<Modif32@>@ getF32Array();
        array<Modibool@>@ getBoolArray();
        array<DefaultModifier@>@ getAllModifiers();
        array<f32>@  getVF32();
        array<bool>@ getVF32Sync();
        array<bool>@ getVBool();
        array<bool>@ getVBoolSync();

        u16 getModif32Point(int _name_hash);
        u16 getModif32Point(string _name);
        u16 getModiboolPoint(int _name_hash);
        u16 getModiboolPoint(string _name);

        bool addModifier(DefaultModifier@ _modi);
        bool removeModifier(u16 _pos);
        bool removeModifier(int _name_hash);
        bool removeModifier(string _name);
        void DebugModiVars(bool full_data = false);

        bool hasTag(string tag_string);
        bool hasTag(int tag_hash);
        void addTag(int tag_hash);
        bool removeTag(int tag_hash);
        void DebugTags();

        void DebugVars();

        void setVars();
        void setModiVars();

        void BaseValueChanged();

        u32 getTicksSinceCreated();
    }

    enum ClassTypes
    {
        ClassBaseModiStore = 0,
        ClassActivatable,
        ClassItem,
        ClassItemAim,
        ClassWeapon,

        ClassTypeCount
    }

    class basemodistore : IModiStore
    {
        basemodistore()
        {
            init = false;

            ticks_since_created = Nu::u32_max();

            debug_color = SColor(255, 22, 222, 22);

            @f32_array = @array<Modif32@>();
            @vf32 = @array<f32>();
            @vf32sync = @array<bool>();

            @bool_array = @array<Modibool@>();
            @vbool = @array<bool>();
            @vboolsync = @array<bool>();

            @all_modifiers = @array<DefaultModifier@>();

            tag_array = array<int>();
            tag_array.reserve(5);
        }

        u8 class_type;
        bool init;
        void Init()
        {
            if(!init)//If init has not yet been called. (most derived class)
            {
                init = true;//Init has been called.
                class_type = ClassBaseModiStore;
            }

            setModiVars();
            setVars();

            AfterInit();
        }
        void AfterInit()
        {
            u16 i;

            for(i = 0; i < bool_array.size(); i++)
            {
                if(bool_array[i] == @null) { Nu::Error("Weird problem, bool_array thing was null at " + i); continue; }
                bool_array[i].setBaseValueChangedFunc(@BASE_VALUE_CHANGED(BaseValueChanged));
            }
            for(i = 0; i < f32_array.size(); i++)
            {
                if(f32_array[i] == @null) { Nu::Error("Weird problem, f32_array thing was null at " + i); continue; }
                f32_array[i].setBaseValueChangedFunc(@BASE_VALUE_CHANGED(BaseValueChanged));
            }
        }

        void Serialize(CBitStream@ bs)
        {
            u16 i;

            bs.write_u8(class_type);
            bs.write_u32(ticks_since_created);
            
            for(i = 0; i < f32_array.size(); i++)
            {
                f32_array[i].Serialize(@bs);
            }
            for(i = 0; i < bool_array.size(); i++)
            {
                bool_array[i].Serialize(@bs);
            }
            for(i = 0; i < vf32.size(); i++)
            {
                bs.write_f32(vf32[i]);
            }
            for(i = 0; i < vbool.size(); i++)
            {
                bs.write_bool(vbool[i]);
            }
        }

        void ResizeThings(u16 f32_size, u16 bool_size, u16 vf32_size, u16 vbool_size)
        {
            u16 i;

            f32_array.reserve(f32_size);
            bool_array.reserve(bool_size);

            vf32.resize(vf32_size);
            vf32sync.resize(vf32_size);

            vbool.resize(vbool_size);
            vboolsync.resize(vbool_size);
        }

        bool Tick(CControls@ controls)
        {
            ticks_since_created++;
            
            return true;
        }

        SColor debug_color;

        array<Modif32@>@ f32_array;//Stores Modif32 .. variables? Don't often change. Things like, "max_ammo_count"
        array<Modif32@>@ getF32Array()
        {
            return @f32_array;
        }

        array<Modibool@>@ bool_array;
        array<Modibool@>@ getBoolArray()
        {
            return @bool_array;
        }

        array<DefaultModifier@>@ all_modifiers;//All modifiers
        array<DefaultModifier@>@ getAllModifiers()
        {
            return @all_modifiers;
        }

        array<f32>@ vf32;//Stores normal f32 variables. The intended to be maluable kind. Things like, "current_ammo_count"
        array<f32>@ getVF32()
        {
            return @vf32;
        }        
        array<bool>@ vf32sync;//Every element matches with an element in the f32 array. If the element in this array is true, then this element in the vf32 array is synced to all other clients when it changes.
        array<bool>@ getVF32Sync()
        {
            return @vf32sync;
        }
    

        array<bool>@ vbool;
        array<bool>@ getVBool()
        {
            return @vbool;
        }
        array<bool>@ vboolsync;
        array<bool>@ getVBoolSync()
        {
            return @vboolsync;
        }

        void DebugVars()
        {
            print("ticks_since_created = " + ticks_since_created, debug_color);
        }

        u16 getModif32Point(int _name_hash)
        {
            for(u16 i = 0; i < f32_array.size(); i++)
            {
                if(f32_array[i].getNameHash() == _name_hash)
                {
                    return i;
                }
            }
            return Nu::u16_max();
        }
        u16 getModif32Point(string _name)
        {
            return getModif32Point(_name.getHash());
        }

        u16 getModiboolPoint(int _name_hash)
        {
            for(u16 i = 0; i < bool_array.size(); i++)
            {
                if(bool_array[i].getNameHash() == _name_hash)
                {
                    return i;
                }
            }
            return Nu::u16_max();
        }
        u16 getModiboolPoint(string _name)
        {
            return getModiboolPoint(_name.getHash());
        }


        void BaseValueChanged()//Called if a base value is changed.
        {
            //RefreshPassiveModifiers();
        }
        
        /*void RefreshPassiveModifiers()
        {
            for(u16 i = 0; i < all_modifiers.size(); i++)
            {
                if(all_modifiers[i].getModifierType() != Active)
                {
                    all_modifiers[i].PassiveTick();
                }
            }
        }
        void RefreshActiveModifiers()
        {
            for(u16 i = 0; i < all_modifiers.size(); i++)
            {
                if(all_modifiers[i].getModifierType() != Passive)
                {
                    all_modifiers[i].ActiveTick();
                }
            }
        }*/

        void DebugModiVars(bool full_data = false)
        {
            u16 i;
            print("f32 vars\n", debug_color);
            for(i = 0; i < f32_array.size(); i++)
            {
                if(f32_array[i] == @null) { Nu::Error("Weird problem2, f32_array thing was null at " + i); continue; }
                print("Name[" + i + "] = " + f32_array[i].getName(), debug_color);
                print("BaseValue = " + f32_array[i][BaseValue], debug_color);
                print("CurrentValue = " + f32_array[i][CurrentValue], debug_color);
                if(full_data)
                {
                    print("BeforeAdd = " + f32_array[i][BeforeAdd], debug_color);
                    print("MultValue = " + f32_array[i][MultValue], debug_color);
                    print("AfterAdd = " + f32_array[i][AfterAdd], debug_color);
                }
                print("");
            }
            print("bool vars\n", debug_color);
            for(i = 0; i < bool_array.size(); i++)
            {
                if(bool_array[i] == @null) { Nu::Error("Weird problem2, bool_array thing was null at " + i); continue; }
                print("Name[" + i + "] = " + bool_array[i].getName(), debug_color);
                print("BaseValue = " + bool_array[i][BaseValue], debug_color);
                print("CurrentValue = " + bool_array[i][CurrentValue], debug_color);
                if(full_data)
                {

                }
                print("");
            }
        }

        void setModiVars()
        {

        }

        void setVars()
        {
            
        }


        bool addModifier(DefaultModifier@ _modi)
        {
            _modi.PassiveTick();
            
            all_modifiers.push_back(@_modi);

            return true;
        }
        bool removeModifier(u16 _pos)
        {
            if(_pos >= all_modifiers.size()) { Nu::Error("Reached out of bounds. Attempted to reach " + _pos + " while all_modifiers.size() was " + all_modifiers.size()); return false; }

            all_modifiers[_pos].AntiPassiveTick();
            
            all_modifiers.removeAt(_pos);

            return true;
        }
        bool removeModifier(int _name_hash)
        {
            u16 _pos;
            
            u16 i;
            
            for(i = 0; i < all_modifiers.size(); i++)
            {
                if(all_modifiers[i].name_hash == _name_hash)
                {
                    return removeModifier(i);
                }
            }

            return false;
        }
        bool removeModifier(string _name)
        {
            int _name_hash = _name.getHash();
            return removeModifier(_name_hash);
        }



        array<int> tag_array;

        bool hasTag(string tag_string)
        {
            return hasTag(tag_string.getHash());
        }

        bool hasTag(int tag_hash)
        {
            for(u16 i = 0; i < tag_array.size(); i++)
            {
                if(tag_array[i] == tag_hash)
                {
                    return true;
                }
            }

            return false;
        }

        void addTag(int tag_hash)
        {
            if(tag_hash == 0)
            {
                Nu::Error("Tried to add tag hash with a value of 0");
                return;
            }
            tag_array.push_back(tag_hash);
        }

        //Returns if the tag was succesfully removed
        bool removeTag(int tag_hash)
        {
            for(u16 i = 0; i < tag_array.size(); i++)//For every tag
            {
                if(tag_array[i] == tag_hash)//If it is equal to the provided tag
                {
                    tag_array.removeAt(i);//Remove it
                    return true;//Success
                }
            }
            return false;//No tag found to remove
        }

        void DebugTags()
        {
            print("all tags\n");
            for(u16 i = 0; i < tag_array.size(); i++)
            {
                print("tag_array[" + i + "] == " + tag_array[i], debug_color);
            }
        }

        u32 ticks_since_created;
        u32 getTicksSinceCreated()
        {
            return u32(ticks_since_created);
        }
    }

    enum ActivatableFloats
    {
        UseAfterdelayLeft = 0,
        AmmoLeft,
        CurrentCharge,

        ActivatableFloatCount
    }
    enum ActivatableBools
    {
        ChargeAllowance = 0,
        StopDischarge,        

        ActivatableBoolCount
    }

    

    //this
    //funcdef void USE_CALLBACK(activatable@);
    //While I would prefer to send the handle to the class itself, kag doesn't let me do casting to upper/lower versions of the class.

    //In order: Modif32@ array handle, Modibool@ array handle, DefaultModifier@ array handle.
    funcdef void USE_CALLBACK(array<Modif32@>@, array<Modibool@>@, array<DefaultModifier@>@);

    //terminology
        //USE                   When the user presses the button to use it once.
        //SHOT                  Single activation of the gun. (can happen several times from a single USE)
        //PROJECTILE            Projectiles from the single SHOT of the gun. (weapon only)
    class activatable : basemodistore 
    {
        activatable()
        {
            use_func = @null;

            use_sfx = "";
            empty_total_sfx = "";
        }

        void Init() override
        {
            if(!init)//If init has not yet been called. (most derived class)
            {
                init = true;//Init has been called.
                class_type = ClassActivatable;
                
                ResizeThings(6,//f32
                2,//bool
                ActivatableFloatCount,//vf32
                ActivatableBoolCount//vbool
                );
            }

            basemodistore::Init();
        }

        void AfterInit() override
        {
            basemodistore::AfterInit();
        }

        void setModiVars() override
        {
            //USE how
            f32_array.push_back(@use_afterdelay);
        
            f32_array.push_back(@max_ammo);

            f32_array.push_back(@using_mode);

            //USE effects
            f32_array.push_back(@knockback_per_use);


            //Charging
            f32_array.push_back(@charge_up_time);
            f32_array.push_back(@charge_down_per_tick);
            f32_array.push_back(@charge_down_per_use);
            bool_array.push_back(@allow_non_charged_shots);
            bool_array.push_back(@charge_during_use);

            //MISC
            bool_array.push_back(@remove_on_empty);
        }

        void setVars() override
        {
            vf32[UseAfterdelayLeft] = 0;
            vf32[AmmoLeft] = 0;            
            vf32[CurrentCharge] = 0;
            
            vbool[ChargeAllowance] = false;
            vbool[StopDischarge] = false;
        }

        void BaseValueChanged() override//Called if a base value is changed.
        {
            basemodistore::BaseValueChanged();
        }

        void DebugVars() override
        {
            basemodistore::DebugVars();
            print("use_afterdelay_left = " + getUseAfterdelayLeft(), debug_color);
            print("ammo_left = " + getAmmoLeft(), debug_color);
            print("stop_discharge = " + getStopDischarge(), debug_color);
            print("current_charge = " + getCurrentCharge(), debug_color);
        }

        /*CBitStream@ SyncVars(CRules@ rules)
        {
            CBitStream@ params;
            params.write_f32(getAmmoLeft());
            params.write_bool(getStopDischarge());
            rules.SendCommand(rules.getCommandID("SyncActive"), CBitStream&in params, CPlayer@ player)
        }*/

        


        bool Tick(CControls@ controls) override
        {
            if(!basemodistore::Tick(@controls)){ return false; }

            DelayLogic(@controls);


            UsingLogic(@controls);
            
            return true;
        }

        void DelayLogic(CControls@ controls)
        {
            u8 can_use_basic = CanUseOnce(@controls, false);
            //Charging
            if(!getStopDischarge() && getCurrentCharge() > 0//If this is not currently charging, and current charge is more than 0
            && can_use_basic == 0)//and the base level of CanUseOnce allows being used. Note that this is done before the other delay lowerings. That makes it not lower until a tick after the other delays have reached 0.
            {
                setCurrentCharge(getCurrentCharge() - charge_down_per_tick[CurrentValue], false);//Lower current_charge by charge_down_per_tick
                if(getCurrentCharge() < 0.0f){ setCurrentCharge(0.0f, false); }//If current_charge goes below 0, set it to 0
                syncCurrentCharge();
            }

            if(getStopDischarge())//If this is currently charging
            {
                setStopDischarge(false);//This is no longer charging.
            }

            if(!getChargeAllowance()//If charge allowance is false
                && can_use_basic == 0)//and CanUseOnce allows being used
            {
                if(using_mode[CurrentValue] != 2)//If using_mode is not on release
                {
                    if(controls.isKeyJustPressed(KEY_LBUTTON))//Left button just pressed?
                    {
                        setChargeAllowance(true);//Charge allowance.
                    }
                } 
                else if(controls.isKeyJustReleased(KEY_LBUTTON))//using_mode is on release, and left button was just released
                {
                    setChargeAllowance(true);
                }
            }
            //Charging

            if(getUseAfterdelayLeft() > 0)
            {
                setUseAfterdelayLeft(getUseAfterdelayLeft() - 1.0f);
                if(getUseAfterdelayLeft() < 0.0f){ setUseAfterdelayLeft(0.0f); }
            }
        }

        u8 UsingLogic(CControls@ controls)
        {
            //Gather variables
            //bool left_button = controls.isKeyPressed(KEY_LBUTTON);

            u8 can_use_reason = CanUseOnce(@controls);

            if(can_use_reason == 10// if current_charge is not equal to the required charge_up_time
            || (charge_during_use[CurrentValue] && controls.isKeyPressed(KEY_LBUTTON)))//Or charge_during_use is true and the left button is being pressed.
            {
                f32 _charge_up_time = charge_up_time[CurrentValue];//Get charge_up_time is a temp variable
                if(getCurrentCharge() != _charge_up_time)//If current_charge is not equal to charge up time
                {
                    setCurrentCharge(getCurrentCharge() + 1.0f, false);//Add one to it
                    if(getCurrentCharge() > charge_up_time[CurrentValue]) { setCurrentCharge(charge_up_time[CurrentValue], false); }//If current_charge went past charge_up_time, set it to charge_up_time
                    syncCurrentCharge();
                    setStopDischarge(true);//This is currently charging
                }
            }

            if(can_use_reason == 0)//Use logic
            {
                UseOnce();
            }
            else if(can_use_reason == 11)//Pressing button, but charge_allowance is false.
            {
                setStopDischarge(true);//To prevent charge from going down when holding on semi-auto? I think.
            }
            else if(can_use_reason == 4//no_ammo_no_shots is true, and the current amount of shots plus the amount that would be added went past max ammo. There are no current queued shots
            || can_use_reason == 7)//Or there is simply no ammo left
            {
                UseOnceReduction(false);//act like this was used, but don't use ammo or "use".

                if(empty_total_sfx != "") { Sound::Play(empty_total_sfx); }//Play attempted use sound//TODO, make sfx better. Have position, volume, pitch as variables. Every client should hear the shots.
            }
            else if(can_use_reason == 8)
            {
                error("TEST! REMOVE ME LATER");
            }

            //print("current_charge = " + getCurrentCharge());
            //print("can_use_reason = " + can_use_reason);

            return can_use_reason;
        }

        //
        //CanUse
        //

        //Reason
        //0 == can use
        //1 == use afterdelay is not over
        //2 == use delay is not over
        //3 == there are queued shots, and this isn't supposed to be used while there are queued shots
        //4 == no_ammo_no_shots is true, and the current amount of shots plus the amount that would be added went past max ammo. There are no current queued shots.
        //6 == button not pressed
        //7 == there is no ammo left
        //8 == Same as 4, but there are queued shots.
        //9 == shot afterdelay is not equal to 0 and use_with_shot_afterdelay is false
        //10 == current charge is not adequate, and button is being pressed.
        //11 == presing button, semi auto, but charge_allowance is false.
        //12 == button is pressed but the using_mode doesn't allow firing
        u8 CanUseOnce(CControls@ controls, bool encore = true)
        {
            if(getUseAfterdelayLeft() != 0.0f)//If use afterdelay is not over
            {
                return 1;//Nope
            }
            
            if(encore)
            {
                return CanUsingMode(controls);
            }

            return 0;
        }
        //TODO, use send a keycode too so other buttons than left mouse button can be used.
        u8 CanUsingMode(CControls@ controls)
        {
            return CanTrigger(@controls);
        }
        u8 CanTrigger(CControls@ controls)
        {
            bool button_release = controls.isKeyJustReleased(KEY_LBUTTON);
            bool button_press = controls.isKeyPressed(KEY_LBUTTON);
            bool button_just = controls.isKeyJustPressed(KEY_LBUTTON);

            u8 return_value = 6;
            
            //
            if(using_mode[CurrentValue] == 2)//Use on release?
            {
                if(button_release)//If button release
                {
                    return_value = 0;//Indeed. used on release.
                }
            }
            else if(using_mode[CurrentValue] == 1)//If full auto
            {
                if(button_press)
                {
                    return_value = 0;//Yup
                }
            }
            else if(button_just)//If semi auto, and the button was just pressed.
            {
                return_value = 0;
            }
            
            if(return_value != 0//According to use mode, this cannot be fired
                && button_press)//Butt the button is being pressed.
            {
                return_value = 12;//button is pressed but the using_mode doesn't allow firing
            }

            //Charging

            if(charge_up_time[CurrentValue] != 0 &&//If charging is enabled
                (return_value == 0 || return_value == 12))//If the button is being triggered, or the button is pressed but the using_mode doesn't allow firing.
            {
                if(!allow_non_charged_shots[CurrentValue]//If this cannot shoot non charged shots
                    && getCurrentCharge() != charge_up_time[CurrentValue])//and current_charge is not adequate.
                {
                    return 10;//Back out of there
                }
                //Can shoot
                else if(getChargeAllowance())//charge_allowance was true, so it is allowed
                {
                    return_value = 0;//Forward!
                }
                else//Charge allowance is false
                {
                    return_value = 11;//Presing button, but charge_allowance is false.
                }
            }
            //Charging

            if(return_value == 0)//If this was going to return true
            {
                if(getAmmoLeft() == 0.0f)//And there was no ammo left
                {
                    return 7;//Nada
                }
            }
            return return_value;
        }


        //
        //CanUse
        //



        private USE_CALLBACK@ use_func;//This function gets called when this item is used
        void addUseListener(USE_CALLBACK@ value)
        {
            @use_func = @value;
        }
        void UseOnce(bool ammo_too = true)
        {
            UseOnceReduction(ammo_too);
            
            if(use_func != @null)//If the function to call exists
            {
                use_func(@f32_array, @bool_array, @all_modifiers);//Call it
                //TODO Apply knockback per use somehow
            }

            if(use_sfx != "")
            {
                Sound::Play(use_sfx);//TODO, make sfx better. Have position, volume, pitch as variables. Every client should hear the shots.
            }
        }
        void UseOnceReduction(bool ammo_too)
        {
            setUseAfterdelayLeft(use_afterdelay[CurrentValue]);
        
            if(ammo_too)
            {
                setAmmoLeft(getAmmoLeft() - 1.0f);
            }

            setCurrentCharge(getCurrentCharge() - charge_down_per_use[CurrentValue], false);
            if(getCurrentCharge() < 0) { setCurrentCharge(0.0f, false); }
            syncCurrentCharge();
            
            if(getChargeAllowance() && using_mode[CurrentValue] != 1)//If charge_allowance is true, and the using_mode is not full auto
            {
                setChargeAllowance(false);//No more charge allowance
            }
        }

        Modif32@ using_mode = Modif32("using_mode", 0);//0 means semi-auto. 1 means you can hold the button to keep automatically shooting when able (full auto). 2 means on_release, this only works when you release the button.


        Modibool@ remove_on_empty = Modibool("remove_on_empty", true);//Kills this when no more use uses are left

        Modif32@ use_afterdelay = Modif32("use_afterdelay", 0.0f);//basically rate of fire. How frequently can this be used? This many ticks before it can be reused.

        f32 getUseAfterdelayLeft()
        {
            return vf32[UseAfterdelayLeft];
        }
        void setUseAfterdelayLeft(f32 value)
        {
            vf32[UseAfterdelayLeft] = value;
        }

        Modif32@ max_ammo = Modif32("max_ammo", 1.0f);//Max amount of times this can be used

        f32 getAmmoLeft()
        {
            return vf32[AmmoLeft];
        }
        void setAmmoLeft(f32 value, bool sync_value = true)
        {
            vf32[AmmoLeft] = value;
            if(sync_value){ syncAmmoLeft(); }
        }
        void syncAmmoLeft()
        {
            //TODO: sync somehow.
        }
        
        Modif32@ knockback_per_use = Modif32("knockback_per_use", 0.0f);//pushes you around when activated, specifically it pushes you away from the direction your mouse is aiming.



        //Charging
    
            Modif32@ charge_up_time = Modif32("charge_up_time", 0.0f);//Time the player must be holding the use button to activate a use of this. Think spinup time for a minigun.

            //Value that stores the current charge
            f32 getCurrentCharge()
            {
                return vf32[CurrentCharge];
            }
            void setCurrentCharge(f32 value, bool sync_value = true)
            {
                vf32[CurrentCharge] = value;
                if(sync_value) { syncCurrentCharge(); }
            }
            void syncCurrentCharge()
            {

            }

            //When this is true, charge_down_per_tick will not lower current_charge
            bool getStopDischarge()
            {
                return vbool[StopDischarge];
            }
            void setStopDischarge(bool value, bool sync_value = true)
            {
                vbool[StopDischarge] = value;
                if(sync_value) { syncStopDischarge(); }
            }
            void syncStopDischarge()
            {
                
            }

            Modif32@ charge_down_per_tick = Modif32("charge_down_per_tick", 1.0f);//Amount the float above charge_up_time is subtracted by every tick. Does not take effect while charging up.

            Modif32@ charge_down_per_use = Modif32("charge_down_per_use", 99999.0f);//How much charge goes down per tick. Charge does not go below 0.

            Modibool@ allow_non_charged_shots = Modibool("allow_non_charged_shots", false);//If this is false, this cannot shoot until current_charge is equal to charge_up_time. If this is true, this can shoot independently of how much charge this has.


            //Charge uses can only happen when this is true. This is turned false after a charge use, and is only turned true after the button is triggered again.
            bool getChargeAllowance()
            {
                return vbool[ChargeAllowance];
            }
            void setChargeAllowance(bool value)
            {
                vbool[ChargeAllowance] = value;
            }

            Modibool@ charge_during_use = Modibool("charge_during_use", false);//If this is true, this continues charging even when in use and not being able to use again. If this is false, this retains it's charge after using, but does not go higher or lower. 

        //Charging


        //SFX
            string use_sfx;
            
            string empty_total_sfx;//When this has 0 ammo total but a use is attempted.
        //SFX
        

    }
    
    enum ItemFloats
    {
        QueuedShots = ActivatableFloatCount,
        ShotAfterdelayLeft,

        ItemFloatCount
    }
    enum ItemBools
    {
        ItemBoolCount = ActivatableBoolCount
    }

    //In order: Angle, Modif32@ array handle, Modibool@ array handle, DefaultModifier@ array handle.
    funcdef void SHOT_CALLBACK(f32, array<Modif32@>@, array<Modibool@>@, array<DefaultModifier@>@);

    class item : activatable
    {
        item()
        {
            shot_func = @null;
            last_shot = Nu::u32_max();

            shot_sfx = "";
            empty_total_ongoing_sfx = "";
        }
        void Init() override
        {
            if(!init)//If init has not yet been called. (most derived class)
            {
                init = true;//Init has been called.
                class_type = ClassItem;
                
                ResizeThings(6 + 6,//f32
                2 + 3,//bool
                ItemFloatCount,//vf32
                ItemBoolCount//vbool
                );
            }
            
            activatable::Init();
        }
        void AfterInit() override
        {
            activatable::AfterInit();
        }

        void setModiVars() override
        {
            activatable::setModiVars();
        
            //Shots
            f32_array.push_back(@ammo_per_shot);
            f32_array.push_back(@knockback_per_shot);
            f32_array.push_back(@shots_per_use);
            f32_array.push_back(@shot_afterdelay);

            //Misc
            f32_array.push_back(@morium_cost);
            f32_array.push_back(@rarity);
            bool_array.push_back(@use_with_queued_shots);
            bool_array.push_back(@use_with_shot_afterdelay);
            bool_array.push_back(@no_ammo_no_shots);
        }

        void setVars() override
        {
            activatable::setVars();

            vf32[QueuedShots] = 0;
            vf32[ShotAfterdelayLeft] = 0;
        }

        void BaseValueChanged() override//Called if a base value is changed.
        {
            activatable::BaseValueChanged();
        }
        
        void DebugVars() override
        {
            activatable::DebugVars();
            print("queued_shots = " + vf32[QueuedShots], debug_color);
            print("shot_afterdelay_left = " + vf32[ShotAfterdelayLeft], debug_color);
        }


        bool Tick(CControls@ controls) override
        {
            if(!activatable::Tick(@controls)){ return false; }

            ShootingLogic();
            return true;
        }

        void DelayLogic(CControls@ controls) override
        {
            activatable::DelayLogic(@controls);

            if(last_shot != Nu::u32_max())
            {
                last_shot++;
            }

            if(vf32[ShotAfterdelayLeft] > 0)
            {
                vf32[ShotAfterdelayLeft] -= 1.0f;
                if(vf32[ShotAfterdelayLeft] < 0.0f){ vf32[ShotAfterdelayLeft] = 0.0f; }
            }
        }

        u8 ShootingLogic()
        {
            while(true)//For shooting several queued shots in one tick
            {
                //Do shot logic
                u8 can_shoot_reason = CanShootOnce();
                if(can_shoot_reason == 1)//No queued up shots
                {
                    
                }
                else if(can_shoot_reason == 2)//delay between shots
                {

                }
                else if(can_shoot_reason == 0)//Can shoot
                {
                    ShootOnce();
                    if(vf32[ShotAfterdelayLeft] == 0){ continue; }//If there is literally no shot_afterdelay, shoot again right here right now.
                }
                else if(can_shoot_reason == 5)//Out of ammo from ongoing queued up shots
                {
                    //TODO: have a bool that changes how this behaves. If the bool is true; it removes all queued shots. If the bool is false; it behaves like it was shooting normally, just nothing was triggered and no heat was generated.
                    vf32[QueuedShots] = 0;//Remove all queued up shots.
                    if(empty_total_ongoing_sfx != "") { Sound::Play(empty_total_ongoing_sfx); }
                }

                return can_shoot_reason;
            }

            return 255;
        }



        //
        //Shoot
        //
        
        //Reason
        //0 == can shoot
        //1 == no queued shots
        //2 == delay between shots
        //5 == out of ammo from ongoing queued up shots
        u8 CanShootOnce()
        {
            if(vf32[QueuedShots] == 0)
            {
                return 1;
            }
            if(vf32[ShotAfterdelayLeft] > 0)
            {
                return 2;
            }
            if(getAmmoLeft() - ammo_per_shot[CurrentValue] < 0.0f)//If there is not enough ammo for another shot
            {
                return 5;
            }
            return 0;
        }


        private SHOT_CALLBACK@ shot_func;//This function gets called when this item is shot
        void addShotListener(SHOT_CALLBACK@ value)
        {
            @shot_func = @value;
        }
        
        void ShootOnce(bool call_func = true)
        {
            setAmmoLeft(getAmmoLeft() - ammo_per_shot[CurrentValue]);
            vf32[QueuedShots] -= 1;
            last_shot = 0;

            if(vf32[ShotAfterdelayLeft] != 0)
            {
                Nu::Warning("shot_afterdelay_left was not 0 when shooting (was " + vf32[ShotAfterdelayLeft] + "), something somewhere somehow is wrong. Good luck.");
            }
            vf32[ShotAfterdelayLeft] = shot_afterdelay[CurrentValue];
            if(getAmmoLeft() < 0.0f)
            {
                Nu::Warning("ammo_left went below 0 (was " + getAmmoLeft() + "), something somewhere somehow is wrong. Good luck.");
            }

            if(call_func && shot_func != @null)//If the function to call exists
            {
                shot_func(0.0f, @f32_array, @bool_array, @all_modifiers);//Call it
                //TODO Apply knockback per shot somehow
            }

            if(shot_sfx != "")
            {
                Sound::Play(shot_sfx);//TODO, make sfx better. Have position, volume, pitch as variables. Every client should hear the shots.
            }
        }

        //
        //Shoot
        //

        //
        //Use
        //

        u8 CanUseOnce(CControls@ controls, bool encore = true) override
        {
            u8 can_use_reason = activatable::CanUseOnce(@controls, false);
            if(can_use_reason != 0) { return can_use_reason; }//If something was wrong previously, just stop there.
            //Continue
            if(use_with_queued_shots[CurrentValue] == false && vf32[QueuedShots] != 0)//If this isn't supposed to be used with queued shots, and there are queued shots
            {
                return 3;//Can't be used right now
            }
            if(use_with_shot_afterdelay[CurrentValue] == false && vf32[ShotAfterdelayLeft] != 0)//If this isn't supposed to be used when shot_afterdelay_left is not equal to 0
            {
                return 9;//STAP
            }
            
            if(encore)
            {
                return CanUsingMode(@controls);
            }
            return 0;
        }

        u8 CanTrigger(CControls@ controls) override
        {
            u8 return_value = activatable::CanTrigger(@controls);
            if(return_value == 0)//If this was going to return true
            {
                //No ammo logic.
                if(no_ammo_no_shots[CurrentValue] == true//and if no_ammo_no_shots is true
                && vf32[QueuedShots] * ammo_per_shot[CurrentValue] + shots_per_use[CurrentValue] * ammo_per_shot[CurrentValue] > getAmmoLeft())//and if the current amount of shots plus the amount that would be added would go past max ammo.
                {
                    if(vf32[QueuedShots] != 0)//Queued shots still going on?
                    {
                        return 8;//Bye
                    }
                    else//No queued shots
                    {
                        return 4;//Cease thy use!
                    }
                }       
            }
            return return_value;
        }

        void UseOnce(bool ammo_too = true) override
        {
            activatable::UseOnce(false);

            vf32[QueuedShots] += shots_per_use[CurrentValue];//Queue up a shot
        }

        //
        //Use
        //



        Modif32@ morium_cost = Modif32("morium_cost", 0.0f);//Morium cost per use when creating ammo for the activatable. a cost below 0 makes this activatable not rechargable

        Modif32@ rarity = Modif32("rarity", Undefined);//Should be an enum.


        //SHOTS
        //
            //EFFECTS
            //
                Modif32@ ammo_per_shot = Modif32("ammo_per_shot", 1.0f);//Uses taken out per shot

                Modif32@ knockback_per_shot = Modif32("knockback_per_shot", 0.0f);//Amount the user is knocked back upon a shot going off.
            //
            //EFFECTS


            //AMOUNT
            //
                //vf32[QueuedShots]//Value that holds shots waiting to be activated. Think burst fire weapons. You cannot fire(use) when there are still shots queued up.

                Modif32@ shots_per_use = Modif32("shots_per_use", 1.0f);//Amount of shots per use.
                
                Modibool@ use_with_queued_shots = Modibool("use_with_queued_shots", false);//When this is false, this cannot be used again until there are no more queued shots left. When this is true, you can continue using this and adding more queued shots.

                Modibool@ use_with_shot_afterdelay = Modibool("use_with_shot_afterdelay", false);//When this is false, you cannot use the weapon when shot afterdelay is not 0. When this is true, you can queue up more shots with less care.

                Modibool@ no_ammo_no_shots = Modibool("no_ammo_no_shots", true);//If this is true, using this wont setup queued shots if the amount of queued up shots left would pass ammo_left. If this is false, it will glady setup 3 shots even if there is only 2 ammo left.
                
                Modif32@ shot_afterdelay = Modif32("shot_afterdelay", 0.0f);//Only relevant if the stat above is more than 0
                //vf32[ShotAfterdelayLeft];
            //
            //AMOUNT


            u32 last_shot;//How many ticks ago was the last shot.





        //
        //Shots




        //SFX
            string shot_sfx;

            string empty_total_ongoing_sfx;//Out of ammo from ongoing queued up shots
        //SFX
    }


    enum ItemAimFloats
    {
        CurrentSpread = ItemFloatCount,

        ItemAimFloatCount
    }
    enum ItemAimBools
    {
        ItemAimBoolCount = ItemBoolCount,
    }

    class itemaim : item
    {
        itemaim()
        {
            
        }
        void Init() override
        {
            if(!init)//If init has not yet been called. (most derived class)
            {
                init = true;//Init has been called.
                class_type = ClassItemAim;
                
                ResizeThings(6 + 6 + 5,//f32
                2 + 3 + 0,//bool
                ItemAimFloatCount,//vf32
                ItemAimBoolCount//vbool
                );
            }
            item::Init();
        }
        void AfterInit() override
        {
            item::AfterInit();
        }

        void setModiVars() override
        {
            item::setModiVars();

            //Shots
            f32_array.push_back(@random_shot_spread);
            f32_array.push_back(@min_shot_spread);
            f32_array.push_back(@max_shot_spread);
            f32_array.push_back(@spread_gain_per_shot);
            f32_array.push_back(@spread_loss_per_tick);        
        }
        void setVars() override
        {
            item::setVars();
            
            vf32[CurrentSpread] = 0;
        }
        
        void BaseValueChanged() override//Called if a base value is changed.
        {
            item::BaseValueChanged();
        }
        
        void DebugVars() override
        {
            item::DebugVars();
        }


        bool Tick(CControls@ controls) override
        {
            if(!item::Tick(@controls)){ return false; }

            return true;
        }


        void DelayLogic(CControls@ controls) override
        {
            item::DelayLogic(@controls);

            //Lower current_spread by spread_loss_per_tick if above min_shot_spread
            if(vf32[CurrentSpread] > min_shot_spread[CurrentValue])
            {
                vf32[CurrentSpread] -= spread_loss_per_tick[CurrentValue];
            }
            //If gone below min_shot_spread, set current_spread to min_shot_spread
            if(vf32[CurrentSpread] < min_shot_spread[CurrentValue])
            {
                vf32[CurrentSpread] = min_shot_spread[CurrentValue];
            }
            //If gone above max_shot_spread, set current_spread to max_shot_spread
            if(vf32[CurrentSpread] > max_shot_spread[CurrentValue])
            {
                vf32[CurrentSpread] = max_shot_spread[CurrentValue];
            }
        }



        void ShootOnce(bool call_func = true)
        {
            item::ShootOnce(false);//Do not call the function

            if(call_func && shot_func != @null)//If the function to call exists
            {
                f32 random_deviation = Nu::getRandomF32(random_shot_spread[CurrentValue] * -0.5, (random_shot_spread[CurrentValue] * 0.5f));

                f32 random_aim = Nu::getRandomF32(vf32[CurrentSpread] * -0.5f, vf32[CurrentSpread] * 0.5f);

                print("\nrandom_deviation = " + random_deviation);
                print("current_spread = " + vf32[CurrentSpread]);
                print("random_aim = " + random_aim);

                shot_func(random_aim + random_deviation, @f32_array, @bool_array, @all_modifiers);//Call it
                //TODO Apply knockback per shot somehow
            }

            vf32[CurrentSpread] += spread_gain_per_shot[CurrentValue];
            if(vf32[CurrentSpread] > max_shot_spread[CurrentValue])
            {
                vf32[CurrentSpread] = max_shot_spread[CurrentValue];
            }
        }



        //AIMING
            //
            //vf32[CurrentSpread];

            Modif32@ random_shot_spread = Modif32("random_shot_spread", 0.0f);//Value that changes direction of where the shot is aimed by picking a value between 0 and this variable. Half chance to invert the value. Applies this to the direction the shot would be going.

            Modif32@ min_shot_spread = Modif32("min_shot_spread", 0.0f);//Min deviation from aimed point for shot.
            Modif32@ max_shot_spread = Modif32("max_shot_spread", 9999.0f);//Max deviation from aimed point for shot.

            Modif32@ spread_gain_per_shot = Modif32("spread_gain_per_shot", 0.0f);//(not per projectile. Per SHOT) (Otherwise known as recoil) (capped to max_shot_spread)

            Modif32@ spread_loss_per_tick = Modif32("spread_loss_per_tick", 0.0f);// (capped to min_projectile_spread)

            //Multiplier applied to each value when crouching? Nah
        //
        //AIMING


    }



    /*



    class weapon : itemaim
    {

        //Jam chance
        //Peanut butter cha- . No
        //Jam size
        //Jam unjam per reload press
        //See SYNTHETIK for how jamming works


        weapon()
        {
            Init();

            
            bool_array.reserve(10);
            f32_array.reserve(30);
            setModiVars();


            AfterInit();

            reload_sfx = "Reload.ogg";
            projectile_sfx = "";
            equip_weapon_sfx = "";
            empty_clip_sfx = "";
            empty_clip_use_sfx = "";
            equip_weapon_sfx = "";
            flesh_hit_sfx = "ArrowHitFlesh.ogg";
            object_hit_sfx = "BulletImpact.ogg";
        }

        bool Tick() override
        {
            if(!activatable::Tick()) { return false; }


            return true;
        }








        void BaseValueChanged() override
        {
            activatable::BaseValueChanged();
            print("weapon base value changed");

        }




        private float[] max_ammo = array<float>(2, 0.0f);
        float getMaxAmmo()//Gets the maximum amount of ammo that this weapon can hold. (not including ammo in clip)
        {
            return max_ammo[1];
        }
        void setMaxAmmo(float value)
        {
            max_ammo[1] = value;
            BaseValueChanged();
        }

        float getTotalAmmo()//Gets the current amount of ammo that this weapon is holding. (not including ammo in clip)
        {
            return max_ammo[0];
        }
        void setTotalAmmo(float value)
        {
            max_ammo[0] = value;
        }

        float getClipSize(bool get_base = false)
        {
            return getMaxUseCount(get_base);
        }
        void setClipSize(float value)//If the clip size is 0, this gun instead draws from max_ammo. As this gun doesn't have a clip.
        {
            setMaxUseCount(value);
        }

        float getAmmoInClip()
        {
            return use_count_left;
        }
        void setAmmoInClip(float value)
        {
            use_count_left = value;
        }

        float getFireRate(bool get_base = false)
        {
            return use_afterdelay[get_base ? 1 : 0];
        }
        void setFireRate(float value)
        {
            use_afterdelay[1] = value;
            BaseValueChanged();
        }


        private float[] unequip_time = array<float>(2, 0.0f);//Ticks taken to unequip a weapon
        float getUnequipTime(bool get_base = false)
        {
            return unequip_time[get_base ? 1 : 0];
        }
        void setUnequipTime(float value)
        {
            unequip_time[1] = value;
            BaseValueChanged();
        }

        private float[] equip_time = array<float>(2, 0.0f);//Ticks taken to equip a weapon
        float getEquipTime(bool get_base = false)
        {
            return equip_time[get_base ? 1 : 0];
        }
        void setEquipTime(float value)
        {
            equip_time[1] = value;
            BaseValueChanged();
        }


        //RELOADING
        //

        private float[] ammo_to_clip_per_reload = array<float>(2, 1.0f);//Amount of ammo added to the clip per reload. 0.0f means max ammo that can be added is added. (I.E default)
        //Weapon will continue to reload until clip is full, unless the weapon is used.


            private float[] reload_time = array<float>(2, 0.0f);//Time taken to reload a clip upon pressing the reload button. (in ticks(float ticks, don't question it.))
            float getReloadTime(bool get_base = false)
            {
                return reload_time[get_base ? 1 : 0];
            }
            void setReloadTime(float value)
            {
                reload_time[1] = value;
                BaseValueChanged();
            }

            private float reload_time_left;//If this is above 0, the weapon is still reloading. It ticks down by one every 
            float getReloadTimeLeft()
            {
                return reload_time_left;
            }
            void setReloadTimeLeft(float value)
            {
                reload_time_left = value;
            }
            bool isReloading()
            {
                if(getReloadTimeLeft() > 0.0f)
                {
                    return true;
                }

                return false;
            }

            private bool auto_reload;//If this is true, the weapon will automatically reload upon reaching a clip size of 0.
            bool getAutoReload()
            {
                return auto_reload;
            }
            void setAutoReload(bool value)
            {
                auto_reload = value;
            }

        //
        //RELOADING

        //HEAT
        //
            bool overheating;//Is this weapon currently overheated? This weapon will be unable to output any shots while this value is true. This value will only stop being true once "heat" reaches 0.

            float heat;//Current heat

            float max_heat;//Upon the value "heat" going above this value the bool "overheating" turns true.

            float overheating_multiplier;//The multiplier applied to "heat_loss_per_tick" when the bool "overheating" is true.

            float heat_loss_per_tick;

            float heat_gain_per_shot;

            float damage_on_overheat;//How much the user is damaged when the gun overheats.
        //
        //Heat

        //PROJECTILES            //Maybe put all projectile stuff in it's own class, so each gun can have it's own projectile class? I.E for the charge pistol. Two projectile types for one gun.
        //
            //EFFECTS
            //
                bool projectile_host_inertia;//If this is true, the velocity of the host is applied to the projectile on its creation.

                array<GunProjectile@> projectile;//By default the gun shoot's the 0'th projectile in this array.
            //
            //EFFECTS

            //AMOUNT
            //
                float queued_projectiles;//Value that holds projectiles waiting to escape from the gun. Think shotgun like weapons.
                float projectiles_per_shot;//Amount of projectiles per shot.
                float projectile_afterdelay;//Only relevant if the stat above is more than 1. Delay in ticks between each projectile
            //
            //AMOUNT

            //AIMING
            //
                float random_projectile_spread;//After random_shot_spread is applied, this applies to every projectile seperately. Otherwise known as deviation.
                //If random_shot_spread changes the aimed direction for every projectile, this changes the aim direction for each projectile individually.

                float same_tick_forced_spread;//When two projectiles are shot in the same tick, this forces each projectile to by default aim x amount apart from each other.
                //With three projectiles and a distance of 3.0f, the middle projectile will shot like normal, but the other two projectiles will be equally apart like a shotgun but without randomness.
                //random_projectile_spread is applied after this.
            //
            //AIMING

            //SFX
            //
                string projectile_sfx;//When created this sound is played.
            //
            //SFX
        //
        //PROJECTILES

        //SFX
        //
            string reload_sfx;

            string empty_clip_sfx;//When the gun has 0 ammo in the clip.

            string empty_clip_use_sfx;//When the gun is attempted to use when there is no ammo in the clip, and auto_reload is false.

            string equip_weapon_sfx;

            string flesh_hit_sfx;

            string object_hit_sfx;
        //
        //SFX

    }

    class ranged : weapon
    {

    }
    class melee : weapon
    {
        float attack_range;

        float attack_width;//When this is 0, the attack is a straight infinitely small line.
    }




    class GunProjectile
    {
        //HIT EFFECTS
        //

            float damage;//below 0 heals

            float terrain_damage;//Amount it damages terrain

            float damage_shield_mult;//Multiplier to damage against shields

            float damage_health_mult;//Multiplier to damage against health

            float stun_chance;//Chance to stun targets

            float stun_length;//Length that targets are stunned, in ticks.

            float knockback;//How much the projectile pushes a target back upon hitting.
            
            float pierce_count;//Amount of times the projectile can pierce enemies without dying. default 0

            u8 damage_type;//See damage type enum.

        //
        //HIT EFFECTS

        float friendly_fire_damage;//Mutliplier to the amount of damage hitting an ally with this does. Setting this value below 0 makes this projectile not even hit friendlies.

        //TRAVEL EFFECTS
        //

            float speed;//Below 0 is hitscan.

            float speed_loss_per_tick;//Amount the projectile speed lowers per tick of flying through the air. (can be negative to increase speed over time.)

            float gravity_mult;//default is 1.0f.

            float max_distance;//Distance the projectile can travel before dying. 0 or below is max.

            float lifespan;//Amount of ticks the projectile can stay alive before it is killed. 0 or below is max.

            float bounce_count;//Amount of times the projectile can bounce. default 0

        //
        //TRAVEL EFFECTS

        
        //AOE
        //
        
            float aoe_radius;//Amount of distance the aoe goes from the projectile.

            float aoe_damage;//Amount of damage the aoe does.

            float aoe_terrain_damage;//Amount the aoe damages the terrain.

            float aoe_knockback;//How much stuff is knocked away from the center point of the aoe.
            
            float aoe_stun_chance;

            float aoe_stun_length;

        //
        //AOE
    }


    //360 weapon aiming is done like this
    //Rotate from the back part of the gun from there, keeping the back of the gun in place. Possibly rotate from even farther behind the back of the gun.
    //See archer bow. But try putting the bow a bit further forward instead.
    //Scoot the point of rotation around based on the aim position if needed.
*/
}