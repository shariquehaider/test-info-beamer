gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.no_globals()

local font = resource.load_font "roboto.ttf"
local background_image = resource.load_image("background.png")
local remaining = 0
local total = 0
local started
local x = WIDTH/2
local size = HEIGHT / 4
local config

local bar

util.json_watch("config.json", function(new_config)
    config = new_config
    size = HEIGHT / config.size
    bar = resource.create_colored_texture(unpack(config.fg.rgba))
end)

util.data_mapper{
    set = function(minutes)
        remaining = tonumber(minutes) * 60
        total = remaining
        started = nil
    end,
    play = function()
        if not started then
            started = sys.now()
        end
    end,
    pause = function()
        if started then
            remaining = remaining - (sys.now() - started)
            started = nil
        end
    end,
}

local function seconds_remaining()
    if started then
        return math.max(0, remaining - (sys.now() - started))
    else
        return remaining
    end
end

local function clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

function node.render()
    gl.clear(unpack(config.bg.rgba))
    local text
    local seconds = seconds_remaining()
    if seconds <= 0 then
        text = "Time's up"
    elseif seconds < 60 then
        text = string.format("%d s", seconds)
    elseif seconds % 60 < 1 or seconds > 180 then
        text = string.format("%d m", seconds/60)
    else
        text = string.format("%d m %d s", seconds/60, seconds%60)
    end

    local w = font:width(text, size)
    local target_x = (WIDTH-w)/2
    x = x + clamp((target_x-x) / 10, -10, 10)
    font:write(x, (HEIGHT-size)/2, text, size, unpack(config.fg.rgba))
    gl:draw(background_image, 0, 0)
    if not started and sys.now()%2 > 1 then
        local w = font:width("II", size/2)
        font:write((WIDTH-w)/2, (HEIGHT+size)/2, "II", size/2, unpack(config.fg.rgba))
    end
    if total > 0 then
        local done = 1 - 1 / total * seconds
        bar:draw(0, HEIGHT - HEIGHT/30, WIDTH * done, HEIGHT, 0.4)
    end
end