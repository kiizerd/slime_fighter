class Game
  attr_gtk

  def initialize args
    init_state(args.state)

    @player  = args.state.player
    @enemies = args.state.enemies
  end

  def init_state state
    state.player  ||= Player.new(state)
    state.enemies ||= (1..5).map { Enemy.new(state) }
  end

  def tick
    init_state(args.state) if args.state.tick_count < 1

    state.player.tick(args)

    state.enemies.each { |e| e.tick(args) }

    state.enemies << Enemy.new(state) if state.enemies.size < 5

    render
  end

  def render
    outputs.static_sprites[0] = state.player.sprite

    outputs.sprites << state.enemies.map(&:sprite)

    outputs.primitives << gtk.current_framerate_primitives

    outputs.background_color = [70, 80, 90]
  end
end
