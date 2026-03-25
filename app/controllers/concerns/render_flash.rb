module RenderFlash
  extend ActiveSupport::Concern

  def render_flash(message, path, type: :alert, status: :unprocessable_entity)
    respond_to do |format|
      format.json { render json: { error: message }, status: status }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "flash",
          partial: "shared/flash",
          locals: { type => message }
        )
      end
      format.html do
        flash[type] = message
        redirect_to path
      end
    end
  end
end