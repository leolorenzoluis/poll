defmodule Poll.Router do
  use Poll.Web, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Poll do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "register", RegisterController, only: [:index, :create]
  end

  scope "/auth", Poll do
    pipe_through :browser
    get "/:provider", AuthenticationController, :request
    get "/:provider/callback", AuthenticationController, :callback
    post "/:provider/callback", AuthenticationController, :callback
    delete "/logout", AuthenticationController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", Poll do
  #   pipe_through :api
  # end
end
