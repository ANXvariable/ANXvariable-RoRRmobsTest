local path_string = "Actors/Large Monsters/Brute Wyverns/Brachydios/"

local spr_none = gm.constants.sNone

local sprites = {
    idle	  = load_sprite("brachydiosIdle", path_string.."sBrachydiosIdle.png", 1, 102, 40),
    walk	  = load_sprite("brachydiosWalk", path_string.."sBrachydiosIdle.png", 1, 102, 40),
    jump	  = load_sprite("brachydiosJump", path_string.."sBrachydiosIdle.png", 1, 102, 40),
    jump_peak = load_sprite("brachydiosJumpPeak", path_string.."sBrachydiosIdle.png", 1, 102, 40),
    fall	  = load_sprite("brachydiosFall", path_string.."sBrachydiosIdle.png", 1, 102, 40)
}

local spr_mask		= sprites.idle
local spr_pal		= load_sprite("brachydiosPalette", path_string.."sBrachydiosPalette.png", 1)
local spr_spawn		= load_sprite("brachydiosSpawn", path_string.."sBrachydiosFunny.png", 1, 102, 40)
local spr_death		= load_sprite("brachydiosDeath", path_string.."sBrachydiosDeath.png", 2, 102, 40)
local spr_shoot1	= load_sprite("brachydiosShoot1", path_string.."sBrachydiosShoot1.png", 14, 102, 124)
local spr_shoot2	= load_sprite("brachydiosShoot2", path_string.."sBrachydiosShoot2.png", 24, 102, 40)
local spr_shoot4	= load_sprite("brachydiosShoot4", path_string.."sBrachydiosShoot4.png", 33, 102, 40)

local spr_puddle	= load_sprite("brachSlimePuddle", path_string.."sBrachSlimePuddle.png", 1, 16, 5)

GM.elite_generate_palettes(spr_pal)

local spr_buff_blastscourge = load_sprite("sBuffBlastscourge", path_string.."sBuffBlastscourge.png", 1, 7, 8)

--snd

local snd_shoot1	= load_sound("brachydiosShoot1", path_string.."wBrachydiosShoot1.ogg")
local snd_shoot2_1	= load_sound("brachydiosShoot2_1", path_string.."wBrachydiosShoot2_1.ogg")
local snd_shoot2_3	= load_sound("brachydiosShoot2_3", path_string.."wBrachydiosShoot2_3.ogg")
local snd_hand1		= load_sound("brachydiosHandImpact1", path_string.."wBrachydiosHandImpact1.ogg")
local snd_hand2		= load_sound("brachydiosHandImpact2", path_string.."wBrachydiosHandImpact2.ogg")

local snd_puddle_create = load_sound("brachydiosSlimePool", path_string.."wBrachydiosSlimePool.ogg")

local snd_spawn = gm.constants.wLizardSpawn
local snd_hit   = gm.constants.wLizardHit
local snd_death = gm.constants.wLizardDeath

local brachydios = Object.new(NAMESPACE, "Brachydios", Object.PARENT.bossClassic)
local brachydios_id = brachydios.value
brachydios.obj_sprite = sprites.idle
brachydios.obj_depth = 11

local obj_brachSlimePuddle = Object.new(NAMESPACE, "brachSlimePuddle")
obj_brachSlimePuddle.obj_sprite = spr_puddle
obj_brachSlimePuddle.obj_depth = -1

local blastScourge = Buff.new(NAMESPACE, "blastScourge")
local blastScourge_id = blastScourge.value
blastScourge.icon_sprite = spr_buff_blastscourge
blastScourge.is_debuff = true

local brachydiosZ = Skill.new(NAMESPACE, "brachydiosZ")
local stateBrachydiosZ = State.new(NAMESPACE, "stateBrachydiosZ")
local stateBrachydiosZ2 = State.new(NAMESPACE, "stateBrachydiosZ2")
local brachydiosX = Skill.new(NAMESPACE, "brachydiosX")
local stateBrachydiosX = State.new(NAMESPACE, "stateBrachydiosX")
local stateBrachydiosX2 = State.new(NAMESPACE, "stateBrachydiosX2")
local brachydiosC = Skill.new(NAMESPACE, "brachydiosC")
local stateBrachydiosC = State.new(NAMESPACE, "stateBrachydiosC")
local stateBrachydiosC2 = State.new(NAMESPACE, "stateBrachydiosC2")
local brachydiosV = Skill.new(NAMESPACE, "brachydiosV")
local stateBrachydiosV = State.new(NAMESPACE, "stateBrachydiosV")
local stateBrachydiosV2 = State.new(NAMESPACE, "stateBrachydiosV2")
local stateBrachydiosReload = State.new(NAMESPACE, "stateBrachydiosReload")

brachydiosZ.cooldown = 100
brachydiosX.cooldown = 150
brachydiosC.cooldown = 120
brachydiosV.cooldown = 600

brachydios:clear_callbacks()
brachydios:onCreate(function(actor)
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

	actor:enemy_stats_init(15, 1350, 150, 90)
	actor.pHmax_base = 2.8

	actor.z_range = 120
    actor.x_range = 120
    actor.v_range = 500
	actor:set_default_skill(Skill.SLOT.primary, brachydiosZ)
	actor:set_default_skill(Skill.SLOT.secondary, brachydiosX)
	--actor:set_default_skill(Skill.SLOT.utility, brachydiosC)
	actor:set_default_skill(Skill.SLOT.special, brachydiosV)

    actor:init_actor_late()
end)

brachydios:onStep(function(actor)
    local data = actor.actor_state_current_data_table
end)

brachydiosZ:clear_callbacks()
brachydiosZ:onActivate(function(actor)
    actor:enter_state(stateBrachydiosZ)
end)

stateBrachydiosZ:clear_callbacks()
stateBrachydiosZ:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0

    actor.interrupt_sound = actor:sound_play(snd_shoot1, 1.0, (0.9 + math.random() * 0.2) * actor.attack_speed)
end)

stateBrachydiosZ:onStep(function(actor, data)
    local signdir = GM.dcos(actor:skill_util_facing_direction())
    --local target = actor.target
    actor:actor_animation_set(spr_shoot1, 0.2)
    actor:skill_util_fix_hspeed()

    if actor.image_index >= 10 and data.fired == 0 then
        local handx = actor.x + 72 * signdir
        actor.interrupt_sound = actor:sound_play(snd_hand1, 1, (0.9 + math.random() * 0.2))
        local attack = actor:fire_explosion_local(handx, actor.y + 32, 48, 32, 1)
        attack.attack_info._anx_blastscourge = true
        puddle = obj_brachSlimePuddle:create(handx, actor.bbox_bottom)
        puddle.parent = actor
        actor:skill_util_nudge_forward(3 * signdir)

        data.fired = 1
    end

    actor:skill_util_exit_state_on_anim_end()
end)

brachydiosX:clear_callbacks()
brachydiosX:onActivate(function(actor)
    actor:enter_state(stateBrachydiosX)
end)

stateBrachydiosX:clear_callbacks()
stateBrachydiosX:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0
    data.rng = math.random()

    actor.interrupt_sound = actor:sound_play(snd_shoot2_1, 1.0, (0.95 + data.rng * 0.1) * actor.attack_speed)
end)

stateBrachydiosX:onStep(function(actor, data)
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
        --actor:sound_play(snd_shoot2_2, 1.0, (0.9 + math.random() * 0.2) * actor.attack_speed)
        local attack = actor:fire_explosion_local(actor.x + 80 * -signdir, actor.y + 9, 48, 32, 1)

        data.fired = 2
    end
    if actor.image_index >= 10 and data.fired == 2 then
        actor.interrupt_sound = actor:sound_play(snd_shoot2_3, 0.8, (0.95 + data.rng * 0.1) * actor.attack_speed)

        data.fired = 3
    end

    actor:skill_util_exit_state_on_anim_end()
end)

brachydiosV:clear_callbacks()
brachydiosV:onActivate(function(actor)
    actor:enter_state(stateBrachydiosV)
end)

stateBrachydiosV:clear_callbacks()
stateBrachydiosV:onEnter(function(actor, data)
	actor.image_index = 0
	data.fired = 0

    actor.interrupt_sound = actor:sound_play(snd_shoot1, 0.8, (0.9 + math.random() * 0.2) * actor.attack_speed)
end)

stateBrachydiosV:onStep(function(actor, data)
    local signdir = GM.dcos(actor:skill_util_facing_direction())
    local target = actor.target
    actor:actor_animation_set(spr_shoot4, 0.2)
    actor:skill_util_fix_hspeed()

    if actor.image_index >= 6 and data.fired == 0 then

        data.fired = 1
    end
    if actor.image_index >= 20 and data.fired == 1 then

        data.fired = 2
    end

    actor:skill_util_exit_state_on_anim_end()
end)

Callback.add(Callback.TYPE.onAttackHit, "anxApplyBlastscourge", function(hit_info)
	if hit_info.attack_info._anx_blastscourge then
        local victim = hit_info.target
        if victim:buff_stack_count(blastScourge) == 0 then
		    victim:buff_apply(blastScourge, 15 * 60)
        end
	end
end)

blastScourge:onApply(function(actor, stack)
    local data = actor:get_data()
    data.blastCureFailure = false
end)

blastScourge:onPostStep(function(actor, stack)
	local data = actor:get_data()
	local bufftime = GM.get_buff_time(actor, blastScourge)
    local utility = actor:get_active_skill(Skill.SLOT.utility)
    local cooldown
    if utility.cooldown > utility.cooldown_base then
        cooldown = utility.cooldown
    else
        cooldown = utility.cooldown_base
    end
	if bufftime <= 1 then
		data.blastCureFailure = true
	end
	if bufftime >= (15 * 60) + (cooldown * 4) + (5 * 60) + 1 then
		data.blastCureFailure = false
		actor:buff_remove(blastScourge)
	end
end)

blastScourge:onUtilityUse(function(actor, stack, utility)
	local bufftime = GM.get_buff_time(actor, blastScourge)
    if bufftime > 1 then
        GM.set_buff_time(actor, blastScourge, bufftime + utility.cooldown_base + (5 * 60))
    end
end)

blastScourge:onRemove(function(actor, stack)
    local data = actor:get_data()
    if data.blastCureFailure == true and actor:is_authority() then
        local x = actor.x
        local y = actor.y
        local xsize = 64
        local ysize = 64
        local team = 2
        local damage = actor.maxhp * 0.05
        local critical = false
        local explosion_sprite = gm.constants.sEfExplosiveGreen
        local sparks_sprite = gm.constants.sNone
        local attack = GM._mod_attack_fire_explosion_noparent(x, y, xsize, ysize, team, damage, critical, explosion_sprite, sparks_sprite)
    end
end)

obj_brachSlimePuddle:onCreate(function(instance)
    instance.parent = -4
    instance.fuse = 0
    instance.interrupt_sound = instance:sound_play(snd_puddle_create, 1, (0.9 + math.random() * 0.2))
end)

obj_brachSlimePuddle:onStep(function(instance)
    local actor = instance.parent
    local actor_collisions, _ = instance:get_collisions(gm.constants.pActorCollisionBase)
    if Instance.exists(actor) then
        for _, other_actor in ipairs(actor_collisions) do
            if actor:attack_collision_canhit(other_actor) and not GM.bool(actor.free) and other_actor:buff_stack_count(blastScourge) == 0 then
                local attack = actor:fire_direct(other_actor, 0.01, 0, other_actor.x, other_actor.y, nil, false)
                attack.attack_info._anx_blastscourge = true
            end
        end
    end
    instance.fuse = instance.fuse + 1
    if instance.fuse >= 180 then
        instance:destroy()
        return
    end
end)

obj_brachSlimePuddle:onDestroy(function(instance)
    local actor = instance.parent
    if Instance.exists(actor) then
        actor:fire_explosion_local(instance.x, instance.y - 3, 34 * instance.image_xscale, 8 * instance.image_yscale, 1, gm.constants.sEfExplosive, false)
    else
        GM._mod_attack_fire_explosion_noparent(instance.x, instance.y - 3, 34 * instance.image_xscale, 8 * instance.image_yscale, 2, 25, false, gm.constants.sEfExplosive, spr_none)
    end
    instance:sound_play(gm.constants.wExplosiveShot, 0.8, 1)
end)

local brachydiosCard = Monster_Card.new(NAMESPACE, "brachydios")
brachydiosCard.object_id = brachydios_id
brachydiosCard.spawn_cost = 800
brachydiosCard.spawn_type = Monster_Card.SPAWN_TYPE.classic
brachydiosCard.is_boss = true
brachydiosCard.can_be_blighted = true

local stages = {
    "ror-ancientValley",
    "ror-magmaBarracks"
}

for _, stageName in ipairs(stages) do
	local stage = Stage.find(stageName)
	stage:add_monster(brachydiosCard)
end

if hotload then return end
