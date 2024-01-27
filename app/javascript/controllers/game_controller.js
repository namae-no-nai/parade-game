import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["playerCard", "board"];

  selectPlayerCard(event) {
    const board = this.boardTarget;
    const boardId = board.dataset.boardId;

    const playerCard = event.target.closest("div.player-card");
    const playerCardId = playerCard.dataset.playerCardId;

    const player = playerCard.closest("div.player");
    const playerId = player.dataset.playerId;

    const gameId = new URL(window.location.href).pathname.split('/').pop();
    this.sendPostRequest(gameId, playerCardId, playerId, boardId);
  }

  sendPostRequest(gameId, playerCardId, playerId, boardId) {
    const url = `/game/${gameId}/player_turn`;
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/html"
      },
      body: JSON.stringify({
        game: {
          card_id: playerCardId,
          player_id: playerId,
          board_id: boardId
        }
      }),
    }).then(response => response.text())
      .then(html => {
        document.body.innerHTML = html;
      })
  }
}
