class Cursor

  attr_accessor :x, :y, :websocket, :id

  def initialize(id, websocket)
  	@id = id
  	@websocket = websocket
  	@x, @y = 0, 0
  end

end