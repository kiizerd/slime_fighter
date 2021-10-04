class Game
  attr_gtk
  attr_reader :ui

  def initialize args
    init_state(args.state)

    @player  = args.state.player
    @enemies = args.state.enemies

    @ui = UI.new
    @ui.args = args
  end

  def init_state state
    state.player  ||= Player.new(state)
    state.enemies ||= (1..5).map { Enemy.new(state) }

    state.scene   ||= :title
  end

  def tick
    init_state(args.state) if args.state.tick_count < 1
    @ui.tick

    if state.scene == :title && inputs.keyboard.key_down.space
      @game_started_at ||= state.tick_count
      state.scene = :game
    end

    render

    tick_children unless state.scene == :title && state.tick_count - @game_started_at > 15
  end

  def tick_children
    state.player.tick(args)

    state.enemies << Enemy.new(state) if state.enemies.size < 5
    state.enemies.each { |e| e.tick(args) }
  end

  def render
    outputs.background_color = [70, 80, 90]

    render_scene
  end

  def render_scene
    case state.scene
    when :title then title_scene
    when :game  then game_scene
    end
  end

  def game_scene
    outputs.static_sprites[0] = state.player.sprite
    outputs.sprites << state.enemies.map(&:sprite)
  end

  def title_scene
    0
  end
end
