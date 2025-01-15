defmodule CropImage.Repo do
  use Ecto.Repo,
    otp_app: :crop_image,
    adapter: Ecto.Adapters.Postgres
end
