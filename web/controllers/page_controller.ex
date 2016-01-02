defmodule Poll.PageController do
  use Poll.Web, :controller
  
  def index(conn, _params) do   
     conn
    |> put_flash(:info, "Welcome to the phoenix from flash info!")
    |> put_flash(:error, "Lets pretend we have an error")
    |> render("index.html")
    #render conn, "index.html"
  end

  def show(conn, %{"id" => id}) do
    IO.puts id
  end
end
