defmodule SoundcloudElixirGenTask.MessageProcessor do
  alias SoundcloudElixirGenTask.Messages
  alias SoundcloudElixirGenTask.Followers
  alias SoundcloudElixirGenTask.Clients

  require Logger

  def process(timeout \\ 1000) do
     case Messages.get do
       {:ok, message} ->
         process_message(message)
      _  ->
         #  Sleeping perfectly ok in elixir processes, mkay!
         :timer.sleep(timeout)
     end
     process
  end

  def process_message(msg = [_, "F", from, to]) do
    Logger.debug "[MessageProcessor] [Following] Following #{from} => #{to}"
    Followers.follow(from, to)
    message(to, msg)
  end
  def process_message([_, "U", from, to]) do
    Logger.debug "[MessageProcessor] [Unfollowing] #{from} => #{to}"
    Followers.unfollow(from, to)
  end

  def process_message(msg = [_, "B"]) do
    Logger.debug "[MessageProcessor] [Broadcasting]"
    Clients.all |> Enum.each(&send_message(&1, msg))
  end

  def process_message(msg = [_, "S", user]) do
    Logger.debug "[MessageProcessor] [STATUS] #{user}"
    followers = Followers.followers(user)
    followers |> Enum.map(&Clients.get/1) |> Enum.each(&send_message(&1, msg))
  end

  def process_message(msg = [_, "P", from, to]) do
    Logger.debug "[MessageProcessor] [PM] #{from} => #{to}"
    message(to,  msg)
  end

  def message(user,  msg) do
    Clients.get(user) |> send_message(msg)
  end

  defp send_message(socket, message) when is_nil(socket), do: :no_op

  defp send_message(socket, message) do
    raw_message = "#{Enum.join(message, "|")}\n"
    Logger.debug "[MessageProcessor] [SENDING MESSAGING] Sending message client #{raw_message}"
    :gen_tcp.send(socket, raw_message)
  end

end
