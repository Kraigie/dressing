defmodule DressingTest do
  use ExUnit.Case
  doctest Dressing

  @path "test/subject/"

  %{
    "cat.jpg" => {"jpg", "image/jpeg"},
    "cat.png" => {"png", "image/png"},
    "cat.gif" => {"gif", "image/gif"},
    "cat.webp" => {"webp", "image/webp"}
  }
  |> Enum.each(fn {key, {ext, _mime} = info} ->
    test "finds " <> ext do
      assert (@path <> unquote(key)) |> File.read!() |> Dressing.get_mime() == unquote(info)
    end
  end)

  test "defaults to nil" do
    assert (@path <> "cat") |> File.read!() |> Dressing.get_mime() ==
             {nil, "application/octet-stream"}
  end

  test "defaults to nil when reading from binary file" do
    assert (@path <> "cat") |> Dressing.get_mime_from_file() == {:ok, {nil, "application/octet-stream"}}
  end

  test "finds mime from file" do
    assert (@path <> "cat.jpg") |> Dressing.get_mime_from_file() == {:ok, {"jpg", "image/jpeg"}}
  end

  test "returns error tuple from errors" do
    assert (@path <> "ca") |> Dressing.get_mime_from_file() == {:error, :enoent}
  end

  test "finds eof in empty file" do
    assert (@path <> "empty_cat") |> Dressing.get_mime_from_file() == :eof
  end

  test "banged method returns just file info" do
    assert (@path <> "cat.jpg") |> Dressing.get_mime_from_file!() == {"jpg", "image/jpeg"}
  end

  test "banged method raises on error" do
    assert_raise File.Error, fn -> Dressing.get_mime_from_file!(@path <> "ca") end
  end

  test "banged method raises on empty file" do
    assert_raise RuntimeError, fn -> Dressing.get_mime_from_file!(@path <> "empty_cat") end
  end
end
