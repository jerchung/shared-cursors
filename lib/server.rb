require 'rubygems'
require 'bundler/setup'

require 'em-websocket'
require_relative 'cursor.rb'
require 'json'

class Server

  def initialize(opts)
    @cursors = {}
    @id = 1
    run(opts)
  end

  def run(opts)
    EM.run {
      EM::WebSocket.start(opts) do |ws|
        ws.onopen { |handshake|
          add_client(@id, ws)
          ws.send({:type => :new, :id => @id}.to_json)
          populate_initials(ws)
          send_all({:type => :create, :id => @id, :x => 0, :y => 0, :display => "none"})
          @id += 1
        }

        #Remove the cursor
        ws.onclose {
          del_id = @cursors[ws].id
          @cursors.delete(ws)
          send_all({:type => :del, :id => del_id})
        }

        # clients will send messages to update cursor position
        ws.onmessage { |msg|
          handle_message(ws, msg)
        }
      end
    }
  end

  def add_client(id, ws)
    cursor = Cursor.new(id, ws)
    @cursors[ws] = cursor
  end

  def handle_message(ws, msg)
    parsed_msg = JSON.parse(msg)
    if not parsed_msg.has_key?("type")
      ws.send "Invalid Message"
      return
    end

    cursor = @cursors[ws]
    case parsed_msg["type"]
    when "update"
      cursor.x, cursor.y = parsed_msg["x"], parsed_msg["y"]
      update_msg = {:type => :update, :id => cursor.id, :x => cursor.x, :y => cursor.y}
      send_all(update_msg)
    else
      ws.send "Invalid Message"
    end

  end

  def populate_initials(ws)
    @cursors.each do |alt_ws, c|
      ws.send({
        :type => :create,
        :id => c.id,
        :x => c.x,
        :y => c.y,
        :display => "block"
      }.to_json)
    end
  end

  def send_all(msg)
    msg_json = msg.to_json
    puts msg_json
    @cursors.each do |ws, cursor|
      ws.send(msg_json)
    end
  end

end

Server.new(:host => "0.0.0.0", :port => 8080, :debug => true)