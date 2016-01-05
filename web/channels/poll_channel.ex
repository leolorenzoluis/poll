defmodule Poll.PollChannel do
  use Phoenix.Channel
  require Logger
  require RethinkDB.Lambda
  import RethinkDB.Query
  import Poll.Database

  def join("eleksyon:lobby", message, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    IO.puts "im in handle info"

    query = db("poll") 
  	|> table("geo") 
  	|> pluck("location") 
  	|> map( RethinkDB.Lambda.lambda fn (record) -> record[:location] |> to_geojson end) 
    result = run(query)
    
    Enum.each(result.data, fn message ->  push socket, "new:msg", message end)

    changes = changes(query)
    |> run

    Task.async fn ->
      Enum.each(changes, fn change ->
        push socket, "new:msg", change["new_val"]
      end)
    end

    {:noreply, socket}
  end

  def handle_in("new:msg", msg, socket) do
    #TODO: handle add/updates?
    {:reply, {:ok, msg["coordinates"]}, assign(socket, :user, msg["type"])}
  end
end