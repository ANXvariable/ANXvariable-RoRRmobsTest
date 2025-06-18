local path_string = "Actors/Small Monsters/Bird Wyverns/Jaggi/"

local sprites = {
    idle	  = load_sprite("jaggiIdle", path_string.."sJaggiIdle.png", 1, 20),
    walk	  = load_sprite("jaggiWalk", path_string.."sJaggiIdle.png", 1, 20),
    jump	  = load_sprite("jaggiJump", path_string.."sJaggiIdle.png", 1, 20),
    jump_peak = load_sprite("jaggiJumpPeak", path_string.."sJaggiIdle.png", 1, 20),
    fall	  = load_sprite("jaggiFall", path_string.."sJaggiIdle.png", 1, 20)
}

local spr_mask		= sprites.idle
local spr_pal		= load_sprite("jaggiPalette", path_string.."sJaggiPalette.png", 1)
local spr_spawn		= load_sprite("jaggiSpawn", path_string.."sJaggiFunny.png", 1, 20)
local spr_death		= load_sprite("jaggiDeath", path_string.."sJaggiDeath.png", 2, 20)
local spr_shoot1	= load_sprite("jaggiShoot1", path_string.."sJaggiShoot1.png", 9, 20)

GM.elite_generate_palettes(spr_pal)

--snd

local snd_spawn = gm.constants.wLizardSpawn
local snd_hit   = gm.constants.wLizardHit
local snd_death = gm.constants.wLizardDeath

local jaggi = Object.new(NAMESPACE, "Jaggi", Object.PARENT.enemyClassic)
local jaggi_id = jaggi.value
jaggi.obj_sprite = sprites.idle
jaggi.obj_depth = 11

local jaggiZ = Skill.new(NAMESPACE, "jaggiZ")
local stateJaggiZ = State.new(NAMESPACE, "stateJaggiZ")
--local jaggiX = Skill.new(NAMESPACE, "jaggiX")
--local stateJaggiX = State.new(NAMESPACE, "stateJaggiX")
--local jaggiC = Skill.new(NAMESPACE, "jaggiC")
--local stateJaggiC = State.new(NAMESPACE, "stateJaggiC")
--local jaggiV = Skill.new(NAMESPACE, "jaggiV")
--local stateJaggiV = State.new(NAMESPACE, "stateJaggiV")

jaggiZ.cooldown = 60

jaggi:clear_callbacks()
jaggi:onCreate(function(actor)
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

	actor:enemy_stats_init(12, 120, 12, 10)
	actor.pHmax_base = 2.6

	actor.z_range = 80
    actor.x_range = 100
    actor.v_range = 500
	actor:set_default_skill(Skill.SLOT.primary, jaggiZ)
	--actor:set_default_skill(Skill.SLOT.secondary, jaggiX)
	--actor:set_default_skill(Skill.SLOT.utility, jaggiC)
	--actor:set_default_skill(Skill.SLOT.special, jaggiV)

    actor:init_actor_late()
    GM.teleport_nearby(actor, actor.x, actor.y)
end)

jaggiZ:clear_callbacks()
jaggiZ:onActivate(function(actor)
    actor:enter_state(stateJaggiZ)
end)

stateJaggiZ:clear_callbacks()
stateJaggiZ:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0

    actor.interrupt_sound = actor:sound_play(gm.constants.wLizardShoot1, 1.0, (0.9 + math.random() * 0.2) * actor.attack_speed)
end)

stateJaggiZ:onStep(function(actor, data)
    local signdir = GM.dcos(actor:skill_util_facing_direction())
    local target = actor.target
    actor:actor_animation_set(spr_shoot1, 0.2)
    actor:skill_util_fix_hspeed()

    if actor.image_index >= 3 and data.fired == 0 then
        local attack = actor:fire_explosion_local(actor.x + 12 * signdir, actor.y + 12, 48, 32, 1)
        actor:skill_util_nudge_forward(3 * signdir)

        data.fired = 1
    end

    actor:skill_util_exit_state_on_anim_end()
end)

local jaggiCard = Monster_Card.new(NAMESPACE, "jaggi")
jaggiCard.object_id = jaggi_id
jaggiCard.spawn_cost = 60
jaggiCard.spawn_type = Monster_Card.SPAWN_TYPE.classic
jaggiCard.is_boss = true
jaggiCard.can_be_blighted = true

local stages = {
    "ror-desolateForest",
    "ror-driedLake"
}

for _, stageName in ipairs(stages) do
	local stage = Stage.find(stageName)
	stage:add_monster(jaggiCard)
end

if hotload then return end
