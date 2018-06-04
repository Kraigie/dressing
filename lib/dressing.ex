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

  # REVIEW: Looks like this number will end up being pretty big. It might be possible that we hit
  # the end of some files before we get the desired buffer size. Maybe get file size and just read
  # the whole thing if it's > this number?
  #
  # We don't want to read the entire file, so we should just take as many bytes as we need.
  @to_read 30

  # TODO: Banged versions
  @spec get_mime_from_file(Path.t()) :: {:ok, file_info} | {:error, File.posix()} | IO.nodata()
  def get_mime_from_file(path) do
    with {:ok, file} <- File.open(path, [:read]),
         binary when is_binary(binary) <- IO.binread(file, @to_read) do
      {:ok, parse(binary)}
    end
  end

  @spec read(File.io_device()) :: {:ok, iodata} | IO.nodata()
  def read(file) do
    case IO.binread(file, @to_read) do
      :eof -> :eof
      {:error, _} = error -> error
      ok -> {:ok, ok}
    end
  end

  @spec get_mime(binary) :: file_info
  def get_mime(binary) do
    parse(binary)
  end

  @spec parse(binary) :: file_info
  def parse(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>),
    do: {"png", "image/png"}

  # REVIEW: Handle text files?
  def parse(<<0x47, 0x49, 0x46, _::binary>>), do: {"gif", "image/gif"}
  def parse(<<0xFF, 0xD8, 0xFF, _::binary>>), do: {"jpg", "image/jpeg"}
  def parse(_), do: {nil, "application/octet-stream"}
end
