local path_string = "Actors/Large Monsters/Bird Wyverns/Kulu-Ya-Ku/"

local sprites = {
    idle	  = load_sprite("kuluIdle", path_string.."sKuluIdle.png", 1, 56),
    walk	  = load_sprite("kuluWalk", path_string.."sKuluIdle.png", 1, 56),
    jump	  = load_sprite("kuluJump", path_string.."sKuluIdle.png", 1, 56),
    jump_peak = load_sprite("kuluJumpPeak", path_string.."sKuluIdle.png", 1, 56),
    fall	  = load_sprite("kuluFall", path_string.."sKuluIdle.png", 1, 56)
}

local spr_mask		= sprites.idle
local spr_pal		= load_sprite("kuluPalette", path_string.."sKuluPalette.png", 1)
local spr_spawn		= load_sprite("kuluSpawn", path_string.."sKuluFunny.png", 1, 56, 4)
local spr_death		= load_sprite("kuluDeath", path_string.."sKuluDeath.png", 2, 56, 4)
local spr_shoot1	= load_sprite("kuluShoot1", path_string.."sKuluShoot1.png", 9, 56, 4)
local spr_shoot2	= load_sprite("kuluShoot2", path_string.."sKuluShoot2.png", 32, 56, 4)

local spr_rock  	= load_sprite("kuluRock", path_string.."sKuluRock.png", 1, 7, 8)
local spr_rock_mask = load_sprite("kuluRockMask", path_string.."sKuluRockMask.png", 1, 7, 22)

GM.elite_generate_palettes(spr_pal)

--snd

local kulu = Object.new(NAMESPACE, "Kulu", Object.PARENT.bossClassic)
local kulu_id = kulu.value
kulu.obj_sprite = sprites.idle
kulu.obj_depth = 11

local obj_kuluRock = Object.new(NAMESPACE, "kuluRock", Object.PARENT.actor)
obj_kuluRock.obj_sprite = spr_rock
obj_kuluRock.obj_depth = 12

local kuluZ = Skill.new(NAMESPACE, "kuluZ")
local stateKuluZ = State.new(NAMESPACE, "stateKuluZ")
local kuluX = Skill.new(NAMESPACE, "kuluX")
local stateKuluX = State.new(NAMESPACE, "stateKuluX")
--local kuluC = Skill.new(NAMESPACE, "kuluC")
--local stateKuluC = State.new(NAMESPACE, "stateKuluC")
local kuluV = Skill.new(NAMESPACE, "kuluV")
local stateKuluV = State.new(NAMESPACE, "stateKuluV")

kuluZ.cooldown = 180
kuluX.cooldown = 180

kuluV.cooldown = 1200

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

    --actor.sound_spawn = snd_spawn
    --actor.sound_hit = snd_hit
    --actor.sound_death = snd_death

    actor.can_jump = true

	actor:enemy_stats_init(12, 1200, 90, 50)
	actor.pHmax_base = 2.6

	actor.z_range = 300
    actor.x_range = 100
    actor.v_range = 500
	actor:set_default_skill(Skill.SLOT.primary, kuluZ)
	actor:set_default_skill(Skill.SLOT.secondary, kuluX)
	--actor:set_default_skill(Skill.SLOT.utility, kuluC)
	actor:set_default_skill(Skill.SLOT.special, kuluV)

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
    local target = actor.target
    local tgtdistx = target.x - actor.x
    if data.fired == 0 then
	    actor:actor_animation_set(spr_shoot1, 0.05)
        actor.pHspeed = -signdir * 0.625
    else
        actor:actor_animation_set(spr_shoot1, 0.2)
    end

    if data.fired == 0 and actor.image_index >= 2 then
        actor.pVspeed = -6
        local t = (-2 * actor.pVspeed) / actor.pGravity1
        if GM.sign(tgtdistx) == signdir then
            actor.pHspeed = tgtdistx / t
        else
            actor.pHspeed = signdir * 8
        end

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

    if actor.image_index >= 10 and data.fired < 4 then 
        if math.floor(actor.image_index) == 10 + data.fired * 4 and data.fired < 4 then
            actor:sound_play(gm.constants.wGolemB_Shoot_2, 1.0, (0.9 + math.random() * 0.2))
            local attack = actor:fire_explosion_local(actor.x + 48 * signdir, actor.y + 40, 48, 32, 1)
            attack.attack_info.climb = data.fired * -4
            actor:skill_util_nudge_forward(3 * signdir)
            data.fired = data.fired + 1
        end
    end

	actor:skill_util_exit_state_on_anim_end()
end)

obj_kuluRock:clear_callbacks()
obj_kuluRock:onCreate(function(actor)
    actor.mask_index = spr_rock_mask

    actor.team = 2
    actor.parent = -4
    actor.armor = 10000
    actor.maxhp_base = 20
    actor.maxhp = 20
    actor.hp = 20
    actor.damage = 1
end)

obj_kuluRock:onStep(function(actor)
    local parent = actor.parent
    local signdir = GM.sign(parent.image_xscale)
    actor.image_xscale = signdir
    if not Instance.exists(parent) then
        actor:destroy()
        return
    end
    actor.x = parent.ghost_x + 32 * signdir
    actor.y = parent.ghost_y + 41
    if actor.hp <= 0 then actor:destroy() return end
end)

kuluV:clear_callbacks()
kuluV:onActivate(function(actor)
    actor:enter_state(stateKuluV)
end)

kuluV:onStep(function(actor, skill)
    if Instance.exists(Wrap.unwrap(actor.myRock)) then
        actor:freeze_default_skill(Skill.SLOT.special)
    end
end)

stateKuluV:clear_callbacks()
stateKuluV:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0

    actor.interrupt_sound = actor:sound_play(gm.constants.wGolemB_Shoot_1, 1.0, (0.9 + math.random() * 0.2) * actor.attack_speed)
end)

stateKuluV:onStep(function(actor, data)
    local signdir = GM.dcos(actor:skill_util_facing_direction())
    actor:skill_util_fix_hspeed()
	actor:actor_animation_set(spr_death, 0.25)
    if data.fired == 0 then
        actor.myRock = obj_kuluRock:create(actor.x + 32 * signdir, actor.y + 41)
        actor.myRock.parent = actor

        data.fired = 1
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
