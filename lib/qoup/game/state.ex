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

  # Initializes game
  @spec init(Game.start_args()) :: {:ok, t()}
  def init(%{player_ids: player_ids, expansion: expansion}) do
    {deck, players} =
      expansion
      |> make_deck()
      |> make_players(player_ids)

    # Initializes state
    state = %__MODULE__{
      players: players,
      deck: deck
    }

    {:ok, state}
  end

  # Builds deck based on expansion
  @spec make_deck(String.t(), [String.t()]) :: deck()
  defp make_deck(expansion, custom_layout \\ []) do
    default_roles = [:ambassador, :assassin, :captain, :contessa, :duke]

    # for the future! (needs updating then)
    case expansion do
      # Do stuff when there's an expansion
      "custom" ->
        custom_layout
        |> Enum.chunk_every(2)
        |> Enum.map(fn {role_string, number} ->
          role_string |> String.to_existing_atom() |> List.duplicate(number)
        end)
        |> List.flatten()

      # When no expansion, add three of every card to deck
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

  # One player performs income
  @spec income(Player.playerid(), State.t()) :: State.t()
  def income(player_id,  %{players: player_map} = state) do
    player = Map.get(player_map, player_id)
    # Gives them one coin
    revised_player = (player, :roles, :coins+1, :challenging?)
    player_map^ = Map.put(player_map, player_id, Map.put(revised_player))
    # Returns new state
    state
  end

  # One player coups another
  @spec coup(Player.playerid(), Player.playerid(), State.t()) :: State.t()
  def coup(player_id, target_id, %{players: player_map} = state) do
    player = Map.get(player_map, player_id)

    if player.coins >= 7 do
      revised_player = (player, :roles, :coins-7, :challenging?)
      player_map^ = Map.put(player_map, player_id, Map.put(revised_player))
      # Returns state after they lose a card
      lose_card(target_id)
    else
      # message player that they don't have enough coins
      # Returns old state
      state
    end
  end

  # One player steals from another
  @spec steal(Player.playerid(), Player.playerid(), State.t()) :: State.t()
  def steal(player_id, target_id, %{players: player_map} = state) do
    player = Map.get(player_map, player_id)
    target = Map.get(player_map, target_id)
    # Removes coins
    if target.coins >= 2 do
      player.coins = player.coins + 2
      target.coins = target.coins - 2
    else
      player.coins = player.coins + target.coins
      target.coins = 0
    end
    # Returns new state
    state
  end

  @spec lose_card(Player.playerid()) :: State.t()
  def lose_card(Player.playerid()) do
    # player loses card
    State.t()
  end
end
