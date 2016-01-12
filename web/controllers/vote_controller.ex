defmodule Poll.VoteController do
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
      |> table("users") 
      |> filter(%{id: currentUser.id})
      |> Poll.Database.run
      
      IO.puts hd(result.data)["president"]
      value = hd(result.data)
      hasPresident = not is_nil (value["president"])
      hasVicePresident = not is_nil (value["vicepresident"])
      IO.inspect is_nil (value["presidents"])
      cond do
        is_nil (value["president"]) ->
          conn |> assign(:current_user, currentUser) |> render("index.html")
        hasPresident && not hasVicePresident ->
          conn |> redirect(to: "/vote/vicepresidents")
        true -> 
          conn |> assign(:current_user, currentUser) |> render("index.html")
      end
    end
  end

  def create(conn, _params) do
    longitudeTuple = Float.parse _params["longitude"] 
    latitudeTuple = Float.parse _params["latitude"]

    long = elem(longitudeTuple,0)
    lat = elem(latitudeTuple,0)

    result = db("poll") 
    |> table("cities") 
    |> get_nearest(point({long,lat}), %{index: "Location", max_dist: 5000})
    |> Poll.Database.run


    currentCity = hd(result.data)["doc"]["City"]

    query = db("poll") 
            |> table("users")
            |> update(%{president: _params["candidate"]})
            |> Poll.Database.run


    conn 
      |> put_flash(:info, "Successfully authenticated.")
      |> assign(:current_user, nil)
      |> assign(:presidents, [])
      |> render("index.html")

  end
end
