# This first layer ensures that rails loads the next layer everytime the code reloads in Development mode.
# This is necessary because PaperTrail's `has_paper_trail` method is called at class load time, and we want to ensure
# that it is applied to the ActionText::RichText model every time the application reloads.
Rails.application.config.to_prepare do
  # With this (metaprogramming) second layer, we ensure that the `has_paper_trail` method is called on the context of
  # the ActionText::RichText class
  ActionText::RichText.class_eval do
    # Because we cant associate the PaperTrail twice or more, we query the model to check if it already has the
    # association before adding it again. This prevents errors when the code reloads in Development mode.
    unless reflect_on_association(:versions)
      # Limit: 15 versions per record (14 most recent, plus a `create` event)
      has_paper_trail only: [ :body ], limit: 14
    end
  end
end
