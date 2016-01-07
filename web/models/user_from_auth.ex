defmodule Poll.UserFromAuth do
  alias Ueberauth.Auth
  import RethinkDB.Query

  def find_or_create(%Auth{} = auth) do
    name = name_from_auth(auth)

    table = db("poll") |> table("users")
    inDatabase =  is_nil(table |> filter(%{provider: auth.provider, id: auth.uid}) |> Poll.Database.run)

    if not inDatabase do
      table |> insert(%{id: auth.uid, name: name, image: auth.info.image, provider: auth.provider }) |> Poll.Database.run  
    end
    {:ok, %{id: auth.uid, name: name, avatar: auth.info.image}}
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))
      if length(name) == 0, do: auth.info.nickname, else: name = Enum.join(name, " ")
    end
  end
end