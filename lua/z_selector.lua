-- NOTE: Place this before the speller to avoid z is accepted by the history

local reject = 0
local accept = 1
local pass_to_next = 2

local is_desktop = true

local function z_selector(key_event, env)
    local context = env.engine.context
    local input = context.input
    local is_number = key_event.keycode >= 48 and key_event.keycode <= 57
    if (not input or #input == 0) and is_number then
        env.engine:commit_text(string.char(key_event.keycode))
        return accept
    end
    if key_event:release() or not input or #input == 0 then return pass_to_next end
    local composition = context.composition:back()
    local dest = 9999
    local page_size = env.engine.schema.page_size
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
    elseif key_event.keycode == 44 then
        -- ',' is used to go back one page
        if composition.selected_index >= page_size then
            return pass_to_next
        elseif context:has_menu() and composition.selected_index < page_size then
            -- When there is no previous page, we commit the first item with punctuation
            env.engine:commit_text(composition.menu:get_candidate_at(0).text .. '，')
            context:clear()
            return accept
        end
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
        end
        return pass_to_next
    elseif
        dest <= page_size
        and math.floor(composition.selected_index / page_size) * page_size + dest - 1
            < composition.menu:candidate_count()
    then
        context:select(composition.selected_index + dest - 1)
        return accept
    elseif dest <= 10 then
        -- We will input ; when there is no three candidates
        env.engine:commit_text(input .. string.char(key_event.keycode))
        context:clear()
        return accept
    end
    return pass_to_next
end
return z_selector
