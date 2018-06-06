defmodule Dressing do
  alias File
  alias IO
  alias Path

  # TODO: Docs :upsidedown:

  @typedoc "File extension derived from the file's magic bytes."
  @type extension :: String.t() | nil

  @typedoc "Mime type derived from the file's magic bytes."
  @type mime_type :: String.t()

  @type file_info :: {extension, mime_type}

  # We don't want to read the entire file, so we should just take as many bytes as we need.
  @to_read 150

  # TODO: Banged versions
  @spec get_mime_from_file(Path.t()) :: {:ok, file_info} | {:error, File.posix()} | IO.nodata()
  def get_mime_from_file(path) do
    with {:ok, file} <- File.open(path, [:binary, :read]),
         binary when is_binary(binary) <- IO.binread(file, @to_read) do
      {:ok, parse(binary)}
    end
  end

  @spec get_mime(binary) :: file_info
  def get_mime(binary) do
    parse(binary)
  end

  @spec parse(binary) :: file_info
  defp parse(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>),
    do: {"png", "image/png"}

  # REVIEW: Handle text files?
  defp parse(<<0x47, 0x49, 0x46, _::binary>>), do: {"gif", "image/gif"}
  defp parse(<<0xFF, 0xD8, 0xFF, _::binary>>), do: {"jpg", "image/jpeg"}
  defp parse(_), do: {nil, "application/octet-stream"}
end
