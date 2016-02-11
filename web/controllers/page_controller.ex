defmodule Poll.PageController do
  use Poll.Web, :controller
  

  def index(conn, _params) do
  	Poll.VoteRepository.get_all()
    render conn, "index.html", current_user: get_session(conn, :current_user)
  end

  def show(conn, %{"id" => id}) do
    IO.puts id
  end
end
