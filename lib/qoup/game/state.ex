defmodule Qoup.Game.State do
  alias Qoup.Game
  alias Qoup.Structs.Player

  defstruct [:players, :seating, :deck, :turns, :status]

  @type deck :: [Player.role()]
  @type t :: %__MODULE__{
          players: player_map(),
          seating: [player_id()],
          deck: deck(),
          turns: [player_id()],
          status:
            :turn
            | {:challenge | :block | :lose_challenge | :still_show, Player.action_tuple(),
               [player_id()]}
            | :resolve_ambassador
            | {:resolve_stab, Player.action_tuple()}
        }

  @type player_id :: Nostrum.Struct.User.id()
  @type player_map :: %{
          Player.player_id() => Player.t()
        }

  @type role :: :ambassador | :assassin | :captain | :contessa | :duke
  @type action :: :income | :foreign_aid | :coup | :tax | :exchange | :assassinate | :steal
  @type action_tuple :: {Player.player_id(), Player.action()}

  @type player :: %{
          roles: [role()],
          coins: integer(),
          challenging?: boolean(),
          dm: Nostrum.Struct.Channel.id()
        }

  @spec init(Game.start_args()) :: {:ok, t()}
  def init(%{player_ids: player_ids, expansion: expansion}) do
    {deck, players} =
      expansion
      |> make_deck()
      |> make_players(player_ids)

    state = %__MODULE__{
      players: players,
      deck: deck
    }

    {:ok, state}
  end

  @spec make_players(deck(), [player_id()]) :: {deck(), player_map()}
  defp make_players(deck, player_ids) do
    t = Enum.chunk_every(deck, 2) |> Enum.zip(player_ids)
    for {roles, _id} <- t do
      %Player{roles: roles, coins: 2, challenging?: false, dm: :unknown}
    end

    nil
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
end
