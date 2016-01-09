defmodule Poll.CandidatesController do
  use Poll.Web, :controller

  def index(conn, _params) do

#  	if(is_nil(get_session(conn, :current_user))) do
  		val = File.read! "/home/leo/Desktop/poll/poll/web/static/assets/ph-all.geo.json"

  		json conn, Poison.decode! val
 # 	else
  #  	render ("index.html")
   # end
  end
end
