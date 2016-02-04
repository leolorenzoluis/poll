defmodule Poll.VoteRepository do
	import Poll.Database
  	import RethinkDB.Query

	def create_vote(currentUser, params, position) do
	    candidate = params["candidate"] 
	    currentCity = get_position(params)
	    |> create_rethink_point
	    |> get_nearest_city

    	IO.puts "current city is" 
    	IO.inspect currentCity

	    if currentCity do
	      db("poll") 
	      |> table("users")
	      |> update(%{president: candidate})
	      |> run

	      insert_vote(currentCity, currentUser, candidate, position)
	    end
	end

	defp get_position(params) do
	    long = get_value(params,"longitude")
	    lat = get_value(params,"latitude")
		%{longitude: long, latitude: lat}
	end

	defp create_rethink_point(position) do
		point({position[:longitude],position[:latitude]})
	end

	defp get_nearest_city(point) do
		result = db("poll") 
	    |> table("cities") 
	    |> get_nearest(point, %{index: "Location", max_dist: 50, unit: "mi"})
	    |> run

	    IO.inspect "RESULT IS" 
	    IO.inspect result
	    if List.first(result.data) do
      		currentCity = hd(result.data)["doc"]["City"]
      	end
	end

	defp get_value(params, key) do
		valueTuple = Float.parse params[key] 
    	value = elem(valueTuple,0)
	end

	def insert_vote(currentCity,currentUser,candidate, position) do
 		db("poll")
	    |> table("votes")
	    |> insert(%{city: currentCity, userid: currentUser.id, candidate: candidate, position: position})
	    |> run
	end
end