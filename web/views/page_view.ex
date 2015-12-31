defmodule Poll.PageView do
  use Poll.Web, :view
  import RethinkDB.Query
  
  alias RethinkDB.Pseudotypes.Geometry.Point

  def test do
  	point = %Point{coordinates: {-122.422876,37.777128}}
    
    value = db("poll") |> table("geo") |> get_nearest(point.coordinates,%{index: "location"}) |> Poll.Database.run 
    
    IO.inspect value
	hd(value.data)["doc"]["name"]
  end
end
