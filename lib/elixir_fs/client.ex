defmodule ElixirFs.Client do
  @behaviour :gen_server

  def start_link do
    :gen_server.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  def init([]) do
    IO.puts "Init EventSocket client\n"
    {:ok, socket} = :gen_tcp.connect({192,168,1,80}, 8021, [:binary, packet: :raw, active: true])
    {:ok, {socket, ""}}
  end

  def handle_info({:tcp, _sock, data}, {socket, buffer}) do
    # IO.puts "[TRACE] client handle_info: #{inspect data}\n"
    aux_buffer = buffer <> data

    case String.contains?(aux_buffer, "\n\n") do
      true ->
        [data, new_buffer] = String.split(aux_buffer, "\n\n", parts: 2)

        case String.contains?(aux_buffer, "Content-Length") do
          true ->
            [_match|[content_length]] = Regex.run(~r/Content-Length: (\d+)\n/, aux_buffer)
            content_length = :erlang.binary_to_integer(content_length)

            case String.length(new_buffer) >= content_length do
              true ->
                {body,new_buffer} = String.split_at(new_buffer, content_length)
                case :gen_server.call(TcpElixir.App, {:msg_with_header, data, body}) do
                  {:response, response} ->
                    :gen_tcp.send(socket, "#{response}\n\n")
                  {:noresponse} ->
                    :ok
                end
                {:noreply, {socket, new_buffer}}
              false ->
                {:noreply, {socket, aux_buffer}}
            end
          false ->
            case :gen_server.call(TcpElixir.App, {:msg, data}) do
              {:response, response} ->
                :gen_tcp.send(socket, "#{response}\n\n")
              {:noresponse} ->
                :ok
            end
            {:noreply, {socket, new_buffer}}
        end
      false ->
        {:noreply, {socket, aux_buffer}}
    end
  end
end
