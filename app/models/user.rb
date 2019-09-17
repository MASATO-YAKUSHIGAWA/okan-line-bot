class User < ApplicationRecord
  belongs_to :area_info
  has_many :garbages, dependent: :destroy
end
