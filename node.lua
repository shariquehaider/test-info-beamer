gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.no_globals()
local white = resource.create_colored_texture(1,1,1,1)
local black = resource.create_colored_texture(0,0,0,1)
local font = resource.load_font "roboto.ttf"

local config = (function()
  local rotation = 0
  local progress = "no"
  local timer = 5
  local config_file = "config.json"

  if CONTENTS["static-config.json"] then
    config_file = "static-config.json"
    print "[WARNING]: will use static-config.json, so config.json is ignored"
  end

  util.json_watch(config_file, function(config)
    print("updated " .. config_file)

    progress = config.progress
    timer = config.timer
    if config.idle.filename == "loading.png" then
        idle_img = nil
    else
        idle_img = resource.load_image(config.idle.asset_name)
    end

    rotation = config.rotation

    gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
    transform = util.screen_transform(rotation)

    playlist = {}
    for _, item in ipairs(config.playlist) do
        if item.duration > 0 then
            local format = item.file.metadata and item.file.metadata.format
            local duration = item.duration + (
                -- On legacy OS versions prior to v14:
                -- Stretch play slot by HEVC load time, as HEVC
                -- decoders cannot overlap, so we have to load
                -- the video while we're scheduled, instead
                -- of preloading... maybe that'll change in the
                -- future.
                (format == "hevc" and legacy_hevc) and settings.HEVC_LOAD_TIME or 0
            )
            playlist[#playlist+1] = {
                duration = duration,
                format = format,
                asset = resource.open_file(item.file.asset_name),
                type = item.file.type,
                schedule = expand_schedule(config, item.schedule),

                -- include playlist properties for simplicity
                audio = config.audio,
                switch_time = config.switch_time,
                kenburns = config.kenburns,
            }
        end
    end
  end)
  return {
    get_timer = function() return timer end;
    get_progress = function() return progress end;
    get_rotation = function() return rotation, portrait end;
}
end)()

local function draw_progress(starts, ends, now)
  local mode = Config.get_progress()
  if mode == "no" then
      return
  end

  if ends - starts < 2 then
      return
  end

  local progress = 1.0 / (ends - starts) * (now - starts)
  if mode == "bar_thin_white" then
      white:draw(0, HEIGHT-10, WIDTH*progress, HEIGHT, 0.5)
  elseif mode == "bar_thick_white" then
      white:draw(0, HEIGHT-20, WIDTH*progress, HEIGHT, 0.5)
  elseif mode == "bar_thin_black" then
      black:draw(0, HEIGHT-10, WIDTH*progress, HEIGHT, 0.5)
  elseif mode == "bar_thick_black" then
      black:draw(0, HEIGHT-20, WIDTH*progress, HEIGHT, 0.5)
  elseif mode == "circle" then
      shaders.progress:use{
          progress_angle = math.pi - progress * math.pi * 2
      }
      white:draw(WIDTH-40, HEIGHT-40, WIDTH-10, HEIGHT-10)
      shaders.progress:deactivate()
  elseif mode == "countdown" then
      local remaining = math.ceil(ends - now)
      local text
      if remaining >= 60 then
          text = string.format("%d:%02d", remaining / 60, remaining % 60)
      else
          text = remaining
      end
      local size = 32
      local w = font:width(text, size)
      black:draw(WIDTH - w - 4, HEIGHT - size - 4, WIDTH, HEIGHT, 0.6)
      font:write(WIDTH - w - 2, HEIGHT - size - 2, text, size, 1,1,1,0.8)
  end
end

function get_ist_time()
  local utc_time = os.time()
  local ist_offset = 5 * 60 * 60 + 30 * 60 
  local ist_time = utc_time + ist_offset

  return ist_time
end

function format_time(seconds)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function get_target_time()
  local current_ist_time = get_ist_time()

  local targetTimeInt = config.get_timer()
  local target_time = current_ist_time + (targetTimeInt * 60) 
  return target_time
end

function format_time(seconds)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  return string.format("%02d:%02d:%02d", hours, minutes, secs)
end


function countdown()
  local target_time = get_target_time()

  while true do
      local current_ist_time = get_ist_time()

      local remaining_time = target_time - current_ist_time

      if remaining_time <= 0 then
          print("Countdown finished!")
          break
      end

      local formatted_time = format_time(remaining_time)
      font:write(500, 50,formatted_time, 80, 1,1,1,1)

  end
end

function node.render()
  gl.clear(0, 0, 0, 0)
  countdown()

end