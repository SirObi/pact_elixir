defmodule PactElixir.PactMockServer do
  use Rustler, otp_app: :pact_elixir, crate: "pactmockserver"
  # When your NIF is loaded, it will override this functions.

  @doc """
  Add numbers

  ## Examples

      iex> PactElixir.PactMockServer.add(2, 3)
      {:ok, 5}

  """
  def add(_a, _b), do: throw(:nif_not_loaded)

  alias PactElixir.ServiceProvider

  # returns ServiceProvider with actual port
  def start(pact_json, %ServiceProvider{} = provider) do
    {:ok, mock_server_port} = create_mock_server(pact_json, provider.port)

    put_in(provider.port, mock_server_port)
  end

  # Create a mock server
  def create_mock_server(_pact_json, _port), do: throw(:nif_not_loaded)

  def mismatches(%ServiceProvider{} = provider) do
    # TODO: fails with seg fault when called with not used port
    {:ok, mismatches} = mock_server_mismatches(provider.port)
    mismatches
  end

  def mock_server_mismatches(_port), do: throw(:nif_not_loaded)

  def matched?(%ServiceProvider{} = provider) do
    {:ok, matched} = mock_server_matched(provider.port)
    matched
  end

  def mock_server_matched(_port), do: throw(:nif_not_loaded)

  def write_pact_file(%ServiceProvider{} = provider) do
    provider
    |> write_pact_file_with_errors
  end

  def write_pact_file_with_errors(%ServiceProvider{} = provider) do
    if matched?(provider) do
      write_pact_file(provider.port, provider.pact_output_dir_path)
      |> process_write_pact_file_error
    else
      # Do not write file when mismatches happend
      {:error, :mismatches_prohibited_file_output}
    end
  end

  # Successfully written
  defp process_write_pact_file_error({:ok, 0}), do: {:success, true}
  defp process_write_pact_file_error({:ok, 1}), do: {:error, :general_panic_caught}

  defp process_write_pact_file_error({:ok, 2}),
    do: {:error, :pact_file_was_not_able_to_be_written}

  defp process_write_pact_file_error({:ok, 3}),
    do: {:error, :mock_server_with_the_provided_port_was_not_found}

  def write_pact_file(_port, _dir_path), do: throw(:nif_not_loaded)
end