defmodule Ethex.Web3.Structs do
  @moduledoc false

  defmodule BlockRange do
    @type t :: %__MODULE__{from_block: pos_integer(), to_block: pos_integer()}
    defstruct from_block: nil, to_block: nil
  end

  defmodule Event do
    @type t :: %__MODULE__{
            address: String.t(),
            block_hash: String.t(),
            block_number: pos_integer(),
	    block_timestamp: pos_integer(),
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
      :block_timestamp,
      :log_index,
      :removed,
      :transaction_hash,
      :transaction_index,
      :returns,
      :event_name
    ]
  end
end
