# rubocop:disable Style/GlobalVars
def tick args
  $game       ||= Game.new(args)
  $game.args  ||= args
  $game.state ||= args.state
  $game.tick

  if args.state.tick_count <= 0
    $game = Game.new(args)
    $game.ui.args = args
  end
end
# rubocop:enable Style/GlobalVars
