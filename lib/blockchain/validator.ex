defmodule UltraDark.Validator do
  alias UltraDark.Blockchain.Block, as: Block

  @doc """
    A block is considered valid if the index is greater than the index of the previous block,
    the previous_hash is equal to the hash of the previous block, and the hash of the block,
    when recalculated, is the same as what the listed block hash is
  """
  def is_block_valid?(block, chain) do
    last_block = List.first(chain)

    with :ok <- valid_index(block.index, last_block.index),
         :ok <- valid_prev_hash(block.previous_hash, last_block.hash),
         :ok <- valid_hash(block)
    do
      :ok
    else
      err -> :error
    end
  end

  defp valid_index(index, prev_index) when index > prev_index, do: :ok
  defp valid_prev_hash(prev_hash, last_block_hash) when prev_hash == last_block_hash, do: :ok

  defp valid_hash(%{index: index, previous_hash: previous_hash, timestamp: timestamp, nonce: nonce, hash: hash}) do
    if Block.calculate_hash([Integer.to_string(index), previous_hash, timestamp, Integer.to_string(nonce)]) == hash, do: :ok
  end


  @doc """
    The merkle root lets us represent a large dataset using only one string. We can be confident that
    if any of the data changes, the merkle root will be different, which invalidates the dataset
  """
  def calculate_merkle_root(list) do
    list
    |> Enum.chunk_every(2)
    |> Enum.map(fn (h) -> :crypto.hash(:sha256, h) |> Base.encode16 end)
    |> calculate_merkle_root(true)
  end

  def calculate_merkle_root(list, true) when length(list) == 1, do: List.first(list)
  def calculate_merkle_root(list, true), do: calculate_merkle_root(list)
end
