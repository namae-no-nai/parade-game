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

  async sendPostRequest(gameId, playerCardId, playerId, boardId) {
    const url = `/game/${gameId}/player_turn`;
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({
          game: {
            card_id: playerCardId,
            player_id: playerId,
            board_id: boardId
          }
        }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }

      // Handle the success response, if needed
      const responseData = await response.json();
      console.log(responseData);
    } catch (error) {
      console.error("Error:", error);
    }
  }
}
