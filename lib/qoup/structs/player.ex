defmodule Qoup.Structs.Player do
  defstruct [:roles, :coins, :challenging?, :dm]

  @type player_id :: integer()
  @type player_map :: %{
          Player.player_id() => Player.t()
        }
  @type role :: :ambassador | :assassin | :captain | :contessa | :duke
  @type action_tuple :: {Player.player_id(), Player.action()}
  @type t :: %__MODULE__{
          roles: [role()],
          lost_roles: [role()],
          coins: integer(),
          challenging?: boolean(),
          dm: Nostrum.Struct.Channel.id()
        }
  @type action :: :income | :foreign_aid | :coup | :tax | :exchange | :assassinate | :steal

  @spec make_players(Qoup.Game.State.deck(), [player_id()]) :: nil
  def make_players(deck, player_ids) do
    nil
  end
end
