# CONSTANTS
BOX_SIZE = 40
WIDHT = 1280
HEIGHT = 720
BOXES_X = (0..(WIDHT - BOX_SIZE)).select{|n| n % BOX_SIZE == 0}
BOXES_Y = (0..(HEIGHT - BOX_SIZE)).select{|n| n % BOX_SIZE == 0}

# GAME
@game_over = false

# PLAYER MOVEMENT
@x_player_buffer = BOXES_X[BOXES_X.length/2]
@y_player_buffer = BOXES_Y[BOXES_Y.length/2]
@movement = 1 # 60 = 1 second
@velocity = 5
@position = %W(LEFT RIGHT UP DOWN).sample
@body = [[@x_player_buffer, @y_player_buffer],[@x_player_buffer+BOX_SIZE, @y_player_buffer+BOX_SIZE]]
@angle = 0

# SPRITES
@body_sprite = '/sprites/square/green_2.png'
@head_sprite = '/sprites/square/green.png'

# SCORE
@score = 0

def new_food_position
  @x_food = BOXES_X.sample
  @y_food = BOXES_Y.sample
end

# FOOD
new_food_position
@food_sprite = "/sprites/circle/red.png"

def tick args
  args.outputs.background_color = [ 6, 6, 6 ]
  args.outputs.borders << [0, 0, WIDHT-1, HEIGHT-1, 255, 255, 255]

  if @game_over
    args.outputs.labels << [WIDHT/2 - 100, HEIGHT/2, "GAME OVER", 255, 255, 255]
    args.outputs.labels << [WIDHT/2 - 90, HEIGHT/2 - 50, "SCORE #{@score}", 255, 255, 255]
    args.outputs.labels << [WIDHT/2 - 165, HEIGHT/2 - 150, "PRESS ESPACE TO RESTART", 255, 255, 255]
    if args.inputs.keyboard.key_down.space
      @x_player_buffer = BOXES_X[BOXES_X.length/2]
      @y_player_buffer = BOXES_Y[BOXES_Y.length/2]
      @movement = 1 # 60 = 1 second
      @velocity = 5
      @score = 0
      @position = %W(LEFT RIGHT UP DOWN).sample
      @body = [[@x_player_buffer, @y_player_buffer],[@x_player_buffer+BOX_SIZE, @y_player_buffer+BOX_SIZE]]
      new_food_position
      @game_over = false
    end
  else
    args.outputs.labels << [WIDHT - 120, HEIGHT - 10, "SCORE #{@score}", 255, 255, 255]
  end

  # PLAYER MOVEMENT
  if (args.inputs.left && @position != 'RIGHT')
    @position = 'LEFT'

  elsif (args.inputs.right && @position != 'LEFT')
    @position = 'RIGHT'
  elsif (args.inputs.up && @position != 'DOWN')
    @position = 'UP'
  elsif (args.inputs.down && @position != 'UP')
    @position = 'DOWN'
  end

  if (@movement > 60)
    if (@position == 'LEFT')
      @x_player_buffer -= BOX_SIZE
      @angle = 180
    elsif (@position == 'RIGHT')
      @x_player_buffer += BOX_SIZE
      @angle = 0
    elsif (@position == 'UP')
      @y_player_buffer += BOX_SIZE
      @angle = 90
    elsif (@position == 'DOWN')
      @y_player_buffer -= BOX_SIZE
      @angle = 270
    end
    move_body
    @movement = 1
  end

  if can_move?
    @movement += @velocity
  else
    @game_over = true
  end

  if snake_eat_food?
    loop do
      new_food_position
      break unless (@x_food == @x_player_buffer && @y_food == @y_player_buffer)
    end
    @body << [@body.last[0], @body.last[1]]
    @velocity += 0.5
    @score += 10
  end

  draw_sprites(args)
end

def is_in_screen?
  (@x_player_buffer <= BOXES_X.last && @x_player_buffer >= 0 && @y_player_buffer <= BOXES_Y.last && @y_player_buffer >= 0)
end

def snake_hitted_himself?
  @body[2..]&.each do |body_part|
    if @x_player_buffer == body_part[0] && @y_player_buffer == body_part[1]
      return true
    end
  end
  false
end

def snake_eat_food?
  @x_player_buffer == @x_food && @y_player_buffer == @y_food
end

def can_move?
  is_in_screen? && !snake_hitted_himself?
end

def move_body
  if can_move?
    body_reverse = @body.reverse
    @body = (0..body_reverse.length - 1).map do |i|
      if i == body_reverse.length - 1
        [@x_player_buffer, @y_player_buffer]
      else
        [body_reverse[i+1][0], body_reverse[i+1][1]]
      end
    end.reverse
  end
end

def draw_sprites(args)
  @body.each do |body_part|
    args.outputs.sprites << { x: body_part[0],
                              y: body_part[1],
                              w: BOX_SIZE,
                              h: BOX_SIZE,
                              angle: @angle,
                              path: @body.first == body_part ? @head_sprite : @body_sprite,
                            }
  end
  args.outputs.sprites << { x: @x_food,
                            y: @y_food,
                            w: BOX_SIZE,
                            h: BOX_SIZE,
                            angle: 90,
                            path: @food_sprite
                          }
end
