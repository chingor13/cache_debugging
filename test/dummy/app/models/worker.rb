class Worker < ActiveRecord::Base

  belongs_to :detail, polymorphic: true, touch: true
  has_many :contracts, dependent: :destroy
  has_many :tweets, dependent: :destroy

end
