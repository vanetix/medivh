defmodule MedivhWeb.PageView do
  use MedivhWeb, :view

  @spec raw_users(Map.t) :: String.t
  def raw_users(users) do
    users
    |> Poison.encode!()
    |> raw()
  end
end
