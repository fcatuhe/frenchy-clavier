import { Controller } from "@hotwired/stimulus"

const COMPOSE_CODE = "CapsLock"
const MAX_COMPOSE = 3
const FLASH_MS = 110

export default class extends Controller {
  static targets = ["box", "keymap"]

  connect() {
    this.keymap = JSON.parse(this.keymapTarget.textContent)
    this.element.classList.add("live")
    this.reset()
  }

  press(event) {
    if (event.metaKey || (event.ctrlKey && !event.altKey)) return

    if (event.code === COMPOSE_CODE) {
      event.preventDefault()
      this.pendingDead = null
      this.composing = event.shiftKey ? null : ""
      this.flash(event.code)
      return this.repaint()
    }

    const level = this.levelAt(event.code, this.levelOf(event))
    if (level === null || level === undefined || level === "") return

    event.preventDefault()
    this.flash(event.code)

    if (this.isDead(level) && !this.pendingDead && this.composing === null) this.pendingDead = level.d
    else this.emit(this.isDead(level) ? level.g : level)

    this.repaint()
  }

  reset() {
    this.pendingDead = null
    this.composing = null
    this.repaint()
  }

  levelOf(event) {
    const altgr = event.getModifierState("AltGraph") || (event.ctrlKey && event.altKey)
    return (altgr ? 2 : 0) + (event.shiftKey ? 1 : 0)
  }

  levelAt(code, level) {
    const key = this.keymap.keys[code]
    return key ? key[level] : null
  }

  isDead(level) {
    return level !== null && typeof level === "object"
  }

  wouldProduce(level) {
    if (level === null || level === undefined || level === "") return null
    if (this.isDead(level)) return null
    if (this.pendingDead) return this.keymap.dead[this.pendingDead][level] || null
    if (this.composing !== null) return this.keymap.compose[this.composing + level] || null
    return null
  }

  startsASequence(sequence) {
    return Object.keys(this.keymap.compose).some((known) => known.length > sequence.length && known.startsWith(sequence))
  }

  emit(character) {
    if (this.pendingDead) {
      const table = this.keymap.dead[this.pendingDead]
      this.insert(table[character] || this.keymap.deadSpacing[this.pendingDead] + character)
      this.pendingDead = null
      return
    }

    if (this.composing !== null) {
      const sequence = this.composing + character
      if (this.keymap.compose[sequence]) this.insert(this.keymap.compose[sequence])
      else if (this.startsASequence(sequence) && sequence.length < MAX_COMPOSE) return (this.composing = sequence)
      this.composing = null
      return
    }

    this.insert(character)
  }

  insert(text) {
    const box = this.boxTarget
    const at = box.selectionStart
    box.value = box.value.slice(0, at) + text + box.value.slice(box.selectionEnd)
    box.selectionStart = box.selectionEnd = at + text.length
  }

  flash(code) {
    this.slotsFor(code).forEach((slot) => {
      slot.classList.add("pressed")
      setTimeout(() => slot.classList.remove("pressed"), FLASH_MS)
    })
  }

  slotsFor(code) {
    return document.querySelectorAll(`[data-code="${code}"]`)
  }

  repaint() {
    const armed = this.pendingDead || this.composing !== null

    document.querySelectorAll("[data-code]").forEach((slot) => {
      const code = slot.dataset.code
      const yields = armed && (this.wouldProduce(this.levelAt(code, 0)) || this.wouldProduce(this.levelAt(code, 1)))

      if (yields) slot.setAttribute("data-live", yields)
      else slot.removeAttribute("data-live")
    })
  }
}
