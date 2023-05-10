defmodule Qoup.Game.WaitingRoom do
  alias Qoup.Game

  @min_players 2

  @spec check_player_count(Game.start_args()) :: boolean()
  def check_player_count(start_args) do
    length(start_args.player_id) >= @min_players
  end
end
