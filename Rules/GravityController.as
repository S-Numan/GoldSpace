void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart(CRules@ this)
{
    f32 gravity_mult = this.get_f32("gravity_mult");

	particles_gravity.y = 0.25f * gravity_mult;
    sv_gravity = 9.81f * gravity_mult;
}