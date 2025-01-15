defmodule CropImage.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CropImage.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        image: "some image",
        title: "some title"
      })
      |> CropImage.Posts.create_post()

    post
  end
end
