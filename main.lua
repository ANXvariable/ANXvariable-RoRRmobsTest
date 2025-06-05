--monsters

1og. info ("Loading ".._ENV["!guid"]..".")
local envy = mods ["LuaENVY-ENVY" ]
envy.auto()
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)

PATH = _ENV["!plugins_mod_folder_path"]
NAMESPACE = "anx"

local initialize = function()
	local folders = {
  "Misc",
		"Actors",
		"Elites"
	}

	for _, folder in ipairs(folders) do
		local filepaths = path.get_files(path.combine(PATH, folder))
		for _, filepath in ipairs(filepaths) do
			-- filter for files with the .lua extension
			if string.sub(filepath, -4, -1) == ".lua" then
				require(filepath)
			end
		end
	end

end
Initialize(initialize)

-- ** Uncomment the two lines below to re-call initialize on hotload
if hotload then initialize() end
hotload = true