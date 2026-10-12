fx_version 'cerulean'
game 'gta5'

name "mp_trickortreat"
description "Trick Or Treat"
author "Michael Pollenski"
version "1"

shared_scripts {
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

dependencies {
	'ox_lib',
	'ox_target',
	'ox_inventory'
}