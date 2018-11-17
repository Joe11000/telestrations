module CardHelper
  # include Rails.application.routes.url_helpers

  # def get_drawing_url card
  #   unless (card.drawing? && card.drawing.attached?)
  #     raise 'Card must be a drawing with an image attached'
  #   end

  #   return rails_blob_path(card.drawing, disposition: 'attachment')
  # end
end
