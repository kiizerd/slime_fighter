class Player
  # TODO: extract methods relating to players shape to a Shape module

  SPRITE_PATH = 'assets/sprites/player/'.freeze

  def initialize state
    # stats
    @max_hp = 5
    @hp     = @max_hp
    @atk_speed  = 10
    @move_speed = 4

    # attack attributes
    @attack_queue = []
    @attack_count = 1
    @last_attack_at = nil

    # sprite attributes
    @x   = 0
    @y   = 0
    @w   = 64
    @h   = 64
    @dir = 1

    # animation attributes
    @action_state = :idle
    @action_start = 0
    @attack_anim_length = 35

    @game_state = state
  end

  def tick args
    process_input(args.inputs)

    process_attacks(args.inputs)
  end

  def process_input inputs
    if inputs.keyboard.space
      if inputs.keyboard.key_held.space
        handle_spacebar_held(inputs)
      elsif inputs.keyboard.key_down.space
        handle_spacebar_down(inputs)
      end
    elsif inputs.directional_vector
      handle_movekeys(inputs)
    else
      @started_holding_at = nil
      reset_state(inputs)
    end
  end

  def handle_spacebar_down _inputs
    @last_attack_at = @game_state.tick_count if attack_over?
    add_attack_to_queue if @attack_queue.size <= 3
  end

  def handle_spacebar_held _inputs
    @started_holding_at ||= @game_state.tick_count
    time_held = @game_state.tick_count - @started_holding_at

    good_tick = time_held % @attack_anim_length == 0
    @last_attack_at = @game_state.tick_count if attack_over? && good_tick
    add_attack_to_queue if @attack_queue.size < 3 && good_tick && dup_attack_check
    @started_holding_at = @game_state.tick_count if time_held / @attack_anim_length > 3
  end

  def dup_attack_check
    return true if @attack_queue.empty?

    last_added = @attack_queue.last.added_at

    !(0..last_added + @attack_anim_length - 1).include? @game_state.tick_count
  end

  def handle_movekeys inputs
    @action_start = @game_state.tick_count if @action_state == :idle
    @action_state = :move
    process_movements(inputs)
  end

  def reset_state inputs
    @action_start = @game_state.tick_count if @action_state == :move
    if @action_state == :atck
      @action_state = :idle if attack_over?
    else
      @action_state = :idle unless inputs.directional_vector
    end
  end

  def process_movements inputs
    @y += @move_speed if inputs.up    && !collide_top?
    @y -= @move_speed if inputs.down  && !collide_bottom?
    @x += @move_speed if inputs.right && !collide_right?
    @x -= @move_speed if inputs.left  && !collide_left?

    @dir = 1 if inputs.right
    @dir = -1 if inputs.left
  end

  def process_attacks _inputs
    next_attack if attack_over? && !@attack_queue.empty?

    if @attack_queue.empty?
      @attack_count = 1
    else
      @action_start = @game_state.tick_count if @action_state == :idle
      @action_state = :atck
      perform_attack
    end
  end

  def perform_attack
    return unless any_in_melee_range?
    return if @game_state.tick_count - @last_attack_at >= @attack_anim_length.quarter * 3

    enemies_in_range.each(&:hurt)
  end

  def next_attack
    @attack_queue.shift
    @attack_count += 1
    @attack_count = 1 if @attack_count > 3
    @last_attack_at = @game_state.tick_count unless @attack_queue.empty?
  end

  def add_attack_to_queue
    @attack_queue << {
      added_at: @game_state.tick_count
    }
  end

  def attack_over?
    return true unless @last_attack_at

    @game_state.tick_count - @last_attack_at > @attack_anim_length
  end

  def any_in_melee_range?
    @game_state.enemies.map(&:rect).any? do |enem_rect|
      attack_rect.any? do |atk_rect|
        $game.geometry.intersect_rect? enem_rect, atk_rect
      end
    end
  end

  def enemies_in_range
    @game_state.enemies.select do |enem|
      attack_rect.any? do |atk_rect|
        $game.geometry.intersect_rect? enem.rect, atk_rect
      end
    end
  end

  def collide_top?
    top_rect = { x: top[0][0] + 5, y: top[0][1] + 5, w: rect.w - 6, h: 1 }
    @game_state.enemies.any? do |enem|
      $game.geometry.intersect_rect? top_rect, enem.rect
    end
  end

  def collide_left?
    left_rect = { x: left[0][0] - 5, y: left[0][1] + 5, w: 1, h: rect.h - 5 }
    @game_state.enemies.any? do |enem|
      $game.geometry.intersect_rect? left_rect, enem.rect
    end
  end

  def collide_right?
    right_rect = { x: right[0][0] + 5, y: right[0][1] + 5, w: 1, h: rect.h - 5 }
    @game_state.enemies.any? do |enem|
      $game.geometry.intersect_rect? right_rect, enem.rect
    end
  end

  def collide_bottom?
    bottom_rect = { x: bottom[0][0] + 5, y: bottom[0][1] - 5, w: rect.w - 6, h: 1 }
    @game_state.enemies.any? do |enem|
      $game.geometry.intersect_rect? bottom_rect, enem.rect
    end
  end

  def top
    [
      [rect.x, rect.y + rect.h],
      [rect.x + rect.w, rect.y + rect.h]
    ]
  end

  def bottom
    [
      [rect.x, rect.y],
      [rect.x + rect.w, rect.y]
    ]
  end

  def left
    [
      [rect.x, rect.y],
      [rect.x, rect.y + rect.h]
    ]
  end

  def right
    [
      [rect.x + rect.w, rect.y],
      [rect.x + rect.w, rect.y + rect.h]
    ]
  end

  def point
    [@x, @y]
  end

  def center
    [@x + @w.half, @y + @h.half]
  end

  def rect
    { x: @x + @w.quarter, y: @y, w: @w.half, h: @h - @h.quarter }
  end

  def sprite
    rect = { x: @x, y: @y, w: @w, h: @h }
    case @action_state
    when :idle then rect.merge(idling)
    when :move then rect.merge(moving)
    when :atck then rect.merge(atking)
    end.merge(flip_horizontally: @dir.negative?)
  end

  def attack_rect
    case @attack_count
    when 1
      [
        {
          x: @dir.negative? ? @x : @x + (@w - 20), y: @y + 15,
          w: @w / 3, h: @h / 1.4, r: 75, g: 140, b: 80
        },
        {
          x: @dir.negative? ? @x + 3 : @x + @w.half, y: @y + 8,
          w: @w / 3 + 5, h: @h / 4, r: 75, g: 140, b: 80
        },
        {
          x: @dir.negative? ? @x + 13 : @x + @w.half - 10, y: @y + rect.h,
          w: @w.half, h: @h / 4, r: 75, g: 140, b: 80
        }
      ]
    when 2
      [
        {
          x: @dir.negative? ? @x + 3 : rect.x + rect.w, y: rect.y + 5,
          w: rect.w.half - 3, h: @h / 1.5, r: 75, g: 140, b: 80
        },
        {
          x: @dir.negative? ? @x + 5 : @x + rect.w - 5, y: @y + rect.h,
          w: @w.half, h: 5, r: 75, g: 140, b: 80
        }
      ]
    when 3
      [
        {
          x: @dir.negative? ? @x + 10 : @x + @w.half, y: @y + 15,
          w: @w / 2.6, h: @h / 2.4, r: 75, g: 140, b: 80
        },
        {
          x: @x,
          y: @y + 3,
          w: @w, h: @h / 2.3, r: 75, g: 140, b: 80
        }
      ]
    end
  end

  def idling
    number_of_sprites = 4
    frames_per_sprite = 8
    anim_loops = true
    frame_index = @action_start.frame_index number_of_sprites,
                                            frames_per_sprite,
                                            anim_loops

    { path: "#{SPRITE_PATH}player-idle-#{frame_index}.png" }
  end

  def moving
    number_of_sprites = 6
    frames_per_sprite = 8
    anim_loops = true
    frame_index = @action_start.frame_index number_of_sprites,
                                            frames_per_sprite,
                                            anim_loops

    { path: "#{SPRITE_PATH}player-run-#{frame_index}.png" }
  end

  def atking
    number_of_sprites = @attack_count == 1 ? 5 : 6
    frames_per_sprite = @attack_anim_length / number_of_sprites
    anim_loops = true
    frame_index = @action_start.frame_index number_of_sprites,
                                            frames_per_sprite,
                                            anim_loops

    { path: "#{SPRITE_PATH}player-attack#{@attack_count.clamp(1, 3)}-#{frame_index}.png" }
  end
end
