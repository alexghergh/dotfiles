-- battery status, using the built-in wezterm.battery_info()
--
-- time_to_empty / time_to_full from battery_info() is preferred when non-nil, but uses sysfs on
-- asahi linux where the macsmc-battery driver reports power_now as a signed negative value when
-- discharging, which the starship-battery crate (used by wezterm) filters out
--
-- since battery_info() (and sysfs) read instant system values, they man to be stable immediately
-- after plugging / unplugging; therefore, we use a smoothing system that alleviates initial
-- jitters, after which the user gets a good baterry reading
local wezterm = require('wezterm')

local bat = {}

-- sysfs fallback read
local function read_sysfs_number(path)
    local f = io.open(path, 'r')
    if not f then
        return nil
    end
    local val = tonumber(f:read('*l'))
    f:close()
    return val
end

-- raw minutes from sysfs; fallback for when battery_info() returns nil
local function sysfs_raw_minutes(mode)
    local base = '/sys/class/power_supply/macsmc-battery/'
    local energy_now = read_sysfs_number(base .. 'energy_now')
    local energy_full = read_sysfs_number(base .. 'energy_full')
    local power = read_sysfs_number(base .. 'power_now')
    if not energy_now or not energy_full or not power or power == 0 then
        return nil
    end
    if mode == 'charging' then
        return (energy_full - energy_now) / math.abs(power) * 60
    elseif mode == 'discharging' then
        return energy_now / math.abs(power) * 60
    end
end

-- raw minutes from whichever source is available: wezterm's battery_info() first, then sysfs as
-- fallback; both these sources are instant values that may differ vastly from call to call
local function raw_minutes(b, mode)
    if mode == 'discharging' and b.time_to_empty then
        return b.time_to_empty / 60
    elseif mode == 'charging' and b.time_to_full then
        return b.time_to_full / 60
    end
    return sysfs_raw_minutes(mode)
end

-- initial plug / unplug smoothing: warmup phase collects 1/s for up to WARMUP_MAX_SECS secs (or
-- until stable), then steady phase samples every few seconds over a longer sliding window period,
-- deleting older samples
local samples = {}
local last_mode = nil
local warmup_done = false
local last_sample_time = 0

-- stylua: ignore start
local WARMUP_MAX_SECS = 30          -- max warmup duration on plug / unplug events
local WARMUP_STABLE_COUNT = 4       -- consecutive samples within tolerance to end warmup early
local WARMUP_STABLE_TOLERANCE = 10  -- minutes
local STEADY_INTERVAL = 5           -- seconds between samples after warmup
local STEADY_WINDOW = 120           -- seconds of history to keep
-- stylua: ignore end

local function samples_average()
    local sum = 0
    for _, s in ipairs(samples) do
        sum = sum + s.v
    end
    return math.floor(sum / #samples)
end

-- readings are stable when WARMUP_STABLE_COUNT consecutive counts are within max
-- WARMUP_STABLE_TOLERANCE minutes of each other
local function is_stable()
    if #samples < WARMUP_STABLE_COUNT then
        return false
    end
    local lo, hi = math.huge, -math.huge
    for i = #samples - WARMUP_STABLE_COUNT + 1, #samples do
        local v = samples[i].v
        if v < lo then
            lo = v
        end
        if v > hi then
            hi = v
        end
    end
    return (hi - lo) <= WARMUP_STABLE_TOLERANCE
end

-- returns minutes (number), "warmup" (string), or nil
local function smoothed_minutes(b, mode)
    local now = os.time()

    -- reset on mode change (i.e. plug / unplug)
    if mode ~= last_mode then
        samples = {}
        last_mode = mode
        warmup_done = false
        last_sample_time = 0
    end

    -- decide whether to take a sample this tick
    local interval = warmup_done and STEADY_INTERVAL or 1
    if (now - last_sample_time) < interval then
        if not warmup_done then
            return 'warmup'
        end
        if #samples == 0 then
            return nil
        end
        return samples_average()
    end

    local raw = raw_minutes(b, mode)
    if not raw then
        return nil
    end

    last_sample_time = now
    table.insert(samples, { t = now, v = raw })

    -- warmup phase
    if not warmup_done then
        if (now - samples[1].t) >= WARMUP_MAX_SECS or is_stable() then
            warmup_done = true
        else
            return 'warmup'
        end
    end

    -- steady phase: prune old samples
    while #samples > 1 and (now - samples[1].t) > STEADY_WINDOW do
        table.remove(samples, 1)
    end

    return samples_average()
end

-- return a formatted status string for each battery, joined by " | "
-- for each battery available on the system, reports mode (charging / discharging) and
-- time to empty / full
-- uses wezterm's battery_info() if information available, but falls back on sysfs readings for
-- Asahi Linux
function bat.status()
    local parts = {}
    for _, b in ipairs(wezterm.battery_info()) do
        local label = ''
        if b.state == 'Charging' then
            label = 'Ch.'
        elseif b.state == 'Discharging' then
            label = 'Disch.'
        end

        local text = string.format('%.0f%%', b.state_of_charge * 100)
        if label ~= '' then
            text = label .. ' ' .. text
        end

        if b.state == 'Discharging' then
            local min = smoothed_minutes(b, 'discharging')
            if min == 'warmup' then
                text = text .. ', calculating...'
            elseif min then
                text = text .. string.format(', ~%d:%02d rem.', math.floor(min / 60), min % 60)
            end
        elseif b.state == 'Charging' then
            local min = smoothed_minutes(b, 'charging')
            if min == 'warmup' then
                text = text .. ', calculating...'
            elseif min then
                text = text .. string.format(', ~%d:%02d to full', math.floor(min / 60), min % 60)
            end
        end

        table.insert(parts, text)
    end
    return table.concat(parts, ' | ')
end

return bat
