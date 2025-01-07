local font = resource.load_font("assets/font.ttf")

local schedule = loadScheduleFromCSV() or {
  {"09:00", "Team Meeting"},
    {"10:30", "Project Planning"},
    {"12:00", "Lunch Break"},
    {"14:00", "Client Presentation"},
    {"16:00", "Wrap-up"},
}

function getCurrentTime()
  return os.date("%H:%M:%S")  -- Use "%H:%M" if you want hours and minutes only
end


function renderClock(currentTime)

  font:write(500, 50, currentTime, 100, 1, 1, 1, 1) 
end

function renderSchedule()
  local yOffset = 200 

  font:write(400, yOffset, "Today's Schedule", 60, 1, 1, 1, 1)
  yOffset = yOffset + 80 


  for _, entry in ipairs(schedule) do
      local time, event = unpack(entry)
      font:write(300, yOffset, time .. " - " .. event, 40, 1, 1, 1, 1)
      yOffset = yOffset + 60
  end
end

function node.render()
  gl.clear(0, 0, 0, 1)
  local currentTime = getCurrentTime()
  renderClock(currentTime)
  renderSchedule()   
end