form filename
	word filename
	positive tiers
	word analysisdir 
endform

select TextGrid 'filename$'_wh
plus LongSound 'filename$'
editor: selected$()
pauseScript: "Make your selection"
start = Get start of selection
startr = round(start)
Zoom to selection
Extract visible spectrogram
Extract selected TextGrid (preserve times)
endeditor
Erase all
Select inner viewport: 3, 9, 0.5, 6
selectObject: "Spectrogram untitled"
Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "yes"
Remove
select TextGrid 'filename$'_wh
if tiers > 2
Remove tier: 2
Remove tier: 6
Remove tier: 5


Select inner viewport: 3, 9, 0.5, 10.125

elsif tiers < 3
Remove tier: 6
Remove tier: 5
Remove tier: 3
Remove tier: 2
Select inner viewport: 3, 9, 0.5, 8.75
endif

Draw: 0, 0, "yes", "yes", "yes"
Remove
pauseScript: "Save as EPS and PNG?"
Save as EPS file: "'analysisdir$''filename$'_'startr'.eps"
Save as 600-dpi PNG file: "'analysisdir$''filename$'_'startr'.png"
