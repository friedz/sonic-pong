#!/usr/bin/env ruby

require 'qml'
require File.dirname(__FILE__) + '/sc/dispatcher.rb'


class Sound
	def initialize
		puts "New Sound"
		@d = SC::Dispatcher.new
		@d.interpret_silent("s.boot;")
		@d.interpret_silent("p = ProxySpace.push(s);")
		@d.interpret_silent("~x.play;")
		@d.interpret_silent("~y.play;")
		@d.interpret_silent("~pad.play;")
		@d.interpret_silent("~pong.play;")
		@d.interpret_silent("~pong = { Pan2.ar(PMOsc.ar(~x), ~y + ~pad) }")
		puts "New Sound"
	end
	def bounce fx, fy, tx, ty, t
		@d.interpret_silent("~x = { Line.ar(#{x_to_f fx}, #{x_to_f tx}, #{t_to_t t}) }")
		@d.interpret_silent("~y = { Line.ar(#{y_to_s fy}, #{y_to_s ty}, #{t_to_t t}) }")
	end
	def change p
		@d.interpret_silent("~pad = #{y_to_s p}")
	end
	def t_to_t t
		return t/100.0
	end
	def x_to_f x
		return x*6 + 200
	end
	def y_to_s y
		return y/50.0 - 1
	end
	def stop
		@d.interpret_silent("~pong.stop;")
		@d.interpret_silent("s.quit")
	end
end

module Pong
	VERSION = "1.0"
	include QML::Access

	class Ball
		attr_reader :steigung, :yachsenabschnitt
		#include QML::Access
		#register_to_qml
		attr_reader :currentVector
		def initialize a, b, direction, frame
			@steigung = a
			@yachsenabschnitt = b
			@direction = direction #Richtung zu der Ball hingeht
      
			@frame = frame
			#Vektor fuer Uebergabe an playSound() in frame
			@currentVector = [@steigung, @yachsenabschnitt, @direction]
		end
		def reset
			@steigung = 0
			@yachsenabschnitt = 50
			@currentVector[0] = @steigung
			@currentVector[1] = @yachsenabschnitt			
		end
		def time
			# TODO const faktor zu x
		end
		def x # Berechnung x-Wert des Balles neue Position mittels x=(y-yachsenabschnitt)/steigung
			res = if 0 == @direction then #Res speichert Zwischenposition des x-Werts

				#Ball bewegt sich nach links
				if 0 < @steigung then
					(0 - @yachsenabschnitt ) / @steigung
				elsif 0 == @steigung
					0
				else # Steigung groesser 0
					(100 - @yachsenabschnitt) / @steigung
				end
			else #Ball bewegt sich nach rechts
				if 0 < @steigung then
					(100 - @yachsenabschnitt) / @steigung
				elsif 0 == @steigung then
					100
				else
					-@yachsenabschnitt / @steigung
				end
			end
			#Setzt X-Wert der neuen Position des Balles auf x-Wert des Spielfeldrands
			if res < 0 then
				@x = 0
			elsif res > 100
				@x = 100
			else
				@x = res
			end
			return @x
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
			if x.round == 0 then #Spiegelung der Geraden an X=0
				# @yachsenabschnitt = @yachsenabschnitt
				@steigung = -@steigung
				unless @frame.leftPaddle.collision(y).nil?  #Prüft, ob Ball den Schläger trifft,
					#Ergebnis von Collision: nil wenn nicht trifft oder Wert, um den sich die Steigung ändert
					@steigung += @frame.leftPaddle.collision y
				else
					reset
					@frame.score 0
					return
				end
				@direction = 100
			elsif x.round == 100 then #Spiegelung der Geraden an X=100
				@steigung = -@steigung
				unless @frame.rightPaddle.collision(y).nil?
					@steigung += @frame.rightPaddle.collision y
				else
					reset
					@frame.score 100
					return
				end
				@yachsenabschnitt = y - @steigung * 100
				@direction = 0
			elsif y.round == 0 then #Spiegelung der Geraden an Y=0
				@steigung = -@steigung
				@yachsenabschnitt = -@yachsenabschnitt
				# @direction = @direction
			elsif y.round == 100 then #Spiegelung der Geraden an Y=100
				@steigung = -@steigung
				@yachsenabschnitt = 2*100 - @yachsenabschnitt
				# @direction = @direction
			end
			#@steigung += change
			puts "Ball.bounce(#{x}, #{y})"
		end
	end

	class Paddle
		# attr_reader creates getter/setter methods (here called size and pos) which in turn create instance variables called @size and @pos
		attr_accessor :size, :pos
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
			puts "collision #{y} (size: #{self.size}, pos: #{self.pos})"
			diff = y - pos
			if diff.abs > self.size + 1 then
				# Schläger nicht getroffen
				puts "score"
				return nil
				#return 0
			elsif 0 == diff then
				return 0
			else # diff < 0
				#Wert zwischen 0 und 2, zusätzliche Beschleunigung (addiert Wert auf Steigung)
				return self.side * diff/self.size #* (y>self.pos ? -1 : 1)
				# zum debugen vereinfacht nur -1 oder 1
				#if self.side < 0 then
				#	return y > self.pos ? -1 : 1
				#else
				#	return y > self.pos ? 1 : -1
				#end
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

		# property() setzt Dinge, die dann in QML verfügbar sind
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
		signal :resetBall, []

		def change
			puts "change"
		end
		def stoped
			puts "stoped"
		end

		def score direction
			if 0 == direction then
				puts "Right #{@score_right}    #{@score_right.class}"
				#self.score_right = (self.score_right.to_i + 1).to_s
				@score_right += 1
			else
				puts "Left #{@score_left}    #{@score_left.class}"
				#self.score_left = (self.score_left.to_i + 1).to_s
				@score_left += 1
			end
			@last_x = 50
			@last_y = 50
			self.to_y = 50
			self.to_x = direction
			self.time = 3000
			resetBall.emit
			runBall.emit
		end

		def right_score
			return @score_right
		end
		def left_score
			return @score_left
    end

		# TODO ----------------------------------------------------------
		# playSound() besorgt sich, durch QML getriggert, aktiv
		# ball.currentVector
		# und loest das Abspielen des Sounds über die Shell aus.
		# Die Funktion gehoert zu frame, weil aus Gruenden nur frame mit
		# QML kommuniziert.
		def playSound()
			puts "\n playSound called" # Debugging-Output
			spawn 'sonic_pi play 50'
			puts "\n" + currentVector = ball.currentVector.to_s

			# startSound nach aufprall = aktueller sound (oben)
			# soll sich ändern nach neuer (x,y)-Wert aus x(), y()
			# über berechnete Zeit <- return-wert bounce(x,y)?



			#puts self.ball.currentVector.to_s
			#puts '\ncurrentVector acquired'
			# dummyFunctionInScrubyCode(currentVector)
			# puts '\ncurrentVector pushed to scruby-function'
		end

		def bounce x, y #Wird von Grafik aufgerufen, wenn Animation fertig.
		# Berechnet Zeit, wie lange die Animation braucht, bis zum nächsten Aufprall
			if @last_x == x and @last_y == y then
				return
			end
			#$d.interpret_silent("~pong = { SinOsc.ar(Linen.kr(150, 10, 500, 0)).dup };")
			@last_x = x
			@last_y = y
			#puts "X: #{x} Y: #{y} Win: #{self.width}x#{self.height}"
			#puts "X: #{x} Y: #{y}"
			#@ball.bounce(x, y)
			@ball.bounce(self.to_x, self.to_y)
			self.to_x = @ball.x()
			self.to_y = @ball.y()
			self.time = (@last_x-self.to_x).abs * 40
			puts "Count: #{self.count}"
			#Vektor setzen

			runBall.emit # Teilt GUI mit, dass Animation für Ball neu gestartet werden soll
			puts "X: #{x} Y: #{y} Steigung: #{ball.steigung}, Y-Achse: #{ball.yachsenabschnitt}, to_X: #{to_x}, to_Y: #{to_y}"
		end
		def sound
			puts "Sound"
			@audio.bounce @last_x, @last_y, @to_x, @to_y, @time
			0
		end
		def move_pad pad
			@audio.change pad
			0
		end
		def initialize #Konstruktor
			self.to_x = 100 * Random.new.rand(0..1) # Setzt zufällig die Richtung des Balles beim Start fest
			self.to_y = 50 #Ball bewegt sich als erstes waagerecht
			self.time = 2000 #Erzeugt Zeit, die benötigt wird, bis Ball auf Spielfeldrand auftrifft
			self.ball = Ball.new 0, 50, self.to_x, self #Instanz eines Balles
			@score_left = 0
			@score_right = 0
			@last_x = 50
			@last_y = 50
			@audio = Sound.new
			runBall.emit #Startet Animation von Ball, funktioniert aber nicht...
			#self.leftPaddle.side = 2
			#self.rightPaddle.side = -2
		end
	end
end

#at_exit do
#	$d.interpret_silent("~pong.stop;")
#end

if __FILE__ == $0 then
	#$d.interpret_silent("s.boot;")
	#$d.interpret_silent("p = ProxySpace.push(s);")
	#$d.interpret_silent("~pong.play;")
	QML.run do |app|
		app.load_path Pathname(__FILE__) + '../pong.qml'
	end
	puts "end"
end
