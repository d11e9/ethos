module.exports = (gui) ->
	class IPFSMenu
		constructor: ({@process, @config, @dialogManager}) ->
			@menu = new gui.Menu()
			@rootItem = new gui.MenuItem
				label: 'IPFS'
				submenu: @menu

			@createItems()
			@process.on( 'status', @updateStatus )
			@process.on( 'connected', @onConnected )


		showHash: (err, hash) =>
			if err
				@dialogManager.newDialog
					title: "Ethos: IPFS Error"
					body: "<p>#{ err.message }</p>"
					type: 'error'
			else
				@dialogManager.newDialog
					title: "Ethos: IPFS"
					body: "<p>Added to IPFS: <em>#{hash}</em></p>"

		createItems: ->
			@status = new gui.MenuItem
				label: 'Status: Not Running'
				enabled: false
				
			@toggle = new gui.MenuItem
				label: 'Start'
				click: => @process.toggle()

			@addFile = new gui.MenuItem
				label: 'Add File'
				click: => @process.addFile( @showHash )
						

			@addFolder = new gui.MenuItem
				label: 'Add Folder'
				click: => @process.addFolder( @showHash )

			@files = new gui.MenuItem
				label: 'Manage Files'
				enabled: false
				click: => gui.Shell.openExternal("http://#{ @apiAddress }/webui/#/files")

			@info = new gui.MenuItem
				label: 'Open Web UI'
				enabled: false
				click: => gui.Shell.openExternal("http://#{ @apiAddress }/webui")

			@log = new gui.MenuItem
				label: "Log"
				click: =>
					gui.Window.open('app://ethos/app/ipfsLog.html', toolbar: @config.getBool( 'debug' ))

			
			@menu.append( @status )
			@menu.append( @toggle )
			@menu.append( @info )
			@menu.append( @files )
			@menu.append( @addFile )
			@menu.append( @addFolder )
			@menu.append( @log )


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
