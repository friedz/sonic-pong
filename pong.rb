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
			@yachsenabschnitt= b
			@direction = direction #Richtung zu der Ball hingeht

			@frame = frame

		end
		def reset
			@steigung = 0
			@yachsenabschnitt = 50
		end
		def time
			# TODO const faktor zu x
		end
		def x # Berechnung x-Wert des Balles neue Position mittels x=(y-yachsenabschnitt)/steigung
			res = if 0 == @direction then #Res speichert Zwischenposition des x-Werts
				# Ball bewegt sich nach links
				if 0 < @steigung then
					(0-@yachsenabschnitt )/ @steigung
				elsif 0 == @steigung
					0
				else # Steigung groeßer 0
					(100 - @yachsenabschnitt) / @steigung
				end
			else #Ball bewegt sich nach rechts
				if 0 < @steigung then
					(100 - @yachsenabschnitt) / @steigung
				elsif 0 == @steigung then
					100
				else
					-@yachsenabschnitt/ @steigung
				end
			end
			#Setzt X-Wert der neuen Position des Balles auf x-Wert des Spielfeldrands
			if res < 0 then
				return 0
			elsif res > 100
				return 100
			else
				return res
			end
		end
		def y #Berechnung Y-Wert der Position des Balles
			puts "#{@steigung} * #{x()} + #{@yachsenabschnitt} = #{x() * @steigung + @yachsenabschnitt}"
			res = x() * @steigung + @yachsenabschnitt
			if res > 100 then
				return 100
			elsif res < 0 then
				return 0
			else
				return res
			end
		end
		def line
		end
		def bounce(x, y) #Überprüfe, was passieren soll, wenn Ball an einen Spielfeldrand ankommt
			#change = if 0 == @direction then
			#						@frame.leftPaddle.collision y
			#				 else
			#						@frame.rightPaddle.collision y
			#				 end
			#if change.nil? then
			#	puts "reset"
			#	change = 0
			#end

			#Bisher nicht betrachtete Fall: Ball trifft genau an der Ecke auf
			#Methode für Ball trifft nicht Schläger noch nicht implementiert
			if y.round == 0 then #Spiegelung der Geraden an Y=0
				@steigung = -@steigung
				@yachsenabschnitt = -@yachsenabschnitt
				# @direction = @direction
			elsif y.round == 100 then #Spiegelung der Geraden an Y=100
				@steigung = -@steigung
				@yachsenabschnitt = 2*100 - @yachsenabschnitt
				# @direction = @direction
			elsif x.round == 0 then #Spiegelung der Geraden an X=0
				# @yachsenabschnitt = @yachsenabschnitt
				@steigung = -@steigung
				unless @frame.leftPaddle.collision(y).nil?  #Prüft, ob Ball den Schläger trifft,
					#Ergebnis von Collision: nil wenn nicht trifft oder Wert, um den sich die Steigung ändert
					@steigung += @frame.leftPaddle.collision y
				end
				@direction = 100
			elsif x.round == 100 then #Spiegelung der Geraden an X=100
				@yachsenabschnitt = (2 * y) - @yachsenabschnitt
				@steigung = -@steigung
				unless @frame.rightPaddle.collision(y).nil?
					@steigung += @frame.rightPaddle.collision y
				end
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

		property(:pos) { 50 } #Startposition von der Mitte des Schlägers (Y-Wert)
		property(:size) { 15 } #Höhe des Schlägers ausgehend von der Mitte bis zum Rand
		property(:side) { 0 }

		signal :move, []

		@@step_size = 0.01
		@@step_time = 0.0001

		def initialize #Konstruktor
			puts "Paddle.new"
			@mutex ||= Mutex.new
		end
		def collision y #Überprüft, ob Schläger getroffen wurde, Rückgabewert: float (später float oder nil)
			puts "collision #{y} (size: #{self.size})"
			diff = y - pos
			if diff.abs > self.size then
				# Schläger nicht getroffen
				puts "score"
				return nil
				#return 0
			elsif 0 == diff then
				return 0
			else # diff < 0
				#return self.side * diff/self.size #Wert zwischen 0 und 2, zusätzliche Beschleunigung (addiert Wert auf Steigung)
				# zum debugen vereinfacht nur -1 oder 1
				if self.side < 0 then
					return -1
				else
					return 1
				end
			end
		end
		def up #Bewegung vom Schläger anschaulich nach unten
			@movement = :up
			unless @mutex.locked?
				Thread.new do
					@mutex.synchronize  do
						while (:up == @movement)
							self.pos += @@step_size
							if self.pos >= 100
								self.pos = 100
							end
							move.emit
							sleep(@@step_time)
						end
					end
				end
			end
			0
		end
		def down #Bewegung vom Schläger anschaulich nach oben
			@movement = :down
			unless @mutex.locked?
				Thread.new do
					@mutex.synchronize  do
						while (:down == @movement)
							self.pos -= @@step_size
							if self.pos <= 0
								self.pos = 0
							end
							move.emit
							sleep(@@step_time)
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

	class Frame # 0-Punkt des Spielfeldes oben links mit positiven Achsen nach unten und rechts
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

		def bounce x, y #Wird von Grafik aufgerufen, wenn Animation fertig.
		# Berechnet Zeit, wie lange die Animation braucht, bis zum nächsten Aufprall
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
			runBall.emit # Teilt GUI mit, dass Animation für Ball neu gestartet werden soll
		end

		def initialize #Konstruktor
			self.to_x = 100 * Random.new.rand(0..1) # Setzt zufällig die Richtung des Balles beim Start fest
			self.to_y = 50 #Ball bewegt sich als erstes waagerecht
			self.time = 2000 #Erzeugt Zeit, die benötigt wird, bis Ball auf Spielfeldrand auftrifft
			self.ball = Ball.new 0, 50, self.to_x, self #Instanz eines Balles
			runBall.emit #Startet Animation von Ball, funktioniert aber nicht...
			#self.leftPaddle.side = 2
			#self.rightPaddle.side = -2
		end
	end
end

QML.run do |app|
	app.load_path Pathname(__FILE__) + '../pong.qml'
end
