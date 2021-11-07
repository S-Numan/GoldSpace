#include "NuLib.as";
#include "ModiVars.as";
#include "WeaponModifiers.as";

//Tuple
//1: Current Stat. 2: Base Stat.

//Change clip to mag. It's shorter and more accurate based on the logic.

namespace It
{

    /*::Weapon stats::
            explode size
            explode damage
            explode damage terrain (y/n)*/
            
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

    class basemodistore
    {
        void Init()
        {
            ticks_since_created = Nu::u32_max();

            array<Modif32@> _f32_array = array<Modif32@>();
            @f32_array = @_f32_array;

            array<Modibool@> _bool_array = array<Modibool@>();
            @bool_array = @_bool_array;

            array<DefaultModifier@> _all_modifiers = array<DefaultModifier@>();
            @all_modifiers = @_all_modifiers;
        }
        void AfterInit()
        {
            u16 i;

            for(i = 0; i < bool_array.size(); i++)
            {
                bool_array[i].setBaseValueChangedFunc(@BASE_VALUE_CHANGED(BaseValueChanged));
            }
            for(i = 0; i < f32_array.size(); i++)
            {
                f32_array[i].setBaseValueChangedFunc(@BASE_VALUE_CHANGED(BaseValueChanged));
            }
        }

        bool Tick()
        {
            ticks_since_created++;
            
            return true;
        }

        array<Modif32@>@ f32_array;
        u16 getModif32Point(string _name)//TODO make a hash method for this too.
        {
            int _name_hash = _name.getHash();
            for(u16 i = 0; i < f32_array.size(); i++)
            {
                if(f32_array[i].getNameHash() == _name_hash)
                {
                    return i;
                }
            }
            return Nu::u16_max();
        }
        array<Modibool@>@ bool_array;
        u16 getModiboolPoint(string _name)
        {
            int _name_hash = _name.getHash();
            for(u16 i = 0; i < bool_array.size(); i++)
            {
                if(bool_array[i].getNameHash() == _name_hash)
                {
                    return i;
                }
            }
            return Nu::u16_max();
        }


        void BaseValueChanged()//Called if a base value is changed.
        {
            print("basemodistore base value changed");
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


        bool addModifier(DefaultModifier@ _modi)
        {
            _modi.PassiveTick();
            
            all_modifiers.push_back(@_modi);

            return true;
        }
        bool removeModifier(u16 _pos)
        {
            if(_pos >= all_modifiers.size()) { Nu::Error("Reached out of bounds"); return false; }

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


        array<DefaultModifier@>@ all_modifiers;//All modifiers

        u32 ticks_since_created;
    }

    //In order: this, params.
    funcdef void USE_CALLBACK(activatable@, CBitStream@);

    //terminology
        //USE                   When the user presses the button to use it once.
        //SHOT                  Single activation of the gun. (can happen several times from a single USE)
        //PROJECTILE            Projectiles from the single SHOT of the gun. (weapon only)
    class activatable : basemodistore 
    {
        activatable()
        {
            Init();

            
            bool_array.reserve(5);
            f32_array.reserve(10);
            setModiVars();
            

            AfterInit();
        }

        void Init()
        {
            basemodistore::Init();

            use_func = @null;
            queued_shots = 0;
            use_afterdelay_left = 0;
            use_delay_left = 0;
        }

        void setModiVars()
        {
            //USE how
            f32_array.push_back(@use_afterdelay);
            f32_array.push_back(@use_delay);
        
            f32_array.push_back(@max_ammo_count);
            ammo_count_left = max_ammo_count[CurrentValue];

            bool_array.push_back(@use_on_release);
            f32_array.push_back(@using_mode);


            //Shots
            f32_array.push_back(@ammo_per_shot);
            f32_array.push_back(@knockback_per_shot);
            f32_array.push_back(@shots_per_use);
            f32_array.push_back(@ticks_between_shots);

            //MISC
            bool_array.push_back(@remove_on_empty);
            f32_array.push_back(@morium_cost);
        }

        void BaseValueChanged() override//Called if a base value is changed.
        {
            basemodistore::BaseValueChanged();
            print("activatable base value changed");
        }


        bool Tick(CControls@ controls)
        {
            if(!basemodistore::Tick()){ return false; }

            DelayLogic();


            UseLogic(controls);

            
            return true;
        }

        void DelayLogic()
        {
            if(use_afterdelay_left > 0)
            {
                use_afterdelay_left -= 1.0f;
                if(use_afterdelay_left < 0.0f){ use_afterdelay_left = 0.0f; }
            }
            if(use_delay_left > 0)
            {
                use_delay_left -= 1.0f;
                if(use_delay_left < 0.0f){ use_delay_left = 0.0f; }
                
                if(use_delay_left == 0.0f)
                {
                    UseOnce();
                }
            }
        }

        void UseLogic(CControls@ controls)
        {
            //Gather variables
            //bool left_button = controls.isKeyPressed(KEY_LBUTTON);
            //bool left_button_release = controls.isKeyJustReleased(KEY_LBUTTON);
            //bool left_button_just = controls.isKeyJustPressed(KEY_LBUTTON);

            //Do use logic
            if(CanUseOnce(controls))
            {
                if(use_delay[CurrentValue] > 0.0f)//Does use delay exist?
                {
                    use_delay_left = use_delay[CurrentValue];//Set use delay
                }
                else//Regular logic
                {
                    UseOnce();
                }
            }


            //Do shot logic
            u8 can_shoot_reason = CanShootOnce();
            if(can_shoot_reason == 1)//No queued up shots
            {
                
            }
            else if(can_shoot_reason == 0)//Can shoot
            {
                ShootOnce();
            }
            else if(can_shoot_reason == 2)//Out of ammo
            {
                queued_shots = 0;//Remove all queued up shots.
                //TODO Play out of ammo sfx
            }
        }

        //
        //Can I?
        //

        //Shot
        //
        
        //Reason
        //0 == can shoot
        //1 == no queued shots
        //2 == not enough ammo 
        u8 CanShootOnce()
        {
            if(queued_shots == 0)
            {
                return 1;
            }
            if(ammo_count_left - ammo_per_shot[CurrentValue] < 0.0f)//If there is not enough ammo for another shot
            {
                return 2;
            }
            return 0;
        }

        //
        //Shot

        bool CanUseOnce(CControls@ controls)
        {
            if(use_afterdelay_left == 0.0f && use_delay_left == 0.0f)//The afterdelay and delay is over.
            {
                return CanUsingMode(controls);
            }
            return false;
        }
        bool CanUsingMode(CControls@ controls)
        {
            if(using_mode[CurrentValue] == 1)//Is full auto?
            {
                return CanFullAuto(controls);
            }
            else if(using_mode[CurrentValue] == 0)//Is semi-auto?
            {
                return CanSemiAuto(controls);
            }
            else
            {
                Nu::Warning("Use mode not supported");
                return false;
            }
        }
        //TODO, use send a keycode too so other buttons than left mouse button can be used.
        bool CanFullAuto(CControls@ controls)
        {
            return CanTrigger(controls.isKeyPressed(KEY_LBUTTON), controls.isKeyJustReleased(KEY_LBUTTON));
        }
        bool CanSemiAuto(CControls@ controls)
        {
            return CanTrigger(controls.isKeyJustPressed(KEY_LBUTTON), controls.isKeyJustReleased(KEY_LBUTTON));
        }
        bool CanTrigger(bool button_no_release, bool button_release)
        {
            if(!use_on_release[CurrentValue])//No use on release?
            {
                return button_no_release;//If button
            }
            else//Use on release
            {
                return button_release;//If button release
            }
        }


        //
        //Can I?
        //



        private USE_CALLBACK@ use_func;//This function gets called when this item is used
        void addUseListener(USE_CALLBACK@ value)
        {
            @use_func = @value;
        }
        void UseOnce()
        {
            queued_shots += shots_per_use[CurrentValue];//Queue up a shot
            use_afterdelay_left = use_afterdelay[CurrentValue];
        }
        void ShootOnce()
        {
            if(use_func != @null)//If the function to call exists
            {
                CBitStream@ _params;
                use_func(@this, @_params);//Call it
                //TODO Apply knockback per shot somehow
            }
            else
            {
                Nu::Error("failure to call function");
            }
            ammo_count_left -= ammo_per_shot[CurrentValue];
            if(ammo_count_left < 0.0f)
            {
                Nu::Warning("ammo count went below 0, something somewhere somehow is wrong. Good luck.");
            }
        }

        Modif32@ using_mode = Modif32("using_mode", 0);//0 means semi-auto. 1 means you can hold the button to keep automatically shooting when able (full auto). 2 is for burst fire. 3 and beyond are extras for specific weapon stuff.

        Modibool@ use_on_release = Modibool("use_on_release", false);//When this is false, it is default behavior. This activatable gets used on press. When this is true, this only gets used on release.



        Modibool@ remove_on_empty = Modibool("remove_on_empty", true);//Kills this when no more use uses are left

        Modif32@ use_afterdelay = Modif32("use_afterdelay", 0.0f);//basically rate of fire. How frequently can this be used? This many ticks before it can be reused.

        f32 use_afterdelay_left;


        Modif32@ use_delay = Modif32("use_delay", 0.0f);//If this is 30.0f, it would take 30 ticks after pressing the use button for this activatable to be used.
        //After this activatable is "used", this intercepts the use and delays it is designed to do by the amount of ticks specified. Further presses of the use button while this activatable is delayed will do nothing.

        f32 use_delay_left;


        Modif32@ max_ammo_count = Modif32("max_ammo_count", 1.0f);//Max amount of times this can be used

        f32 ammo_count_left;

        Modif32@ morium_cost = Modif32("morium_cost", 0.0f);//Morium cost per use when creating ammo for the activatable. a cost below 0 makes this activatable not rechargable
        
        
        //SHOTS
            //EFFECTS
            //
                Modif32@ ammo_per_shot = Modif32("ammo_per_shot", 1.0f);//Uses taken out per shot

                Modif32@ knockback_per_shot = Modif32("knockback_per_shot", 0.0f);//Amount the user is knocked back upon a shot going off.
            //
            //EFFECTS


            //AMOUNT
            //
                float queued_shots;//Value that holds shots waiting to be activated. Think burst fire weapons. You cannot fire(use) when there are still shots queued up.
                Modif32@ shots_per_use = Modif32("shots_per_use", 1.0f);//Amount of shots per use.
                Modif32@ ticks_between_shots = Modif32("ticks_between_shots", 0.0f);//Only relevant if the stat above is more than 0
            //
            //AMOUNT
        //SHOTS
        

    }


    class item : activatable
    {
        item()
        {
            Init();

            
            bool_array.reserve(5);
            f32_array.reserve(20);
            setModiVars();


            AfterInit();
        }
        void Init()
        {
            activatable::Init();


        }

        void setModiVars() override
        {
            activatable::setModiVars();
            

            //Charging
            f32_array.push_back(@charge_up_time);
            f32_array.push_back(@charge_down_per_tick);

            //USE effects
            f32_array.push_back(@knockback_per_use);
            f32_array.push_back(@rarity);

            //Shots
            f32_array.push_back(@random_shot_spread);
            f32_array.push_back(@min_shot_spread);
            f32_array.push_back(@max_shot_spread);
            f32_array.push_back(@spread_gain_per_shot);
            f32_array.push_back(@spread_loss_per_tick);        
        }
        
        void BaseValueChanged() override//Called if a base value is changed.
        {
            activatable::BaseValueChanged();
            print("item base value changed");
        }


        bool Tick()
        {
            if(!activatable::Tick()){ return false; }
            
            return true;
        }


        Modif32@ rarity = Modif32("rarity", Undefined);//Should be an enum.

        Modif32@ knockback_per_use = Modif32("knockback_per_use", 0.0f);//pushes you around when activated, specifically it pushes you away from the direction your mouse is aiming.




        Modif32@ charge_up_time = Modif32("charge_up_time", 0.0f);//Time the player must be holding the use button to activate a use of this. Think spinup time for a minigun.

        Modif32@ charge_down_per_tick = Modif32("charge_down_per_tick", 0.0f);//Amount the float above charge_up_time is subtracted by every tick.

        //SHOTS
        //
            //AIMING
            //
                Modif32@ random_shot_spread = Modif32("random_shot_spread", 0.0f);//Value that changes direction of where the shot is aimed by picking a value between 0 and this variable. Half chance to invert the value. Applies this to the direction the shot would be going.

                Modif32@ min_shot_spread = Modif32("min_shot_spread", 0.0f);//Min deviation from aimed point for shot.
                Modif32@ max_shot_spread = Modif32("max_shot_spread", 0.0f);//Max deviation from aimed point for shot.

                Modif32@ spread_gain_per_shot = Modif32("spread_gain_per_shot", 0.0f);//(not per projectile. Per USE) (Otherwise known as recoil) (capped to max_shot_spread)

                Modif32@ spread_loss_per_tick = Modif32("spread_loss_per_tick", 0.0f);// (capped to min_projectile_spread)

                //Multiplier applied to each value when crouching.
            //
            //AIMING

        //
        //Shots
    }



    /*



    class weapon : item
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
            shot_sfx = "AssaultFire.ogg";
            projectile_sfx = "";
            equip_weapon_sfx = "";
            empty_clip_sfx = "";
            empty_total_sfx = "";
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
                float ticks_between_projectiles;//Only relevant if the stat above is more than 1
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

            string shot_sfx;

            string empty_clip_sfx;//When the gun has 0 ammo in the clip.

            string empty_total_sfx;//When the gun has 0 ammo total.

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