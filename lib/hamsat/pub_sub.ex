defmodule Hamsat.PubSub do
  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(__MODULE__, topic, message)
  end

  def broadcast_alert_saved(alert, user) do
    broadcast(
      "alerts",
      {:alert_saved, %{alert_id: alert.id, user_id: user.id, saved_count: alert.saved_count}}
    )

    alert
  end

  def broadcast_alert_unsaved(alert, user) do
    broadcast(
      "alerts",
      {:alert_unsaved, %{alert_id: alert.id, user_id: user.id, saved_count: alert.saved_count}}
    )

    alert
  end
end
