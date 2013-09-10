class Plumber < ActiveRecord::Base
  has_one :worker, as: :detail
end