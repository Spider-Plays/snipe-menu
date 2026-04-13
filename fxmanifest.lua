fx_version 'cerulean'
game 'gta5'

description 'Admin Menu Script'
author 'SNIPE'

lua54 'yes'
ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
	'config/config.lua',
    'config/*.lua',
    'custom/custom_config.lua',
}

files {
	'html/**/*',
}

client_scripts{
    'utils/cl_utils.lua',
    'client/**/*',
    'custom/client.lua'
} 

server_scripts{
    'utils/sv_utils.lua',
    '@oxmysql/lib/MySQL.lua',
    'server/**/*',
    'custom/server.lua'
} 

dependency '/assetpacks'