class UI

  # TODO: replace all outputs with render_targets

  attr_gtk

  def init_state

  end

  def tick
    player_health && player_score
  end

  def player_health
    outputs.borders << health_border
    outputs.solids  << health_bar
  end

  def health_label

  end

  def health_border
    {
      x: grid.left + 15, y: grid.top - 50,
      w: 240, h: 40,
      r: 50, g: 50, b: 50, a: 240
    }
  end

  def health_bar
    player = state.player
    max_hp = state.player.max_hp
    health = player.hp

    {
      x: grid.left + 20, y: grid.top - 46,
      w: (230 / max_hp) * health, h: 32,
      r: 200, g: 50, b: 50, a: 240
    }
  end

  def player_score
    outputs.borders << score_border
    outputs.labels << score_label
  end

  def score_label
    player = state.player
    score  = player.score
    text   = "Score: #{score}"
    w, h   = gtk.calcstringbox text
    x      = grid.right.half - w.half
    y      = grid.top - 20

    [x, y, text]
  end

  def score_border
    {
      x: grid.right.half - 70, y: grid.top - 50,
      w: 140, h: 40, r: 250, g: 150, b: 100, a: 150
    }
  end
end
