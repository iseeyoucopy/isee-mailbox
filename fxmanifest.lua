fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game "rdr3"

lua54 'yes'
author '@iseeyoucopy'

description 'MailBox'

shared_scripts {
  'config.lua',
  'shared/locale.lua',
  'languages/*.lua'
}

client_scripts {
  'client/client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/DbUpdater.lua',
  'server/versioncheck.lua',
  'server/server.lua'
}

dependency {
  'vorp_core',
  'oxmysql',
  'feather-menu',
  'bcc-utils'
}

version '1.0.1'
