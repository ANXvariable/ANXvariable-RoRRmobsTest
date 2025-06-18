local path_string = "Actors/Large Monsters/Bird Wyverns/Great Jaggi/"

local sprites = {
    idle	  = load_sprite("jaggiGIdle", path_string.."sJaggiGIdle.png", 1, 50),
    walk	  = load_sprite("jaggiGWalk", path_string.."sJaggiGIdle.png", 1, 50),
    jump	  = load_sprite("jaggiGJump", path_string.."sJaggiGIdle.png", 1, 50),
    jump_peak = load_sprite("jaggiGJumpPeak", path_string.."sJaggiGIdle.png", 1, 50),
    fall	  = load_sprite("jaggiGFall", path_string.."sJaggiGIdle.png", 1, 50)
}

local spr_mask		= sprites.idle
local spr_pal		= load_sprite("jaggiGPalette", path_string.."sJaggiGPalette.png", 1)
local spr_spawn		= load_sprite("jaggiGSpawn", path_string.."sJaggiGFunny.png", 1, 50)
local spr_death		= load_sprite("jaggiGDeath", path_string.."sJaggiGDeath.png", 2, 50)
local spr_shoot1	= load_sprite("jaggiGShoot1", path_string.."sJaggiGShoot1.png", 9, 50)
local spr_shoot2	= load_sprite("jaggiGShoot2", path_string.."sJaggiGShoot2.png", 24, 50)
local spr_shoot4	= load_sprite("jaggiGShoot4", path_string.."sJaggiGShoot4.png", 44, 50)

GM.elite_generate_palettes(spr_pal)

--snd

local howl_sounds = {
    load_sound("jaggiGHowl1", path_string.."wJaggiGHowl1.ogg"),
    load_sound("jaggiGHowl2", path_string.."wJaggiGHowl2.ogg"),
    load_sound("jaggiGHowl3", path_string.."wJaggiGHowl3.ogg")
}

local snd_growl = load_sound("jaggiGGrowl1", path_string.."wJaggiGGrowl1.ogg")
local snd_shoot2_1 = load_sound("jaggiGShoot2_1", path_string.."wJaggiGShoot2_1.ogg")
local snd_shoot2_2 = load_sound("jaggiGShoot2_2", path_string.."wJaggiGShoot2_2.ogg")
local snd_shoot2_3 = load_sound("jaggiGShoot2_3", path_string.."wJaggiGShoot2_3.ogg")

local snd_spawn = gm.constants.wLizardSpawn
local snd_hit   = gm.constants.wLizardHit
local snd_death = gm.constants.wLizardDeath

local jaggiG = Object.new(NAMESPACE, "GreatJaggi", Object.PARENT.bossClassic)
local jaggiG_id = jaggiG.value
jaggiG.obj_sprite = sprites.idle
jaggiG.obj_depth = 11
--local jaggi = Object.find(NAMESPACE, "Jaggi")

local jaggiGZ = Skill.new(NAMESPACE, "jaggiGZ")
local stateJaggiGZ = State.new(NAMESPACE, "stateJaggiGZ")
local jaggiGX = Skill.new(NAMESPACE, "jaggiGX")
local stateJaggiGX = State.new(NAMESPACE, "stateJaggiGX")
--local jaggiGC = Skill.new(NAMESPACE, "jaggiGC")
--local stateJaggiGC = State.new(NAMESPACE, "stateJaggiGC")
local jaggiGV = Skill.new(NAMESPACE, "jaggiGV")
local stateJaggiGV = State.new(NAMESPACE, "stateJaggiGV")

jaggiGZ.cooldown = 100
jaggiGX.cooldown = 150
--
jaggiGV.cooldown = 600

jaggiG:clear_callbacks()
jaggiG:onCreate(function(actor)
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

	actor.z_range = 80
    actor.x_range = 90
    actor.v_range = 500
	actor:set_default_skill(Skill.SLOT.primary, jaggiGZ)
	actor:set_default_skill(Skill.SLOT.secondary, jaggiGX)
	--actor:set_default_skill(Skill.SLOT.utility, jaggiGC)
	actor:set_default_skill(Skill.SLOT.special, jaggiGV)

    actor:init_actor_late()
end)

jaggiGZ:clear_callbacks()
jaggiGZ:onActivate(function(actor)
    actor:enter_state(stateJaggiGZ)
end)

stateJaggiGZ:clear_callbacks()
stateJaggiGZ:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0

    actor.interrupt_sound = actor:sound_play(gm.constants.wLizardShoot1, 1.0, (0.9 + math.random() * 0.2) * actor.attack_speed)
end)

stateJaggiGZ:onStep(function(actor, data)
    local signdir = GM.dcos(actor:skill_util_facing_direction())
    local target = actor.target
    actor:actor_animation_set(spr_shoot1, 0.2)
    actor:skill_util_fix_hspeed()

    if actor.image_index >= 3 and data.fired == 0 then
        local attack = actor:fire_explosion_local(actor.x + 36 * signdir, actor.y + 32, 48, 32, 1)
        actor:skill_util_nudge_forward(3 * signdir)

        data.fired = 1
    end

    actor:skill_util_exit_state_on_anim_end()
end)

jaggiGX:clear_callbacks()
jaggiGX:onActivate(function(actor)
    actor:enter_state(stateJaggiGX)
end)

stateJaggiGX:clear_callbacks()
stateJaggiGX:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0

    actor.interrupt_sound = actor:sound_play(snd_shoot2_1, 1.0, (1 + math.random() * 0.1) * actor.attack_speed)
end)

stateJaggiGX:onStep(function(actor, data)
    local signdir = GM.dcos(actor:skill_util_facing_direction())
    local target = actor.target
    actor:actor_animation_set(spr_shoot2, 0.2)
    actor:skill_util_fix_hspeed()
    actor:freeze_default_skill(Skill.SLOT.secondary)

    if actor.image_index >= 6 and data.fired == 0 then
        actor.image_xscale = -actor.image_xscale

        data.fired = 1
    end
    if actor.image_index >= 9 and data.fired == 1 then
        actor:sound_play(snd_shoot2_2, 1.0, (0.9 + math.random() * 0.2) * actor.attack_speed)
        local attack = actor:fire_explosion_local(actor.x + 36 * -signdir, actor.y + 32, 48, 32, 1)

        data.fired = 2
    end
    if actor.image_index >= 10 and data.fired == 2 then
        actor.interrupt_sound = actor:sound_play(snd_shoot2_3, 0.8, actor.attack_speed)

        data.fired = 3
    end

    actor:skill_util_exit_state_on_anim_end()
end)

jaggiGV:clear_callbacks()
jaggiGV:onActivate(function(actor)
    actor:enter_state(stateJaggiGV)
end)

stateJaggiGV:clear_callbacks()
stateJaggiGV:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0

    actor.interrupt_sound = actor:sound_play(snd_growl, 1.0, (0.9 + math.random() * 0.2) * actor.attack_speed)
end)

stateJaggiGV:onStep(function(actor, data)
    local signdir = GM.dcos(actor:skill_util_facing_direction())
    local target = actor.target
    actor:actor_animation_set(spr_shoot4, 0.2)
    actor:skill_util_fix_hspeed()

    if actor.image_index >= 6 and data.fired == 0 then
        local i = math.random(#howl_sounds)
        local snd_howl = howl_sounds[i]
        actor.interrupt_sound = actor:sound_play(snd_howl, 1.0, (1 + math.random() * 0.1) * actor.attack_speed)

        data.fired = 1
    end
    if actor.image_index >= 20 and data.fired == 1 then
        local jaggi = Object.find(NAMESPACE, "Jaggi")
        local j = jaggi:create(actor.x + 250 * math.random(), actor.y + 30)
        GM.elite_set(j, actor.elite_type)
        data.minion = Wrap.unwrap(j)
        local j2 = jaggi:create(actor.x - 250 * math.random(), actor.y + 30)
        GM.elite_set(j2, actor.elite_type)
        data.minion2 = Wrap.unwrap(j2)

        data.fired = 2
    end

    actor:skill_util_exit_state_on_anim_end()
end)

local jaggiGCard = Monster_Card.new(NAMESPACE, "greatJaggi")
jaggiGCard.object_id = jaggiG_id
jaggiGCard.spawn_cost = 600
jaggiGCard.spawn_type = Monster_Card.SPAWN_TYPE.classic
jaggiGCard.is_boss = true
jaggiGCard.can_be_blighted = true

local stages = {
    "ror-desolateForest",
    "ror-driedLake"
}

for _, stageName in ipairs(stages) do
	local stage = Stage.find(stageName)
	stage:add_monster(jaggiGCard)
end

if hotload then return end
