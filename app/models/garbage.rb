class Garbage < ApplicationRecord
  belongs_to :user

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :wday
  belongs_to_active_hash :nth
  belongs_to_active_hash :garbage_type

end
