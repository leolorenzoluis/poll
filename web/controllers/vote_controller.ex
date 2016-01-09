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
      |> table("presidents") 
      |> Poll.Database.run
      

      split = Enum.chunk(result.data, 3,3,[nil,nil,nil])

      Enum.each(split, fn (x) -> Enum.each(x, fn (y) -> IO.inspect y["firstname"] end) end)

      test =hd (hd(split))
      #IO.inspect test
      #IO.inspect test["firstname"]
      val = Poison.encode split
      conn 
      |> assign(:current_user, currentUser)
      |> assign(:presidents, split)
      |> render("index.html")
      
    end
  end

  def create(conn, _params) do
    
    IO.inspect  _params

    conn 
      |> put_flash(:info, "Successfully authenticated.")
      |> assign(:current_user, nil)
      |> assign(:presidents, [])
      |> render("index.html")

  end
end
