-- NOTE: Place this before the speller to avoid z is accepted by the history

local reject = 0
local accept = 1
local pass_to_next = 2

local is_desktop = false

local function z_selector(key_event, env)
    local context = env.engine.context
    local input = context.input
    if key_event:release() then return pass_to_next end
    if not input or #input == 0 then
        if key_event.keycode >= 48 and key_event.keycode <= 57 then
            -- Commit numbers directly
            env.engine:commit_text(string.char(key_event.keycode))
            context:clear()
            return accept
        else
            return pass_to_next
        end
    end
    local composition = context.composition:back()
    local dest = 9999
    if key_event.keycode == 122 and not input:match('^z') then
        -- We use 'z' to select the third item
        dest = 3
    elseif
        (key_event.keycode == 59 and is_desktop or key_event.keycode == 47 and not is_desktop)
        and not input:match('^z')
    then
        -- On desktop, we use ';' to select the second item;
        -- On phone, we use '/' to select the second item;
        dest = 2
    end
    if not context:has_menu() then
        if key_event.keycode > 32 and key_event.keycode < 127 then
            -- Other visible characters, this means that we are inputing alphabets
            context:push_input(string.char(key_event.keycode))
            return accept
        elseif key_event.keycode == 32 then
            -- We always commit the text when space is pressed
            env.engine:commit_text(input)
            context:clear()
            return accept
        end
        return pass_to_next
    elseif composition.selected_index + dest - 1 < composition.menu:candidate_count() then
        context:select(composition.selected_index + dest - 1)
        return accept
    end
    return pass_to_next
end
return z_selector
