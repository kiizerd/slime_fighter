module Shape
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
    { x: @x, y: @y, w: @w, h: @h }
  end
end
