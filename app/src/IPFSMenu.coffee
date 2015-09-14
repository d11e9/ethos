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

			@files = new gui.MenuItem
				label: 'Manage Files'
				enabled: false
				click: => gui.Shell.openExternal("http://#{ @apiAddress }/webui/#/files")

			@info = new gui.MenuItem
				label: 'Open Web UI'
				enabled: false
				click: => gui.Shell.openExternal("http://#{ @apiAddress }/webui")
			
			@menu.append( @status )
			@menu.append( @toggle )
			@menu.append( @info )
			@menu.append( @files )

		updateStatus: (running) =>
			@status.label = "Status: Connecting"
			@toggle.label = "Stop"
			@files.enabled = false
			@info.enabled = false
			if !running
				@status.label = "Status: Not Running"
				@toggle.label = "Start"

		onConnected: =>
			@process.api.id (err, info) =>
				unless err
					console.log( "IPFS connected: ", err, info)
					@apiAddress = @process.getAPI() 
					console.log( "IPFS API address: #{ @apiAddress }" )
					@status.label = "Status: Connected" unless err
					notification = new window.Notification "Ethos",
						body: "IPFS Network Connected."
					notification.onshow = -> setTimeout( ( -> notification.close() ), 3000)
				@files.enabled = !err
				@info.enabled = !err

		get: -> @rootItem
