defmodule Cgnaflightsapi.Fetchdata do
  def call(date) do
    date
    |> get_file()
  end

  defp get_file(date) do
    case HTTPoison.get(
           "http://portal.cgna.decea.mil.br/files/abas/#{date}/painel_rpl/bdr/RPLSBCW.zip"
         ) do
      {:ok, %HTTPoison.Response{body: body}} -> IO.inspect(:zlib.gunzip(body))
      {:error, error} -> error
    end
  end
end
