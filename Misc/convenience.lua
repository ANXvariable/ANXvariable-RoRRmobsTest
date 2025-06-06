-- Utility function for getting paths concisely
load_sprite = function (id, filename, frames, orig_x, orig_y, speed, left, top, right, bottom)
    local sprite_path = path.combine(PATH, "Sprites",  filename)
    return Resources.sprite_load(NAMESPACE, id, sprite_path, frames, orig_x, orig_y, speed, left, top, right, bottom)
end
load_sound = function (id, filename)
    local sound_path = path.combine(PATH, "Sounds", filename)
    return Resources.sfx_load(NAMESPACE, id, sound_path)
end
