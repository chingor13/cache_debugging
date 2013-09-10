class Electrician < ActiveRecord::Base
  has_one :worker, as: :detail
end