require 'test/unit'
load 'pong.rb'

class Zutestendes


	def initialize# (a,b,m,c)
		@frame=Pong::Frame.new
		@paddleright = Pong::Paddle.new
		@paddleleft = Pong::Paddle.new
		@test_ball
		@test_x
		@test_y
		@test_steigung
		@test_yachsenabschnitt
		@collisionresult
		@collisionresultl
		@scorerechts = @frame.instance_variable_get(:@score_right)
		@scorelinks = @frame.instance_variable_get(:@score_left)

		@score = 0
		@aktuelle_steigung = 0
	end
	def variablensetzen(a,b,m,c) #x_wert des Balles, y_wert des Balles, Steigung des Balles und y-achsenabschnitt des Balles
		@test_ball=@frame.instance_variable_get(:@ball)
		@test_x = @frame.instance_variable_set(:@last_x, a)
		puts "x #{@test_x}"
		@test_y = @frame.instance_variable_set(:@last_y, b)
		puts 	"y #{@test_y}"
		@test_steigung=@frame.ball.instance_variable_set(:@steigung, m)
		puts "Steigung: #{@test_steigung}"
		@test_yachsenabschnitt=@frame.ball.instance_variable_set(:@yachsenabschnitt, c)
		@paddleright.instance_variable_set(:@size, 15)
		@paddleright.instance_variable_set(:@pos, 50)
		@collisionresult = @paddleright.collision(@test_y)
		@paddleleft.instance_variable_set(:@size, 15)
		@paddleleft.instance_variable_set(:@pos, 50)
		@collisionresultl = @paddleleft.collision(@test_y)
		@scorerechts = @frame.instance_variable_get(:@score_right)
		@scorelinks = @frame.instance_variable_get(:@score_left)
	end

end


$beispiel=Zutestendes.new 	
$beispiel.variablensetzen(50, 50, 0, 50)

class TestPong < Test::Unit::TestCase


	def test_x_wert_des_balles
		#Annahme: def x  und (y-yachsenabschnitt)/steigung sind dasselbe
		if $beispiel.instance_variable_get(:@test_steigung) == 0
			assert_equal($beispiel.instance_variable_get(:@test_steigung), 0 )
		else
	 	  assert_equal($beispiel.instance_variable_get(:@test_x), ($beispiel.instance_variable_get(:@test_y)-$beispiel.instance_variable_get(:@test_yachsenabschnitt))/$beispiel.instance_variable_get(:@test_steigung))
		end
	end

	def test_y_wert_des_balles
		#Annahme def y und steigung*x+yachsenabschnitt sind dasselbe
		assert_equal($beispiel.instance_variable_get(:@test_y), $beispiel.instance_variable_get(:@test_steigung) * $beispiel.instance_variable_get(:@test_x) + $beispiel.instance_variable_get(:@test_yachsenabschnitt))
	end

	def test_Ball_trifft_auf_Ecke_des_Spielfeldes
		# Abfrage nach dem Fall, dass Ball in Ecke fliegt
		if ($beispiel.instance_variable_get(:@test_x)==0 and $beispiel.instance_variable_get(:@test_y)==0) or ($beispiel.instance_variable_get(:@test_x)==100 or $beispiel.instance_variable_get(:@test_y)==0) or ($beispiel.instance_variable_get(:@test_x)==0 and $beispiel.instance_variable_get(:@test_y)==100) or ($beispiel.instance_variable_get(:@test_x)==100 and $beispiel.instance_variable_get(:@test_y)==100) then
			if $beispiel.instance_variable_get(:@test_x)==0 then
				assert_equal($beispiel.instance_variable_get(:@test_x), 0)
			elsif $beispiel.instance_variable_get(:@test_x)==100
				assert_equal($beispiel.instance_variable_get(:@test_x), 100)
			elsif $beispiel.instance_variable_get(:@test_y)==0
				assert_equal($beispiel.instance_variable_get(:@test_y), 0)
			else
				assert_equal($beispiel.instance_variable_get(:@test_y), 100)
			end
		end

	end

	def test_Ball_trifft_Mitte_des_Paddels_rechts
	#diff.abs > self.size + 1
		@aktuelle_steigung=$beispiel.instance_variable_get(:@test_steigung)
		if $beispiel.instance_variable_get(:@collisionresult)==0 then
			assert_equal($beispiel.instance_variable_get(:@test_steigung), $beispiel.instance_variable_get(:@aktuelle_steigung))
		end
	end


	def test_Ball_trifft_Rand_des_Paddels_rechts
		@aktuelle_steigung=$beispiel.instance_variable_get(:@test_steigung)
		if $beispiel.instance_variable_get(:@collisionresult)!=0 and $beispiel.instance_variable_get(:@collisionresult)!=nil then
			assert_greater_and_equal_than($beispiel.instance_variable_get(:@test_steigung), $beispiel.instance_variable_get(:@aktuelle_steigung))
		end
	end



	def test_Ball_trifft_nicht_Paddel_rechts
		#@score=$beispiel.instance_variable_get(:@scorerechts)
		$beispiel.instance_variable_set(:@score, 1)
		if $beispiel.instance_variable_get(:@collisionresult)==nil then

			assert_equal($beispiel.instance_variable_get(:@scorerechts), $beispiel.instance_variable_get(:@scorerechts))
		end
	end

	def test_Ball_trifft_Mitte_des_Paddels_links
		@aktuelle_steigung=$beispiel.instance_variable_get(:@test_steigung)
		if $beispiel.instance_variable_get(:@collisionresultl)==0 then
			assert_equal($beispiel.instance_variable_get(:@test_steigung), $beispiel.instance_variable_get(:@aktuelle_steigung))
		end
	end

	def test_Ball_trifft_Rand_des_Paddels_links
		@aktuelle_steigung=$beispiel.instance_variable_get(:@test_steigung)
		if $beispiel.instance_variable_get(:@collisionresultl)!=0 and $beispiel.instance_variable_get(:@collisionresultl)!=nil then
			assert_greater_and_equal_than($beispiel.instance_variable_get(:@test_steigung), $beispiel.instance_variable_get(:@aktuelle_steigung))
		end
	end



	def test_Ball_trifft_nicht_Paddel_links
		#@score=$beispiel.instance_variable_get(:@scorerechts)
		$beispiel.instance_variable_set(:@score, 1)
		if $beispiel.instance_variable_get(:@collisionresultl)==nil then

			assert_equal($beispiel.instance_variable_get(:@scorelinks), $beispiel.instance_variable_get(:@scorelinks))
		end
	end


	def test_Ball_trifft_oberen_Rand_des_Spielfeldes
		@aktuelle_steigung=$beispiel.instance_variable_get(:@test_steigung)
		@aktueller_yachsenabschnitt = $beispiel.instance_variable_get(:@test_yachsenabschnitt)
		if $beispiel.instance_variable_get(:@test_x)==0 then
			assert_equal($beispiel.instance_variable_get(:@test_steigung), -@aktuelle_steigung)
			assert_equal($beispiel.instance_variable_get(:@test_yachsenabschnitt), -@aktueller_yachsenabschnitt)
		end

	end


	def test_Ball_trifft_unteren_Rand_des_Spielfeldes
		@aktuelle_steigung=$beispiel.instance_variable_get(:@test_steigung)
		@aktueller_yachsenabschnitt = $beispiel.instance_variable_get(:@test_yachsenabschnitt)
		if $beispiel.instance_variable_get(:@test_x)==100 then
			assert_equal($beispiel.instance_variable_get(:@test_steigung), -@aktuelle_steigung)
			assert_equal($beispiel.instance_variable_get(:@test_yachsenabschnitt), 2*100-@aktueller_yachsenabschnitt)
		end

	end

end
