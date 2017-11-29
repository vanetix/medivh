defmodule MedivhWeb.UsersChannel do
  use MedivhWeb, :channel

  def join("users:lobby", payload, socket) do
    {:ok, socket}
  end
end
