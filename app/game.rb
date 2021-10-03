class Game
  attr_gtk

  def initialize args
    init_state(args.state)

    @player  = args.state.player
    @enemies = args.state.enemies
  end

  def init_state state
    state.player  ||= Player.new(args)
    state.enemies ||= (1..5).map { Enemy.new(args) }
  end

  def tick
    init_state(args.state) if args.state.tick_count < 1

    state.player.tick(args)

    state.enemies.first.tick(args)

    render
  end

  def render
    outputs.static_sprites[0] = state.player.sprite
    outputs.borders << state.player.attack_rect
    outputs.static_borders[1] = state.player.rect
    outputs.static_borders[2] = state.enemies.first.rect
    outputs.static_sprites[1] = state.enemies.first.sprite

    outputs.primitives << gtk.current_framerate_primitives

    outputs.background_color = [70, 80, 90]
  end
end
