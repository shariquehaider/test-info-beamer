gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.no_globals()

local font = resource.load_font "roboto.ttf"


function node.render()
  gl.clear(0, 0, 0, 0)
  font:write(500,10, "Hello", 80, 1,1,1,-1)

end