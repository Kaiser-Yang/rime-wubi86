-- NOTE: Place this before the speller to avoid z is accepted by the history

local reject = 0
local accept = 1
local pass_to_next = 2

local is_desktop = false
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
    [123] = '｛', -- {
    [124] = '|', -- |
    [125] = '｝', -- }
    [126] = '~', -- ~
}
local function z_selector(key_event, env)
    local context = env.engine.context
    local composition = context.composition:back()
    local input = context.input
    if key_event:release() then
        return pass_to_next
    elseif not input or #input == 0 then
        if not punctuation[key_event.keycode] then return pass_to_next end
        env.engine:commit_text(punctuation[key_event.keycode])
        context:clear()
        return accept
    end
    local dest = 9999
    local is_number = key_event.keycode >= 48 and key_event.keycode <= 57
    if key_event:shift() and key_event.keycode == 65505 then -- shift
        env.engine:commit_text(input)
        context:clear()
        return accept
    elseif is_number then
        if key_event.keycode >= 49 and key_event.keycode <= 51 then -- 1, 2, 3
            -- I never use 1, 2, 3 to select candidates
            context.input = input .. string.char(key_event.keycode)
            return accept
        end
        dest = key_event.keycode - 48
        if dest == 0 then dest = 10 end -- 0 for select the 10-th item
    elseif key_event.keycode == 122 and not input:match('^z') then -- z
        dest = 3
    elseif
        (key_event.keycode == 59 and is_desktop or key_event.keycode == 47 and not is_desktop)
        and not input:match('^z')
    then -- ; or /
        dest = 2
    elseif
        key_event.keycode == 46
        and context:has_menu()
        and composition.menu:candidate_count() <= 10
    then -- .
        env.engine:commit_text(
            composition.menu:get_candidate_at(0).text .. punctuation[key_event.keycode]
        )
        context:clear()
        return accept
    end
    if not context:has_menu() then
        if key_event.keycode >= 65 and key_event.keycode <= 90 then -- A-Z
            return pass_to_next
        elseif key_event.keycode > 32 and key_event.keycode < 127 then -- other visible characters
            context.input = input .. string.char(key_event.keycode)
            return accept
        elseif key_event.keycode == 32 then -- space
            env.engine:commit_text(input)
            context:clear()
            return accept
        end
    elseif composition.menu:candidate_count() >= dest then
        env.engine:commit_text(composition.menu:get_candidate_at(dest - 1).text)
        context:clear()
        return accept
    elseif punctuation[key_event.keycode] then
        if key_event.keycode ~= punctuation[key_event.keycode]:byte() then
            env.engine:commit_text(
                composition.menu:get_candidate_at(0).text .. punctuation[key_event.keycode]
            )
            context:clear()
        else
            context.input = input .. punctuation[key_event.keycode]
        end
        return accept
    elseif key_event.keycode == 122 then -- z
        context.input = input .. string.char(key_event.keycode)
        return accept
    end
    return pass_to_next
end
return z_selector
