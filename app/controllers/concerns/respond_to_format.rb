module RespondToFormat
  extend ActiveSupport::Concern

  def respond_to_format(json_opts, path, message, type: :alert)
    respond_to do |format|
      format.json do
        # If 'json_opts' has a :json key, render it. 
        # If it only has a :status, use 'head'.
        if json_opts.key?(:json)
          render json_opts
        else
          head json_opts[:status] || :ok
        end
      end

      format.html do
        flash[type] = message
        redirect_to path
      end
    end
  end
end