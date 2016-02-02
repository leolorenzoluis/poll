defmodule Poll.VicePresidentsController do
  use Poll.Web, :controller
  import RethinkDB.Query
  import Poll.CandidatesRepository

  def index(conn, _params) do
    currentUser = get_session(conn, :current_user)
  	if(is_nil(currentUser)) do
      conn
      |> put_flash(:error, "You must sign in to your Facebook account in order to vote.")
      |> redirect(to: "/")
  	else
      result = get_all_candidates_by_position("Vice President")

      conn 
      |> assign(:current_user, currentUser)
      |> assign(:candidates, result)
      |> render("index.html")
    end
  end

  def create(conn, _params) do
    currentUser = get_session(conn, :current_user)
    longitudeTuple = Float.parse _params["longitude"] 
    latitudeTuple = Float.parse _params["latitude"]

    IO.inspect _params["longitude"] 
    long = elem(longitudeTuple,0)
    lat = elem(latitudeTuple,0)
    IO.puts "HIII IM IN CREATE"
    IO.inspect point({long,lat})

    result = db("poll") 
    |> table("cities") 
    |> get_nearest(point({long,lat}), %{index: "Location", max_dist: 5000})
    |> Poll.Database.run
    candidate = _params["candidate"]

    currentCity = hd(result.data)["doc"]["City"]

    query = db("poll") 
            |> table("users")
            |> update(%{vicepresident: candidate })
            |> Poll.Database.run

    db("poll")
      |> table("votes")
      |> insert(%{city: currentCity, userid: currentUser.id, candidate: candidate, position: "vice-president"})
      |> Poll.Database.run
    
    conn 
      |> put_flash(:info, "Successfully authenticated.")
      |> assign(:current_user, nil)
      |> assign(:candidates, [])
      |> redirect(to: "/vote/")

  end
end
