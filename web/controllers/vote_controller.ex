defmodule Poll.VoteController do
  use Poll.Web, :controller

  def index(conn, _params) do
    currentUser = get_session(conn, :current_user)
  	if(is_nil(currentUser)) do
      conn
      |> put_flash(:error, "Failed to authenticate.")
      |> redirect(to: "/")
  	else
  		conn 
  		|> put_flash(:error, "Time to vote papi.")
  		|> redirect(to: "/")
    end
  	
  end
end
