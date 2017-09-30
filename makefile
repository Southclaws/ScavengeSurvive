BUILD_NUMBER := $(shell cat BUILD_NUMBER)


# Dependencies: git-clones each of the project dependencies into gamemodes/vendor
dependencies:
	-git clone https://github.com/Zeex/samp-plugin-crashdetect gamemodes/vendor/samp-plugin-crashdetect
	-git clone https://github.com/maddinat0r/sscanf gamemodes/vendor/sscanf
	-git clone https://github.com/Zeex/amx_assembly gamemodes/vendor/amx_assembly
	-git clone https://github.com/Misiur/YSI-Includes gamemodes/vendor/YSI-Includes
	-git clone https://github.com/Southclaws/samp-redis gamemodes/vendor/samp-redis
	-git clone https://github.com/samp-incognito/samp-streamer-plugin gamemodes/vendor/samp-streamer-plugin
	-git clone https://github.com/Southclaws/formatex gamemodes/vendor/formatex
	-git clone https://github.com/oscar-broman/strlib gamemodes/vendor/strlib
	-git clone https://github.com/Southclaws/SAMP-geoip gamemodes/vendor/SAMP-geoip
	-git clone https://github.com/Southclaws/samp-ctime gamemodes/vendor/samp-ctime
	-git clone https://github.com/Awsomedude/easyDialog gamemodes/vendor/easyDialog
	-git clone https://github.com/Southclaws/progress2 gamemodes/vendor/progress2
	-git clone https://github.com/Southclaws/SA-MP-FileManager gamemodes/vendor/SA-MP-FileManager
	-git clone https://github.com/Southclaws/samp-plugin-mapandreas gamemodes/vendor/samp-plugin-mapandreas
	-git clone https://github.com/Southclaws/SimpleINI gamemodes/vendor/SimpleINI
	-git clone https://github.com/Southclaws/modio gamemodes/vendor/modio
	-git clone https://github.com/Southclaws/SIF gamemodes/vendor/SIF
	-git clone https://github.com/Southclaws/AdvancedWeaponData gamemodes/vendor/AdvancedWeaponData
	-git clone https://github.com/Southclaws/Line gamemodes/vendor/Line
	-git clone https://github.com/Southclaws/Zipline gamemodes/vendor/Zipline
	-git clone https://github.com/Southclaws/Ladder gamemodes/vendor/Ladder


# dev builds: uses BUILD_MINIMAL to speed up the compile
dev-windows: dependencies
	pawncc \
		-Dgamemodes \
		-ivendor/samp-plugin-crashdetect/include \
		-ivendor/sscanf \
		-ivendor/amx_assembly \
		-ivendor/YSI-Includes \
		-ivendor/samp-redis \
		-ivendor/samp-streamer-plugin \
		-ivendor/formatex \
		-ivendor/strlib \
		-ivendor/SAMP-geoip \
		-ivendor/samp-ctime \
		-ivendor/easyDialog \
		-ivendor/progress2 \
		-ivendor/SA-MP-FileManager \
		-ivendor/samp-plugin-mapandreas/include \
		-ivendor/SimpleINI \
		-ivendor/modio \
		-ivendor/SIF \
		-ivendor/AdvancedWeaponData \
		-ivendor/Line \
		-ivendor/Zipline \
		-ivendor/Ladder \
		-\;+ \
		-\(+ \
		-\\+ \
		-d3 \
		BUILD_MINIMAL= \
		ScavengeSurvive.pwn
	$(eval BUILD_NUMBER=$(shell echo $$(($(BUILD_NUMBER)+1))))
	echo -n $(BUILD_NUMBER) > BUILD_NUMBER


dev-linux:
	pawncc \
		-Dgamemodes \
		-iinclude \
		-ivendor/samp-plugin-crashdetect/include \
		-ivendor/sscanf \
		-ivendor/amx_assembly \
		-ivendor/YSI-Includes \
		-ivendor/samp-redis \
		-ivendor/samp-streamer-plugin \
		-ivendor/formatex \
		-ivendor/strlib \
		-ivendor/SAMP-geoip \
		-ivendor/samp-ctime \
		-ivendor/easyDialog \
		-ivendor/progress2 \
		-ivendor/SA-MP-FileManager \
		-ivendor/samp-plugin-mapandreas/include \
		-ivendor/SimpleINI \
		-ivendor/modio \
		-ivendor/SIF \
		-ivendor/AdvancedWeaponData \
		-ivendor/Line \
		-ivendor/Zipline \
		-ivendor/Ladder \
		-\;+ \
		-\(+ \
		-\\+ \
		-d3 \
		-Z+ \
		BUILD_MINIMAL= \
		ScavengeSurvive.pwn
	$(eval BUILD_NUMBER=$(shell echo $$(($(BUILD_NUMBER)+1))))
	echo -n $(BUILD_NUMBER) > BUILD_NUMBER


# Production builds: does not use BUILD_MINIMAL
prod-windows:
	pawncc \
		-Dgamemodes \
		-ivendor/samp-plugin-crashdetect/include \
		-ivendor/sscanf \
		-ivendor/amx_assembly \
		-ivendor/YSI-Includes \
		-ivendor/samp-redis \
		-ivendor/samp-streamer-plugin \
		-ivendor/formatex \
		-ivendor/strlib \
		-ivendor/SAMP-geoip \
		-ivendor/samp-ctime \
		-ivendor/easyDialog \
		-ivendor/progress2 \
		-ivendor/SA-MP-FileManager \
		-ivendor/samp-plugin-mapandreas/include \
		-ivendor/SimpleINI \
		-ivendor/modio \
		-ivendor/SIF \
		-ivendor/AdvancedWeaponData \
		-ivendor/Line \
		-ivendor/Zipline \
		-ivendor/Ladder \
		-\;+ \
		-\(+ \
		-\\+ \
		-d3 \
		ScavengeSurvive.pwn

prod-linux:
	pawncc \
		-ivendor/samp-plugin-crashdetect/include \
		-ivendor/sscanf \
		-ivendor/amx_assembly \
		-ivendor/YSI-Includes \
		-ivendor/samp-redis \
		-ivendor/samp-streamer-plugin \
		-ivendor/formatex \
		-ivendor/strlib \
		-ivendor/SAMP-geoip \
		-ivendor/samp-ctime \
		-ivendor/easyDialog \
		-ivendor/progress2 \
		-ivendor/SA-MP-FileManager \
		-ivendor/samp-plugin-mapandreas/include \
		-ivendor/SimpleINI \
		-ivendor/modio \
		-ivendor/SIF \
		-ivendor/AdvancedWeaponData \
		-ivendor/Line \
		-ivendor/Zipline \
		-ivendor/Ladder \
		-Dgamemodes \
		-\;+ \
		-\(+ \
		-\\+ \
		-d3 \
		-Z+ \
		ScavengeSurvive.pwn


# Compiles required filterscripts
filterscripts:
	pawncc \
		-\;+ \
		-\(+ \
		-\\+ \
		filterscripts/rcon.pwn

	pawncc
		-igamemodes/vendor/samp-streamer-plugin \
		-igamemodes/vendor/sscanf \
		-igamemodes/vendor/SA-MP-FileManager \
		filterscripts/object-loader.pwn


# Runs a Redis container for testing
redis:
	docker run --name redis redis
