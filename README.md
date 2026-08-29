# clavier

An AZERTY layout for writing French and English prose and for coding in Ruby, CSS, HTML, JS and Python, on a ThinkPad X1 Carbon Gen 6 (ANSI).

`layout.yml` is the only thing to edit. Everything else is generated from it: the XKB symbols file that Hyprland loads, and a printable reference sheet.

```bash
./bin/build          # out/fc (xkb symbols) + out/sheet.html
./bin/apply          # build, install to ~/.config/xkb/symbols/fc, switch Hyprland to it
ruby test/layout_test.rb
```

`bin/apply` is live only. To keep the layout across a Hyprland restart, set it in `~/.config/hypr/input.lua`:

```lua
hl.config({ input = { kb_layout = "fc" } })
```

If a build ever leaves you unable to type, letters keep their QWERTY-adjacent positions except `a/q`, `z/w` and `m`, so this still works:

```bash
hyprctl keyword input:kb_layout us
```

## The design

Four levels per key: base, Shift, AltGr, AltGr+Shift. AltGr is the right Alt.

- Prose runs unshifted: `à é è`, `. , ' "`, and `ç` on AltGr+C. Digits are on Shift.
- Code runs unshifted too: `@ ( ) - _ + * ~ / : ? #` and `|`, with `{ }` on AltGr+`(`/`)`, `[ ]` on AltGr+R/T, `< >` on AltGr+F/G, `$` on AltGr+S, `&` on AltGr+é, backtick on AltGr+è.
- Accented capitals sit on AltGr+Shift of the key that carries the lowercase: `À É È` on the `à é è` keys, `Ù` on U, `Ç` on C.
- `^` is a literal caret on AltGr+`@`. The dead circumflex and dead diaeresis keep their own key, at the ANSI `[` position, so `ê ë î ï ô û` still work.
- Space: AltGr gives U+202F (narrow no-break space, the correct one before `; : ! ?` in French), AltGr+Shift gives U+00A0.

This is close to AFNOR NF Z71-300 (`fr(afnor)` in xkeyboard-config), which was derived independently. Two deliberate departures: AFNOR puts `<` `>` and `|` on keys that do not exist on ANSI hardware, and it has no literal `^`.

## The hardware

The board drawn on the sheet is the X1 Carbon Gen 6: ANSI, no ISO key left of Shift, 11 keys on the home row, no Menu key, one Super, `Home End Ins Del` closing the function row, `Fn` left of `Ctrl`, and PgUp/PgDn as their own keys above the left and right arrows. Key widths come from Lenovo's own dimensions, through `pfaion/x1carbon-xkb-geometry`.

Two tests keep the drawing and `layout.yml` honest about the hardware: `test_every_key_lands_on_a_slot_of_the_ansi_board` and `test_every_row_spans_the_full_board`.

## Open questions

Both are Shift-level today, and both are frequent in CSS and JS:

- `;` on Shift+`,`
- `=` on Shift+`:`

`.` and `,` stay unshifted, so those two have nowhere cheaper to go without giving up something else. The 67 free levels listed at the bottom of the sheet are the room left to trade with.

## Caps Lock

Caps is Compose. Shift+Caps toggles the digit row onto its Shift level, so a long number does not need Shift held. Caps Lock itself is both Shifts together.

That needs `compose:caps` out of `kb_options`, since the option redefines the key and would win:

```lua
hl.config({ input = { kb_layout = "fc", kb_options = "shift:both_capslock_cancel" } })
```
