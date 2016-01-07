defmodule Poll.UserFromAuthTest do
	alias Ueberauth.Auth
	alias Ueberauth.Info
	import RethinkDB.Query
	use ExUnit.Case, async: true
	import Poll.UserFromAuth
	import Poll.Database

	#TODO: Uhh.. get to know more on testing?
	@table_name "testUsers"

	setup_all do
		start_link
		table_create(@table_name) |> run
		on_exit fn -> 
			start_link
		end
		:ok
	end

	test "user is not yet in the database" do
		value = %Auth{provider: "facebook", uid: "1"}
		measure = find_or_create(value)
		assert measure == {:ok, %{avatar: nil, id: "1", name: nil}}
	end

end
