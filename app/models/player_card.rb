class PlayerCard < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :card
end
