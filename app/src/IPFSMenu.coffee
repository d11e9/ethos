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
				click: => @process.addFile (err, hash) ->
					window.alert( "File added: #{hash}")

			@addFolder = new gui.MenuItem
				label: 'Add Folder'
				click: => @process.addFolder (err, hash) ->
					window.alert( "Folder added: #{hash}")

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
			@menu.append( @addFile )
			@menu.append( @addFolder )


		updateStatus: (running) =>
			@status.label = "Status: Connecting"
			@toggle.label = "Stop"
			@files.enabled = false
			@addFile.enabled = false
			@addFolder.enabled = false
			@info.enabled = false
			if !running
				@status.label = "Status: Not Running"
				@toggle.label = "Start"

		onConnected: =>
			@process.api.id (err, info) =>
				unless err
					console.log( "IPFS connected: ", info)
					@apiAddress = @process.getAPI() 
					@status.label = "Status: Connected"
					notification = new window.Notification "Ethos",
						body: "IPFS Network Connected."
					notification.onshow = -> setTimeout( ( -> notification.close() ), 3000)
				@files.enabled = !err
				@info.enabled = !err
				@addFile.enabled = !err
				@addFolder.enabled = !err

		get: -> @rootItem
