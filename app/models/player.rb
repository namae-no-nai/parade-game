class Player < ApplicationRecord
  include Cardable

  validates :name, presence: true
  validates :turn_order, uniqueness: { scope: :game_id }, if: -> { game.started? }
  validates :leader, inclusion: { in: [true, false] }
  validate :unique_leader

  belongs_to :game

  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards

  enum status: %i[waiting ready]

  scope :leader, -> { where(leader: true) }

  after_create_commit :broadcast_new_player
  after_update_commit :broadcast_player_list_update

  def all_suits?
    player_cards.on_table.group_by(&:suit).count == 6
  end

  def broadcast_game_change
    broadcast_replace_to(
      self,
      target: game,
      partial: 'games/game',
      locals: { game:, current_player: self }
    )
  end

  private

  def unique_leader
    errors.add(:leader, 'already exists') if leader? && game.players.leader.where.not(id:).exists?
  end

  def broadcast_new_player
    broadcast_append_to(
      game,
      target: 'waiting_list',
      partial: 'games/waiting_player',
      locals: { player: self }
    )
  end

  def broadcast_player_list_update
    broadcast_replace_to(
      game,
      target: 'waiting_list',
      partial: 'games/players_list',
      locals: { game: }
    )
  end
end
