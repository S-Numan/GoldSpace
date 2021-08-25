/*::Weapon stats::
        explode size
        explode damage
        explode damage terrain (y/n)*/
        
enum RarityTypes
{
    Undefined,
    Common,
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
    //Primary
    PriSubmachine,
    PriMachine,
    PriAssault,
    PriShotgun,
    PriMarksman,
    PriLauncher,
    PriSpecial,
    PriThrowable,
    PriMelee,
    PriClose,
    PriDual,  

    //Secondary
    SecPistol,
    SecSubmachine,
    SecShotgun,
    SecMelee,
    SecMisc,




    WeaponTypeCount
}


class activatable
{
    bool Init()
    {
        rarity = Undefined;

        knockback = 0.0f;

        full_auto = false;
        remove_on_empty = false;
        use_interval = 0;
        max_use_count = 1;
        use_count = 1;
        charge_up_time = 0;

        morium_cost = 0.0f;



        return true;
    }

    bool Tick()
    {


        return true;
    }

    u8 rarity;//Should be an enum.

    float knockback;//pushes you around when activated, specifically it pushes you away from the direction your mouse aiming.


    bool full_auto;//false means semi-auto. true means you can hold the button to keep automatically activating it.

    bool remove_on_empty;//Kills this when no more use uses are left

    float use_interval;//basically rate of fire. How frequently can this be used? This many ticks before it can be reused.

    float max_use_count;//Default max amount this can be used. Default is 1. CONST

    float use_count;//Amount of times left that this can be used.

    float charge_up_time;//Time the player must be holding the use button to activate a use of this weapon.


    float morium_cost;//Morium cost per use when creating ammo for the activatable. a cost below 0 makes this activatable not rechargable

    //u16 times_activated_on_use;//usually 1, but can be more if the activatable is a shotgun or something. Or something more unique. Dunno.
}

class weapon : activatable
{
    bool Init() override
    {
        if(!activatable::Init()) { return false; }

        max_ammo = 0.0f;
        total_ammo = 0.0f;

        ammo_to_clip_per_reload = 0.0f;
        reload_time = 0;
        reload_time_left = 0;
        auto_reload = false;

        overheating = false;
        heat = 0.0f;
        max_heat = 0.0f;
        overheating_multiplier = 1.0f;
        heat_loss_per_tick = 0.0f;
        heat_gain_per_shot = 0.0f;
        damage_on_overheat = 0.0f;

        ammo_per_shot = 1.0f;
        knockback_per_shot = 0.0f;

        queued_shots = 0;
        shots_per_use = 1;
        ticks_between_shots = 0;

        random_shot_spread = 0.0f;
        min_shot_spread = 0.0f;
        max_shot_spread = 0.0f;
        spread_gain_per_shot = 0.0f;
        spread_loss_per_tick = 0.0f;

        projectile_damage = 0.0f;
        projectile_speed = -1.0f;//Below 0 is hitscan
        projectile_gravity = 0.0f;
        projectile_knockback = 0.0f
        projectile_max_distance = 0.0f;
        projectile_lifespan = 0;
        projectile_bounce_count = 0;
        projectile_pierce_count = 0;

        queued_projectiles = 0;
        projectiles_on_shot = 1;
        ticks_between_projectiles = 0;

        random_projectile_spread = 0.0f;
        same_tick_forced_spread = 0.0f;

        reload_sound = "Reload.ogg";
        shot_sound = "AssaultFire.ogg";
        projectile_sfx = "";
        equip_weapon_sfx = "";
        empty_clip_sfx = "";
        empty_total_sfx = "";
        empty_clip_use_sfx = "";
        equip_weapon_sfx = "";
        flesh_hit_sfx = "ArrowHitFlesh.ogg"
        object_hit_sfx = "BulletImpact.ogg";
    }

    bool Tick() override
    {
        if(!activatable::Tick()) { return false; }


    }












    private float max_ammo;
    float getMaxAmmo()//Gets the maximum amount of ammo that this weapon can hold. (not including ammo in clip)
    {
        return max_ammo
    }
    void setMaxAmmo(float value)
    {
        max_ammo = value;
    }

    private float total_ammo;
    float getTotalAmmo()//Gets the current amount of ammo that this weapon is holding. (not including ammo in clip)
    {
        return total_ammo
    }
    void setTotalAmmo(float value)
    {
        total_ammo = value;
    }

    float getClipSize()
    {
        return max_use_count;
    }
    void setClipSize(float value)
    {
        max_use_count = value;
    }

    float getAmmoInClip()
    {
        return use_count;
    }
    void setAmmoInClip(float value)
    {
        use_count = value;
    }

    float getFireRate()
    {
        return use_interval;
    }
    void setFireRate(float value)
    {
        use_interval = value;
    }

    //terminology
    //USE                   When the user presses the button to use the gun once.
    //SHOT                  Single fire of the gun.
    //PROJECTILE            Projectiles from the single SHOT of the gun.


    float ammo_to_clip_per_reload;//Amount of ammo added to the clip per reload. 0.0f means max ammo that can be added is added. (I.E default)
    //Weapon will continue to reload until clip is full, unless the weapon is used.

    private float reload_time;//Time taken to reload a clip upon pressing the reload button. (in ticks)
    float getReloadTime()
    {
        return reload_time;
    }
    void setReloadTime(float value)
    {
        reload_time = value;
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

    //SHOTS
    //
        //EFFECTS
        //
            float ammo_per_shot;//Ammo taken out of the clip per shot.

            float knockback_per_shot;//Amount the user is knocked back upon a shot going off.
        //
        //EFFECTS


        //AMOUNT
        //
            float queued_shots;//Value that holds shots waiting to be activated. Think burst fire weapons.
            float shots_per_use;//Amount of shots per use.
            float ticks_between_shots;//Only relevant if the stat above is more than 1
        //
        //AMOUNT

        //AIMING
        //
            float random_shot_spread;//Value that changes direction of where the shot is aimed by picking a value between 0 and this variable. Half chance to invert the value. Applies this to the direction the shot would be going.

            float min_shot_spread;//Min deviation from aimed point for shot.
            float max_shot_spread;//Max deviation from aimed point for shot.

            float spread_gain_per_shot;//(not per projectile. Per USE) (Otherwise known as recoil) (capped to max_shot_spread)

            float spread_loss_per_tick;// (capped to min_projectile_spread)

            //Multiplier applied to each value when crouching.
        //
        //AIMING

    //
    //Shots

    //PROJECTILES
    //
        //EFFECTS
        //
            float projectile_damage;//below 0 heals

            float projectile_speed;//Below 0 is hitscan.

            float projectile_gravity;//default is 1.0f.

            float projectile_knockback;//How much the projectile pushes a target back upon hitting.
        
            float projectile_max_distance;//Distance the projectile can travel before dying. 0 or below is max.

            u16 projectile_lifespan;//Amount of ticks the projectile can stay alive before it is killed. 0 or below is max.

            u16 projectile_bounce_count;//Amount of times the projectile can bounce. default 0
            
            u16 projectile_pierce_count;//Amount of times the projectile can pierce enemies without dying. default 0
        //
        //EFFECTS

        //AMOUNT
        //
            float queued_projectiles;//Value that holds projectiles waiting to escape from the gun. Think shotgun like weapons.
            float projectiles_on_shot;//Amount of projectiles per shot.
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
    //
    //PROJECTILES

    //SFX
    //
        string reload_sfx;

        string shot_sfx;
        
        string projectile_sfx;//Default nothing.

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


//360 weapon aiming is done like this
//Rotate from the back part of the gun from there, keeping the back of the gun in place. Possibly rotate from even farther behind the back of the gun.
//See archer bow. But try putting the bow a bit further forward instead.
//Scoot the point of rotation around based on the aim position if needed.