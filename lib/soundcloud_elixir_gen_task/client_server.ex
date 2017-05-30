defmodule SoundcloudElixirGenTask.ClientServer do
  require Logger

  def listen_on(port) do
    Logger.info "[ClientServer] Accepting connections on port #{port}"
    {:ok, connection} = :gen_tcp.listen(port,[:binary, packet: :line, active: false, reuseaddr: true])
    connected(connection)
  end

  defp connected(connection) do
    {:ok, socket} = :gen_tcp.accept(connection)
    Logger.debug "[ClientConnection] accepted connection from #{inspect(socket)}"
    # Spawn another task for every client connection to wait for name
    Task.start_link(SoundcloudElixirGenTask.ClientConnection, :await_name, [socket])
    connected(connection)
  end

end
