suits = %w[Dodo MadHatter HumptyDumpty Alice CheshireCat WhiteRabbit ]
value = (0..10).map(&:to_s)

suits.each do |suit|
  value.each do |value|
    Card.create(suit:, value:)
  end
end