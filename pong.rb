#!/usr/bin/env ruby

require 'qml'

module Pong
	VERSION = "1.0"
	include QML::Access
	#register_to_qml under: "Pong", version: "1.0"

	class Ball
		include QML::Access
		register_to_qml
		def initialize a, b, direction
			@a = a
			@b = b
			@direction = direction
		end
		def reset
			@a = 0
			@b = 50
		end
		def time
			# TODO const faktor zu x
		end
		def x
			res = if 0 == @direction then
				if 0 < @a then
					-@b / @a
				elsif 0 == @a
					0
				else
					(100 - @b) / @a
				end
			else
				if 0 < @a then
					(100 - @b) / @a
				elsif 0 == @a then
					100
				else
					-@b / @a
				end
			end
			if res < 0 then
				return 0
			elsif res > 100
				return 100
			else
				return res
			end
		end
		def y
			puts "#{@a} * #{x()} + #{@b}"
			x() * @a + @b
		end
		def line
		end
		def bounce(x, y)
			#if @last_x == x and @last_y == y then
			#	return
			#end
			#@last_x = x
			#@last_y = y
			if y == 0 then
				@a = -@a
				@b = -@b
			elsif y == 100 then
				@a = -@a
				@b = 2*100 - @b
			elsif x == 0 then
				# @b = @b
				# @a = @a
				@direction = 100
			elsif x == 100 then
				@b = (2 * y) - @b
				# @a = @a
				@direction = 0
			end
			puts "Ball.bounce(#{x}, #{y})"
		end
	end

	class Paddle
		attr_reader :size, :pos

		include QML::Access
		register_to_qml

		property(:pos) { 50 }
		property(:size) { 15 }

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
		property(:ball) { Ball }
		property(:height) { 0 }
		property(:width) { 0 }
		property(:to_x) { 100 }
		property(:to_y) { 50 }
		property(:time) { 2000 }

		signal :runBall, []

		on_changed :leftPaddle do
			puts "Left Paddle changed"
		end
		on_changed :rightPaddle do
			puts "Right Paddle changed"
		end

		def change
			puts "change"
		end
		def stoped
			puts "stoped"
		end

		def bounce x, y
			if @last_x == x and @last_y == y then
				return
			end
			@last_x = x
			@last_y = y
			#puts "X: #{x} Y: #{y} Win: #{self.width}x#{self.height}"
			puts "X: #{x} Y: #{y}"
			@ball.bounce(x, y)
			self.to_x = @ball.x()
			self.to_y = @ball.y()

			#self.to_x = (self.to_x + 10) % 100
			#if x == 0 then
			#	# TODO check collision leftPaddle
			#	if (self.leftPaddle.pos - x).abs > self.leftPaddle.size then
			#		#	change score
			#		self.to_y = 50
			#		self.to_x = 0
			#		#@ball.reset
			#	else
			#		#@ball.bounce(x, y)
			#	end
			#elsif x == 100 then
			#	# TODO check collision rightPaddle
			#	if (self.rightPaddle.pos - x).abs > self.rightPaddle.size then
			#		#change score
			#		self.to_y = 50
			#		self.to_x = 100
			#		@ball.reset
			#		#run.emit
			#	else
			#		#ball.bounce(x, y)
			#	end
			#else
			#	# TODO ball.bounce(x, y)
			#	#@ball.bounce(x, y)
			#end
			#if to_x == 100 then
			#	self.to_x = 0
			#else
			#	self.to_x = 100
			#end
			#if to_y == 100 then
			#	self.to_y = 0
			#else
			#	self.to_y = 100
			#end
			self.time = (x-self.to_x).abs * 40
			runBall.emit
		end

		def initialize
			self.to_x = 100 * Random.new.rand(0..1)
			self.to_y = 50
			self.time = 2000
			self.ball = Ball.new 0, 50, self.to_x
			runBall.emit
		end
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
