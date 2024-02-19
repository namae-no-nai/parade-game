class Player < ApplicationRecord
  include Cardable

  validates :name, presence: true
  validates :turn_order, uniqueness: { scope: :game_id }, if: -> { game.started? }
  validates :leader, inclusion: { in: [true, false] }
  validate :unique_leader

  belongs_to :game

  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards

  enum status: %i[waiting ready finished]

  scope :leader, -> { where(leader: true) }
  scope :ordered, -> { order(turn_order: :asc) }

  after_create_commit :broadcast_waiting_list
  after_update_commit :broadcast_waiting_list

  def all_suits?
    player_cards.on_table.group_by(&:suit).count == 6
  end

  private

  def unique_leader
    errors.add(:leader, 'already exists') if leader? && game.players.leader.where.not(id:).exists?
  end

  def broadcast_waiting_list
    ::BroadcastWaitingList.send(game:)
  end
end
