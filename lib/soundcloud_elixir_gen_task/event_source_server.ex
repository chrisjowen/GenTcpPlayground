defmodule SoundcloudElixirGenTask.EventSourceServer do
  require Logger
  alias SoundcloudElixirGenTask.Clients
  alias SoundcloudElixirGenTask.Messages

  def listen_on(port) do
    Logger.info "[EventSourceServer] Accepting connections on port #{port}"
    {:ok, connection} = :gen_tcp.listen(port,[:binary, packet: :line, active: false, reuseaddr: true])
    connected(connection)
  end

  def connected(connection) do
    case :gen_tcp.accept(connection) do
      {:ok, socket} ->
        # Spawn another task for every event stream connection (even thought there should only be one)
        Logger.debug "[EventSourceServer] accepted connection from #{inspect(socket)}"
        Task.start_link(__MODULE__, :await_messages, [socket])
    end
    connected(connection)
  end

  def await_messages(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        line = data |> String.replace("\n", "")
        msg  = line |> String.split("|")
        Logger.debug("[EventSourceServer] Recieved message #{line} adding")
        Messages.add(List.first(msg), msg)
        await_messages(socket)
      {:error, error} -> Logger.info("No more events")
    end
  end

end
