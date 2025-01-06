-- NOTE: Place this before the default selector

local accept = 1
local pass_to_next = 2

local function z_selector(key_event, env)
    if key_event:release() or key_event:alt() then return pass_to_next end
    local context = env.engine.context
    local composition = context.composition:back()
    -- not z, ignore
    if key_event.keycode ~= 0x7A then return pass_to_next end
    -- Less than 3 candidates
    -- Accept this key, but do nothing
    if not context:has_menu() or composition.menu:candidate_count() < 3 then return accept end
    context:clear()
    env.engine:commit_text(composition.menu:get_candidate_at(2).text)
    return accept
end
return z_selector
