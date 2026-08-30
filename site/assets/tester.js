(function () {
  "use strict";

  var box = document.querySelector("[data-tester]");
  var map = document.querySelector("[data-keymap]");
  if (!box || !map) return;

  var keymap = JSON.parse(map.textContent);
  var COMPOSE_CODE = "CapsLock";
  var MAX_COMPOSE = 3;

  var pendingDead = null;
  var composing = null;

  document.documentElement.classList.remove("no-js");

  function levelOf(event) {
    var altgr = event.getModifierState("AltGraph") || (event.ctrlKey && event.altKey);
    return (altgr ? 2 : 0) + (event.shiftKey ? 1 : 0);
  }

  function levelAt(code, level) {
    var key = keymap.keys[code];
    return key ? key[level] : null;
  }

  function isDead(level) {
    return level !== null && typeof level === "object";
  }

  function wouldProduce(level) {
    if (level === null || level === undefined || level === "") return null;
    if (isDead(level)) return pendingDead || composing !== null ? null : level.g;
    if (pendingDead) return keymap.dead[pendingDead][level] || null;
    if (composing !== null) return keymap.compose[composing + level] || null;
    return level;
  }

  function composePrefix(sequence) {
    return Object.keys(keymap.compose).some(function (known) {
      return known.length > sequence.length && known.indexOf(sequence) === 0;
    });
  }

  function insert(text) {
    var at = box.selectionStart;
    box.value = box.value.slice(0, at) + text + box.value.slice(box.selectionEnd);
    box.selectionStart = box.selectionEnd = at + text.length;
  }

  function slotsFor(code) {
    return document.querySelectorAll('[data-code="' + code + '"]');
  }

  function eachSlot(callback) {
    document.querySelectorAll("[data-code]").forEach(callback);
  }

  function repaintPreview() {
    eachSlot(function (slot) {
      var armed = pendingDead || composing !== null;
      var yields = armed && (wouldProduce(levelAt(slot.dataset.code, 0)) || wouldProduce(levelAt(slot.dataset.code, 1)));

      if (yields) slot.setAttribute("data-live", yields);
      else slot.removeAttribute("data-live");
    });
  }

  function flash(code) {
    slotsFor(code).forEach(function (slot) {
      slot.classList.add("pressed");
      setTimeout(function () { slot.classList.remove("pressed"); }, 110);
    });
  }

  function typed(character) {
    if (pendingDead) {
      insert(keymap.dead[pendingDead][character] || keymap.deadSpacing[pendingDead] + character);
      pendingDead = null;
      return;
    }

    if (composing !== null) {
      var sequence = composing + character;
      if (keymap.compose[sequence]) insert(keymap.compose[sequence]);
      else if (composePrefix(sequence) && sequence.length < MAX_COMPOSE) return void (composing = sequence);
      composing = null;
      return;
    }

    insert(character);
  }

  box.addEventListener("keydown", function (event) {
    if (event.metaKey || (event.ctrlKey && !event.altKey)) return;

    if (event.code === COMPOSE_CODE) {
      event.preventDefault();
      composing = event.shiftKey ? null : "";
      pendingDead = null;
      flash(event.code);
      repaintPreview();
      return;
    }

    var level = levelAt(event.code, levelOf(event));
    if (level === null || level === undefined || level === "") return;

    event.preventDefault();
    flash(event.code);

    if (isDead(level) && !pendingDead && composing === null) pendingDead = level.d;
    else typed(isDead(level) ? level.g : level);

    repaintPreview();
  });

  box.addEventListener("blur", function () {
    pendingDead = null;
    composing = null;
    repaintPreview();
  });
})();
