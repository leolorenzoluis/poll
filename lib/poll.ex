defmodule Poll do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Poll.Endpoint, []),
      # Here you could define other workers and supervisors as children
      # worker(Poll.Worker, [arg1, arg2, arg3]),
      worker(Poll.Database, []),
      #worker(Poll.PersonFeed, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Poll.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Poll.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Poll.Database do
  use RethinkDB.Connection
end


defmodule Poll.PersonFeed do
  use RethinkDB.Connection
  import RethinkDB.Query
  use RethinkDB.Changefeed

  def init do
    db = db("poll")
    query = db
    |> table("geo")
    |> changes 
    |> Poll.Database.run
    {:subscribe, query, db, nil}
  end


  def handle_update(%{"new_value" => data}, _) do
    {:next, data}
  end

  def handle_call(:get,_from,data) do
    {:reply, data, data}
  end
end