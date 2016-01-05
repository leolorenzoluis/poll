
defmodule UserFromAuth do
  alias Ueberauth.Auth
  alias Ueberauth.Auth.Credentials
  import RethinkDB.Query

  def find_or_create(%Auth{} = auth) do
    db("poll") |> table("users") |> insert(%{something: auth.uid, name: name_from_auth(auth), image: auth.info.image, provider: auth.provider }) |> Poll.Database.run
    {:ok, %{id: auth.uid, name: name_from_auth(auth), avatar: auth.info.image}}
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