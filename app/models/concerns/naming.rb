module Naming
  extend ActiveSupport::Concern
  # We dont want anyone to be able to create a scribble with a reserved name, so we will not allow these words to be used as names for scribbles
  RESERVED_WORDS = %w[admin assets api about contact help support login logout signup settings].freeze

  included do
    before_validation :normalize_name

    validates :name,
              presence: true,
              uniqueness: { case_sensitive: false },
              length: { in: 3..50 },
              format: { with: /\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" },
              exclusion: { in: RESERVED_WORDS, message: "'%{value}' is reserved and cannot be used" }

    def to_param
      name
    end
  end

  private

  def normalize_name
    return if name.blank?

    self.name = name.to_s.downcase.strip.gsub(/\s+/, "-").gsub(/[^a-z0-9-]/, "")
  end
end
