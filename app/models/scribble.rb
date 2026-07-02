class Scribble < ApplicationRecord
  include Naming

  before_validation :convert_delete_time_to_integer
  after_create :schedule_autmatic_deletion

  has_rich_text :body
  has_secure_password validations: false


  validates :name, presence: true
  validates :name, uniqueness: { message: "This Scribble has already been taken, please choose another one!" }
  validates :body, :deleteTime, presence: true

  validate :body_cannot_contain_attachments

  # Only validate the password if the user is trying to set one
  validates :password,
            presence: true,
            length: { minimum: 6 },
            allow_blank: true, # Allows it to be empty/nil safely
            if: :password_digest_changed?

  private

  def schedule_autmatic_deletion
    expires_at = Time.current + deleteTime.days

    DeleteScribbleJob.set(wait_until: expires_at).perform_later(name)
  end

  def body_cannot_contain_attachments
    # Check the actual raw HTML code string for any attachment tags
    if body.present? && body.to_s.include?("<action-text-attachment")
      errors.add(:body, "cannot contain images, files, or attachments")
    end
  end

  def convert_delete_time_to_integer
    # Self-assign the integer value if it's present
    self.deleteTime = deleteTime.to_i if deleteTime.present?
  end
end
