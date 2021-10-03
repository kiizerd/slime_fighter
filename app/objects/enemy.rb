class Enemy

  # TODO - add random color selection on initialize to correspond to 
  # TODO - add size

  attr_accessor :dir, :x, :y, :w, :h, :action_state, :r, :g ,:b, :a

  def initialize args, spawner=nil
    # stats
    @max_hp = 1
    @hp = @max_hp
    @atk_speed = 5
    @move_speed = 3

    # sprite attributes
    @x = args.grid.right.half
    @y = args.grid.top.half
    @w = 64
    @h = 64
    @dir = 4

    # animation attributes
    @action_state = :idle
    @action_start = 0
    @attack_count = nil
    @last_attack_at = nil

    # AI
    @actions = {
      idle: { weight: 0 },
      roam: { weight: 1 },
      seek: { weight: 2 },
      hurt: { weight: -1 }
    }

    @game_state = args.state
  end

  def tick args
    return if args.state.tick_count <= 3

    determine_action(args)
  end

  def determine_action args
    @actions[:seek][:weight] = dist_from_player >= 350 ? 0 : 2

    @action_state = @actions.find { |_a, prop| prop.weight == 3 }&.first ||
                    @actions.find { |_a, prop| prop.weight == 2 }&.first ||
                    @actions.find { |_a, prop| prop.weight == 1 }&.first ||
                    :idle

    perform @action_state
    puts @action_state
  end

  def perform action
    case action
    when :idle # then puts 'enemy idling'
    when :roam # then puts 'enemy roaming'
    when :seek then approach_player
    when :hurt then puts "anythin"
    end
  end

  def hurt
    @actions[:hurt][:weight] = 3
    puts 'hmm'
  end

  def approach_player
    apply_delta unless $game.geometry.intersect_rect? rect, @game_state.player.rect
  end

  def calc_movement_delta
    rx = rise_run_to_player.x.round(5) * 1000 / 1000
    ry = rise_run_to_player.y.round(5) * 1000 / 1000
    total_shares = (rx + ry).abs * 100
    share_value  = (@move_speed / total_shares).round(5).abs * 100

    delta_x = (share_value * rx).round(4).clamp(-2, 2) * 1000 / 1000
    delta_y = (share_value * ry).round(4).clamp(-2, 2) * 1000 / 1000

    delta_x += 0.55 && delta_y -= 0.55 if delta_x.between?(0, 0.3)  || delta_y.between?(-0.3, 0)
    delta_x -= 0.55 && delta_y += 0.55 if delta_x.between?(-0.3, 0) || delta_y.between?(0, 0.3)

    [delta_x, delta_y]
  end

  def apply_delta
    player = @game_state.player.point
    delta_x, delta_y = calc_movement_delta

    case delta_x.abs > delta_y.abs
    when true  then @dir = delta_x > 0 ? 3 : 1
    when false then @dir = delta_y > 0 ? 2 : 4
    end

    @x += delta_x unless @x.between?(player[0] - delta_x, player[0] + delta_x)
    @y += delta_y unless @y.between?(player[1] - delta_y, player[1] + delta_y)
  end

  def rise_run_to_player
    x1, y1 = @game_state.player.point
    x2, y2 = point

    { x: (x1 - x2).clamp(-50, 50), y: (y1 - y2).clamp(-50, 50) }
  end

  def dist_from_player
    player = @game_state.player.point
    $game.geometry.distance point, player
  end

  def point
    [@x, @y]
  end

  def center
    [@x + @w.half, @y + @h.half]
  end

  # make rect half sized to ensure sprite fills rect
  def rect
    { x: @x + @w.quarter, y: @y + @h.quarter + 3, w: @w.half, h: @h.half - 6 }
  end

  def sprite
    rect = { x: @x, y: @y, w: @w, h: @h }
    case @action_state
    when :idle then rect.merge(idling)
    when :roam then rect.merge(moving)
    when :seek then rect.merge(atking)
    when :hurt then rect.merge(hrting)
    end
  end

  def idling
    tile_index = @action_start.frame_index(4, 8, true) || 0
    {
      path: "assets/sprites/enemy/slimes/slime-med-blue.png",
      tile_x: 0 + (tile_index * 32),
      tile_y: 128 - (@dir * 32),
      tile_w: 32,
      tile_h: 32
      # r: 250, g: 0, b: 0, a: 150
    }
  end

  def moving
    tile_index = @action_start.frame_index(4, 8, true) || 0
    {
      path: "assets/sprites/enemy/slimes/slime-med-blue.png",
      tile_x: 0 + (tile_index * 32),
      tile_y: 128 - (@dir * 32),
      tile_w: 32,
      tile_h: 32
      # r: 250, g: 0, b: 0, a: 150
    }
  end

  def atking
    tile_index = @action_start.frame_index(4, 8, true) || 0
    {
      path: "assets/sprites/enemy/slimes/slime-med-blue.png",
      tile_x: 0 + (tile_index * 32),
      tile_y: 128 - (@dir * 32),
      tile_w: 32,
      tile_h: 32
      # r: 250, g: 0, b: 0, a: 150
    }
  end

  def hrting
    tile_index = @action_start.frame_index(4, 8, true) || 0
    @hurt_started_at ||= @game_state.tick_count
    ease = $gtk.args.easing.ease(@hurt_started_at, @game_state.tick_count, 35, :cube)
    puts "ease: #{ease}"
    {
      path: "assets/sprites/enemy/slimes/slime-med-blue.png",
      tile_x: 0 + (tile_index * 32),
      tile_y: 128 - (@dir * 32),
      tile_w: 32,
      tile_h: 32,
      r: 255,
      g: 255 * (1 - ease), b: 255 * (1 - ease), a: 255 * (1 - ease.half),
      w: @w * (1 - ease), h: @h * (1 - ease),
      x: @x + ease * @w.half, y: @y + ease * @w.half
    }
  end
end
