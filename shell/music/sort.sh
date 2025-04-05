#! /bin/bash
#automatically sort your music collection!
#if you're like me, you probably started with a folder full of loose files but later had to reorganize the whole thing to make it actually navigatable for use on stuff like Jellyfin and Kodi
#run this in your folder full of loose audio files
#i cant believe i did half of my library manually so thank me later
#it will sort them like this:
#.../music/
#	<performer/>
#		<album/>
#			<position>. <track> - <performer>
#if there are multiple performers, it will just list them all as the <performer>
for entry in *.flac; do #list all stuff with *.flac in dir; you can probably get away with mp3 but it wont work if they dont contain metadata
	if [[ -f $entry ]]; then #check if it's a file
		performer="$(mediainfo --Language=raw --Full --Inform="General;%Performer%" "$entry")"
		album="$(mediainfo --Language=raw --Full --Inform="General;%Album%" "$entry")"
		track="$(mediainfo --Language=raw --Full --Inform="General;%Track%" "$entry")"
		position="$(mediainfo --Language=raw --Full --Inform="General;%Track/Position%" "$entry")"
		position="$(printf "%02d" "${position#0}")"
		#echo $entry
		#echo ${position}
		echo "$entry" "->" "${performer}/${album}/${position}. ${track} - ${performer}"
		echo 
		mkdir -p "${performer}/${album}" #make tree
		mv "$entry" "${performer}/${album}/${position} ${track} - ${performer}"
	fi
done
