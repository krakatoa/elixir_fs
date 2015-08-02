defmodule TcpElixir.Server do
  #@behaviour :gen_server

  #def start_link do
  #  :gen_server.start_link({:local, __MODULE__}, __MODULE__, [], [])
  #end

  #def init([]) do
  #  IO.puts "Init TCP Server"
  #  {:ok, []}
  #end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false])
    IO.puts "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(TcpElixir.TaskSupervisor, fn -> serve(client) end)
    :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    IO.puts "Received: #{data}"
    # IO.puts "Received: #{:erlang.binary_to_term(data)}"
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, "tarola")
  end
end
