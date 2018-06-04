defmodule DressingTest do
  use ExUnit.Case
  doctest Dressing

  @path "test/subject/"

  %{
    "cat.jpg" => {"jpg", "image/jpeg"},
    "cat.png" => {"png", "image/png"},
    "cat.gif" => {"gif", "image/gif"}
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

  # REVIEW: Should we extend this to check each mime type definition?
  test "finds mime from file" do
    assert (@path <> "cat.jpg") |> Dressing.get_mime_from_file() == {:ok, {"jpg", "image/jpeg"}}
  end
end
