module.exports = (gui) ->
	class IPFSMenu
		constructor: ({@process, @config}) ->
			@menu = new gui.Menu()
			@rootItem = new gui.MenuItem
				label: 'IPFS'
				submenu: @menu

			@createItems()
			@process.on( 'status', @updateStatus )
			@process.on( 'connected', @onConnected )

		createItems: ->
			@status = new gui.MenuItem
				label: 'Status: Not Running'
				enabled: false
			@toggle = new gui.MenuItem
				label: 'Start'
				click: => @process.toggle()
			@addFile = new gui.MenuItem
				label: 'Add File'
				enabled: false
				click: => @process.addFile()
			@info = new gui.MenuItem
				label: 'Info'
				enabled: false
				click: =>
					@process.info (err,res) =>
						address = @process.getGateway()
						console.log( "IPFS Gateway address: #{address}" )
						gui.Shell.openExternal("http://#{ address }/ipns/#{ res.info.ID }") unless err
			
			@menu.append( @status )
			@menu.append( @toggle )
			@menu.append( @addFile )
			@menu.append( @info )

		updateStatus: (running) =>
			@status.label = "Status: Connecting"
			@toggle.label = "Stop"
			@addFile.enabled = false
			@info.enabled = false
			if !running
				@status.label = "Status: Not Running"
				@toggle.label = "Start"

		onConnected: =>
			@process.api.id (err, info) =>
				console.log( "IPFS connected: ", err, info)
				@status.label = "Status: Connected" unless err
				@addFile.enabled = !err
				@info.enabled = !err

		get: -> @rootItem
