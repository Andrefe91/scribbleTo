module Naming
  extend ActiveSupport::Concern
  # We dont want anyone to be able to create a scribble with a reserved name, so we will not allow these words to be used as names for scribbles
  RESERVED_WORDS = %w[admin assets api about contact help support login logout signup settings new].freeze

  class_methods do
    def normalizeName(string)
      return string if string.blank?
      string.to_s.downcase.strip.gsub(/\s+/, "-").gsub(/[^a-z0-9\- _+.~]/, "")
    end
  end

  included do
    before_validation :normalize_name

    validates :name,
              presence: true,
              uniqueness: { case_sensitive: false },
              length: { in: 3..50 },
              format: { with: /\A[a-z0-9\- _+.~]+\z/, message: "can only contain lowercase letters, numbers, hyphens, spaces, underscores, plus signs, periods, and tildes" },
              exclusion: { in: RESERVED_WORDS, message: "'%{value}' is reserved and cannot be used" }

    def to_param
      name
    end
  end

  private

  def normalize_name
    return if name.blank?

    self.name = self.class.normalizeName(name)
  end
end
