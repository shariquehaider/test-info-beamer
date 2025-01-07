gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.no_globals()
local white = resource.create_colored_texture(1,1,1,1)
local black = resource.create_colored_texture(0,0,0,1)
local font = resource.load_font "roboto.ttf"

local config = (function()
  local rotation = 0
  local progress = "no"
  local config_file = "config.json"

  if CONTENTS["static-config.json"] then
    config_file = "static-config.json"
    print "[WARNING]: will use static-config.json, so config.json is ignored"
  end

  util.json_watch(config_file, function(config)
    print("updated " .. config_file)

    synced = config.synced
    progress = config.progress

    if config.idle.filename == "loading.png" then
        idle_img = nil
    else
        idle_img = resource.load_image(config.idle.asset_name)
    end

    rotation = config.rotation
    portrait = rotation == 90 or rotation == 270

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

function create_clock() 
  local size = 80
  local time = os.date("*t")
  local hours = time.hour % 12
  local minutes = time.min
  local seconds = time.sec
  local w = font:width(hours, size)

  font:write((WIDTH-w)/2, (HEIGHT-size)/2, hours, size,1,1,1,alpha)

end

function node.render()
  gl.clear(0, 0, 0, 0)
  create_clock();
end