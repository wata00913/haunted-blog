# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where('secret = FALSE') }

  scope :referable, ->(user_id) { published.or(where(user_id: user_id)) }

  scope :search, lambda { |term|
    like_term = "%#{sanitize_sql_like(term.to_s)}%"
    where('title LIKE :like_term OR content LIKE :like_term', like_term: like_term)
  }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end
end
