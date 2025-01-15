defmodule CropImageWeb.PostLive.Index do
  use CropImageWeb, :live_view

  alias CropImage.Posts
  alias CropImage.Posts.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :posts, Posts.list_posts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Posts.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({CropImageWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Posts.get_post!(id)
    {:ok, _} = Posts.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  def handle_event(
        "upload_cropped_image",
        %{"cropped_image" => base64, "extension" => extension},
        socket
      ) do
    [_, base64_data] = String.split(base64, ",")
    binary_data = Base.decode64!(base64_data)
    IO.inspect(binary_data)

    case File.exists?("uploads/images") do
      true ->
        :ok

      false ->
        File.mkdir_p!("uploads/images")
    end

    File.write!("uploads/images/test-image.#{extension}", binary_data)
    |> IO.inspect(label: "Image savings")

    {:noreply, socket}
  end
end
