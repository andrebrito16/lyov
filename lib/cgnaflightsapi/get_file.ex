defmodule Cgnaflightsapi.GetFile do
  defstruct state: :not_inside_flight

  use Machinist

  transitions do
    from :not_inside_flight, to: :inside_flight, event: "start_flight"
    from :inside_flight, to: :not_inside_flight, event: "end_flight"
  end

  def call(date, company) do
    get_file(date, company)
    |> format_array()
    |> build_array()
    |> isolate_lines()
    # |> build_flights()
    |> Enum.reverse()
  end

  defp build_flights(array) do
    array
    |> Enum.reduce([], fn item, acc ->
      [item, acc]
    end)
  end

  defp isolate_lines(array) do
    array
    |> Enum.map(fn elem -> String.split(elem, "\r") end)
  end

  defp format_array(array) do
    array
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, ",") end)
    |> Enum.map(fn elem -> Enum.at(elem, 0) end)
  end

  defp build_array(array) do
    new_array = array

    new_array
    |> Enum.reduce([], fn item, acc ->
      case Integer.parse(String.slice(item, 3..8)) do
        {_, ""} -> ["#{item} #{append_next_line(array, item)}" | acc]
        _ -> acc
      end
    end)
  end

  defp append_next_line(array, item) do
    index =
      array
      |> Enum.find_index(fn x -> x == item end)

    new_array =
      array
      |> Enum.drop(index + 1)

    new_array
    |> Enum.reduce_while("", fn item, acc ->
      case Integer.parse(String.slice(item, 3..8)) do
        {_, ""} ->
          {:halt, acc}

        _ ->
          case item == "\r" do
            true -> {:halt, acc}
            false -> {:cont, "#{acc} #{item}"}
          end
      end
    end)
  end

  defp get_file(date, company) do
    case HTTPoison.get(
           "http://portal.cgna.decea.mil.br/files/abas/#{date}/painel_rpl/companhias/Cia_#{company}_CS.txt"
         ) do
      {:ok, %HTTPoison.Response{body: body}} -> body
      {:error, error} -> error
    end
  end
end
