module.exports = # Keycount =
  keycountView: null

  activate: ({attached}={}) ->
    @createView().toggle() if attached
    atom.commands.add 'atom-workspace',
      'keycount:toggle': => @createView().toggle()
      'core:cancel': => @createView().detach()
      'core:close': => @createView().detach()

  createView: ->
    unless @keycountView?
      KeycountView = require './keycount-view'
      @keycountView = new KeycountView()
    @keycountView

  deactivate: ->
    @keycountView?.destroy()

  serialize: ->
    @keycountView?.serialize()
