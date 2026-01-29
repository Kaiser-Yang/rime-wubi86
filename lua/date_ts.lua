--[[
组件名称：时间转换器-扩展
描述：输入 今天/明天/后天/前天等
作者：空山明月
时间：2024-6-6
--]]

--------------------------------------------------------------------------------------

-- 分割字符串
-- str: 需要被分割的字符串
-- reps: 分割字符串的符号
-- return: 返回被一个字符集
local function split(str, reps)
    local resultStrList = {}
    string.gsub(str, '[^' .. reps .. ']+', function(w) table.insert(resultStrList, w) end)
    return resultStrList
end

-- 将数字转换成纯大写文本
local function num_to_cnstr(num)
    local hzNum = { '一', '二', '三', '四', '五', '六', '七', '八', '九', '〇' }
    local result = ''

    for i = 1, string.len(tostring(num)) do
        local strNum = string.sub(num, i, i)
        if strNum == '0' then strNum = '10' end
        local index = tonumber(strNum)
        local strValue = hzNum[index]
        result = result .. strValue
    end

    return result
end

-- 将数字转换成纯大写数字
local function num_to_cnnum(num)
    local hzNum = { '一', '二', '三', '四', '五', '六', '七', '八', '九', '〇' }
    local hzWei = { '十', '百', '千', '万' }
    local result = ''
    local num_len = string.len(tostring(num))

    for i = 1, num_len do
        local strNum = string.sub(num, i, i)
        if i == num_len then
            result = result .. (hzNum[tonumber(strNum)] or '')
        elseif i == 1 then
            if strNum ~= '0' then
                local _num = hzNum[tonumber(strNum)] .. hzWei[num_len - i]
                if _num == '一十' then _num = '十' end
                result = result .. _num
            end
        else
            if strNum == '0' then strNum = '10' end
            local _num = hzNum[tonumber(strNum)] .. hzWei[num_len - i]
            if _num == '一十' then _num = '十' end
            result = result .. _num
        end
    end

    return result
end

-- 将时间字符串转换成中文时间格式
-- strDate: 格式 2024.05.12
-- return: 返回中文描述的时间字符串，格式 二〇二四年五月十二日
local function date_to_cnstr(strDate)
    local strYear, strMoth, strDay = '', '', ''
    -- 将日期以.分割
    local dtArray = split(strDate, '.')
    -- 转换年
    strYear = num_to_cnstr(dtArray[1])
    -- 转换月
    strMoth = num_to_cnnum(dtArray[2])
    -- 转换日
    strDay = num_to_cnnum(dtArray[3])

    return strYear .. '年' .. strMoth .. '月' .. strDay .. '日'
end

-- 返回年月日纯数字部分
-- 如 2024年06月06日 返回 {2024, 6, 6}
local function get_date_nums(date)
    local dt = date or os.date('%Y.%m.%d')
    local nums = split(tostring(dt), '.')
    local y = tostring(tonumber(nums[1]))
    local m = tostring(tonumber(nums[2]))
    local d = tostring(tonumber(nums[3]))

    return { y, m, d }
end

-- 获取时间
local function get_time(input, seg)
    yield(Candidate(input, seg.start, seg._end, os.date('%H:%M:%S'), '〈时间〉'))
    yield(
        Candidate(
            input,
            seg.start,
            seg._end,
            os.date('%H') .. '时' .. os.date('%M') .. '分' .. os.date('%S') .. '秒',
            '〈时间〉'
        )
    )
    yield(
        Candidate(
            input,
            seg.start,
            seg._end,
            num_to_cnnum(tostring(os.date('%H')))
                .. '时'
                .. num_to_cnnum(tostring(os.date('%M')))
                .. '分'
                .. num_to_cnnum(tostring(os.date('%S')))
                .. '秒',
            '〈时间〉'
        )
    )
end

-- 时间向前或向后计算
local function addDaysToDate(days, format) return os.date(format, os.time() + days * 86400) end

-- 从当前日期向前或向后计算
local function get_date(input, seg, days)
    yield(Candidate(input, seg.start, seg._end, addDaysToDate(days, '%Y-%m-%d'), '〈日期〉'))
    yield(Candidate(input, seg.start, seg._end, addDaysToDate(days, '%Y%m%d'), '〈日期〉'))
    local dt_nums = get_date_nums(addDaysToDate(days, '%Y.%m.%d'))
    local dt_str = dt_nums[1] .. '年' .. dt_nums[2] .. '月' .. dt_nums[3] .. '日'
    yield(Candidate(input, seg.start, seg._end, dt_str, '〈日期〉'))
    yield(
        Candidate(
            input,
            seg.start,
            seg._end,
            addDaysToDate(days, '%Y年%m月%d日'),
            '〈日期〉'
        )
    )
    yield(
        Candidate(
            input,
            seg.start,
            seg._end,
            date_to_cnstr(addDaysToDate(days, '%Y.%m.%d')),
            '〈日期〉'
        )
    )
end

local function get_date_time(input, seg, days)
    yield(
        Candidate(
            input,
            seg.start,
            seg._end,
            addDaysToDate(days, '%Y-%m-%d %H:%M:%S'),
            '〈日期时间〉'
        )
    )
    yield(
        Candidate(
            input,
            seg.start,
            seg._end,
            addDaysToDate(days, '%Y%m%d %H:%M:%S'),
            '〈日期时间〉'
        )
    )

    local dt_nums = get_date_nums(addDaysToDate(days, '%Y.%m.%d'))
    local dt_str = dt_nums[1]
        .. '年'
        .. dt_nums[2]
        .. '月'
        .. dt_nums[3]
        .. '日 '
        .. os.date('%H:%M:%S')
    yield(Candidate(input, seg.start, seg._end, dt_str, '〈日期时间〉'))
    yield(
        Candidate(
            input,
            seg.start,
            seg._end,
            addDaysToDate(days, '%Y年%m月%d日 %H时%M分%S秒'),
            '〈日期时间〉'
        )
    )
    yield(
        Candidate(
            input,
            seg.start,
            seg._end,
            date_to_cnstr(addDaysToDate(days, '%Y.%m.%d'))
                .. ' '
                .. num_to_cnnum(tostring(os.date('%H')))
                .. '时'
                .. num_to_cnnum(tostring(os.date('%M')))
                .. '分'
                .. num_to_cnnum(tostring(os.date('%S')))
                .. '秒',
            '〈日期时间〉'
        )
    )
end

-- 获取本月相邻月份同一天时的日期
-- 比如今天是 2024-05-13，则可获取 2024-04/6-13 的日期
-- today: 当天日期
-- is_next: true 表示获取下个月，fase 表示获取上个月
-- retrun: 返回结果表示与当天相差的天数
local function get_month_sameday(is_next)
    local offset_days = 0
    local this_year, this_month = os.date('%Y', os.time()), os.date('%m', os.time())
    local now_days = os.date('%d', os.time()) -- 本月第几天

    local last_month, next_month = 0, 0
    local this_day_amount = 0
    local last_day_amount = 0
    local next_day_amount = 0

    if is_next then
        -- 如果现在是12月份，需要向后推一年
        if this_month == 12 then
            last_month, next_month = this_month - 1, 1
        else
            last_month, next_month = this_month - 1, this_month + 1
        end

        this_day_amount =
            os.date('%d', os.time({ year = this_year, month = this_month + 1, day = 0 }))
        next_day_amount =
            os.date('%d', os.time({ year = this_year, month = next_month + 1, day = 0 }))

        -- 如果时间间隔超出了下个月的最后一天，则按最后一天算
        local temp_offset_max = this_day_amount
        local temp_offset_min = this_day_amount - now_days + next_day_amount
        if now_days >= next_day_amount then
            offset_days = temp_offset_min
        else
            offset_days = temp_offset_max
        end
    else
        -- 如果当前是1月份，需要向前推一年
        if this_month == 1 then
            last_month, next_month = 12, this_month + 1
        else
            last_month, next_month = this_month - 1, this_month + 1
        end

        this_day_amount =
            os.date('%d', os.time({ year = this_year, month = this_month + 1, day = 0 }))
        last_day_amount =
            os.date('%d', os.time({ year = this_year, month = last_month + 1, day = 0 }))

        -- 如果时间间隔超出了下个月的最后一天，则按最后一天算
        if now_days <= last_day_amount then
            offset_days = last_day_amount
        else
            offset_days = now_days
        end
    end

    return offset_days
end

local normal_symbol_len = 4
-- TODO: support fdate3m to get date after 3 months
--- @param input string
local function str_to_datetime(input, seg)
    if not input or #input < normal_symbol_len then return end
    local symbol = input:sub(1, normal_symbol_len)
    if
        #input > normal_symbol_len
        and input:sub(normal_symbol_len + 1, normal_symbol_len + 1) == 'f'
    then
        symbol = symbol .. 'f'
    end
    local number = nil
    if #input > #symbol then number = input:sub(#symbol + 1):match('^[+-]?%d+') end
    local unit = nil
    if number == nil then
        if #input == #symbol + 1 then
            unit = input:sub(#symbol + 1, #symbol + 1)
        elseif #input > #symbol then
            return
        end
    elseif #symbol + #number + 1 == #input then
        unit = input:sub(#input, #input)
    end
    local parsed_len = #symbol + (number and #number or 0) + (unit and #unit or 0)
    if parsed_len ~= #input then return end

    if symbol:match(SpecialFunctionToKey.time) then
        get_time(symbol, seg)
    elseif symbol:match(SpecialFunctionToKey.date) then
        get_date(symbol, seg, number and tonumber(number) or 0)
    elseif symbol:match(SpecialFunctionToKey.dati) then
        get_date_time(symbol, seg, number and tonumber(number) or 0)
    end
end

return str_to_datetime
