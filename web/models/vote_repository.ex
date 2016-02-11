defmodule Poll.VoteRepository do
	import Poll.Database
  	import RethinkDB.Query
  	alias RethinkDB.Record
  	require RethinkDB.Lambda
  	import RethinkDB.Lambda

  	def get_all() do

  		result = db("poll") 
			  	|> table("cities") 
			  	|> pluck("City")
			  	|> order_by(desc("City"))
			    |> run

		IO.inspect result.data
		Enum.each(result.data, fn x -> 
			validCity = String.replace(x["City"], " ","")
			IO.inspect validCity
			result = db("poll") |> table_create(validCity) |> run 
			IO.inspect result
		end)

  	end

	def create_vote(currentUser, params, positionType) do
	    candidate = params["candidate"] 

	    currentCity = get_position(params)
	    |> create_rethink_point
	    |> get_nearest_city

    	IO.puts "current city is" 
    	IO.inspect currentCity

    	case currentCity do
    		{:ok, value} ->
			    			db("poll") 
						      |> table("users")
						      |> update(%{president: candidate})
						      |> run

						      insert_vote(value, currentUser, candidate, positionType,1)
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

	def get_nearest_city(point) do
		result = db("poll") 
	    |> table("cities") 
	    |> get_nearest(point, %{index: "Location", max_dist: 100, unit: "mi"})
	    |> run

	    case result do
	    	%RethinkDB.Record{} -> if List.first(result.data) do
      								{:ok, hd(result.data)["doc"]["City"]} #Get the nearest which is the first one
								   else 
									{:ok, result.data}
      							   end
	    	%RethinkDB.Response{} -> {:error, result.data["r"]}
	    	%RethinkDB.Feed{} -> raise "not implemented"
	    end
	end

	defp get_value(params, key) do
		valueTuple = Float.parse params[key] 
    	value = elem(valueTuple,0)
	end

	def insert_vote(currentCity,currentUser,candidate, positionType, n) when n<= 1 do
		IO.puts " HELLO WORLD "
		IO.inspect currentCity
		
		validCity = String.replace(currentCity, " ","")
 		db("poll")
	    |> table(validCity)
	    |> insert(%{userid: currentUser.id, candidate: candidate, position: positionType})
	    |> run
	end

	def insert_vote(currentCity,currentUser,candidate, positionType, n) do
		insert_vote(currentCity,currentUser,candidate, positionType, n-1)
		insert_vote(currentCity,currentUser,candidate, positionType, n-1)
	end
end