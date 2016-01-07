defmodule Poll.CandidatesController do
  use Poll.Web, :controller

  def index(conn, _params) do

  	if(is_nil(get_session(conn, :current_user))) do
  		redirect conn, to: "/"
  	else
    	text conn, "yuou are authenticated broo"
    end
  end
end
