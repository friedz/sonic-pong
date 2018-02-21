require 'test/unit'
load 'pong.rb'

class Zutestendes
	
	
	def initialize #(a,b,m,c)
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
		@scorerechts
		@scorelinks
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
		

$beispiel=Zutestendes.new 	#0, 0, 0, 0
$beispiel.variablensetzen(	50, 50, 0, 50)
		
class TestPong < Test::Unit::TestCase
	@ywert=$beispiel.instance_variable_get(:@test_y)
	puts "ywert #{@ywert}"
	@xwert=$beispiel.instance_variable_get(:@test_x)
	puts "xwert #{@xwert}"
	@yachsenabschnittwert=$beispiel.instance_variable_get(:@test_yachsenabschnitt)
	puts "yachsenabschnitt #{@yachsenabschnittwert}"
	@steigungwert=$beispiel.instance_variable_get(:@test_steigung)
	puts "steigungwert #{@steigungwert}"
	@collision=$beispiel.instance_variable_get(:@collisionresult)
	puts "collision #{@collision}"
	@collisionl=$beispiel.instance_variable_get(:@collisionresultl)
	@scorer = $beispiel.instance_variable_get(:@scorerechts)
	@scorel = $beispiel.instance_variable_get(:@scorelinks)
	puts "scorerechts #{@scorer}"
	

	def test_x_wert_des_balles
		#Annahme: def x  und (y-yachsenabschnitt)/steigung sind dasselbe
		if @steigungwert == 0
			#assert_equal( )
		else
	 	  assert_equal(@xwert, (@ywert-@yachsenabschnittwert)/@steigungwert)
		end
	end

	def test_y_wert_des_balles
		#Annahme def y und steigung*x+yachsenabschnitt sind dasselbe
		assert_equal(@ywert, @steigungwert * @xwert + @yachsenabschnittwert)
	end
			
	def test_Ball_trifft_auf_Ecke_des_Spielfeldes
		# Abfrage nach dem Fall, dass Ball in Ecke fliegt
		if (@xwert== 0 and @ywert=0) or (@xwert==100 or @ywert==0) or (@xwert==0 and @ywert==100) or (@xwert==100 and @ywert==100) then
			if @bxwert==0 then
				assert_equal(@xwert, 0)
			elsif @xwert==100
				assert_equal(@xwert, 100)
			elsif @ywert==0
				assert_equal(@ywert, 0)
			else 
				assert_equal(@ywert, 100)
			end
		end
		
	end

	def test_Ball_trifft_Mitte_des_Paddels_rechts
	#diff.abs > self.size + 1
		@aktuelle_steigung=@steigungwert
		if @collision==0 then
			assert_equal(@steigungwert, @aktuelle_steigung)
		end	
	end
	

	def test_Ball_trifft_Rand_des_Paddels_rechts
		@aktuelle_steigung=@steigungwert
		if @collision!=0 and @collision!=nil then
			assert_greater_and_equal_than(@steigungwert, @aktuelle_steigung)
		end
	end
	

	
	def test_Ball_trifft_nicht_Paddel_rechts
		@score=@scorer
		@score+=1
		if @collision==nil then
		
			assert_equal(@scorer, @score)
		end
	end

	def test_Ball_trifft_Mitte_des_Paddels_links
		@aktuelle_steigung=@steigungwert
		if @collisionl==0 then
			assert_equal(@steigungwert, @aktuelle_steigung)
		end	
	end
	
=begin
	
	def test_Ball_trifft_oberen_Rand_des_Spielfeldes
	
	
	end
	
	def test_Ball_trifft_unteren_Rand_des_Spielfeldes
	end
=end
end









