class RemoveExpiredSessionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Session.where("expires_at <= ?", Time.current).delete_all
  end
end
