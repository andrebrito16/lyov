defmodule CgnaflightsapiWeb.GetFlightsController do
  use CgnaflightsapiWeb, :controller
  alias Cgnaflightsapi.Parser

  def index(conn, %{"company" => _company, "date" => _date} = params) do
    header_test =
      conn
      |> get_req_header("api-token")
      |> to_string()

    if (header_test !== System.get_env("API_TOKEN")) do
      conn
      |> put_status(401)
      |> json(%{error: "api-token invalid"})
    else
      company = params["company"]
      date = params["date"]
      payload = Parser.call(date, company)

      conn
      |> json(payload)
    end
  end
end
