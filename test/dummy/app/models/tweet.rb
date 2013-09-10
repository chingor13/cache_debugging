class Tweet < ActiveRecord::Base

  # broken dependency - should touch worker, but won't for testing
  belongs_to :worker

end