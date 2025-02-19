defmodule Test.USDT do
  @moduledoc false
  use Ethex.Abi,
    # rpc: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
    rpc: "https://binance.llamarpc.com",
    abi_path: "./priv/abi/usdt.abi.json",
    contract_address: "0x55d398326f99059fF775485246999027B3197955"
end
