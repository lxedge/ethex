defmodule Ethex.Struct.Transaction do
  @moduledoc """
  %Ethex.Struct.Transaction{
    address: "0x42f771dc235830077a04ee518472d88671755ff8",
    block_hash: "0xcc827e8fae4271bf91c65ce10b3a590b6d9c2d665cf8ae55224caf1444753b9d",
    block_number: 30950172,
    log_index: "0x10",
    removed: false,
    transaction_hash: "0x48965d02c69f3eae46486d677efd55f06943fda3d8c2acf667ac5980ad569a1c",
    transaction_index: "0x5",
    returns: [
      %{name: "_from", value: "0x8ccf629e123d83112423c283998443829a291334"},
      %{name: "_to", value: "0xa2e7d1addb682c3f2ba78d5124433cb8ba2a4f4b"},
      %{name: "_value", value: 10000000000000000000000}
    ],
    event_name: "Transfer"
  }
  """

  @type t :: %__MODULE__{
          address: String.t(),
          block_hash: String.t(),
          block_number: non_neg_integer(),
          log_index: String.t(),
          removed: boolean(),
          transaction_hash: String.t(),
          transaction_index: String.t(),
          returns: list(),
          event_name: String.t()
        }

  defstruct [
    :address,
    :block_hash,
    :block_number,
    :log_index,
    :removed,
    :transaction_hash,
    :transaction_index,
    :returns,
    :event_name
  ]
end
