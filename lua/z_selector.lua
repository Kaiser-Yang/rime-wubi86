-- NOTE: Place this before the speller to avoid z is accepted by the history

local accept = 1
local pass_to_next = 2

local function z_selector(key_event, env)
    if key_event:release() or key_event:alt() then return pass_to_next end
    local context = env.engine.context
    local composition = context.composition:back()
    local input = context.input
    local dest = 9999
    local keycode_is_alphanumeric_except_z = key_event.keycode >= 0x30 and key_event.keycode <= 0x39
        or key_event.keycode >= 0x41 and key_event.keycode <= 0x5A
        or key_event.keycode >= 0x61 and key_event.keycode < 0x7A
    local keycode_is_visible = key_event.keycode > 0x20 and key_event.keycode <= 0x7E
    local is_reverse_lookup = input and #input >= 1 and input:match('^z')
    if keycode_is_alphanumeric_except_z or not keycode_is_visible then
        return pass_to_next
    elseif not is_reverse_lookup then
        if
            key_event.keycode == 0x7A -- z
            or key_event.keycode == 0x27 -- apostrophe
        then
            dest = 3
        elseif
            key_event.keycode == 0x2F -- slash
            or key_event.keycode == 0x3B -- semicolon
        then
            dest = 2
        end
    end
    if not context:has_menu() or composition.menu:candidate_count() < dest then
        if input and #input > 0 then
            context:clear()
            env.engine:commit_text(input .. string.char(key_event.keycode))
            return accept
        else
            return pass_to_next
        end
    end
    context:clear()
    env.engine:commit_text(composition.menu:get_candidate_at(dest - 1).text)
    return accept
end
return z_selector
