defmodule Poll.VoteRepositoryTest do
	use ExUnit.Case, async: true
	import RethinkDB.Query
	import Poll.VoteRepository
	import Poll.Database
	#TODO: Uhh.. get to know more on testing?
	@table_name "ZamboangaSibugay"

	setup_all do
		start_link
		table_create(@table_name) |> run
		on_exit fn -> 
			start_link
			table_drop(@table_name) |> run
		end
		:ok
	end

	test "get nearest city when invalid latitude" do
		value = point(7,122.053986)
		measure = get_nearest_city(value)
		assert measure == {:error, ["Latitude must be between -90 and 90.  Got 122.05398599999999476."]}
	end


	test "get nearest city when valid longitude and latitude" do
		value = point(122.053986,7) #Zamboanga Sibugay
		measure = get_nearest_city(value)
		assert measure == {:ok,"Zamboanga Sibugay"}
	end

	test "get nearest city when no city found" do
		value = point(0,0) 
		measure = get_nearest_city(value)
		assert measure == {:ok, []}
	end

	test "create vote" do
		value = point(0,0) 
		measure = get_nearest_city(value)
		assert measure == {:ok, []}
	end

	test "changefeed process" do
		q = table(@table_name) |> changes
		changes =  run(q)
		t = Task.async fn ->
			RethinkDB.Connection.next(changes)
		end

		data = %{"test" => "data"}
		q = table(@table_name) |> insert(data)
		res = run(q)
		expected = res.data["id"]
		changes = Task.await(t)
		^expected = changes.data |> hd |> Map.get("id")

		#test enumerable
		t = Task.async fn ->
			changes |> Enum.take(5)
		end
		1..6 |> Enum.each(fn _ ->
			q = table(@table_name) |> insert(data)
			run(q)
		end)
		data = Task.await(t)
		IO.inspect data
		5 = Enum.count(data)
	end
end
