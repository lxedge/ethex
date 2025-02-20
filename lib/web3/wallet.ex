defmodule Ethex.Web3.Wallet do
  @moduledoc """
  Wallet
  """

  defstruct private_key: nil,
            public_key: nil,
            eth_address: nil,
            mnemonic_phrase: nil

  @doc """
  Create wallet or import from private key.

  ### Example

  ```elixir
  iex(1)> Ethex.create_wallet
  %Ethex.Web3.Wallet{
    private_key: "58d4475ecd42f9be425b28866374741db82dd6b71cfb0eb54bb1a09ff85ca87b",
    public_key: "04d179509d453e1d401850c1dc4ba16541487dd22565747ccde722312802e05c3b4f39375891a711f05aa93f56da130eed164efa10620a9a45390b66046862653b",
    eth_address: "0x2dc3c3ce6901ab9be01379d374d58c1eb0fc7a85",
    mnemonic_phrase: "flee peasant stumble once convince tennis annual govern major brick brown derive lizard twice symbol panda attitude prevent unaware donkey zebra comic peanut lazy"
  }

  iex(2)> Ethex.create_wallet "58d4475ecd42f9be425b28866374741db82dd6b71cfb0eb54bb1a09ff85ca87b"
  %Ethex.Web3.Wallet{
    private_key: "58d4475ecd42f9be425b28866374741db82dd6b71cfb0eb54bb1a09ff85ca87b",
    public_key: "04d179509d453e1d401850c1dc4ba16541487dd22565747ccde722312802e05c3b4f39375891a711f05aa93f56da130eed164efa10620a9a45390b66046862653b",
    eth_address: "0x2dc3c3ce6901ab9be01379d374d58c1eb0fc7a85",
    mnemonic_phrase: "flee peasant stumble once convince tennis annual govern major brick brown derive lizard twice symbol panda attitude prevent unaware donkey zebra comic peanut lazy"
  }
  ```
  """
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

  @doc """
  Generate private key

  ### Example

  ```elixir
  iex(2)> Ethex.Web3.Wallet.get_private_key
  <<207, 228, 100, 110, 23, 247, 233, 255, 88, 87, 82, 9, 91, 99, 158, 96, 34, 4,
    80, 197, 207, 233, 111, 200, 254, 152, 148, 230, 93, 78, 135, 57>>
  ```
  """
  @spec get_private_key() :: binary()
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
