defmodule Qoup.Game.State do
  alias Qoup.Game
  alias Qoup.Structs.Player

  defstruct [:players, :seating, :deck, :turns, :status]

  @type deck :: [Player.role()]
  @type t :: %__MODULE__{
          players: Player.player_map(),
          seating: [Player.player_id()],
          deck: deck(),
          turns: [Player.player_id()],
          status:
            :turn
            | {:challenge | :block | :lose_challenge | :still_show, Player.action_tuple(),
               [Player.player_id()]}
            | :resolve_ambassador
            | {:resolve_stab, Player.action_tuple()}
        }

  @spec init(Game.start_args()) :: {:ok, t()}
  def init(%{player_ids: player_ids, expansion: expansion}) do
    {deck, players} =
      expansion
      |> make_deck()
      |> Player.make_players(player_ids)

    state = %__MODULE__{
      players: players,
      deck: deck
    }

    {:ok, state}
  end

  @spec make_deck(String.t(), [String.t()]) :: deck()
  defp make_deck(expansion, custom_layout \\ []) do
    default_roles = [:ambassador, :assassin, :captain, :contessa, :duke]

    # for the future!
    case expansion do
      "custom" ->
        custom_layout
        |> Enum.chunk_every(2)
        |> Enum.map(fn {role_string, number} ->
          role_string |> String.to_existing_atom() |> List.duplicate(number)
        end)
        |> List.flatten()

      _ ->
        default_roles
        |> Enum.map(fn role -> List.duplicate(role, 3) end)
        |> List.flatten()
    end
  end

  # def assasinate(Player.playerid(), Player.playerid()) do
  # check if challeged
  # lose_card(...)
  # end

  @spec steal(Player.playerid(), Player.playerid(), Player.player_map()) :: :ok
  def steal(player_id, target_id, player_map) do
    player = player_map.get[player_id]
    target = player_map.get[target_id]

    if target.coins >= 2 do
      player.coins = player.coins + 2
      target.coins = target.coins - 2
    else
      player.coins = player.coins + target.coins
      target.coins = 0
    end

    :ok
  end

  @spec lose_card(Player.playerid()) :: :ok
  def lose_card(Player.playerid()) do
    # player loses card
    :ok
  end
end
