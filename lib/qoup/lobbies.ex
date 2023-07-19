defmodule Qoup.Lobbies do
  alias Qoup.Game
  use GenServer

  @type state :: %{
          lobbies: %{integer() => boolean()},
          players_to_lobbies: %{integer() => integer()}
        }

  @type msg :: Nostrum.Struct.Message.t()

  @spec start_link(any()) :: {:ok, pid()}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec init(any()) :: {:ok, any()}
  def init(_args) do
    {:ok, %{}}
  end

  @spec start_lobby(msg()) :: :ok
  def start_lobby(msg) do
    GenServer.cast(__MODULE__, {:start_lobby, msg})
  end

  @spec ready(msg()) :: :ok
  def ready(msg) do
    GenServer.cast(__MODULE__, {:ready, msg})
  end

  @init true
  @spec handle_cast({:start_lobby, msg()}, state()) :: {:noreply, state()}
  def handle_cast({:start_lobby, msg}, state) do
    mentioned_ids = msg.mentions |> Enum.map(fn u -> u.id end)
    IO.inspect(mentioned_ids)
    IO.puts("starting lobby!")
    {:noreply, state}
  end
end
