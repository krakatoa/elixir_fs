defmodule ElixirFs.App do
  @behaviour :gen_server

  def start_link do
    :gen_server.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  def init([]) do
    IO.puts "Started App\n"
    {:ok, {}}
  end

  def handle_call({:msg, "Content-Type: auth/request"}, _from, state) do
    IO.puts "app handle auth\n"
    response = "auth ClueCon"
    {:reply, {:response, response}, state}
  end

  def handle_call({:msg, "Content-Type: command/reply\nReply-Text: +OK accepted"}, _from, state) do
    IO.puts "[TRACE] app auth accepted\n"
    response = "events json ALL"
    {:reply, {:response, response}, state}
  end

  def handle_call({:msg, "Content-Type: command/reply\nReply-Text: +OK event listener enabled json"}, _from, state) do
    IO.puts "[TRACE] app listening events\n"
    {:reply, {:noresponse}, state}
  end

  def handle_call({:msg, data}, _from, state) do
    IO.puts "[TRACE] msg: #{inspect data}"
    case String.contains?(data, "Content-Type: text/event-json") do
      true ->
        {:reply, {:noresponse}, state}
      false ->
        json = JSON.decode(data)
        {:reply, {:noresponse}, state}
    end
  end

  def handle_call({:msg_with_header, header, body}, _from, state) do
    # IO.puts "[TRACE] app msg_with_header: #{inspect body}\n"
    {:ok, json} = JSON.decode(body)
    IO.puts "[DEBUG] EventName: #{json["Event-Name"]}"
    case json["Event-Name"] do
      "CHANNEL_PARK" ->
        case json["Channel-Call-State"] do
          "RINGING" ->
            uuid = json["Channel-Call-UUID"]
            response = "sendmsg #{uuid}\ncall-command: execute\nexecute-app-name: answer"
            {:reply, {:response, response}, state}
          _ -> {:reply, {:noresponse}, state}
        end
      "CHANNEL_EXECUTE" ->
        IO.puts "[DEBUG] #{inspect json}\n"
        # uuid = json["variable_call_uuid"]
        {:reply, {:noresponse}, state}
      _ ->
        {:reply, {:noresponse}, state}
    end
  end

end
