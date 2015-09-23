
Backbone = require 'backbone'

module.exports = (gui) ->
	root = this

	class DialogWindow extends Backbone.Model
		initialize: (options) ->
			self = this
			@title = options.title or 'Ethos'
			@body = options.body or 'Are you sure?'
			@width = options.width or 500
			@height = options.height or 200
			@type = options.type or ''
			@callback = options.callback or null
			@form = options.form or null
			@options = options.options or [{title: 'Ok', value: 1}]
			@set( 'dialogID', global.randomString() )
			@win = gui.Window.open "app://ethos/app/dialog.html##{ @get('dialogID') }",
				icon: "app/images/icon-tray.ico"
				title: @title
				toolbar: false
				frame: false
				show: true
				focus: true
				resizable: false
				show_in_taskbar: true
				transparent: true
				width: @width
				height: @height
				position: "center"
				min_width: 500
				min_height: 200
			@win.on 'close', ->
				self.trigger('dialog:closed', self)
				this.close(true)

	class EthosDialogManager extends Backbone.Model
		constructor: ->
			self = this
			@dialogs = new Backbone.Collection([])
			@listenTo( @dialogs, 'dialog:closed', @_handleDialogClosed )

			global.dialogContent = (id) ->
				dialog = self.dialogs.findWhere({dialogID: id})
				title: dialog.title
				body: dialog.body
				options: dialog.options
				form: dialog.form
				type: dialog.type

			global.dialogResponse = (data) ->
				dialog = self.dialogs.findWhere({dialogID: data.id})
				if dialog?
					dialog.win.close()
					dialog.callback?( data )

		newDialog: (options) ->
			dialog = new DialogWindow(options)
			@dialogs.add( dialog )

		_handleDialogClosed: (model) =>
			@dialogs.remove( model )



		

