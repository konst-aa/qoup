defmodule Qoup.Game do
  use GenServer

  alias __MODULE__.State

  @type start_args :: %{
          # Nostrum.id as an int
          player_ids: [integer()],
          expansion: String.t()
        }

  @spec start_game(start_args()) :: GenServer.on_start()
  def start_game(start_args) do
    GenServer.start_link(__MODULE__, start_args)
  end

  @impl true
  def init(start_args) do
    State.init(start_args)
  end

  def seated?(id, %{seating: seating} = _state) do
    Enum.member?(seating, id)
  end

  # turns
  @impl true
  def handle_cast(
        {:coup, from_id, target_id},
        %State{turns: [from_id | _], status: :turn} = state
      ) do
    if seated?(target_id, state) do
      {:noreply, State.coup(state, from_id, target_id)}
    else
      {:noreply, state}
    end
  end

  def handle_cast(
        {:assassinate, from_id, target_id},
        %State{turns: [from_id | _], status: :turn} = state
      ) do
    if seated?(target_id, state) do
      {:noreply, State.assassinate(state, from_id, target_id)}
    else
      {:noreply, state}
    end
  end

  def handle_cast(
        {:steal, from_id, target_id},
        %State{turns: [from_id | _], status: :turn} = state
      ) do
    if seated?(target_id, state) do
      {:noreply, State.steal(state, from_id, target_id)}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:income, from_id}, %State{turns: [from_id | _], status: :turn} = state) do
    {:noreply, State.income(state, from_id)}
  end

  def handle_cast({:foreign_aid, from_id}, %State{turns: [from_id | _], status: :turn} = state) do
    {:noreply, State.foreign_aid(state, from_id)}
  end

  def handle_cast({:tax, from_id}, %State{turns: [from_id | _], status: :turn} = state) do
    {:noreply, State.tax(state, from_id)}
  end

  def handle_cast({:exchange, from_id}, %State{turns: [from_id | _], status: :turn} = state) do
    {:noreply, State.exchange(state, from_id)}
  end

  # challenge, progresses the challenge forwards if in challenge state
  def handle_cast({:buffer_challenge, from_id}, state) do
    {:noreply, State.buffer_challenge(state, from_id)}
  end

  def handle_cast({:buffer_pass, from_id}, state) do
    {:noreply, State.buffer_pass(state, from_id)}
  end

  def handle_cast({:remove_buffer, from_id}, state) do
    {:noreply, State.buffer_pass(state, from_id)}
  end

  # block
  def handle_cast(
        {:block, from_id},
        %State{status: {:block, _, [from_id | _]}} = state
      ) do
    {:noreply, State.block(state, from_id)}
  end

  # still show if actor
  def handle_cast(
        {:still_show, from_id, yn_string},
        %State{
          turns: [from_id | _],
          status: {:still_show, _, _}
        } = state
      ) do
    {:noreply, State.actor_still_show(state, from_id, yn_string)}
  end

  # still show if blocker
  def handle_cast(
        {:still_show, from_id, yn_string},
        %State{
          status: {:still_show, _, [from_id | _]}
        } = state
      ) do
    {:noreply, State.blocker_still_show(state, from_id, yn_string)}
  end

  # lose_challenge as actor
  def handle_cast(
        {:lose_card, from_id, role_string},
        %State{
          turns: [from_id | _],
          status: {:lose_challenge, _, _}
        } = state
      ) do
    {:noreply, State.actor_lose_challenge(state, from_id, role_string)}
  end

  # lose_challenge as a blocker
  def handle_cast(
        {:lose_card, from_id, role_string},
        %State{
          status: {:lose_challenge, _, [from_id | _]}
        } = state
      ) do
    {:noreply, State.blocker_lose_challenge(state, from_id, role_string)}
  end

  # effect resolution
  # ambassador
  def handle_cast(
        {:resolve_ambassador, from_id, drop_role0, drop_role1},
        %State{
          turns: [from_id | _],
          status: {:resolve_ambassador, from_id}
        } = state
      ) do
    {:noreply, State.resolve_ambassador(state, from_id, drop_role0, drop_role1)}
  end

  def handle_cast(
        {:lose_card, from_id, role_string},
        %State{status: {:resolve_stab, {from_id, _}}} = state
      ) do
    {:noreply, State.resolve_stab(state, from_id, role_string)}
  end
end
