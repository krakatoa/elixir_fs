defmodule TcpElixir do
  use Application

  def start(_type, _args) do
    # TcpElixir.Server.start_link

    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: TcpElixir.TaskSupervisor]]),
      worker(Task, [TcpElixir.Server, :accept, [34254]])
    ]

    opts = [strategy: :one_for_one, name: TcpElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
