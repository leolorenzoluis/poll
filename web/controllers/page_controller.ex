defmodule Poll.PageController do
  use Poll.Web, :controller
  
  def index(conn, _params) do
    render conn, "index.html", current_user: get_session(conn, :current_user)
  end

  def show(conn, %{"id" => id}) do
    IO.puts id
  end
end
