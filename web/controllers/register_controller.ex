defmodule Poll.RegisterController do
  use Poll.Web, :controller
  require RethinkDB.Lambda
  import RethinkDB.Query
  alias RethinkDB.Pseudotypes.Geometry.Point

  def index(conn, _params) do   

  	value = db("poll") 
  	|> table("geo") 
  	|> pluck("location") 
  	|> map( RethinkDB.Lambda.lambda fn (record) -> record[:location] |> to_geojson end) 
  	|> Poll.Database.run
  	IO.inspect Poison.encode(value)
    Phoenix.Controller.json conn, value
  end

  def create(conn, %{"register" => register_params}) do
  	IO.puts "hello"
    IO.puts register_params
  end
end
