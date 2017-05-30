defmodule SoundcloudElixirGenTask do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      # Stateful actors
       worker(SoundcloudElixirGenTask.Followers, [],[]),
       worker(SoundcloudElixirGenTask.Messages, [],[]),
       worker(SoundcloudElixirGenTask.Clients, [],[ name: "Clients"]),

      #  Message Processing worker process
       worker(Task, [SoundcloudElixirGenTask.MessageProcessor, :process, []], []),

      #  Server processes
       worker(Task, [SoundcloudElixirGenTask.ClientServer, :listen_on, [9099]],[ id: 1, name: "ClientServer"]),
       worker(Task, [SoundcloudElixirGenTask.EventSourceServer, :listen_on, [9090]], [id: 2, name: "EventSourceServer"]),
    ]

    opts = [strategy: :one_for_one, name: SoundcloudElixirGenTask.Supervisor]
    Supervisor.start_link(children, opts)

  end
end
