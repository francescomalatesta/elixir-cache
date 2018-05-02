defmodule ElixirCacheServer.Command do
  @doc ~S"""
  Parses the line into a valid command.

  ## Examples

    iex> ElixirCacheServer.Command.parse "CREATE shopping\r\n"
    {:ok, {:create, "shopping"}}

    iex> ElixirCacheServer.Command.parse "CREATE  shopping  \r\n"
    {:ok, {:create, "shopping"}}

    iex> ElixirCacheServer.Command.parse "PUT shopping milk 1\r\n"
    {:ok, {:put, "shopping", "milk", "1"}}

    iex> ElixirCacheServer.Command.parse "GET shopping milk\r\n"
    {:ok, {:get, "shopping", "milk"}}

    iex> ElixirCacheServer.Command.parse "DELETE shopping eggs\r\n"
    {:ok, {:delete, "shopping", "eggs"}}

    iex> ElixirCacheServer.Command.parse "UNKNOWN shopping eggs\r\n"
    {:error, :unknown_command}

    iex> ElixirCacheServer.Command.parse "GET shopping\r\n"
    {:error, :unknown_command}
  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", cache] -> {:ok, {:create, cache}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given command.
  """
  def run({:create, cache}) do
    ElixirCache.Registry.create(ElixirCache.Registry, cache)
    {:ok, "OK\r\n"}
  end

  def run({:get, cache, key}) do
    lookup cache, fn pid ->
      value = ElixirCache.Cache.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end
  end

  def run({:put, cache, key, value}) do
    lookup cache, fn pid ->
      ElixirCache.Cache.put(pid, key, value)
      {:ok, "OK\r\n"}
    end
  end

  def run({:delete, cache, key}) do
    lookup cache, fn pid ->
      ElixirCache.Cache.delete(pid, key)
      {:ok, "OK\r\n"}
    end
  end

  defp lookup(cache, callback) do
    case ElixirCache.Registry.lookup(ElixirCache.Registry, cache) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
