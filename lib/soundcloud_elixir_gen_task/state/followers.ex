defmodule SoundcloudElixirGenTask.Followers do
  require Logger
  
  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def follow(from, to) do
    Agent.update(__MODULE__, fn map ->
      followers = Map.get(map, to, [])
      Map.put(map, to, followers ++ [from])
    end)
  end

  def unfollow(from, to) do
    Agent.update(__MODULE__, fn map ->
      followers = Map.get(map, to, [])
      followers = followers |> Enum.filter(fn it -> it != from end)
      Map.put(map, to, followers)
    end)
  end

  def followers(user) do
    Agent.get(__MODULE__, fn map -> Map.get(map, user, []) end)
  end

end
