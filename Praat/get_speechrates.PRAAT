form Search Settings
	comment File Settings
	word textdir 
endform

Read Strings from raw text file: 'textdir$' + "filenames.txt"
numberOfFiles = Get number of strings
for ifile from 1 to numberOfFiles
    selectObject: "Strings filenames"
    file$ = Get string: ifile
    Read from file: 'textdir$' + file$ + "_wh" + ".TextGrid"
endfor

for ifile from 1 to numberOfFiles
	selectObject: "Strings filenames"
  file$ = Get string: ifile
	filename$ = file$
	select TextGrid 'file$'_wh


  Insert interval tier: 3, "pauses"
  word_Total = Get number of intervals: 1

    for word from 1 to word_Total
      word$ = Get label of interval: 1, word
      end_Time = Get end point: 1, word_Total

      if word$ == ""
      pause_Start = Get start point: 1, word
      pause_End = Get end point: 1, word
      pause_Dur = pause_End - pause_Start
        if pause_Dur >= 3
          if pause_Start != 0 and pause_End != end_Time
            Insert boundary: 3, pause_Start
            Insert boundary: 3, pause_End
            pause_Int = Get interval at time: 3, (pause_Start + 0.001)
            Set interval text: 3, pause_Int, "pause"
          endif
        endif
      endif
    endfor

    total_Pausechunks = Get number of intervals: 3

    for chunk from 1 to total_Pausechunks
			chunk$ = Get label of interval: 3, chunk
      if chunk$ != "pause"
      chunk_Start = Get start point: 3, chunk
      chunk_End = Get end point: 3, chunk
      chunk_Duration = chunk_End - chunk_Start

      first_Word = Get interval at time: 1, (chunk_Start + 0.001)
      last_Word = Get interval at time: 1, (chunk_End - 0.001)
      words_Chunk = last_Word - first_Word

      words_per_second = words_Chunk/chunk_Duration

      syllable_count = 0
      first_Phone = Get interval at time: 2, (chunk_Start + 0.001)
      last_Phone = Get interval at time: 2, (chunk_End - 0.001)
      vowel_regex$ = "(\*|-|~)*(a+|e+|i+|u+|o+|iy|l!|n!|m!)(r)*"
      for phone from first_Phone to last_Phone
        phone_label$ = Get label of interval: 2, phone
        if index_regex(phone_label$,  vowel_regex$)
          syllable_count = syllable_count + 1
        endif
      endfor

      syllables_per_second = syllable_count/chunk_Duration
      appendFileLine: "speechrate.txt", "'filename$''tab$''chunk''tab$''chunk_Start''tab$''chunk_End''tab$''words_Chunk''tab$''words_per_second''tab$''syllable_count''tab$''syllables_per_second'"
			endif

endfor
endfor
