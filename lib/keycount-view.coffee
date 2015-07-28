{Disposable, CompositeDisposable} = require 'atom'
{$$, View} = require 'atom-space-pen-views'

module.exports =
class KeycountView extends View
  @content: ->
    @div class: 'key-count-resolver', =>
      @div class: 'panel-heading padded', =>
        @div class: 'block', =>
          @span class: 'keycount-menu', 'Key count '
          @span class: 'badge badge-info keycount-menu', outlet: 'keystroke', ' 0'
          @span class: 'badge badge-info keycount-menu', outlet: 'keys', ' 0'
          @button class: 'inline-block-tight reset', "Reset"
      @div outlet: 'keylist', class: 'panel-body padded'


  add: (keys) ->
    @count++
    @history = @history[-2..]
    @history.push keys
    @refresh()

  refresh: () ->
    c = @count
    history = @history

    @keystroke.html $$ ->
      @span class: 'keycount', " " + c
    @keys.html $$ ->
      @span class: 'keycount', " " + (history[-1..] or '-')
    @keylist.html $$ ->
      @table class: 'table-condensed', =>
        for key, i in history
          @tr class: 'used', =>
            @td class: 'source', (i + c - history.length + 1) + " " + key

  initialize: ->
    @count = 0
    @history = []
    @on 'click', '.reset', ({target}) => @reset()

  # Tear down any state and detach
  destroy: ->

  serialize: ->
    attached: @panel?.isVisible()

  toggle: ->
    if @panel?.isVisible()
      @detach()
    else
      @attach()

  reset: ->
    @count = 0
    @history = []
    @refresh()

  attach: ->
    @disposables = new CompositeDisposable

    @panel = atom.workspace.addBottomPanel(item: this)
    @disposables.add new Disposable =>
      @panel.destroy()
      @panel = null

    @disposables.add atom.keymaps.onDidMatchBinding ({keystrokes, binding, keyboardEventTarget}) =>
      @update(keystrokes, binding, keyboardEventTarget)

    @disposables.add atom.keymaps.onDidPartiallyMatchBindings ({keystrokes, partiallyMatchedBindings, keyboardEventTarget}) =>
      @updatePartial(keystrokes, partiallyMatchedBindings)

    @disposables.add atom.keymaps.onDidFailToMatchBinding ({keystrokes, keyboardEventTarget}) =>
      @update(keystrokes, null, keyboardEventTarget)

  detach: ->
    @disposables?.dispose()

  update: (keystrokes, keyBinding, keyboardEventTarget) ->
    @add keystrokes
