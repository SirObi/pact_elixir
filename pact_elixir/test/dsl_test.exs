defmodule PactElixir.DslTest do
  use ExUnit.Case

  import PactElixir.Dsl

  test "Provider responds to /foo with 'bar'" do
    provider =
      service_provider(consumer: "PactTester", provider: "PactProvider")
      |> add_interaction(
        "give me foo",
        given("foo exists"),
        with_request(method: :get, path: "/foo"),
        will_respond_with(status: 200, body: "bar")
      )
      |> add_interaction(
        "give me foo",
        given("foo exists"),
        with_request(method: :get, path: "/foo"),
        will_respond_with(status: 200, body: "bar")
      )
      |> build

    assert get_request(provider, "/foo").body == "bar"
    {:ok}
  end

  defp get_request(provider, path) do
    %HTTPoison.Response{} = HTTPoison.get!("http://localhost:#{provider.port}#{path}")
  end
end