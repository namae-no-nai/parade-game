import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["playerCard"]

  selectPlayerCard(event) {
    const playerCard = event.target.closest("div.player-card")
    const playerCardId = playerCard.dataset.playerCardId

    const player = playerCard.closest("div.player")
    const playerId = player.dataset.playerId

    alert(`Player: ${playerId} selected the card ${playerCardId}`)
  }
}
