gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.no_globals()
local white = resource.create_colored_texture(1,1,1,1)
local black = resource.create_colored_texture(0,0,0,1)
local font = resource.load_font "roboto.ttf"


function node.render()
  gl.clear(0, 0, 0, 0)
  font:write(500,10, "Hello", 1,1,1,1)

end