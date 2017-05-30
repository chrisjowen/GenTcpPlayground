defmodule SoundcloudElixirGenTask.Clients do
  require Logger

  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def add_client(name, socket) do
    Logger.debug("[Clients] Adding client #{name} socket #{inspect(socket)}")
    Agent.update(__MODULE__, fn map -> Map.put(map, name, socket) end)
  end

  def get(name) do
    client = Agent.get(__MODULE__, fn map -> Map.get(map, name) end)
    Logger.debug("[Clients] Searching for client #{name} found #{inspect(client)}")
    client
  end

  def all do
     Agent.get(__MODULE__, fn map -> Map.values(map) end)
  end
end
