defmodule Poll.PollChannel do
  use Phoenix.Channel
  require Logger
  require RethinkDB.Lambda
  import RethinkDB.Query
  import Poll.Database

  def join("eleksyon:gauge", message, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def join("eleksyon:cities", message, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do

    IO.puts "HANDLE_INFO"
    IO.inspect socket.topic
    case socket.topic do
      "eleksyon:cities" -> handle_cities(socket)
      "eleksyon:gauge" -> handle_gauge(socket)
    end
    {:noreply, socket}
  end

  def handle_cities(socket) do
    IO.puts "==== inside handle gauge ====="
    cities = db("poll") 
    |> table("cities") 
    |> pluck("City")
    |> run



    Enum.each(cities, fn city -> result = String.replace(city["City"], " ", "") 
                                 result = String.replace(result, "-","")
                                 totalVotes = db("poll") 
                                  |> table(result) 
                                  |> count
                                  |> run
                                 message = %{City: city["City"], TotalVotes: totalVotes.data}
                                 push socket, "new:msg", message

                                 changes =db("poll") 
                                  |> table(result) 
                                  |> changes
                                  |> run
                                  Task.async fn ->
                                   Enum.each(changes, fn change ->
                                      IO.inspect "******** CHANGING SOMETHING HERE ****"
                                      message = %{City: city["City"], TotalVotes: 1}
                                      push socket, "new:msg", message
                                    end)
                                  end
                                 end)

  end

  def handle_gauge(socket) do
    IO.puts "inside handle gauge"
    query = db("poll") 
    |> table("votes") 
    #|> pluck("location") 
    #|> map( RethinkDB.Lambda.lambda fn (record) -> record[:location] |> to_geojson end) 
    result = run(query)


    #IO.puts "Inspecting result in poll channel"
    #IO.inspect result
    #result.data 
    #|> Enum.into(%{})
    #|> IO.inspect
    #Enum.each(result.data, fn message -> push socket, "new:msg", %{city: hd(elem(message,0)), candidate: hd(tl(elem(message,0))), count: elem(message,1) } end)
    Enum.each(result.data, fn message -> push socket, "new:msg", message end)

    changes =db("poll") 
    |> table("votes") 
    |> changes
    |> run


    #IO.puts "Inspecting changes  in info poll channel"
    #IO.inspect changes

    Task.async fn ->
     Enum.each(changes, fn change ->
        IO.inspect changes
        push socket, "new:msg", change["new_val"]
      end)
    end

  end

  #def handle_in("new:msg", msg, socket) do
  #  IO.puts "IM IN HANDLE IN BABY"
    #TODO: handle add/updates?
  # {:reply, {:ok, msg["coordinates"]}, assign(socket, :user, msg["type"])}
  #end
end