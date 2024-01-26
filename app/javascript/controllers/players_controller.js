import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["playerName"]

  addPlayer(event) {
    const playersList = event.target.closest("div#playersList")
    playersList.appendChild(this.newPlayer())
  }

  removePlayer(event) {
    event.target.closest('div').remove()
  }

  newPlayer() {
    const divPlayer = document.createElement('div')
    divPlayer.classList.add('player')

    const inputPlayer = document.createElement('input')
    inputPlayer.setAttribute('type', 'text')
    inputPlayer.setAttribute('name', 'game[players][]')
    inputPlayer.setAttribute('data-players-target', 'playerName')
    inputPlayer.setAttribute('placeholder', 'Player Name')

    const buttonRemove = document.createElement('button')
    buttonRemove.setAttribute('type', 'button')
    buttonRemove.setAttribute('name', 'button')
    buttonRemove.setAttribute('data-action', 'click->players#removePlayer')
    buttonRemove.innerHTML = 'Remove Player'

    divPlayer.appendChild(inputPlayer)
    divPlayer.appendChild(buttonRemove)

    return divPlayer
  }
}
