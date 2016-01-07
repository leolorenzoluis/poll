defmodule Poll.AuthenticationController do
  use Poll.Web, :controller
  require RethinkDB.Lambda
  import RethinkDB.Query
  alias RethinkDB.Pseudotypes.Geometry.Point
  plug Ueberauth

  def index(conn, _params) do   

  	value = db("poll") 
  	|> table("geo") 
  	|> pluck("location") 
  	|> map( RethinkDB.Lambda.lambda fn (record) -> record[:location] |> to_geojson end) 
  	|> Poll.Database.run
  	
    Phoenix.Controller.json conn, value
  end

   def callback(%{ assigns: %{ ueberauth_failure: fails } } = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

   def callback(%{ assigns: %{ ueberauth_auth: auth } } = conn, params) do
    case Poll.UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
