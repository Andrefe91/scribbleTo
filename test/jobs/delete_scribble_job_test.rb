require "test_helper"

class DeleteScribbleJobTest < ActiveJob::TestCase
  test "automatically enqueues deletion at a dynamic dynamic user-selected time" do
    chosen_expiry = Time.current + 1.day

    assert_enqueued_with(job: DeleteScribbleJob, at: chosen_expiry) do
      Scribble.create!(
        name: "short-lived-note",
        body: "Gone in three hours.",
        deleteTime: 1
      )
    end
  end
end
