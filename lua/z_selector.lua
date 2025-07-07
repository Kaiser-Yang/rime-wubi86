-- NOTE: Place this before the speller to avoid z is accepted by the history

local accept = 1
local pass_to_next = 2

local function z_selector(key_event, env)
    if key_event:release() or key_event:alt() then return pass_to_next end
    local context = env.engine.context
    local composition = context.composition:back()
    local input = context.input
    local dest = 9999
    local is_number = key_event.keycode >= 0x30 and key_event.keycode <= 0x39
    local is_alpha_except_z = key_event.keycode >= 0x41 and key_event.keycode <= 0x5A
        or key_event.keycode >= 0x61 and key_event.keycode < 0x7A
    local keycode_is_visible = key_event.keycode > 0x20 and key_event.keycode <= 0x7E
    local is_reverse_lookup = input and #input >= 1 and input:match('^z')
    -- FIX: why shift can not commit code
    if key_event.keycode == 15 then -- Shift
        context:clear()
        env.engine:commit_text(input)
    elseif is_number then
        dest = key_event.keycode - 0x30
        if dest == 0 then dest = 10 end -- 0 for select the 10-th item
        if context:has_menu() and composition.menu:candidate_count() >= dest then
            return pass_to_next
        end
    elseif is_alpha_except_z or not keycode_is_visible then
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
        if key_event.keycode ~= 0x7A and input and #input > 0 then
            -- TODO: how to make the input continue
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
