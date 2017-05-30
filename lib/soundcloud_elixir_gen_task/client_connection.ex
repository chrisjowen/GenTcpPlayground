defmodule SoundcloudElixirGenTask.ClientConnection do
  require Logger
  alias SoundcloudElixirGenTask.Clients

  def await_name(socket) do
    name = socket |> read_line()
    Logger.debug "[ClientConnection] established client name #{name} for socket #{inspect(socket)} self #{inspect(self())}"
    Clients.add_client(name, socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data |> String.replace("\n", "")
  end

end
