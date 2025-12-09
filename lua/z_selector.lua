-- NOTE: Place this before the speller to avoid z is accepted by the history

local reject = 0
local accept = 1
local pass_to_next = 2

local is_desktop = true
local shift_pressed

local function z_selector(key_event, env)
    local context = env.engine.context
    local input = context.input
    if key_event.keycode == 65505 then -- Shift key
        if not key_event:release() then
            shift_pressed = true
        elseif shift_pressed then
            -- For single shift key, we commit the text
            env.engine:commit_text(input)
            context:clear()
            shift_pressed = nil
        end
        return accept
    end
    shift_pressed = nil
    if key_event:release() or not input or #input == 0 then return pass_to_next end
    local composition = context.composition:back()
    local dest = 9999
    local page_size = env.engine.schema.page_size
    local is_number = key_event.keycode >= 48 and key_event.keycode <= 57
    if is_number then
        dest = key_event.keycode - 48
        if dest == 0 then dest = 10 end -- 0 for select the 10-th item
    elseif key_event.keycode == 122 and not input:match('^z') then
        -- We use 'z' to select the third item
        dest = 3
    elseif
        (key_event.keycode == 59 and is_desktop or key_event.keycode == 47 and not is_desktop)
        and not input:match('^z')
    then
        -- On desktop, we use ';' to select the second item;
        -- On phone, we use '/' to select the second item;
        dest = 2
    elseif key_event.keycode == 44 and composition.selected_index > page_size then
        -- ',' is used to go back one page
        return pass_to_next
    elseif key_event.keycode == 46 then
        -- '.' is used to go forward one page
        if context:has_menu() and composition.menu:candidate_count() < page_size then
            -- When there is no next page, we commit the first item with punctuation
            env.engine:commit_text(composition.menu:get_candidate_at(0).text .. '。')
            context:clear()
            return accept
        end
    end
    if not context:has_menu() then
        if
            key_event.keycode >= string.byte('a') and key_event.keycode <= string.byte('z')
            or key_event.keycode >= string.byte('A') and key_event.keycode <= string.byte('Z')
        then
            context:push_input(string.char(key_event.keycode))
            return accept
        elseif key_event.keycode > 32 and key_event.keycode < 127 then
            -- Other visible characters, this means that we are inputing alphabets
            env.engine:commit_text(input .. string.char(key_event.keycode))
            context:clear()
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
