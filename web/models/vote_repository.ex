defmodule Poll.VoteRepository do
	import Poll.Database
  	import RethinkDB.Query

	def create_vote(currentUser, params) do

    candidate = params["candidate"] 
    long = get_value(params,"longitude")
    lat = get_value(params,"latitude")

    result = db("poll") 
    |> table("cities") 
    |> get_nearest(point({long,lat}), %{index: "Location", max_dist: 5000})
    |> run

    if List.first(result.data) do
      currentCity = hd(result.data)["doc"]["City"]

      db("poll") 
      |> table("users")
      |> update(%{president: candidate})
      |> run

      db("poll")
      |> table("votes")
      |> insert(%{city: currentCity, userid: currentUser.id, candidate: candidate, position: "president"})
      |> run
    end

	end

	def get_value(params, key) do
		valueTuple = Float.parse params[key] 
    	value = elem(valueTuple,0)
	end

	def update_vote(currentCity,currentUser,candidate) do
 		db("poll")
	    |> table("votes")
	    |> insert(%{city: currentCity, userid: currentUser.id, candidate: candidate, position: "president"})
	    |> run
	end
end