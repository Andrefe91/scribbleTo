class DeleteScribbleJob < ApplicationJob
  queue_as :default

  def perform(scribbleName)
    scribble = Scribble.find_by(name: scribbleName)

    scribble.destroy if scribble.present?
  end
end
