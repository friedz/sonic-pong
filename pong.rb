#!/usr/bin/env ruby

require 'qml'

module Pong
	VERSION = '0.1'

	class Ball
		def initialize x_pos, y_pos
		end
	end

	class Paddle
		attr_reader :size
		def initialize pos, size=10.0
			@pos = pos
			@size = size
		end
		def + n
			@pos += n
		end
		def - n
			@pos -= n
		end
		def up n=1
			@pos += n
		end
		def down n=1
			@pos -= n
		end
	end

	class Frame
		def initialize
		end
		def left_paddle
		end
		def run
			@paddles << Thread.new
			@paddles << Thread.new
		end
	end
end

QML.run do |app|
	app.load_path Pathname(__FILE__) + '../pong.qml'
end
