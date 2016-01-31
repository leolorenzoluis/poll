defmodule Poll.PresidentsController do
  use Poll.Web, :controller
  import RethinkDB.Query

  def index(conn, _params) do
    currentUser = get_session(conn, :current_user)
  	if(is_nil(currentUser)) do
      conn
      |> put_flash(:error, "You must sign in to your Facebook account in order to vote.")
      |> redirect(to: "/")
  	else
      result = db("poll") 
      |> table("candidates") 
      |> filter(%{Type: "President"})
      |> Poll.Database.run
      

      split = Enum.chunk(result.data, 3,3,[nil,nil,nil])

      Enum.each(split, fn (x) -> Enum.each(x, fn (y) -> IO.inspect y["firstname"] end) end)

      test =hd (hd(split))
      #IO.inspect test
      #IO.inspect test["firstname"]
      #val = Poison.encode split
      conn 
      |> assign(:current_user, currentUser)
      |> assign(:candidates, split)
      |> render("index.html")
    end
  end

  def create(conn, _params) do

    currentUser = get_session(conn, :current_user)
    longitudeTuple = Float.parse _params["longitude"] 
    latitudeTuple = Float.parse _params["latitude"]
    candidate = _params["candidate"] 
    long = elem(longitudeTuple,0)
    lat = elem(latitudeTuple,0)

    result = db("poll") 
    |> table("cities") 
    |> get_nearest(point({long,lat}), %{index: "Location", max_dist: 5000})
    |> Poll.Database.run

    IO.puts "CREATE CREATE CREATE"
    IO.inspect result.data
    blah = is_list result.data
    IO.inspect blah
    if List.first(result.data) do
      currentCity = hd(result.data)["doc"]["City"]

      db("poll") 
              |> table("users")
              |> update(%{president: candidate})
              |> Poll.Database.run

      db("poll")
      |> table("votes")
      |> insert(%{city: currentCity, userid: currentUser.id, candidate: candidate, position: "president"})
      |> Poll.Database.run
    end

    conn 
      |> put_flash(:info, "Successfully authenticated.")
      |> assign(:current_user, nil)
      |> assign(:candidates, [])
      |> redirect(to: "/vote/vicepresidents")
  end
end
