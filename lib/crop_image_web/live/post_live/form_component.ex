defmodule CropImageWeb.PostLive.FormComponent do
  use CropImageWeb, :live_component

  alias CropImage.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.live_file_input upload={@uploads.avatar} />
        <div id="crop-div" phx-hook="Cropper" class="">
          <%= for entry <- @uploads.avatar.entries do %>
            <div class="w-[184px] h-[45px]">
              <.live_img_preview
                entry={entry}
                id="image-to-crop"
                class="w-full h-full object-cover"
                style="max-width: 100%;"
              />
            </div>
          <% end %>
        </div>

        <:actions>
          <.button id="crop-button" phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 1)
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Posts.change_post(post))
     end)}
  end

  # @impl true
  # def handle_event("validate", %{"post" => post_params}, socket) do
  #   changeset = Posts.change_post(socket.assigns.post, post_params)
  #   {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  # end

  def handle_event("validate", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  def handle_event("save", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  def handle_event("upload_cropped_image", %{"cropped_image" => base64}, socket) do
    [_, base64_data] = String.split(base64, ",")
    binary_data = Base.decode64!(base64_data)
    IO.inspect(binary_data)
    {:noreply, socket}
  end

  # def handle_event("save", %{"post" => post_params}, socket) do
  #   save_post(socket, socket.assigns.action, post_params)
  # end

  defp save_post(socket, :edit, post_params) do
    case Posts.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Posts.create_post(post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  def error_to_string(:too_many_files), do: "You have selected too many files"
  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
