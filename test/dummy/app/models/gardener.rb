class Gardener < ActiveRecord::Base
  has_one :worker, as: :detail
end