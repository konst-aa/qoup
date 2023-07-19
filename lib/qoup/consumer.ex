defmodule Qoup.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    IO.puts("started consumer!")
    Consumer.start_link(__MODULE__)
  end

  @spec hack(Nostrum.Struct.Message.t()) :: {String.t(), [String.t()] | [], atom()} | :badmessage
  defp hack(message) do
    supers = Application.fetch_env!(:qoup, :super_users)

    case String.split(message.content) do
      [command | args] ->
        %{username: username, discriminator: discriminator} = message.author

        if Enum.member?(supers, username <> "#" <> discriminator) do
          {command, args, :super}
        else
          {command, args, :notsuper}
        end

      _ ->
        :badmessage
    end
  end


  @spec dispatch(Nostrum.Struct.Message.t()) :: :ok | :ignore
  defp dispatch(msg) do
    case hack(msg) do
      # super user commands
      # normal user commands
      {">ping", _, _} ->
        IO.puts("hello!")
        Api.create_message(msg.channel_id, "pong!")
      {">start", _, _} ->
        IO.puts("!?!?")
        Api.create_message(msg.channel_id, "creating pod!")
        Qoup.Lobbies.start_lobby(msg)

      _ -> :ignore
    end
  end

  @spec handle_event(Nostrum.Consumer.event()) :: :ok
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Task.start(fn -> dispatch(msg) end)
    :ok
  end

  # Default event handler.
  def handle_event(_event) do
    :noop
  end
end
