url = require( 'url' )

module.exports = (app, server) ->
  NAMEREG_ADDRESS = 'NNN0'

  MOCK_DATA =
    dox:
      AAA1: 'DOC_HASH0'
      AAA2: 'DOC_HASH1'
      AAA3: 'DOC_HASH2'
      AAA4: 'DOC_HASH3'
      NNN0: 'DOC_HASH4'
    th:
      AAA1: 'CONTENT_HASH0'
    ip:
      AAA1: 'http://projectdnet.github.io/d2'
      AAA4: 'http://gavwood.com/gavcoin.html'
      AAA5: 'http://example.com'
      AAA6: 'http://d11e9.github.io/Occams-Run'
      EEE0: "http://localhost:#{ server.address().port }/index.html"
      EEE1: "http://eth:#{ server.address().port }/swarm"

  MOCK_DATA[NAMEREG_ADDRESS] =
    ethos: 'EEE0'
    occamsrun: 'AAA6'
    namereg: NAMEREG_ADDRESS
    dox: 'AAA1'
    th: 'AAA2'
    ip: 'AAA3'
    gavcoin: 'AAA4'
    etherchain: 'AAA5'
    swarm: 'EEE1'

  reg = (address, name) ->
    MOCK_DATA[NAMEREG_ADDRESS][address] = name

  for name, address in MOCK_DATA[NAMEREG_ADDRESS]
    reg( address, name )

  app.get '*', (req,res) ->

    url = url.parse( req.url, true )
    base = url.pathname.split('/')[1]
    rest = url.pathname.split('/').splice( 2, url.pathname.split('/').length - 1 )
    
    protocol = 'eth'
    path = rest.join( '/' )

    if MOCK_DATA.ip[ MOCK_DATA[ NAMEREG_ADDRESS ][base] ]
      protocol = 'ip'
      domain =  MOCK_DATA.ip[ MOCK_DATA[ NAMEREG_ADDRESS ][base] ]

    if MOCK_DATA.th[ MOCK_DATA[ NAMEREG_ADDRESS ][base] ]
      protocol = 'th'
      domain = MOCK_DATA.th[ MOCK_DATA[ NAMEREG_ADDRESS ][base] ]
    
    if protocol is 'eth' and MOCK_DATA.dox[ MOCK_DATA[ NAMEREG_ADDRESS ][base] ]
      protocol = 'th'
      base = MOCK_DATA.dox[ MOCK_DATA[ NAMEREG_ADDRESS ][base] ]
      domain = 'dox'


    scheme = "#{ protocol }://#{ domain }"
    scheme += url.search if url.search
    scheme += "##{ path }" if path

    if protocol is 'ip'
      domain = MOCK_DATA.ip[ MOCK_DATA[ NAMEREG_ADDRESS ][base] ]
      path = rest.join('/')
      scheme = "#{domain}"
      scheme += url.search if url.search
      method = req.method
      res.render( 'ip', url: scheme )
    else if protocol is 'th'
      res.render( 'swarm', torrents: app.swarmClient.torrents, hash: domain, title: base )
    else
      res.json
        url: url
        scheme: scheme
