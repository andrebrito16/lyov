defmodule CgnaflightsapiWeb.GetFlightsController do
  use CgnaflightsapiWeb, :controller
  alias Cgnaflightsapi.Parser

  def index(conn, %{"company" => _company, "date" => _date} = params) do
    ## Returns hello world response
    company = params["company"]
    date = params["date"]
    payload = Parser.call(date, company)

    conn
    |> json(payload)
  end
end
