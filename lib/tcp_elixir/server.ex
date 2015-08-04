defmodule TcpElixir.Server do
  require Record
  # Record.defrecord :ipv4, Record.extract(:ipv4, from: "./deps/pkt/include/pkt.hrl")
  Record.defrecord :tcp, Record.extract(:tcp, from: "./deps/pkt/include/pkt_tcp.hrl")

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
                      [:binary, packet: :raw, active: false, reuseaddr: true])
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
    # IO.puts "Packet: #{inspect data, limit: 150}"
    #try do
      [ether|[ipv4|[tcp|[payload|_]]]] = :pkt.decapsulate(data)
      if length(:erlang.binary_to_list(payload)) == 0 do
        "OK"
      else
        # IO.puts "IPv4 Head: #{inspect ipv4(ipv4)}"
        IO.puts "TCP Head: #{inspect tcp(tcp)}"
        IO.puts "Payload: #{inspect payload}\n"
        "OK"
      end
    #rescue
    #  e -> "ERR"
    #end
  end

  defp write_line(response, socket) do
    :gen_tcp.send(socket, response)
  end
end
