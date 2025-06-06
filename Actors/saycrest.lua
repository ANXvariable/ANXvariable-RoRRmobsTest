local sprites = {
    idle	  = gm.constants.sLizardFGIdle,
    walk	  = gm.constants.sLizardFGWalk,
    jump	  = gm.constants.sLizardFGJump,
    jump_peak = gm.constants.sLizardFGJumpPeak,
    fall	  = gm.constants.sLizardFGFall
}

local spr_mask		= gm.constants.sLizardMask
local spr_pal		= gm.constants.sLizardFPal
local spr_spawn		= gm.constants.sLizardFSpawn
local spr_death		= gm.constants.sLizardFGDeath
local spr_shoot1	= gm.constants.sLizardFGShoot1

GM.elite_generate_palettes(spr_pal)

local seikret = Object.new(NAMESPACE, "Seikret", Object.PARENT.enemyClassic)
local seikret_id = seikret.value
seikret.obj_sprite = sprites.idle
seikret.obj_depth = 11

local seikretZ = Skill.new(NAMESPACE, "seikretZ")
local stateSeikretZ = State.new(NAMESPACE, "stateSeikretZ")

seikret:clear_callbacks()
seikret:onCreate(function(actor)
    actor.sprite_palette = spr_pal
    actor.sprite_spawn = spr_spawn
    actor.sprite_idle = sprites.idle
    actor.sprite_walk = sprites.walk
    actor.sprite_jump = sprites.jump
    actor.sprite_jump_peak = sprites.jump_peak
    actor.sprite_fall = sprites.fall
    actor.sprite_death = spr_death
    actor.mask_index = spr_mask

    actor.can_jump = true

	actor:enemy_stats_init(17, 120, 12, 15)
	actor.pHmax_base = 2.4

	actor.z_range = 150
	actor:set_default_skill(Skill.SLOT.primary, seikretZ)

    actor:init_actor_late()
end)

seikretZ:clear_callbacks()
seikretZ:onActivate(function(actor)
    actor:enter_state(stateSeikretZ)
end)

stateSeikretZ:clear_callbacks()
stateSeikretZ:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0
end)

stateSeikretZ:onStep(function(actor, data)
    local signdir = GM.dcos(actor:skill_util_facing_direction())
    local free = actor.free
    if data.fired == 0 then
	    actor:actor_animation_set(spr_shoot1, 0.05)
        actor.pHspeed = -signdir * 0.625
    else
        actor:actor_animation_set(spr_shoot1, 0.2)
    end

    if data.fired == 0 and actor.image_index >= 2 then
        actor.pVspeed = -4
        actor.pHspeed = signdir * 8

        data.fired = 1
    end
    if data.fired == 1 and actor.image_index >= 3 and free then
        actor.image_index = 3
    elseif data.fired == 1 and actor.image_index >= 3 and not free then
        data.fired = 2
	    actor:skill_util_fix_hspeed()
        actor.image_index = 4
        local attack = actor:fire_explosion_local(actor.x + 8 * signdir, actor.y + 4, 64, 32, 1)
    end

    actor:skill_util_exit_state_on_anim_end()
end)

local seikretCard = Monster_Card.new(NAMESPACE, "seikret")
seikretCard.object_id = seikret_id
seikretCard.spawn_cost = 15
seikretCard.spawn_type = Monster_Card.SPAWN_TYPE.classic
seikretCard.can_be_blighted = true

local stages = {
    "ror-desolateForest",
    "ror-driedLake",
    "ror-dampCaverns",
    "ror-hiveCluster"
}

for _, stageName in ipairs(stages) do
	local stage = Stage.find(stageName)
	stage:add_monster(seikretCard)
end

if hotload then return end
