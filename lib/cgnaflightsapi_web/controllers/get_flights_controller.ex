defmodule CgnaflightsapiWeb.GetFlightsController do
  use CgnaflightsapiWeb, :controller
  alias Cgnaflightsapi.GetFile

  def call(conn, _error) do
    ## Returns hello world response
    payload = GetFile.call("2021-12-30", "AZU")

    conn
    |> json(payload)
  end
end
