
###############################################################################
# This script takes in a list of filenames and the directories where they     #
# can be found. It assumes that TextGrids have a word tier at tier 1.         #
# It then iterates over words to find the specified segment in the specified  #
# tier. The segment can be specified using a regular expression.              #
# When a segment is found it is shown to you and you can change formant       #
# settings or specify a different selection before either measuring the       #
# formants or skipping the token. Formants are calculated using "To Burg..."  #
###############################################################################

form Search Settings
	comment File Settings
	comment Specify directory containing audio files (with quotes)
	word audiodir "C:\Users\ninal\UoE_OneDrive\University\Postgrad\Research\Research_Projects\ASR_Bias\VCTK-Corpus\VCTK-Corpus\UK_Ireland\stella\wav\"
	comment Specify directory containing TextGrid files (with quotes)
	word textdir "C:\Users\ninal\UoE_OneDrive\University\Postgrad\Research\Research_Projects\ASR_Bias\VCTK-Corpus\VCTK-Corpus\UK_Ireland\stella\aligned\"
	comment Specify desired output directory (without quotes)
	word outdir C:\Users\ninal\UoE_OneDrive\University\Postgrad\Research\Research_Projects\ASR_Bias\VCTK-Corpus\VCTK-Corpus\UK_Ireland\stella
	comment Path to file listing all file names to be processed
	word files_to_process "C:\Users\ninal\UoE_OneDrive\University\Postgrad\Research\Research_Projects\ASR_Bias\filenames.txt"
	comment Segments to Search For (in regular expression format)
	sentence search_Segments (\*|-|~)*(A+|E+|I+|U+|O+)(r)*
	comment Tier to search in
	positive search_Tier 2
	comment Extra Settings
	positive Window_Size 1
	real Start_Time 0
	boolean Play_on_Continue 0
endform

if files_to_process$ != "all"
	Read Strings from raw text file: 'files_to_process$'


else

Create Strings as file list: "Strings filenames", "'audiodir$'*.wav"

endif

numberOfFiles = Get number of strings
for ifile from 1 to numberOfFiles
		selectObject: "Strings filenames"
		file$ = Get string: ifile
		Read from file: 'textdir$' + file$  + ".TextGrid"
		Open long sound file: 'audiodir$' + file$ + ".wav"
endfor


for ifile from 1 to numberOfFiles
 selectObject: "Strings filenames"
  file$ = Get string: ifile
  select TextGrid 'file$'
  plus LongSound 'file$'
  Edit
  editor TextGrid 'file$'
  endeditor

  select TextGrid 'file$'

	numberTiers = Get number of tiers


# These are the default settings for measuring formants

state$ = "measuring"
number_of_formants = 5
maximum_formant = 5500
window_length = 0.025
dynamic_range = 30.0
notes$ = ""


token_id = 1

word_Intervals = Get number of intervals... 1
file_End = Get end point... 1 word_Intervals
start_Interval = Get interval at time... 1 start_Time
for int from start_Interval to word_Intervals
	word$ = Get label of interval... 1 int
	word_Start = Get start point... 1 int
	word_End = Get end point... 1 int

	ph_First_Int = Get interval at time... search_Tier word_Start + 0.0005
	ph_Last_Int = Get interval at time... search_Tier word_End - 0.0005

	for ph_Int from ph_First_Int to ph_Last_Int

		seg$ = Get label of interval... search_Tier ph_Int

		if index_regex(seg$, search_Segments$)

				context$ = "internal"
			if ph_First_Int == ph_Last_Int
				context$ = "coextensive"
			elsif ph_Int == ph_First_Int
				context$ = "initial"
			elsif ph_Int == ph_Last_Int
				context$ = "final"
			endif


			window_Start = Get start point... 1 max(1,int - 1)
			window_End = Get end point... 1 min(int + 1, word_Intervals)
			window_Dur = window_End - window_Start

			firstPhInt = Get interval at time... search_Tier window_Start+0.0005
			lastPhInt = Get interval at time... search_Tier window_End-0.0005


			pre_Seg_Start = Get start point... search_Tier ph_Int-1
			pre_Seg_End = Get end point... search_Tier ph_Int-1
			pre_Seg_Label$ = Get label of interval... search_Tier ph_Int-1
			pre_Seg_Dur = pre_Seg_End - pre_Seg_Start

			post_Seg_Start = Get start point... search_Tier ph_Int+1
			post_Seg_End = Get end point... search_Tier ph_Int+1
			post_Seg_Label$ = Get label of interval... search_Tier ph_Int+1
			post_Seg_Dur = post_Seg_End - post_Seg_Start

			seg_Start =  Get start point... search_Tier ph_Int
			seg_End = Get end point... search_Tier ph_Int

			mid_Point = seg_Start + ((seg_End - seg_Start)/2)



			editor TextGrid 'file$'
			Zoom... max(1,window_Start) min(window_End, file_End)
			if play_on_Continue = 1
				Play window
			endif
			coded = 0


			Formant settings... maximum_formant number_of_formants window_length dynamic_range 1

			Select... window_Start window_End
			Play window
			Select... seg_Start seg_End


			coded = 0
			while coded == 0

			beginPause ("Adjust the formant settings")
				comment ("Measure the vowel /"+seg$+"/ in the word "+word$)
				comment ("Formant Settings")


				real ("Maximum formant", maximum_formant)
				real ("Number of formants", number_of_formants)
				real ("Window length", window_length)
				real ("Dynamic range", dynamic_range)
				word ("Notes", notes$)

				clicked = endPause ("Replay", "Apply", "Measure", "Skip", "Break", 2, 1)

				if clicked == 1
					Play window

				elsif clicked == 4
					coded = 1
					state$ = "breaking"
					endeditor
				elsif clicked == 5
					coded = 1
					goto breaking

				elsif clicked == 2
					Formant settings... maximum_formant number_of_formants window_length dynamic_range 1
				elsif clicked == 3
					select_start = Get start of selection
					select_end = Get end of selection

					coded = 1
					settings$ = Editor info

					max_formant = extractNumber (settings$, "Formant maximum formant:")
					n_poles = extractNumber (settings$, "Formant number of poles:")
					window_length = extractNumber (settings$, "Formant window length:")
					dynamic_range = extractNumber (settings$, "Formant dynamic range:")
					pre_emph = extractNumber (settings$, "Formant pre-emphasis from:")

					endeditor

					nformants = n_poles/2

					select LongSound 'file$'
					part = Extract part... select_start select_end 1
					formant_part = To Formant (burg)... 0 nformants max_formant window_length pre_emph
					formant_table = Down to Table... 0 1 6 0 3 1 3 1
					nrow = Get number of rows

					Append column... speaker
					Append column... token_id
					Append column... seg_start
					Append column... seg_end
					Append column... select_start
					Append column... select_end
					Append column... label
					Append column... word
					Append column... pre_seg
					Append column... post_seg
					Append column... context
					Append column... notes

					for row from 1 to nrow
						Set string value... row speaker 'file$'
						Set string value... row label 'seg$'
						Set string value... row word 'word$'
						Set string value... row pre_seg 'pre_Seg_Label$'
						Set string value... row post_seg 'post_Seg_Label$'
						Set string value... row context 'context$'
						Set string value... row notes 'notes$'
						Set numeric value... row token_id 'token_id'
						Set numeric value... row seg_start 'seg_Start'
						Set numeric value... row seg_end 'seg_End'
						Set numeric value... row select_start 'select_start'
						Set numeric value... row select_end 'select_end'
					endfor

					Save as tab-separated file... 'outdir$'\'file$'_'seg_Start'.txt
					token_id = token_id + 1

					selectObject: part, formant_part, formant_table
					Remove
					select TextGrid 'file$'

				endif
			endwhile
		endif
	endfor
endfor
endfor

label breaking
clearinfo
printline Thanks! Go get a coffee or a water. You deserve it. Come back soon!
printline You left off at 'file$': 'seg_End'.
