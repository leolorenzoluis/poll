defmodule Poll.CandidatesRepository do
  import RethinkDB.Query
  
	def get_all_candidates_by_position(position) do
		db("poll") 
      	|> table("candidates") 
	    |> filter(%{Type: position})
	    |> Poll.Database.run
	end
end