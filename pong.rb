#!/usr/bin/env ruby

require 'qml'

module Pong
	VERSION = "1.0"
	include QML::Access

	class Ball
		#include QML::Access
		#register_to_qml
		def initialize a, b, direction, frame
			@steigung = a
			@yachsenabschnit= b
			@direction = direction
			@frame = frame
		end
		def reset
			@steigung = 0
			@yachsenabschnit= 50
		end
		def time
			# TODO const faktor zu x
		end
		def x
			res = if 0 == @direction then
				if 0 < @steigung then
					-@yachsenabschnit/ @steigung
				elsif 0 == @steigung
					0
				else
					(100 - @yachsenabschnit) / @steigung
				end
			else
				if 0 < @steigung then
					(100 - @yachsenabschnit) / @steigung
				elsif 0 == @steigung then
					100
				else
					-@yachsenabschnit/ @steigung
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
			puts "#{@steigung} * #{x()} + #{@yachsenabschnit} = #{x() * @steigung + @yachsenabschnit}"
			x() * @steigung + @yachsenabschnit
		end
		def line
		end
		def bounce(x, y)
			#change = if 0 == @direction then
			#						@frame.leftPaddle.collision y
			#				 else
			#						@frame.rightPaddle.collision y
			#				 end
			#if change.nil? then
			#	puts "reset"
			#	change = 0
			#end
			if y.round == 0 then
				@steigung = -@steigung
				@yachsenabschnit = - @yachsenabschnit
				# @direction = @direction
			elsif y.round == 100 then
				@steigung = -@steigung
				@yachsenabschnit = 2*100 - @yachsenabschnit
				# @direction = @direction
			elsif x.round == 0 then
				# @yachsenabschnit= @yachsenabschnit
				@steigung = -@steigung
				@steigung += @frame.leftPaddle.collision y
				@direction = 100
			elsif x.round == 100 then
				@yachsenabschnit = (2 * y) - @yachsenabschnit
				@steigung = -@steigung
				@steigung += @frame.rightPaddle.collision y
				@direction = 0
			end
			#@steigung += change
			puts "Ball.bounce(#{x}, #{y})"
		end
	end

	class Paddle
		attr_reader :size, :pos
		#attr_accessor :side

		include QML::Access
		register_to_qml

		property(:pos) { 50 }
		property(:size) { 15 }
		property(:side) { 0 }

		signal :move, []

		@@step = 1

		def initialize
			puts "Paddle.new"
			@mutex ||= Mutex.new
		end
		def collision y
			puts "collision #{y} (size: #{self.size})"
			diff = y - pos
			if diff.abs > self.size then
				#return nil
				puts "score"
				return 0
			#elsif diff < 0 then
			elsif 0 == diff then
				return 0
			else
				return self.side * diff/self.size
			end
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
		property(:count) { 0 }

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
			#puts "X: #{x} Y: #{y}"
			#@ball.bounce(x, y)
			@ball.bounce(self.to_x, self.to_y)
			self.to_x = @ball.x()
			self.to_y = @ball.y()
			self.time = (x-self.to_x).abs * 40
			puts "Count: #{self.count}"
			runBall.emit
		end

		def initialize
			self.to_x = 100 * Random.new.rand(0..1)
			self.to_y = 50
			self.time = 2000
			self.ball = Ball.new 0, 50, self.to_x, self
			runBall.emit
			#self.leftPaddle.side = 2
			#self.rightPaddle.side = -2
		end
	end
end

QML.run do |app|
	app.load_path Pathname(__FILE__) + '../pong.qml'
end
