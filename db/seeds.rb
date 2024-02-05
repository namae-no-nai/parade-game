# frozen_string_literal: true

suits = %w[Dodo MadHatter HumptyDumpty Alice CheshireCat WhiteRabbit]
values = (0..10).map(&:to_s)

suits.each do |suit|
  values.each do |value|
    Card.find_or_create_by!(suit:, value:)
  end
end
