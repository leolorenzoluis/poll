defmodule Poll.VicePresidentsController do
  use Poll.Web, :controller
  import RethinkDB.Query
  import Poll.VoteRepository
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
    create_vote(currentUser, _params, "Vice-President")
    
    conn 
      |> put_flash(:info, "Successfully authenticated.")
      |> assign(:current_user, nil)
      |> assign(:candidates, [])
      |> redirect(to: "/vote/")

  end
end
