local sprites = {
    idle	  = load_sprite("kuluIdle", "Actors/Large Monsters/Bird Wyverns/sKuluIdle.png", 1, 56),
    walk	  = load_sprite("kuluWalk", "Actors/Large Monsters/Bird Wyverns/sKuluIdle.png", 1, 56),
    jump	  = load_sprite("kuluJump", "Actors/Large Monsters/Bird Wyverns/sKuluIdle.png", 1, 56),
    jump_peak = load_sprite("kuluJumpPeak", "Actors/Large Monsters/Bird Wyverns/sKuluIdle.png", 1, 56),
    fall	  = load_sprite("kuluFall", "Actors/Large Monsters/Bird Wyverns/sKuluIdle.png", 1, 56)
}

local spr_mask		= sprites.idle
local spr_pal		= load_sprite("kuluPalette", "Actors/Large Monsters/Bird Wyverns/sKuluPalette.png", 1)
local spr_spawn		= load_sprite("kuluSpawn", "Actors/Large Monsters/Bird Wyverns/sKuluFunny.png", 1, 56, 4)
local spr_death		= load_sprite("kuluDeath", "Actors/Large Monsters/Bird Wyverns/sKuluDeath.png", 2, 56, 4)
local spr_shoot1	= load_sprite("kuluShoot1", "Actors/Large Monsters/Bird Wyverns/sKuluShoot1.png", 9, 56, 4)
local spr_shoot2	= load_sprite("kuluShoot2", "Actors/Large Monsters/Bird Wyverns/sKuluShoot2.png", 32, 56, 4)

GM.elite_generate_palettes(spr_pal)

--snd

local kulu = Object.new(NAMESPACE, "Kulu", Object.PARENT.bossClassic)
local kulu_id = kulu.value
kulu.obj_sprite = sprites.idle
kulu.obj_depth = 11

local kuluZ = Skill.new(NAMESPACE, "kuluZ")
local stateKuluZ = State.new(NAMESPACE, "stateKuluZ")
local kuluX = Skill.new(NAMESPACE, "kuluX")
local stateKuluX = State.new(NAMESPACE, "stateKuluX")

kuluZ.cooldown = 180
kuluX.cooldown = 90

kulu:clear_callbacks()
kulu:onCreate(function(actor)
    actor.sprite_palette = spr_pal
    actor.sprite_spawn = spr_spawn
    actor.sprite_idle = sprites.idle
    actor.sprite_walk = sprites.walk
    actor.sprite_jump = sprites.jump
    actor.sprite_jump_peak = sprites.jump_peak
    actor.sprite_fall = sprites.fall
    actor.sprite_death = spr_death
    actor.mask_index = spr_mask

    actor.sound_spawn = snd_spawn
    actor.sound_hit = snd_hit
    actor.sound_death = snd_death

    actor.can_jump = true

	actor:enemy_stats_init(12, 1200, 90, 50)
	actor.pHmax_base = 2.6

	actor.z_range = 225
    actor.x_range = 100
	actor:set_default_skill(Skill.SLOT.primary, kuluZ)
	actor:set_default_skill(Skill.SLOT.secondary, kuluX)

    actor:init_actor_late()
end)

kuluZ:clear_callbacks()
kuluZ:onActivate(function(actor)
    actor:enter_state(stateKuluZ)
end)

stateKuluZ:clear_callbacks()
stateKuluZ:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0

    actor.interrupt_sound = actor:sound_play(gm.constants.wGolemB_Shoot_1, 1.0, (0.9 + math.random() * 0.2) * actor.attack_speed)
end)

stateKuluZ:onStep(function(actor, data)
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
        actor:sound_play(gm.constants.wGolemB_Shoot_2, 1.0, (0.9 + math.random() * 0.2))
        local attack = actor:fire_explosion_local(actor.x + 44 * signdir, actor.y + 40, 64, 32, 1)
    end

    actor:skill_util_exit_state_on_anim_end()
end)

kuluX:clear_callbacks()
kuluX:onActivate(function(actor)
    actor:enter_state(stateKuluX)
end)

stateKuluX:clear_callbacks()
stateKuluX:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0

    actor.interrupt_sound = actor:sound_play(gm.constants.wGolemB_Shoot_1, 1.0, (0.9 + math.random() * 0.2) * actor.attack_speed)
end)

stateKuluX:onStep(function(actor, data)
    local signdir = GM.dcos(actor:skill_util_facing_direction())
    actor:skill_util_fix_hspeed()
	actor:actor_animation_set(spr_shoot2, 0.25)

    if math.floor(actor.image_index) == 10 + data.fired * 4 and data.fired < 4 then
        actor:sound_play(gm.constants.wGolemB_Shoot_2, 1.0, (0.9 + math.random() * 0.2))
        local attack = actor:fire_explosion_local(actor.x + 48 * signdir, actor.y + 40, 48, 32, 1)
        attack.attack_info.climb = data.fired * -4
        data.fired = data.fired + 1
    end

	actor:skill_util_exit_state_on_anim_end()
end)

local kuluCard = Monster_Card.new(NAMESPACE, "kulu")
kuluCard.object_id = kulu_id
kuluCard.spawn_cost = 600
kuluCard.spawn_type = Monster_Card.SPAWN_TYPE.classic
kuluCard.is_boss = true
kuluCard.can_be_blighted = true

local stages = {
    "ror-desolateForest",
    "ror-driedLake"
}

for _, stageName in ipairs(stages) do
	local stage = Stage.find(stageName)
	stage:add_monster(kuluCard)
end

if hotload then return end
