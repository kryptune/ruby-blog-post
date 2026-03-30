module SessionsHelper
  def parse_device(user_agent)
    return "Unknown Device" if user_agent.blank?

    case user_agent
      when /iPhone/       then "iPhone"
      when /iPad/         then "iPad"
      when /Android/      then "Android"
      when /Windows/      then "Windows PC"
      when /Macintosh/    then "Mac"
      when /Linux/        then "Linux"
      else "Unknown Device"
    end
  end

  def device_icon(user_agent)
    return "💻" if user_agent.blank?

    case user_agent
      when /iPhone/, /iPad/   then "📱"
      when /Android/          then "📱"
      when /Windows/, /Mac/   then "💻"
      when /Linux/            then "🖥️"
      else "🌐"
    end
  end
end
