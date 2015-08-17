Ξthos
=====

An Ethereum Browser

Still under development.
Binaries for the various platforms (where appropriate) will be available as [releases on github](http://github.com/projectdnet/ethos/releases)

## Getting started

Ethos aims to be the easiest way to use Ethereum for non technical users. Once installed and run for the first time, the user should be prompted whether they want it to launch at startup. This then handles running both Ethereum and IPFS nodes under the hood. Allowing the end user to use their browser of choice to interact with the network.

###OSX

![OSX screenshot](/app/images/screenshots/osx.png?raw=true "OSX screenshot")

###Windows

![Windows screenshot](/app/images/screenshots/win.png?raw=true "Windows screenshot")

##Development Build

This application is essentially a node-webkit wrapper around other [Ethereum](http://ethereum.org) projects and [IPFS](http://ipfs.io) which when used together make for a better DApp user experience.

To build from source or contribute you can do the following:

    $ git clone https://githib.com/projectdnet/ethos
    $ cd ethos
    $ npm install

    $ # to run without building
    $ npm run app

    $ # to build distribution binaries
    $ # NOTE: This build will not work on windows unless you are using npm >= 3
    $ # This is due to long path names in dependencies, npm 3 creates a better/flatter structure.
    $
    $ npm run build



