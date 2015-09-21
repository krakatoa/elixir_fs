defmodule ElixirFs do
  use Application

  def start(_type, _args) do
    ElixirFs.Client.start_link
    ElixirFs.App.start_link
  end
end
