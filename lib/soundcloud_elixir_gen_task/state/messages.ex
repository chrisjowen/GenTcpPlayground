defmodule SoundcloudElixirGenTask.Messages do
  require Logger
  
  def start_link do
    Agent.start_link(fn -> {1, Map.new} end, name: __MODULE__)
  end

  def add(seq_no, message) do
    {seq_no, _} = Integer.parse(seq_no, 10)
    Agent.update(__MODULE__, fn {seq, map} -> {seq, Map.put(map, seq_no, message)} end)
  end

  def get do
    result = Agent.get(__MODULE__, fn {seq, map} ->{seq, Map.get(map, seq)}
   end)
    case result do
      {_, nil} -> {:error, :no_message}
      {seq, message} ->
        Agent.update(__MODULE__, fn {seq, map} -> {seq+1, Map.delete(map, seq)} end)
        {:ok, message}
    end
  end

  def remaining do
    keys = Agent.get(__MODULE__, fn {seq, map} -> Map.keys(map) end)
    length(keys)
  end

end
