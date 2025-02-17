defmodule Ethex.Account.Wallet do
  @moduledoc """
  Wallet Address
  """

  defstruct private_key: nil,
            public_key: nil,
            eth_address: nil,
            mnemonic_phrase: nil

  @spec create() :: %__MODULE__{}
  @spec create(binary()) :: %__MODULE__{}
  def create(private_key \\ :crypto.strong_rand_bytes(32))

  def create(<<encoded_private_key::binary-size(64)>>) do
    public_key = get_public_key(encoded_private_key)
    eth_address = get_address(public_key)

    %__MODULE__{
      private_key: encoded_private_key,
      public_key: Base.encode16(public_key, case: :lower),
      eth_address: eth_address,
      mnemonic_phrase: Mnemonic.entropy_to_mnemonic(encoded_private_key)
    }
  end

  def create(private_key) do
    encoded_private_key = Base.encode16(private_key, case: :lower)
    public_key = get_public_key(private_key)
    eth_address = get_address(public_key)

    %__MODULE__{
      private_key: encoded_private_key,
      public_key: Base.encode16(public_key, case: :lower),
      eth_address: eth_address,
      mnemonic_phrase: Mnemonic.entropy_to_mnemonic(encoded_private_key)
    }
  end

  def get_private_key(), do: :crypto.strong_rand_bytes(32)

  defp get_public_key(<<private_key::binary-size(32)>>) do
    {:ok, public_key} = ExSecp256k1.create_public_key(private_key)
    public_key
  end

  defp get_public_key(<<encoded_private_key::binary-size(64)>>) do
    private_key = Base.decode16!(encoded_private_key, case: :mixed)
    {:ok, public_key} = ExSecp256k1.create_public_key(private_key)
    public_key
  end

  defp get_address(<<private_key::binary-size(32)>>) do
    <<4::size(8), key::binary-size(64)>> = private_key |> get_public_key()
    <<_::binary-size(12), eth_address::binary-size(20)>> = ExKeccak.hash_256(key)
    "0x#{Base.encode16(eth_address)}"
  end

  defp get_address(<<encoded_private_key::binary-size(64)>>) do
    public_key = Base.decode16!(encoded_private_key, case: :mixed) |> get_public_key()
    <<4::size(8), key::binary-size(64)>> = public_key
    <<_::binary-size(12), eth_address::binary-size(20)>> = ExKeccak.hash_256(key)
    "0x#{Base.encode16(eth_address, case: :lower)}"
  end

  defp get_address(<<4::size(8), key::binary-size(64)>>) do
    <<_::binary-size(12), eth_address::binary-size(20)>> = ExKeccak.hash_256(key)
    "0x#{Base.encode16(eth_address, case: :lower)}"
  end

  defp get_address(<<encoded_public_key::binary-size(130)>>) do
    <<4::size(8), key::binary-size(64)>> = Base.decode16!(encoded_public_key, case: :mixed)
    <<_::binary-size(12), eth_address::binary-size(20)>> = ExKeccak.hash_256(key)
    "0x#{Base.encode16(eth_address, case: :lower)}"
  end
end
