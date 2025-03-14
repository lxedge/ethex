defmodule Ethex.Accounts.Account do
  @moduledoc """
  TODO:
  1. pad 0 to start for r and s
  """
  alias Ethex.Utils

  @doc """
  Hashes the given message.
  The data will be `UTF-8 HEX` decoded and enveloped as follows:
  `"\x19Ethereum Signed Message:\n" + message.length + message` and hashed using keccak256.

  NOTE: Prefix above is Ethereum-specific prefix.
  """
  @spec hash_message(String.t(), boolean()) :: String.t()
  def hash_message(message, _skip_prefix \\ false) do
    signed_message = ExKeccak.hash_256(message) |> Base.encode16(case: :lower)
    "0x#{signed_message}"
  end

  # Takes a hash of a message and a private key,
  # signs the message using the SECP256k1 elliptic curve algorithm, and returns the signature components.
  defp sign_message_with_private_key("0x" <> hash, private_key) do
    binary_hash = Base.decode16!(hash, case: :lower)
    {:ok, {signature, recovery}} = ExSecp256k1.sign_compact(binary_hash, private_key)
    <<r::binary-size(32), s::binary-size(32)>> = signature
    hex_signature = Base.encode16(signature, case: :lower)
    v = recovery + 27

    %{
      message_hash: "0x#{hash}",
      v: Utils.to_hex(v),
      r: "0x#{Base.encode16(r, case: :lower)}",
      s: "0x#{Base.encode16(s, case: :lower)}",
      signature: "0x#{hex_signature}#{String.downcase(Integer.to_string(v, 16))}"
    }
  end

  @type sign_result :: %{
          message: String.t(),
          message_hash: String.t(),
          v: String.t(),
          r: String.t(),
          s: String.t(),
          signature: String.t()
        }

  @doc """
  Signs raw data with a given private key without adding the Ethereum-specific prefix.

  iex> k = Base.decode16! "4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318", case: :lower
  iex> Ethex.Accounts.Account.sign_raw("Some data", k)
  %{
    message: "Some data",
    s: "0x334485e42b33815fd2cf8a245a5393b282214060844a9681495df2257140e75c",
    signature: "0x93da7e2ddd6b2ff1f5af0c752f052ed0d7d5bff19257db547a69cd9a879b37d4334485e42b33815fd2cf8a245a5393b282214060844a9681495df2257140e75c1B",
    v: "0x1b",
    r: "0x93da7e2ddd6b2ff1f5af0c752f052ed0d7d5bff19257db547a69cd9a879b37d4",
    message_hash: "0x43a26051362b8040b289abe93334a5e3662751aa691185ae9e9a2e1e0c169350"
  }
  """
  @spec sign_raw(String.t(), binary()) :: sign_result()
  def sign_raw(data, private_key) do
    hash = hash_message(data, true)
    sign_result = sign_message_with_private_key(hash, private_key)
    Map.put(sign_result, :message, data)
  end
end
