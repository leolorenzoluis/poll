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

    query = db("poll") 
  	|> table("votes") 
  	#|> pluck("location") 
  	#|> map( RethinkDB.Lambda.lambda fn (record) -> record[:location] |> to_geojson end) 
    result = run(query)


    IO.puts "Inspecting result in poll channel"
    IO.inspect result
    #result.data 
    #|> Enum.into(%{})
    #|> IO.inspect
    #Enum.each(result.data, fn message -> push socket, "new:msg", %{city: hd(elem(message,0)), candidate: hd(tl(elem(message,0))), count: elem(message,1) } end)
    Enum.each(result.data, fn message -> push socket, "new:msg", message end)

    changes =db("poll") 
    |> table("votes") 
    |> changes
    |> run


    IO.puts "Inspecting changes  in info poll channel"
    IO.inspect changes

    Task.async fn ->
     Enum.each(changes, fn change ->
        IO.inspect changes
        push socket, "new:msg", change["new_val"]
      end)
    end

    {:noreply, socket}
  end

  #def handle_in("new:msg", msg, socket) do
  #  IO.puts "IM IN HANDLE IN BABY"
    #TODO: handle add/updates?
  # {:reply, {:ok, msg["coordinates"]}, assign(socket, :user, msg["type"])}
  #end
end