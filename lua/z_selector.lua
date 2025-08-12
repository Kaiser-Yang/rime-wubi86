-- NOTE: Place this before the speller to avoid z is accepted by the history

local reject = 0
local accept = 1
local pass_to_next = 2

local is_desktop = true
local punctuation = {
    [33] = '！', -- !
    [35] = '#', -- #
    [36] = '￥', -- $
    [37] = '％', -- %
    [38] = '&', -- &
    [40] = '（', -- (
    [41] = '）', -- )
    [42] = '*', -- *
    [43] = '+', -- +
    [44] = '，', -- ,
    [45] = '-', -- -
    [46] = '。', -- .
    [47] = '/', -- /
    [58] = '：', -- :
    [59] = '；', -- ;
    [60] = '《', -- <
    [61] = '=', -- =
    [62] = '》', -- >
    [63] = '？', -- ?
    [64] = '@', -- @
    [91] = '【', -- [
    [92] = '、', -- \
    [93] = '】', -- ]
    [94] = '……', -- ^
    [95] = '——', -- _
    [96] = '`', -- `
    [123] = '{', -- {
    [124] = '|', -- |
    [125] = '}', -- }
    [126] = '~', -- ~
}
local continuous_punctuation = {
    [33] = '!', -- !
    [35] = '#', -- #
    [36] = '$', -- $
    [37] = '%', -- %
    [38] = '&', -- &
    [40] = '(', -- (
    [41] = ')', -- )
    [42] = '*', -- *
    [43] = '+', -- +
    -- [44] = '，', -- ,
    [45] = '-', -- -
    -- [46] = '。', -- .
    [47] = '/', -- /
    -- [58] = '：', -- :
    -- [59] = '；', -- ;
    [60] = '<', -- <
    [61] = '=', -- =
    [62] = '>', -- >
    -- [63] = '？', -- ?
    [64] = '@', -- @
    [91] = '[', -- [
    [92] = '\\', -- \
    [93] = ']', -- ]
    [94] = '^', -- ^
    [95] = '_', -- _
    [96] = '`', -- `
    [123] = '{', -- {
    [124] = '|', -- |
    [125] = '}', -- }
    [126] = '~', -- ~
}
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
    if key_event:release() then return pass_to_next end
    if not input or #input == 0 then
        if punctuation[key_event.keycode] then
            -- If punctuation is pressed without input, we commit the punctuation
            env.engine:commit_text(punctuation[key_event.keycode])
            context:clear()
            return accept
        elseif key_event.keycode >= 48 and key_event.keycode <= 57 then
            env.engine:commit_text(string.char(key_event.keycode))
            context:clear()
            return accept
        else
            return pass_to_next
        end
    end
    local composition = context.composition:back()
    local dest = 9999
    local is_number = key_event.keycode >= 48 and key_event.keycode <= 57
    if is_number then
        dest = key_event.keycode - 48
        if dest == 0 then dest = 10 end -- 0 for select the 10-th item
    elseif key_event.keycode == 122 and not input:match('^z') then -- z
        dest = 3
    elseif
        (key_event.keycode == 59 and is_desktop or key_event.keycode == 47 and not is_desktop)
        and not input:match('^z')
    then -- ; or /
        dest = 2
    elseif key_event.keycode == 44 and composition.selected_index > 10 then -- ,
        return pass_to_next
    elseif key_event.keycode == 46 then -- .
        if context:has_menu() and composition.menu:candidate_count() < 10 then
            env.engine:commit_text(
                composition.menu:get_candidate_at(0).text .. punctuation[key_event.keycode]
            )
            context:clear()
            return accept
        else
            return pass_to_next
        end
    end
    if not context:has_menu() then
        if key_event.keycode > 32 and key_event.keycode < 127 then -- other visible characters
            context:push_input(string.char(key_event.keycode))
            return accept
        elseif key_event.keycode == 32 then -- space
            env.engine:commit_text(input)
            context:clear()
            return accept
        end
        return pass_to_next
    elseif composition.menu:candidate_count() >= dest then
        context:select(dest - 1)
        return accept
    elseif punctuation[key_event.keycode] then
        if continuous_punctuation[key_event.keycode] then
            context:push_input(continuous_punctuation[key_event.keycode])
        else
            env.engine:commit_text(
                composition.menu:get_candidate_at(0).text .. punctuation[key_event.keycode]
            )
            context:clear()
        end
        return accept
    end
    return pass_to_next
end
return z_selector
