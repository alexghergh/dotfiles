-- battery and power draw for the status bar, read from linux sysfs
--
-- the battery's `status` says "Charging" whenever a charger is plugged in, even when the system
-- draws more than the charger supplies; the direction comes from the sign of the battery's
-- `power_now` instead, negative while it drains
--
-- `power_now` is an instant reading, so it's smoothed with running averages: a short one for the
-- watts shown, and a long one for the time estimate, which divides the energy left by the averaged
-- power; both restart when the charger is plugged or unplugged
local power = {}

-- stylua: ignore start
local REFRESH_SECS = 5   -- seconds between new readings; the bar shows the last text in between
local WATTS_TAU = 30     -- seconds, running average of the watts shown
local TIME_TAU = 120     -- seconds, running average of the battery power, for the time estimate
local SETTLE_SECS = 10   -- "calculating..." after the charger is plugged or unplugged
local SWITCH_WATTS = 1   -- battery power that switches the display to charging or draining
-- stylua: ignore end

local function read(path)
    local f = io.open(path, 'r')
    if not f then
        return nil
    end
    local value = f:read('*l')
    f:close()
    return value
end

local function read_number(path)
    return tonumber(read(path))
end

-- asahi's battery and charger (macsmc-power driver)
local battery_dir = '/sys/class/power_supply/macsmc-battery/'
local charger_dir = '/sys/class/power_supply/macsmc-ac/'

-- the power sensors of asahi's macsmc-hwmon driver, found by their labels, as the hwmon numbers can
-- change between boots; plain file reads, as `wezterm.glob()` cannot run while `require()` loads
-- this module
local SENSOR_LABELS = { ['AC Input Power'] = 'ac', ['Total System Power'] = 'sys' }
local sensors = {}
for hwmon = 0, 15 do
    for sensor = 1, 15 do
        local base = string.format('/sys/class/hwmon/hwmon%d/power%d_', hwmon, sensor)
        local name = SENSOR_LABELS[read(base .. 'label') or '']
        if name then
            sensors[name] = base .. 'input'
        end
    end
end

-- add a reading to a running average over time (exponential moving average), `{ tau = seconds }`;
-- its window grows with the time since the first reading, up to `tau`, so right after a restart it
-- follows the readings closely
local function update(avg, now, value)
    if not avg.value then
        avg.value, avg.start = value, now
    else
        local tau = math.min(avg.tau, math.max(now - avg.start, 1))
        avg.value = avg.value + (1 - math.exp(-(now - avg.time) / tau)) * (value - avg.value)
    end
    avg.time = now
    return avg.value
end

-- 1.5 -> "1:30"; `os.date()` would wrap at 24 hours
local function hours_minutes(hours)
    local minutes = math.floor(hours * 60 + 0.5)
    return string.format('%d:%02d', math.floor(minutes / 60), minutes % 60)
end

-- charging or draining once the averaged battery power passes `SWITCH_WATTS` either way, then
-- neither once it crosses zero; a load close to what the charger supplies would otherwise flip the
-- display on every refresh
local function direction(current, watts)
    if watts > SWITCH_WATTS then
        return 'charging'
    elseif watts < -SWITCH_WATTS then
        return 'draining'
    elseif (current == 'charging' and watts > 0) or (current == 'draining' and watts < 0) then
        return current
    end
    return nil
end

local state = {}

local function restart(now, online)
    state.online, state.since, state.direction = online, now, nil
    state.battery = { tau = TIME_TAU }
    state.ac = { tau = WATTS_TAU }
    state.sys = { tau = WATTS_TAU }
end

local function battery_text(now, online)
    local capacity = read_number(battery_dir .. 'capacity')
    local power_now = read_number(battery_dir .. 'power_now')
    local energy_now = read_number(battery_dir .. 'energy_now')
    local energy_full = read_number(battery_dir .. 'energy_full')
    if not (capacity and power_now and energy_now and energy_full) then
        return nil
    end
    -- read each time, so a changed charge limit shows right away
    local limit = read_number(battery_dir .. 'charge_control_end_threshold') or 100

    -- sysfs reports micro-watts and micro-watt-hours
    local watts = update(state.battery, now, power_now / 1e6)
    state.direction = direction(state.direction, watts)
    if now - state.since < SETTLE_SECS then
        return string.format('%d%%, calculating...', capacity), capacity
    elseif state.direction == 'charging' then
        local hours = math.max(energy_full * limit / 100 - energy_now, 0) / 1e6 / watts
        local target = limit < 100 and limit .. '%' or 'full'
        return string.format('ch. %d%%, ~%s to %s', capacity, hours_minutes(hours), target),
            capacity
    elseif state.direction == 'draining' then
        local hours = energy_now / 1e6 / -watts
        return string.format('disch. %d%%, ~%s rem.', capacity, hours_minutes(hours)), capacity
    elseif online and limit < 100 and capacity >= limit then
        return string.format('%d%%, held at %d%%', capacity, limit), capacity
    end
    return string.format('%d%%', capacity), capacity
end

-- averaged watts of the sensors that read; the charger's input only while it's plugged in
local function watts(now, online)
    local result = {}
    for _, name in ipairs({ 'ac', 'sys' }) do
        local value = sensors[name] and read_number(sensors[name])
        if value then
            local average = update(state[name], now, value / 1e6)
            if name ~= 'ac' or online then
                result[name] = average
            end
        end
    end
    return result
end

-- the pieces of the status, for the bar to lay out; nil when the system has no battery:
-- `{ capacity = 54, direction = 'charging'|'draining'|nil, battery = 'ch. 54%, ...', ac = 18.2, sys = 21.0 }`,
-- where `ac` and `sys` are nil without a reading
function power.status()
    local now = os.time()
    if state.time and now - state.time < REFRESH_SECS then
        return state.status
    end
    state.time = now

    local online = read(charger_dir .. 'online') == '1'
    if online ~= state.online then
        restart(now, online)
    end

    local battery, capacity = battery_text(now, online)
    if not battery then
        state.status = nil
        return nil
    end
    local w = watts(now, online)
    state.status = {
        capacity = capacity,
        direction = state.direction,
        battery = battery,
        ac = w.ac,
        sys = w.sys,
    }
    return state.status
end

return power
