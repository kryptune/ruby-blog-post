module UserTimeZone
  extend ActiveSupport::Concern

  def with_user_time_zone(&block)
    # change 'Asia/Manila' to current_user.time_zone to make it dynamic
    Time.use_zone('Asia/Manila', &block)
  end
end

#TODO