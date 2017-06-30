defmodule ExClearbit.API.Enrichment do
  import Pit

  alias ExClearbit.Model.{Person, Company}

  def combined(email, params \\ [], options \\ []) do
    url = case options[:stream] do
      true -> "https://person-stream.clearbit.com/v2/combined/find"
      _ -> "https://person.clearbit.com/v2/combined/find"
    end

    case request(url, [email: email] ++ params) do
      {:ok, %{"company" => company, "person" => person}} ->
        %{
          company: company |> pit(not nil, else: %{}) |> ExClearbit.Model.Company.new,
          person: person |> pit(not nil, else: %{}) |> ExClearbit.Model.Person.new
        }
      error -> error
    end
  end

  def company(domain, params \\ [], options \\ []) do
    url = case options[:stream] do
      true -> "https://company-stream.clearbit.com/v2/companies/find"
      _ -> "https://company.clearbit.com/v2/companies/find"
    end

    case request(url, [domain: domain] ++ params) do
      {:ok, company} -> company |> Company.new
      error -> error
    end
  end

  def person(email, params \\ [], options \\ []) do
    url = case options[:stream] do
      true -> "https://person-stream.clearbit.com/v2/people/find"
      _ -> "https://person.clearbit.com/v2/people/find"
    end

    case request(url, [email: email] ++ params) do
      {:ok, person} -> person |> Person.new
      error -> error
    end
  end

  defp request(url, params) do
    case ExClearbit.API.Base.get(url, [], params) do
      %{"error" => error} ->
        message = error["message"]
        type = error["type"] |> String.to_atom

        {:error, %{code: type, message: message}}
      response -> {:ok, response}
    end
  end
end
