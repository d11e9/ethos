Ξthos
=====

An Ethereum Browser

Still under development. Be waned that this project is still in an early alpha phase.
Binaries and Installers for Windows & OSX will be available under the **Releases** tab on GitHub.

##Features

* Built in IPFS Node
* Built in Ethereum Full node (geth)
* Import Presale Wallet
* Create new accounts
* Simple GUI
* Basic DApp Wallet
* Allow connecting to remote Ethereum Node

## Getting started

Ethos aims to be the easiest way to use Ethereum for non technical users. This then handles running both Ethereum and IPFS nodes under the hood. Allowing the end user to use their browser of choice to interact with the network.

The main interface of Ethos is in the form of a tray menu (see screenshots below for OS specific location).

###OSX

![OSX screenshot](/app/images/screenshots/osx.png?raw=true "OSX screenshot")


###Windows

![Windows screenshot](/app/images/screenshots/win.png?raw=true "Windows screenshot")

We have provided an easy installer for windows, as well as a compressed archive whichever suits you best.
**Please note:** There is currently a significant startup time for the windows binaries, this is something we are aware of and are busy looking into resolving.

##Development Build

This application is essentially a barebones GUI wrapper around the [Ethereum](http://ethereum.org) and [IPFS](http://ipfs.io) projects which when used together make for a better DApp user experience.

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


##Known bugs and issues

* Very slow startup when launching Windows binaries.
* Mining is still under development.
* Launch at startup in settings page is not yet functional.
* File upload on OSX is still a little buggy.


