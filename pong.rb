#!/usr/bin/env ruby

require 'qml'

module Pong
	VERSION = "1.0"
	include QML::Access
	#register_to_qml under: "Pong", version: "1.0"

	class Ball
		def initialize x_pos, y_pos
			@x_pos = x_pos
			@y_pos = y_pos
		end
		def time
			# TODO const faktor zu x
		end
		def x_speed
			# TODO const
		end
		def y_speed
		end
		def line
		end
		def bounce(x, y)
		end
	end

	class Paddle
		attr_reader :size, :pos

		include QML::Access
		register_to_qml

		property(:pos) { 50 }
		property(:size) { 10 }

		signal :move, []

		@@step = 1

		def initialize
			puts "Paddle.new"
			@mutex ||= Mutex.new
		end

		def up
			@movement = :up
			unless @mutex.locked?
				Thread.new do
					@mutex.synchronize  do
						while (:up == @movement)
							self.pos += @@step
							if self.pos >= 100
								self.pos = 100
							end
							move.emit
							sleep(0.1)
						end
					end
				end
			end
			0
		end
		def down
			@movement = :down
			unless @mutex.locked?
				Thread.new do
					@mutex.synchronize  do
						while (:down == @movement)
							self.pos -= @@step
							if self.pos <= 0
								self.pos = 0
							end
							move.emit
							sleep(0.1)
						end
					end
				end
			end
			0
		end
		def stop
			@movement = :none
		end
	end

	class Frame
		include QML::Access
		register_to_qml
		@right = 100
		@left = 0
		attr_accessor :left_paddle, :right_paddle

		property(:leftPaddle) { Paddle }
		property(:rightPaddle) { Paddle }
		property(:height) { 0 }
		property(:width) { 0 }
		property(:to_x) { 100 }
		property(:to_y) { 50 }
		property(:time) { 2000 }

		on_changed :leftPaddle do
			puts "Left Paddle changed"
		end
		on_changed :rightPaddle do
			puts "Right Paddle changed"
		end

		def bounce x, y
			puts "X: #{x} Y: #{y} Win: #{self.width}x#{self.height}"
			self.to_x = (self.to_x + 10) % 100
			if x == 0 then
				# TODO check collision leftPaddle
				# if scored then
				#		change score
				#		start new
				#	else
				#		ball.bounce(x, y)
				#	end
			elsif x == 100 then
				# TODO check collision rightPaddle
			else
				# TODO ball.bounce(x, y)
			end
			#if to_x == 100 then
			#	self.to_x = 0
			#else
			#	self.to_x = 100
			#end
			if to_y == 100 then
				self.to_y = 0
			else
				self.to_y = 100
			end
			self.time = 2000
		end

		#def initialize
		#end
		#def initialize
		#	@left_paddle = Paddle.new(50, 30)
		#	@right_paddle = Paddle.new(50, 30)
		#	puts "Left: #{@left_paddle.size} #{@left_paddle.pos}"
		#	puts "Right: #{@right_paddle.size} #{@right_paddle.pos}"
		#end
		#def run
		#	@paddles << Thread.new
		#	@paddles << Thread.new
		#end
	end
end

QML.run do |app|
	app.load_path Pathname(__FILE__) + '../pong.qml'
end
