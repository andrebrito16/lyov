defmodule Cgnaflightsapi.Parser do
  def call(date, company) do
    get_file(date, company)
    |> format_array()
    |> build_array()
    |> isolate_lines()
    |> Enum.map(fn flight -> build_flight(flight) end)
    |> Enum.reverse()
  end

  defp build_flight(flight) do
    route =
      flight
      |> Enum.reduce("", fn item, acc ->
        "#{acc} #{String.slice(item, 59..92)}"
      end)
      |> String.trim()
      |> String.replace("  ", "")

    remarks =
      flight
      |> Enum.reduce("", fn item, acc ->
        "#{acc} #{String.slice(item, 104..125)}"
      end)
      |> String.trim()
      |> String.replace("  ", "")

    first_line = Enum.at(flight, 0)

    callsign = String.slice(first_line, 25..31)
    aicraft_type = String.slice(first_line, 33..36)
    code = String.slice(first_line, 25..27)
    flight_number = String.slice(first_line, 28..31)
    wake_turbulence = String.at(first_line, 38)
    departure_icao = String.slice(first_line, 40..43)
    arrival_icao = String.slice(first_line, 95..98)
    eobt = String.slice(first_line, 44..47)
    cruise_flight_level = String.slice(first_line, 55..57)
    cruise_speed = String.slice(first_line, 49..53)
    enroute_time = String.slice(first_line, 99..102)

    flight_on_monday = String.at(first_line, 17) == "1"
    flight_on_tuesday = String.at(first_line, 18) == "2"
    flight_on_wednesday = String.at(first_line, 19) == "3"
    flight_on_thursday = String.at(first_line, 20) == "4"
    flight_on_friday = String.at(first_line, 21) == "5"
    flight_on_saturday = String.at(first_line, 22) == "6"
    flight_on_sunday = String.at(first_line, 23) == "7"

    flight_days = %{
      sunday: flight_on_sunday,
      monday: flight_on_monday,
      tuesday: flight_on_tuesday,
      wednesday: flight_on_wednesday,
      thursday: flight_on_thursday,
      friday: flight_on_friday,
      saturday: flight_on_saturday
    }

    %{
      route: route,
      remarks: remarks,
      callsign: callsign,
      code: code,
      flight_number: flight_number,
      aicraft_type: aicraft_type,
      wake_turbulence: wake_turbulence,
      arrival_icao: arrival_icao,
      departure_icao: departure_icao,
      eobt: eobt,
      cruise_flight_level: cruise_flight_level,
      cruise_speed: cruise_speed,
      enroute_time: enroute_time,
      flight_days: flight_days
    }
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
            false -> {:cont, "#{acc}#{item}"}
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
