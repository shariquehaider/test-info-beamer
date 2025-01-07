local font = resource.load_font("assets/font.ttf")

function loadScheduleFromCSV()
  local schedule = {}
  local file = sys.get_ext("Default.csv")
  
  -- Read CSV file line by line
  for line in file:lines() do
      local time, event = line:match("([^,]+),([^,]+)")
      if time and event then
          table.insert(schedule, {time, event})
      end
  end
  return schedule
end

local schedule = loadScheduleFromCSV() or {
  {"09:00", "Team Meeting"},
    {"10:30", "Project Planning"},
    {"12:00", "Lunch Break"},
    {"14:00", "Client Presentation"},
    {"16:00", "Wrap-up"},
}

function getCurrentTime()
  local time = os.date("*t")
  return string.format("%02d:%02d", time.hour, time.min)
end


function renderClock()
  local currentTime = getCurrentTime()

  gl.clear(0, 0, 0, 1)

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
  renderClock()   
  renderSchedule()   
end