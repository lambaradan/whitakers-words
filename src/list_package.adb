with config; use config;
with strings_package; use strings_package;
with latin_file_names; use latin_file_names;
with word_parameters; use word_parameters;
with inflections_package; use inflections_package;
with dictionary_package; use dictionary_package;
with addons_package; use addons_package;
with uniques_package; use uniques_package;
with word_support_package; use word_support_package;
with developer_parameters; use developer_parameters;
with word_package; use word_package;
with dictionary_form;
with put_example_line;
with list_sweep;
with put_stat;
package body list_package is
   
   package boolean_io is new text_io.enumeration_io(boolean);
   
   subtype xons is part_of_speech_type range tackon..suffix;
   
   type dictionary_mnpc_record is record
	  d_k  : dictionary_kind := default_dictionary_kind;
	  mnpc : mnpc_type := null_mnpc;
	  de   : dictionary_entry := null_dictionary_entry;
   end record;
   null_dictionary_mnpc_record : dictionary_mnpc_record
	 := (x, null_mnpc, null_dictionary_entry);
   
   max_meaning_print_size : constant := 79;
   mm : integer := max_meaning_size;
   i, j, k : integer := 0;
   
   
   inflection_frequency : array (frequency_type) of string(1..8) :=
	 ("        ",  --  X
	  "mostfreq",  --  A
	  "sometime",  --  B
	  "uncommon",  --  C
	  "infreq  ",  --  D
	  "rare    ",  --  E
	  "veryrare",  --  F
	  "inscript",  --  I
	  "        ",  --  Not used
	  "        " );
   inflection_age : array (age_type) of string(1..8) :=
	 ("Always  ",   --  X
	  "Archaic ",   --  A
	  "Early   ",   --  B
	  "Classic ",   --  C
	  "Late    ",   --  D
	  "Later   ",   --  E
	  "Medieval",   --  F
	  "Scholar ",   --  G
	  "Modern  " ); --  H   
   
   dictionary_frequency : array (frequency_type) of string(1..8) :=
	 ("        ",  --  X
	  "veryfreq",  --  A
	  "frequent",  --  B
	  "common  ",  --  C
	  "lesser  ",  --  D
	  "uncommon",  --  E
	  "veryrare",  --  F
	  "inscript",  --  I
	  "graffiti",  --  J
	  "Pliny   " );--  N
   
   dictionary_age : array (age_type) of string(1..8) :=
	 ("        ",   --  X
	  "Archaic ",   --  A
	  "Early   ",   --  B
	  "Classic ",   --  C
	  "Late    ",   --  D
	  "Later   ",   --  E
	  "Medieval",   --  F
	  "NeoLatin",   --  G
	  "Modern  " ); --  H
   
   
   function cap_stem(s : string) return string  is
   begin
	  if all_caps  then
		 return upper_case(s);
	  elsif capitalized  then
		 return upper_case(s(s'first)) & s(s'first+1..s'last);
	  else
		 return s;
	  end if;
   end cap_stem;
   
   function cap_ending(s : string) return string  is
   begin
	  if all_caps  then
		 return upper_case(s);
	  else
		 return s;
	  end if;
   end cap_ending;
   
   
   procedure put_dictionary_flags(output : text_io.file_type;
								  de     : dictionary_entry;
								  hit    : out boolean) is
   begin

	  if words_mode(show_age)   or 
		(trim(dictionary_age(de.tran.age))'length /= 0)  then  --  Not X
		 text_io.put(output, "  " & trim(dictionary_age(de.tran.age)));
		 hit := true;
	  end if;
	  if (words_mode(show_frequency) or 
			(de.tran.freq >= d))  and 
		(trim(dictionary_frequency(de.tran.freq))'length /= 0)  then
		 text_io.put(output, "  " & trim(dictionary_frequency(de.tran.freq)));
		 hit := true;
	  end if;
   end put_dictionary_flags; 
   
   
   
   procedure put_dictionary_form(output : text_io.file_type;
								 d_k    : dictionary_kind;
								 mnpc   : dict_io.count; 
								 de     : dictionary_entry) is
	  chit, dhit, ehit, fhit, lhit : boolean := false;   --  Things on this line?
	  dictionary_line_number : integer := integer(mnpc);
	  --DE : DICTIONARY_ENTRY := DM.DE;
	  
	  
   begin                               --  PUT_DICTIONARY_FORM
	  if words_mode(do_dictionary_forms)  then
		 if words_mdev(do_pearse_codes) then
			text_io.put(output, "02 ");
			dhit := true;
		 end if;
		 if dictionary_form(de)'length /= 0  then
			text_io.put(output, dictionary_form(de) & "  ");
			
			--TEXT_IO.PUT(OUTPUT, PART_OF_SPEECH_TYPE'IMAGE(DE.PART.POFS)& "  ");
			--                     if DE.PART.POFS = N  then
			--                        TEXT_IO.PUT(OUTPUT, "  " & GENDER_TYPE'IMAGE(DE.PART.N.GENDER) & "  ");
			--                      end if;
			--                      if (DE.PART.POFS = V)  and then  (DE.PART.V.KIND in GEN..PERFDEF)  then
			--                        TEXT_IO.PUT(OUTPUT, "  " & VERB_KIND_TYPE'IMAGE(DE.PART.V.KIND) & "  ");
			--                      end if;
			
			dhit := true;
		 end if;
	  end if;
	  
	  
	  
	  if words_mdev(show_dictionary_codes) and then
		de.part.pofs not in xons              then
		 text_io.put(output, " [");
		 age_type_io.put(output, de.tran.age);
		 area_type_io.put(output, de.tran.area);
		 geo_type_io.put(output, de.tran.geo);
		 frequency_type_io.put(output, de.tran.freq);
		 source_type_io.put(output, de.tran.source);
		 text_io.put(output, "]  ");
		 chit := true;
	  end if;
	  
	  
	  if words_mdev(show_dictionary) then
		 text_io.put(output, ext(d_k) & ">");
		 ehit := true;
	  end if;
	  
	  if words_mdev(show_dictionary_line)  then
		 if dictionary_line_number > 0  then
			text_io.put(output, "(" 
						  & trim(integer'image(dictionary_line_number)) & ")");
			lhit := true;
		 end if;
	  end if;
	  
	  
	  put_dictionary_flags(output, de, fhit);       
	  
	  
	  if (chit or dhit or ehit or fhit or lhit)  then
		 text_io.new_line(output);
	  end if;
	  --end if;
	  
   end put_dictionary_form;
   
   
   
   
   
   

   procedure list_stems(output   : text_io.file_type;
						raw_word : string;
						input_line : string;
						pa       : in out parse_array; 
						pa_last  : in out integer) is
	  use text_io;
	  use dict_io;
      
	  
      --  The main WORD processing has been to produce an array of PARSE_RECORD
      --      type PARSE_RECORD is
      --        record
      --          STEM  : STEM_TYPE := NULL_STEM_TYPE;
      --          IR    : INFLECTION_RECORD := NULL_INFLECTION_RECORD;
      --          D_K   : DICTIONARY_KIND := DEFAULT_DICTIONARY_KIND;
      --          MNPC  : DICT_IO.COUNT := NULL_MNPC;
      --        end record;
      --  This has involved STEMFILE and INFLECTS, no DICTFILE
	  
      --  PARSE_RECORD is put through the LIST_SWEEP procedure that does TRIMing
      --  Then, for processing for output, the data is converted to arrays of   
      --      type STEM_INFLECTION_RECORD is
      --        record
      --          STEM : STEM_TYPE          := NULL_STEM_TYPE;
      --          IR   : INFLECTION_RECORD  := NULL_INFLECTION_RECORD;
      --        end record;
      --  and
      --      type DICTIONARY_MNPC_RECORD is 
      --        record
      --          D_K  : DICTIONARY_KIND;
      --          MNPC : MNPC_TYPE;
      --          DE   : DICTIONARY_ENTRY;
      --        end record;
      --  containing the same data plus the DICTFILE data DICTIONARY_ENTRY
      --  but breaking it into two arrays allows different manipulation
      --  These are only within this routine, used to clean up the output   
	  
	  
	  
      type stem_inflection_record is
		 record
			stem : stem_type          := null_stem_type;
			ir   : inflection_record  := null_inflection_record;
		 end record;
      null_stem_inflection_record : stem_inflection_record;
      
      stem_inflection_array_size       : constant := 10;
      stem_inflection_array_array_size : constant := 40;
      type stem_inflection_array is array (integer range <>) of stem_inflection_record;
      type stem_inflection_array_array is array (integer range <>)
		of stem_inflection_array(1..stem_inflection_array_size);
      
      sra, osra, null_sra : stem_inflection_array(1..stem_inflection_array_size)
		:= (others => (null_stem_type, null_inflection_record));
      sraa, null_sraa : stem_inflection_array_array(1..stem_inflection_array_array_size)
		:= (others => null_sra);
      
	  --      type DICTIONARY_MNPC_RECORD is record
	  --        D_K  : DICTIONARY_KIND := DEFAULT_DICTIONARY_KIND;
	  --        MNPC : MNPC_TYPE := NULL_MNPC;
	  --        DE   : DICTIONARY_ENTRY := NULL_DICTIONARY_ENTRY;
	  --      end record;
	  --      NULL_DICTIONARY_MNPC_RECORD : DICTIONARY_MNPC_RECORD
	  --                                  := (X, NULL_MNPC, NULL_DICTIONARY_ENTRY);
      dm, odm : dictionary_mnpc_record := null_dictionary_mnpc_record;
      
      dictionary_mnpc_array_size : constant := 40;
      
      type dictionary_mnpc_array is array (1..dictionary_mnpc_array_size)
		of dictionary_mnpc_record;
      dma, odma, null_dma : dictionary_mnpc_array;
      
      
      --MEANING_ARRAY_SIZE : constant := 5;
      --MEANING_ARRAY : array (1..MEANING_ARRAY_SIZE) of MEANING_TYPE;
      
      dea : dictionary_entry := null_dictionary_entry;
      
      
	  
	  
	  
	  
	  w : constant string := raw_word;
	  j, j1, j2, k : integer := 0;
	  there_is_an_adverb : boolean := false;
	  
	  
	  
      
      
	  
	  
	  procedure  put_inflection(sr : stem_inflection_record; 
								dm : dictionary_mnpc_record) is
         --  Handles putting ONLY_MEAN, PEARSE_CODES, CAPS, QUAL, V_KIND, FLAGS
		 procedure put_inflection_flags is
		 begin
			if (words_mode(show_age)   or 
				  (sr.ir.age /= x))  and     --  Warn even if not to show AGE
			  trim(inflection_age(sr.ir.age))'length /= 0  then
               text_io.put(output, "  " & inflection_age(sr.ir.age));
			end if; 
			if (words_mode(show_frequency)  or
				  (sr.ir.freq >= c))  and    --  Warn regardless
			  trim(inflection_frequency(sr.ir.freq))'length /= 0  then
               text_io.put(output, "  " & inflection_frequency(sr.ir.freq));
			end if;
		 end put_inflection_flags;
		 
	  begin
		 --TEXT_IO.PUT_LINE("PUT_INFLECTION ");
		 if (not words_mode(do_only_meanings) and
               not (configuration = only_meanings))       then
			text_io.set_col(output, 1);
			if words_mdev(do_pearse_codes) then
               if dm.d_k = addons  then
				  text_io.put(output, "05 ");
               elsif dm.d_k in xxx..yyy  then
				  text_io.put(output, "06 ");
               else
				  text_io.put(output, "01 ");
               end if;
			end if;
			
            
			--TEXT_IO.PUT(OUTPUT, CAP_STEM(TRIM(SR.STEM)));
			text_io.put(output, (trim(sr.stem)));
			if sr.ir.ending.size > 0  then
               text_io.put(output, ".");
			   --TEXT_IO.PUT(OUTPUT, TRIM(CAP_ENDING(SR.IR.ENDING.SUF)));
               text_io.put(output, trim((sr.ir.ending.suf)));
			end if;
			
			
			if words_mdev(do_pearse_codes) then
               text_io.set_col(output, 25);
			else
               text_io.set_col(output, 22);
			end if;
			
			
			if sr.ir /= null_inflection_record  then

			   --PRINT_MODIFIED_QUAL:   --  Really pedantic
			   --declare
			   --  OUT_STRING : STRING(1..QUALITY_RECORD_IO.DEFAULT_WIDTH);
			   --WHICH_START : constant INTEGER 
			   --            := PART_OF_SPEECH_TYPE_IO.DEFAULT_WIDTH + 1 + 1; --  8
			   --VARIANT_START : constant INTEGER  
			   --            := WHICH_START + WHICH_TYPE_IO_DEFAULT_WIDTH + 1;
			   --VARIANT_FINISH : constant INTEGER  
			   --            := VARIANT_START + VARIANT_TYPE_IO_DEFAULT_WIDTH;
			   --WHICH_BLANK : constant STRING(WHICH_START..VARIANT_START) := (others => ' ');
			   --VARIANT_BLANK : constant STRING(VARIANT_START..VARIANT_FINISH) := (others => ' ');
			   --begin
			   --  QUALITY_RECORD_IO.PUT(OUT_STRING, SR.IR.QUAL);
			   --  case SR.IR.QUAL.POFS is
			   --    when N | NUM | V | VPAR | SUPINE  =>         --  ADJ?
			   --      OUT_STRING(VARIANT_START..VARIANT_FINISH) := VARIANT_BLANK; 
			   --    when PRON | PACK   =>
			   --      OUT_STRING(WHICH_START..VARIANT_FINISH) := WHICH_BLANK & VARIANT_BLANK;
			   --    when ADJ  =>
			   --      if SR.IR.QUAL.ADJ.DECL.WHICH = 1  then
			   --        OUT_STRING(VARIANT_START..VARIANT_FINISH) := VARIANT_BLANK;  
			   --      end if;
			   --    when others  => 
			   --      null;
			   --  end case;
			   --  TEXT_IO.PUT(OUTPUT, OUT_STRING);
			   --end PRINT_MODIFIED_QUAL;
               
			   --QUALITY_RECORD_IO.PUT(OUTPUT, SR.IR.QUAL);
			   --NEW_LINE(OUTPUT);
			   --DICTIONARY_ENTRY_IO.PUT(OUTPUT, DM.DE);              
			   --NEW_LINE(OUTPUT);
			   
               
		   print_modified_qual:   
			   declare
				  out_string : string(1..quality_record_io.default_width);
				  passive_start  : integer :=
					part_of_speech_type_io.default_width + 1 +
					decn_record_io.default_width + 1 +
					tense_type_io.default_width + 1;
				  passive_finish : integer :=
                    passive_start + 
                    voice_type_io.default_width;             
				  ppl_start      : integer :=
					part_of_speech_type_io.default_width + 1 +
					decn_record_io.default_width + 1 +
					case_type_io.default_width + 1 +
					number_type_io.default_width + 1 +
					gender_type_io.default_width + 1 +
					tense_type_io.default_width + 1;
				  ppl_finish     : integer :=
                    ppl_start + 
                    voice_type_io.default_width;             
				  passive_blank : constant string(1..voice_type_io.default_width) :=
					(others => ' ');
			   begin
				  
				  --TEXT_IO.PUT_LINE("PASSIVE_START   = " & INTEGER'IMAGE(PASSIVE_START));
				  --TEXT_IO.PUT_LINE("PASSIVE_FINISH  = " & INTEGER'IMAGE(PASSIVE_FINISH));
				  --TEXT_IO.PUT_LINE("PPL_START   =  " & INTEGER'IMAGE(PPL_START));
				  --TEXT_IO.PUT_LINE("PPL_FINISH   =  " & INTEGER'IMAGE(PPL_FINISH));
				  --  
				  
				  --TEXT_IO.PUT_LINE("START PRINT MODIFIED QUAL " );
				  --  QUALITY_RECORD_IO.PUT(OUT_STRING, SR.IR.QUAL);
				  --  if (DM.D_K in GENERAL..LOCAL)  and then  --  UNIQUES has no DE
				  --     (SR.IR.QUAL.POFS = V)    and then
				  --    ((SR.IR.QUAL.V.TENSE_VOICE_MOOD.MOOD in IND..INF)   and
				  --     (DM.DE.PART.V.KIND = DEP))       then
				  ----TEXT_IO.PUT_LINE("PRINT MODIFIED QUAL 1a" );
				  --    OUT_STRING(PASSIVE_START+1..PASSIVE_FINISH) := PASSIVE_BLANK; 
				  ----TEXT_IO.PUT_LINE("PRINT MODIFIED QUAL 2a" );
				  --  elsif (DM.D_K in GENERAL..LOCAL)  and then  --  UNIQUES has no DE
				  --     (SR.IR.QUAL.POFS = VPAR)  and then
				  --    ((SR.IR.QUAL.V.TENSE_VOICE_MOOD.MOOD = PPL)   and
				  --     (DM.DE.PART.V.KIND = DEP))       then
				  --TEXT_IO.PUT_LINE("PRINT MODIFIED QUAL 1b" );
				  --    OUT_STRING(PPL_START+1..PPL_FINISH) := PASSIVE_BLANK; 
				  --TEXT_IO.PUT_LINE("PRINT MODIFIED QUAL 2b" );
				  --    
				  --  end if;
				  ----TEXT_IO.PUT_LINE("PRINT MODIFIED QUAL 3" );
				  
				  
				  
				  --TEXT_IO.PUT_LINE("START PRINT MODIFIED QUAL " );
				  quality_record_io.put(out_string, sr.ir.qual);
				  if (dm.d_k in general..local)  then  --  UNIQUES has no DE
					 
					 
					 if (sr.ir.qual.pofs = v)    and then
					   (dm.de.part.v.kind = dep)       and then
					   (sr.ir.qual.v.tense_voice_mood.mood in ind..inf)   then
						--TEXT_IO.PUT_LINE("START PRINT MODIFIED QUAL   V" );
						out_string(passive_start+1..passive_finish) := passive_blank; 
					 elsif (sr.ir.qual.pofs = vpar)    and then
					   (dm.de.part.v.kind = dep)    and then
					   (sr.ir.qual.vpar.tense_voice_mood.mood = ppl)  then
						--TEXT_IO.PUT_LINE("START PRINT MODIFIED QUAL   VPAR" );
						out_string(ppl_start+1..ppl_finish) := passive_blank; 
					 end if;
				  end if;
				  
				  text_io.put(output, out_string);
				  --TEXT_IO.PUT_LINE("PRINT MODIFIED QUAL 4" );
			   end print_modified_qual;

			   


			   --               if ((SR.IR.QUAL.POFS = NUM)  and      --  Don't want on inflection
			   --                   (DM.D_K in GENERAL..UNIQUE))  and then  
			   --                   (DM.DE.KIND.NUM_VALUE > 0)  then
			   --                 TEXT_IO.PUT(OUTPUT, "  ");
			   --                 INFLECTIONS_PACKAGE.INTEGER_IO.PUT(OUTPUT, DM.DE.KIND.NUM_VALUE);
			   --               end if;
               put_inflection_flags;
               text_io.new_line(output);
               put_example_line(output, sr.ir, dm.de);    --  Only full when DO_EXAMPLES
            else
			   text_io.new_line(output);
			end if;
		 end if;   
		 
	  end put_inflection;
	  
	  
	  --         procedure PUT_DICTIONARY_FORM(OUTPUT : TEXT_IO.FILE_TYPE;
	  --                                       DM     : DICTIONARY_MNPC_RECORD) is
	  --             HIT : BOOLEAN := FALSE;   --  Is anything on this line
	  --             DICTIONARY_LINE_NUMBER : INTEGER := INTEGER(DM.MNPC);
	  --             DE : DICTIONARY_ENTRY := DM.DE;
	  --             
	  --       
	  --         begin                               --  PUT_DICTIONARY_FORM
	  --               if WORDS_MODE(DO_DICTIONARY_FORMS)  then
	  --                 if WORDS_MDEV(DO_PEARSE_CODES) then
	  --                   TEXT_IO.PUT(OUTPUT, "02 ");
	  --                   HIT := TRUE;
	  --                end if;
	  --                if DICTIONARY_FORM(DE)'LENGTH /= 0  then
	  --                  TEXT_IO.PUT(OUTPUT, DICTIONARY_FORM(DE) & "  ");
	  --                  HIT := TRUE;
	  --                end if;
	  --               end if;
	  --     
	  --               
	  --                    
	  --               if WORDS_MDEV(SHOW_DICTIONARY_CODES) and then
	  --                  DE.PART.POFS not in XONS              then
	  --                  TEXT_IO.PUT(OUTPUT, " [");
	  --                 AGE_TYPE_IO.PUT(OUTPUT, DE.TRAN.AGE);
	  --                 AREA_TYPE_IO.PUT(OUTPUT, DE.TRAN.AREA);
	  --                 GEO_TYPE_IO.PUT(OUTPUT, DE.TRAN.GEO);
	  --                 FREQUENCY_TYPE_IO.PUT(OUTPUT, DE.TRAN.FREQ);
	  --                 SOURCE_TYPE_IO.PUT(OUTPUT, DE.TRAN.SOURCE);
	  --                 TEXT_IO.PUT(OUTPUT, "]  ");
	  --                 HIT := TRUE;
	  --               end if;
	  --               
	  --                        
	  --               if WORDS_MDEV(SHOW_DICTIONARY) then
	  --                 TEXT_IO.PUT(OUTPUT, EXT(DM.D_K) & ">");
	  --                 HIT := TRUE;
	  --              end if;
	  --               
	  --               
	  --               if WORDS_MDEV(SHOW_DICTIONARY_LINE)  then
	  --                 if DICTIONARY_LINE_NUMBER > 0  then
	  --                   TEXT_IO.PUT(OUTPUT, "(" 
	  --                         & TRIM(INTEGER'IMAGE(DICTIONARY_LINE_NUMBER)) & ")");
	  --                   HIT := TRUE;
	  --                  end if;
	  --               end if;
	  --            
	  --         
	  --            
	  --               PUT_DICTIONARY_FLAGS(DM, HIT);       
	  --            
	  --            
	  --               if HIT   then
	  --                  TEXT_IO.NEW_LINE(OUTPUT);
	  --               end if;
	  --            
	  --            --end if;
	  --         
	  --         end PUT_DICTIONARY_FORM;
	  --      
	  --     
	  
	  procedure put_form(sr : stem_inflection_record; 
						 dm : dictionary_mnpc_record) is
         --  Handles PEARSE_CODES and DICTIONARY_FORM (which has FLAGS) and D_K
         --  The Pearse 02 is handled in PUT_DICTIONARY_FORM
	  begin
		 if (sr.ir.qual.pofs not in xons)  and
		   (dm.d_k in general..unique)           then
			--DICTIONARY_ENTRY_IO.PUT(DM.DE);
			put_dictionary_form(output, dm.d_k, dm.mnpc, dm.de);
		 end if;
	  end put_form;
	  

	  
	  function trim_bar(s : string) return string is
         --  Takes vertical bars from begining of MEAN and TRIMs
	  begin
		 if s'length >3  and then s(s'first..s'first+3) = "||||"  then
			return trim(s(s'first+4.. s'last));
		 elsif s'length >2  and then s(s'first..s'first+2) = "|||"  then
			return trim(s(s'first+3.. s'last));
		 elsif s'length > 1  and then  s(s'first..s'first+1) = "||"  then
			return trim(s(s'first+2.. s'last));
		 elsif s(s'first) = '|'  then
			return trim(s(s'first+1.. s'last));
		 else
			return trim(s);
		 end if;
	  end trim_bar;
	  
	  
	  

      procedure put_meaning(output : text_io.file_type;
                            raw_meaning : string) is
		 --  Handles the MM screen line limit and TRIM_BAR, then TRIMs
		 
      begin
		 
		 text_io.put(output, trim(head(trim_bar(raw_meaning), mm)));
      end put_meaning;
	  
	  
      function constructed_meaning(sr : stem_inflection_record;
                                   dm  : dictionary_mnpc_record) return string is
		 --  Constructs the meaning for NUM from NUM.SORT and NUM_VALUE
		 s : string(1..max_meaning_size) := null_meaning_type;
		 n : integer := 0;
      begin
		 if dm.de.part.pofs = num  then
			n := dm.de.part.num.value;
			if sr.ir.qual.pofs = num  then    --  Normal parse 
			   case sr.ir.qual.num.sort is
				  when card  =>
					 s := head(integer'image(n) &  " - (CARD answers 'how many');", max_meaning_size);
				  when ord   =>
					 s := head(integer'image(n) & "th - (ORD, 'in series'); (a/the)" & integer'image(n) &
								 "th (part) (fract w/pars?);", max_meaning_size);
				  when dist  =>
					 s := head(integer'image(n) & " each/apiece/times/fold/together/at a time - 'how many each'; by " &
								 integer'image(n) & "s; ", max_meaning_size);
				  when adverb =>
					 s := head(integer'image(n) & " times, on" & integer'image(n) &
								 " occasions - (ADVERB answers 'how often');", max_meaning_size);
				  when others =>
					 null;
			   end case;  
			else  -- there is fix so POFS is not NUM
			   s := head("Number " & integer'image(n), max_meaning_size);
			end if;
		 end if;
		 
		 return s;
		 
      end constructed_meaning;
	  

	  
	  
	  procedure put_meaning_line(sr : stem_inflection_record;
								 dm  : dictionary_mnpc_record) is
	  begin
		 if dm.d_k not in addons..ppp  then
			
			if words_mdev(do_pearse_codes) then
			   text_io.put(output, "03 ");
			end if;
			if dm.de.part.pofs = num  and then dm.de.part.num.value > 0  then   
			   text_io.put_line(output, constructed_meaning(sr, dm));    --  Constructed MEANING
			elsif dm.d_k = unique  then
			   put_meaning(output, uniques_de(dm.mnpc).mean); 
			   text_io.new_line(output);
			else
			   put_meaning(output, trim_bar(dm.de.mean)); 
			   text_io.new_line(output);
			end if;
		 else
			if dm.d_k = rrr  then 
			   if rrr_meaning /= null_meaning_type   then
				  --PUT_DICTIONARY_FLAGS;
				  if words_mdev(do_pearse_codes) then
					 text_io.put(output, "03 ");
				  end if;
				  put_meaning(output, rrr_meaning);      --  Roman Numeral
				  rrr_meaning := null_meaning_type;
				  text_io.new_line(output);
			   end if;
			   
			elsif dm.d_k = nnn then 
			   if nnn_meaning /= null_meaning_type  then
				  --PUT_DICTIONARY_FLAGS;
				  if words_mdev(do_pearse_codes) then
					 text_io.put(output, "03 ");
				  end if;
				  put_meaning(output, nnn_meaning);  --  Unknown Name
				  nnn_meaning := null_meaning_type;
				  text_io.new_line(output);
			   end if;
			   
			elsif dm.d_k = xxx  then 
			   if xxx_meaning /= null_meaning_type  then
				  if words_mdev(do_pearse_codes) then
					 text_io.put(output, "06 ");
				  end if;
				  put_meaning(output, xxx_meaning);  --  TRICKS
				  xxx_meaning := null_meaning_type;
				  text_io.new_line(output);
			   end if;
			   
			elsif dm.d_k = yyy  then 
			   if yyy_meaning /= null_meaning_type  then
				  if words_mdev(do_pearse_codes) then
					 text_io.put(output, "06 ");
				  end if;
				  put_meaning(output, yyy_meaning);  --  Syncope
				  yyy_meaning := null_meaning_type;
				  text_io.new_line(output);
			   end if;
			   
			elsif dm.d_k = ppp  then 
			   if ppp_meaning /= null_meaning_type  then
				  if words_mdev(do_pearse_codes) then
					 text_io.put(output, "06 ");
				  end if;
				  put_meaning(output, ppp_meaning); --  Compounds
				  ppp_meaning := null_meaning_type;
				  text_io.new_line(output);
			   end if;
			   
			   
			elsif dm.d_k = addons  then 
			   if words_mdev(do_pearse_codes) then
				  text_io.put(output, "06 ");
			   end if;
			   put_meaning(output, means(integer(dm.mnpc))); 
			   text_io.new_line(output);
			   
			end if;
			
		 end if;
	  end put_meaning_line;


	  
      
   begin
      trimmed := false;
	  
      --  Since this procedure weeds out possible parses, if it weeds out all
      --  (or all of a class) it must fix up the rest of the parse array,
      --  e.g., it must clean out dangling prefixes and suffixes

	  --    --  Just to find the words with long/complicated output at the processing level 
	  --    --  This is done with the final PA_LAST, entering LIST_STEM, before SWEEP
	  --       if PA_LAST > PA_LAST_MAX   then
	  --         PUT_STAT("$PA_LAST_MAX    for RAW_WORD " & HEAD(RAW_WORD, 24) & "   = " & INTEGER'IMAGE(PA_LAST));
	  --         PA_LAST_MAX := PA_LAST;
	  --       end if;
	  
	  --TEXT_IO.PUT_LINE("PA on entering LIST_STEMS    PA_LAST = " & INTEGER'IMAGE(PA_LAST));
	  --for I in 1..PA_LAST  loop
	  --PARSE_RECORD_IO.PUT(PA(I)); TEXT_IO.NEW_LINE;
	  --end loop;
      

	  if (text_io.name(output) = 
			text_io.name(text_io.standard_output))  then
		 mm := max_meaning_print_size;   --  to keep from overflowing screen line
										 --  or even adding blank line
	  else
		 mm := max_meaning_size;
		 
	  end if;
      
      -------  The gimick of adding an ADV if there is only ADJ VOC  ----
	  --TEXT_IO.PUT_LINE("About to do the ADJ -> ADV kludge");
	  for i in pa'first..pa_last  loop
		 if pa(i).ir.qual.pofs = adv   then
			there_is_an_adverb := true;
			exit;
		 end if;
	  end loop;
      
	  --TEXT_IO.PUT_LINE("In the ADJ -> ADV kludge  Checked to see if there is an ADV");
	  
	  if ((not there_is_an_adverb) and (words_mode(do_fixes)))  then
		 --TEXT_IO.PUT_LINE("In the ADJ -> ADV kludge  There is no ADV");
		 for i in reverse pa'first..pa_last  loop
            
			if pa(i).ir.qual.pofs = adj and then
			  (pa(i).ir.qual.adj = ((1, 1), voc, s, m, pos)    or
				 ((pa(i).ir.qual.adj.cs = voc)   and
					(pa(i).ir.qual.adj.number = s)   and
					(pa(i).ir.qual.adj.gender = m)   and
					(pa(i).ir.qual.adj.co = super)))    then
               
			   j := i;
               
			   while j >=  pa'first  loop  --Back through other ADJ cases
				  if pa(j).ir.qual.pofs /= adj  then
					 j2 := j;                          --  J2 is first (reverse) that is not ADJ
					 exit;
				  end if;
				  j := j - 1;
			   end loop;
			   while j >=  pa'first  loop  --  Sweep up associated fixes
				  if pa(j).ir.qual.pofs not in xons  then
					 j1 := j;                      --  J1 is first (reverse) that is not XONS
					 exit;
				  end if;
				  j := j - 1;
			   end loop;
               
               
               
			   for j in j1+1..j2  loop
				  pa(pa_last+j-j1+1) := pa(j);
			   end loop;
			   --TEXT_IO.PUT_LINE("In the ADJ -> ADV kludge  Ready to add PA for ADV");
			   pa_last := pa_last + j2 - j1 + 1;
			   pa(pa_last) := pa(j2+1);
			   --TEXT_IO.PUT_LINE("In the ADJ -> ADV kludge  Adding SUFFIX E ADV");
			   pa(pa_last) := ("e                 ",
							   ((suffix, null_suffix_record), 0, null_ending_record, x, b),
							   ppp, null_mnpc);
			   --PARSE_RECORD_IO.PUT(PA(PA_LAST)); TEXT_IO.NEW_LINE;
			   pa_last := pa_last + 1;
			   if pa(j2+1).ir.qual.adj.co = pos   then
				  --TEXT_IO.PUT_LINE("In the ADJ -> ADV kludge  Adding POS for ADV");
				  pa(pa_last) := (pa(j2+1).stem,
								  ((pofs => adv, adv => (co => pa(j2+1).ir.qual.adj.co)),
								   key => 0, ending => (1, "e      "), age => x, freq => b),
								  pa(j2+1).d_k,
								  pa(j2+1).mnpc);
				  --PARSE_RECORD_IO.PUT(PA(PA_LAST)); TEXT_IO.NEW_LINE;
				  ppp_meaning :=
					head("-ly; -ily;  Converting ADJ to ADV",
						 max_meaning_size);
                  
			   elsif pa(j2+1).ir.qual.adj.co = super  then
				  pa(pa_last) := (pa(j2+1).stem,
								  ((pofs => adv, adv => (co => pa(j2+1).ir.qual.adj.co)),
								   key => 0, ending => (2, "me     "), age => x, freq => b),
								  pa(j2+1).d_k,
								  pa(j2+1).mnpc);
				  ppp_meaning :=
					head("-estly; -estily; most -ly, very -ly  Converting ADJ to ADV",
						 max_meaning_size);
			   end if;
			   --TEXT_IO.PUT_LINE("In the ADJ -> ADV kludge  Done adding PA for ADV");
			end if;           --  PA(I).IR.QUAL.POFS = ADJ
            
		 end loop;
         
	  end if;           --  not THERE_IS_AN_ADVERB
						-- TEXT_IO.PUT_LINE("In the ADJ -> ADV kludge  FINISHED");
	  
	  list_sweep(pa(1..pa_last), pa_last);   
	  
	  
	  --TEXT_IO.PUT_LINE("PA after leaving LIST_SWEEP    PA_LAST = "  & INTEGER'IMAGE(PA_LAST));
	  --for I in 1..PA_LAST  loop
	  --PARSE_RECORD_IO.PUT(PA(I)); TEXT_IO.NEW_LINE;
	  --end loop;
	  -- 
	  
	  

	  
	  
	  
	  
	  --               --  Does STATS
	  --      
	  --TEXT_IO.PUT_LINE("Before STATING FIXES");
	  if  words_mdev(write_statistics_file)    then      --  Omit rest of output
		 
		 for i in 1..pa_last  loop                       --  Just to PUT_STAT
			if (pa(i).d_k = addons)  then
			   if pa(i).ir.qual.pofs = prefix  then
				  put_stat("ADDON PREFIX at "
							 & head(integer'image(line_number), 8) & head(integer'image(word_number), 4)
							 & "   " & head(w, 20) & "   "  & pa(i).stem & "  " & integer'image(integer(pa(i).mnpc)));
			   elsif pa(i).ir.qual.pofs = suffix  then
				  put_stat("ADDON SUFFIX at "
							 & head(integer'image(line_number), 8) & head(integer'image(word_number), 4)
							 & "   " & head(w, 20) & "   "  & pa(i).stem & "  " & integer'image(integer(pa(i).mnpc)));
			   elsif pa(i).ir.qual.pofs = tackon  then
				  put_stat("ADDON TACKON at "
							 & head(integer'image(line_number), 8) & head(integer'image(word_number), 4)
							 & "   " & head(w, 20) & "   "  & pa(i).stem & "  " & integer'image(integer(pa(i).mnpc)));
			   end if;
			end if;
		 end loop;
         
		 
		 ----    --  Just to find the words with long/complicated output at the LIST level 
		 ----    --  This is done with the final PA_LAST, after SWEEP
		 ----       if PA_LAST > FINAL_PA_LAST_MAX   then
		 ----         PUT_STAT("$FINAL_PA_LAST_MAX    for RAW_WORD " & HEAD(RAW_WORD, 24) & "   = " & INTEGER'IMAGE(PA_LAST));
		 ----         FINAL_PA_LAST_MAX := PA_LAST;
		 ----       end if;
		 
	  end if;
	  
	  --TEXT_IO.PUT_LINE("After STATING FIXES");
	  
	  
	  
	  
	  
	  
	  
	  --  Convert from PARSE_RECORDs to DICTIONARY_MNPC_RECORD and STEM_INFLECTION_RECORD         
	  --TEXT_IO.PUT_LINE("Doing arrays in LIST_STEMS    PA_LAST = "  & 
	  --                 INTEGER'IMAGE(PA_LAST));
	  i := 1;           --  I cycles on PA
	  j := 0;           --  J indexes the number of DMA arrays  --  Initialize
	  sraa := null_sraa;
	  dma := null_dma;
  cycle_over_pa:
	  while i <= pa_last  loop       --  I cycles over full PA array
									 --TEXT_IO.PUT_LINE("Starting loop for I    I = " & INTEGER'IMAGE(I));
		 odm := null_dictionary_mnpc_record;

		 if pa(i).d_k = unique  then
			j := j + 1;
			sraa(j)(1) := (pa(i).stem, pa(i).ir);
			--TEXT_IO.PUT_LINE("UNIQUE   I = " & INTEGER'IMAGE(I) & "  J = " & INTEGER'IMAGE(J)); 
			dm := null_dictionary_mnpc_record;
			dm.d_k := unique;
			dm.mnpc := pa(i).mnpc;  
			dm.de := uniques_de(pa(i).mnpc);  
			dma(j) := dm;
			i := i + 1;
		 else
			
			case pa(i).ir.qual.pofs  is
			   
			   when n  =>  
				  osra := null_sra;
				  odma := null_dma;
				  --ODM := NULL_DICTIONARY_MNPC_RECORD;
				  --DM := NULL_DICTIONARY_MNPC_RECORD;
				  while pa(i).ir.qual.pofs = n   and
					i <= pa_last                   loop
					 --TEXT_IO.PUT_LINE("Starting loop for N    I = " & INTEGER'IMAGE(I) & "   K = " & INTEGER'IMAGE(K));
					 if pa(i).mnpc  /= odm.mnpc  then   --  Encountering new MNPC
						osra := sra;
						k := 1;                  --  K indexes within the MNPCA array --  Initialize
												 --TEXT_IO.PUT_LINE("Starting IRA for N    I = " & INTEGER'IMAGE(I) & "   K = " & INTEGER'IMAGE(K));
						j := j + 1;             --  J indexes the number of MNPCA arrays - Next MNPCA
												--TEXT_IO.PUT_LINE("Shifting J for N  I = " & INTEGER'IMAGE(I) & "   J = " & INTEGER'IMAGE(J));
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
						dict_io.set_index(dict_file(pa(i).d_k), pa(i).mnpc); 
						dict_io.read(dict_file(pa(i).d_k), dea);
						dm := (pa(i).d_k, pa(i).mnpc, dea);
						dma(j) := dm;
						odm := dm;
					 else
						k := k + 1;              --  K indexes within the MNPCA array  - Next MNPC
												 --TEXT_IO.PUT_LINE("Continuing IRA for N  I = " & INTEGER'IMAGE(I) & "   K = " & INTEGER'IMAGE(K)
												 --                                                                 & "   J = " & INTEGER'IMAGE(J));
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
					 end if;

					 i := i + 1;              --  I cycles over full PA array
				  end loop;
				  
			   when pron  =>  
				  osra := null_sra;
				  odma := null_dma;
				  --ODM := NULL_DICTIONARY_MNPC_RECORD;
				  --DM := NULL_DICTIONARY_MNPC_RECORD;
				  while pa(i).ir.qual.pofs = pron   and
					i <= pa_last                   loop
					 if pa(i).mnpc  /= odm.mnpc  then   --  Encountering new MNPC
						osra := sra;
						k := 1;                  --  K indexes within the MNPCA array --  Initialize
						j := j + 1;             --  J indexes the number of MNPCA arrays - Next MNPCA
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
						dict_io.set_index(dict_file(pa(i).d_k), pa(i).mnpc); 
						dict_io.read(dict_file(pa(i).d_k), dea);
						dm := (pa(i).d_k, pa(i).mnpc, dea);
						dma(j) := dm;
						odm := dm;
					 else
						k := k + 1;              --  K indexes within the MNPCA array  - Next MNPC
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
					 end if;

					 i := i + 1;              --  I cycles over full PA array
				  end loop;
				  
			   when pack  =>  
				  osra := null_sra;
				  odma := null_dma;
				  --ODM := NULL_DICTIONARY_MNPC_RECORD;
				  --DM := NULL_DICTIONARY_MNPC_RECORD;
				  while pa(i).ir.qual.pofs = pack   and
					i <= pa_last                   loop
					 if pa(i).mnpc  /= odm.mnpc  then   --  Encountering new MNPC
						osra := sra;
						k := 1;                  --  K indexes within the MNPCA array --  Initialize
						j := j + 1;             --  J indexes the number of MNPCA arrays - Next MNPCA
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
						dict_io.set_index(dict_file(pa(i).d_k), pa(i).mnpc); 
						dict_io.read(dict_file(pa(i).d_k), dea);
						dm := (pa(i).d_k, pa(i).mnpc, dea);
						dma(j) := dm;
						odm := dm;
					 else
						k := k + 1;              --  K indexes within the MNPCA array  - Next MNPC
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
					 end if;

					 i := i + 1;              --  I cycles over full PA array
				  end loop;
				  
			   when adj  =>  
				  osra := null_sra;
				  odma := null_dma;
				  --ODM := NULL_DICTIONARY_MNPC_RECORD;
				  --DM := NULL_DICTIONARY_MNPC_RECORD;
				  while pa(i).ir.qual.pofs = adj   and
					i <= pa_last                   loop
					 --TEXT_IO.PUT_LINE("SRAA - ADJ");
					 if pa(i).mnpc  /= odm.mnpc  then   --  Encountering new MNPC
						osra := sra;
						k := 1;                  --  K indexes within the MNPCA array --  Initialize
						j := j + 1;             --  J indexes the number of MNPCA arrays - Next MNPCA
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
						dict_io.set_index(dict_file(pa(i).d_k), pa(i).mnpc); 
						dict_io.read(dict_file(pa(i).d_k), dea);
						dm := (pa(i).d_k, pa(i).mnpc, dea);
						dma(j) := dm;
						odm := dm;
					 else
						k := k + 1;              --  K indexes within the MNPCA array  - Next MNPC
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
					 end if;
					 --TEXT_IO.PUT_LINE("SRAA  + ADJ");
					 i := i + 1;              --  I cycles over full PA array
				  end loop;
				  
			   when num  =>  
				  osra := null_sra;
				  odma := null_dma;
				  --ODM := NULL_DICTIONARY_MNPC_RECORD;
				  --DM := NULL_DICTIONARY_MNPC_RECORD;
				  while pa(i).ir.qual.pofs = num   and
					i <= pa_last                   loop
					 if (pa(i).d_k = rrr)  then        --  Roman numeral
						osra := sra;
						k := 1;                  --  K indexes within the MNPCA array --  Initialize
						j := j + 1;             --  J indexes the number of MNPCA arrays - Next MNPCA
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
						--DICT_IO.SET_INDEX(DICT_FILE(PA(I).D_K), PA(I).MNPC); 
						--DICT_IO.READ(DICT_FILE(PA(I).D_K), DEA);
						

						
						
						dea := null_dictionary_entry;
						dm := (pa(i).d_k, pa(i).mnpc, dea);
						dma(j) := dm;
						odm := dm;
					 elsif (pa(i).mnpc  /= odm.mnpc) then    --  Encountering new MNPC    
						osra := sra;
						k := 1;                  --  K indexes within the MNPCA array --  Initialize
						j := j + 1;             --  J indexes the number of MNPCA arrays - Next MNPCA
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
						dict_io.set_index(dict_file(pa(i).d_k), pa(i).mnpc); 
						dict_io.read(dict_file(pa(i).d_k), dea);
						dm := (pa(i).d_k, pa(i).mnpc, dea);
						dma(j) := dm;
						odm := dm;
					 else
						k := k + 1;              --  K indexes within the MNPCA array  - Next MNPC
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
					 end if;

					 i := i + 1;              --  I cycles over full PA array
				  end loop;
				  
				  
			   when v | vpar | supine  =>  
				  osra := null_sra;
				  odma := null_dma;
				  --ODM := NULL_DICTIONARY_MNPC_RECORD;
				  --DM := NULL_DICTIONARY_MNPC_RECORD;
				  while (pa(i).ir.qual.pofs = v      or
						   pa(i).ir.qual.pofs = vpar   or
						   pa(i).ir.qual.pofs = supine)   and
					i <= pa_last                   loop
					 --TEXT_IO.PUT_LINE("Starting loop for VPAR I = " & INTEGER'IMAGE(I) & "   K = " & INTEGER'IMAGE(K));
					 if (pa(i).mnpc  /= odm.mnpc) and (pa(i).d_k /= ppp)   then   --  Encountering new MNPC
						osra := sra;                                               --  But not for compound
						k := 1;                  --  K indexes within the MNPCA array --  Initialize
												 --TEXT_IO.PUT_LINE("Starting IRA for VPAR I = " & INTEGER'IMAGE(I) & "   K = " & INTEGER'IMAGE(K));
						j := j + 1;             --  J indexes the number of MNPCA arrays - Next MNPCA
												--TEXT_IO.PUT_LINE("Shifting J for VPAR I = " & INTEGER'IMAGE(I) & "   J = " & INTEGER'IMAGE(J));
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
						if pa(i).d_k /= ppp  then
						   dict_io.set_index(dict_file(pa(i).d_k), pa(i).mnpc); 
						   dict_io.read(dict_file(pa(i).d_k), dea);
						end if;     --  use previous DEA
						dm := (pa(i).d_k, pa(i).mnpc, dea);
						dma(j) := dm;
						odm := dm;
					 else
						k := k + 1;              --  K indexes within the MNPCA array  - Next MNPC
												 --TEXT_IO.PUT_LINE("Continuing IRA for VPAR  I = " & INTEGER'IMAGE(I) & "   K = " & INTEGER'IMAGE(K)
												 --                                                                      & "   J = " & INTEGER'IMAGE(J));
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
					 end if;

					 i := i + 1;              --  I cycles over full PA array
				  end loop;
				  
				  
			   when others  =>  
				  --TEXT_IO.PUT_LINE("Others");
				  osra := null_sra;
				  odma := null_dma;
				  --ODM := NULL_DICTIONARY_MNPC_RECORD;
				  --DM := NULL_DICTIONARY_MNPC_RECORD;
				  while i <= pa_last                   loop
					 --TEXT_IO.PUT_LINE("Starting loop for OTHER I = " & INTEGER'IMAGE(I) & "   K = " & INTEGER'IMAGE(K));
					 if (odm.d_k  /= pa(i).d_k)  or
					   (odm.mnpc /= pa(i).mnpc)      then   --  Encountering new single (K only 1)
						osra := sra;
						k := 1;                  --  K indexes within the MNPCA array --  Initialize
												 --TEXT_IO.PUT_LINE("Starting IRA for OTHER I = " & INTEGER'IMAGE(I) & "   K = " & INTEGER'IMAGE(K));
						j := j + 1;             --  J indexes the number of MNPCA arrays - Next MNPCA
												--TEXT_IO.PUT_LINE("Shifting J for OTHER I = " & INTEGER'IMAGE(I) & "   J = " & INTEGER'IMAGE(J));
						sraa(j)(k) := (pa(i).stem, pa(i).ir);
						if pa(i).mnpc /= null_mnpc  then
						   if pa(i).d_k = addons  then
							  dea :=  null_dictionary_entry;   --  Fix for ADDONS in MEANS, not DICT_IO
						   else
							  dict_io.set_index(dict_file(pa(i).d_k), pa(i).mnpc); 
							  dict_io.read(dict_file(pa(i).d_k), dea);
						   end if;
						else                       --  Has no dictionary to read
						   dea:= null_dictionary_entry;
						end if;
						dm := (pa(i).d_k, pa(i).mnpc, dea);
						dma(j) := dm;
						odm := dm;
						--else
						--  K := K + 1;              --  K indexes within the MNPCA array  - Next MNPC
						--  SRAA(J)(K) := (PA(I).STEM, PA(I).IR);
					 end if;

					 i := i + 1;              --  I cycles over full PA array
					 exit;                    --  Since Other is only one, don't loop
				  end loop;    
				  
			end case;

		 end if;      
		 --  --  This just for developer test, will be commented out   
		 --  if K > SRA_MAX  then 
		 --    SRA_MAX := K;
		 --PUT_STAT("*SRA_MAX for RAW_WORD " & HEAD(RAW_WORD, 26) & "   = " & INTEGER'IMAGE(SRA_MAX));
		 --  end if;
		 --  if J > DMA_MAX  then 
		 --    DMA_MAX := J;
		 --PUT_STAT("*DMA_MAX for RAW_WORD " & HEAD(RAW_WORD, 26) & "   = " & INTEGER'IMAGE(DMA_MAX));
		 --  end if;
		 
	  end loop cycle_over_pa;

	  --TEXT_IO.PUT_LINE("Made QA");





	  

	  --TEXT_IO.PUT_LINE("QA ARRAYS   FFFFFF  ======================================");
	  --     for J in 1..DICTIONARY_MNPC_ARRAY_SIZE  loop
	  --       if DMA(J) /= NULL_DICTIONARY_MNPC_RECORD  then
	  --         TEXT_IO.PUT(INTEGER'IMAGE(J) & "  ");
	  --         DICTIONARY_KIND_IO.PUT(DMA(J).D_K); TEXT_IO.PUT("  "); 
	  --         MNPC_IO.PUT(DMA(J).MNPC); TEXT_IO.NEW_LINE;
	  --       end if;
	  --     end loop;  
	  --     for J in 1..STEM_INFLECTION_ARRAY_ARRAY_SIZE  loop
	  --       for K in 1..STEM_INFLECTION_ARRAY_SIZE  loop
	  --         if SRAA(J)(K) /= NULL_STEM_INFLECTION_RECORD  then
	  --           TEXT_IO.PUT(INTEGER'IMAGE(J) & " " & INTEGER'IMAGE(K) & "  ");
	  --           QUALITY_RECORD_IO.PUT(SRAA(J)(K).IR.QUAL); TEXT_IO.NEW_LINE;
	  --         end if;
	  --       end loop;
	  --     end loop;  








	  
	  --  Sets + if capitalized      
      --  Strangely enough, it may enter LIST_STEMS with PA_LAST /= 0
      --  but be weeded and end up with no parse after LIST_SWEEP  -  PA_LAST = 0      
      if pa_last = 0  then  --  WORD failed
							--????      (DMA(1).D_K in ADDONS..YYY  and then TRIM(DMA(1).DE.STEMS(1)) /= "que")  then  --  or used FIXES/TRICKS
		 if words_mode(ignore_unknown_names)  and capitalized  then
			nnn_meaning := head(
								"Assume this is capitalized proper name/abbr, under MODE IGNORE_UNKNOWN_NAME ",
								max_meaning_size);
			pa(1) := (head(raw_word, max_stem_size),
					  ((n, ((0, 0), x, x, x)), 0, null_ending_record, x, x),
					  nnn, null_mnpc);
			pa_last := 1;    --  So LIST_NEIGHBORHOOD will not be called
			sraa := null_sraa;
			dma := null_dma;
			sraa(1)(1) := (pa(1).stem, pa(1).ir);
			dma(1) := (nnn, 0, null_dictionary_entry);
         elsif  words_mode(ignore_unknown_caps)  and all_caps  then
			nnn_meaning := head(
								"Assume this is capitalized proper name/abbr, under MODE IGNORE_UNKNOWN_CAPS ",
								max_meaning_size);
			pa(1) := (head(raw_word, max_stem_size),
					  ((n, ((0, 0), x, x, x)), 0, null_ending_record, x, x),
					  nnn, null_mnpc);
			pa_last := 1;
			sraa := null_sraa;
			dma := null_dma;
			sraa(1)(1) := (pa(1).stem, pa(1).ir);
			dma(1) := (nnn, 0, null_dictionary_entry);
         end if;
      end if;
	  

	  --                --  Does STATS
	  --      
	  ----TEXT_IO.PUT_LINE("Before STATING FIXES");
	  --     if  WORDS_MDEV(WRITE_STATISTICS_FILE)    then      --  Omit rest of output
	  ----            
	  ----       for I in 1..PA_LAST  loop                       --  Just to PUT_STAT
	  ----         if (PA(I).D_K = ADDONS)  then
	  ----           if PA(I).IR.QUAL.POFS = PREFIX  then
	  ----             PUT_STAT("ADDON PREFIX at "
	  ----                     & HEAD(INTEGER'IMAGE(LINE_NUMBER), 8) & HEAD(INTEGER'IMAGE(WORD_NUMBER), 4)
	  ----                     & "   " & HEAD(W, 20) & "   "  & PA(I).STEM);
	  ----           elsif PA(I).IR.QUAL.POFS = SUFFIX  then
	  ----             PUT_STAT("ADDON SUFFIX at "
	  ----                     & HEAD(INTEGER'IMAGE(LINE_NUMBER), 8) & HEAD(INTEGER'IMAGE(WORD_NUMBER), 4)
	  ----                     & "   " & HEAD(W, 20) & "   "  & PA(I).STEM);
	  ----           elsif PA(I).IR.QUAL.POFS = TACKON  then
	  ----             PUT_STAT("ADDON TACKON at "
	  ----                     & HEAD(INTEGER'IMAGE(LINE_NUMBER), 8) & HEAD(INTEGER'IMAGE(WORD_NUMBER), 4)
	  ----                     & "   " & HEAD(W, 20) & "   "  & PA(I).STEM);
	  ----           end if;
	  ----         end if;
	  ----       end loop;
	  --         
	  --       
	  ----    --  Just to find the words with long/complicated output at the LIST level 
	  ----    --  This is done with the final PA_LAST, after SWEEP
	  --       if PA_LAST > FINAL_PA_LAST_MAX   then
	  --         PUT_STAT("$FINAL_PA_LAST_MAX    for RAW_WORD " & HEAD(RAW_WORD, 24) & "   = " & INTEGER'IMAGE(PA_LAST));
	  --         FINAL_PA_LAST_MAX := PA_LAST;
	  --       end if;
	  --       
	  --     end if;
	  
	  
      
	  
	  
	  
	  
      
	  if pa_last = 0   then

		 if  words_mode(write_output_to_file)      then
			if words_mdev(do_pearse_codes) then
			   text_io.put(output, "04 ");
			end if;
			text_io.put(output, raw_word); 
			text_io.set_col(output, 30);
			inflections_package.integer_io.put(output, line_number, 7);
			inflections_package.integer_io.put(output, word_number, 7);
			text_io.put_line(output, "    ========   UNKNOWN    ");
			--TEXT_IO.NEW_LINE(OUTPUT);
		 else              --  Just screen output
			if words_mdev(do_pearse_codes) then
			   text_io.put("04 ");
			end if;
			text_io.put(raw_word);
			text_io.set_col(30);
			text_io.put_line("    ========   UNKNOWN    ");
			--TEXT_IO.NEW_LINE;
		 end if;

		 if words_mode(write_unknowns_to_file)  then
			if words_mdev(include_unknown_context) or
			  words_mdev(do_only_initial_word)  then
			   text_io.put_line(input_line);
			   text_io.put_line(unknowns, input_line);
			end if;
			if words_mdev(do_pearse_codes) then
			   text_io.put(unknowns, "04 ");
			end if;
			text_io.put(unknowns, raw_word);
			text_io.set_col(unknowns, 30);
			inflections_package.integer_io.put(unknowns, line_number, 7);
			inflections_package.integer_io.put(unknowns, word_number, 7);
			text_io.put_line(unknowns, "    ========   UNKNOWN    ");
		 end if;
      end if;

      if pa_last = 0   then
		 if words_mode(do_stems_for_unknown)   then  
			if  words_mode(write_output_to_file)  and then
              not words_mode(write_unknowns_to_file)   then  
			   list_neighborhood(output, raw_word);     
			elsif  words_mode(write_output_to_file)  and then
			  words_mode(write_unknowns_to_file)   then  
			   list_neighborhood(output, raw_word);     
			   list_neighborhood(unknowns, raw_word);     
			elsif (name(current_input) = name(standard_input))  then
			   list_neighborhood(output, raw_word); 
			end if; 
		 end if;
      end if;

      if pa_last = 0   then
		 if words_mdev(update_local_dictionary)  and  -- Don't if reading from file
		   (name(current_input) = name(standard_input))  then
			update_local_dictionary_file;
			word(raw_word, pa, pa_last);       --  Circular if you dont update!!!!!
		 end if;
      end if;     
	  
	  
	  
	  
	  
	  --  Exit if UNKNOWNS ONLY (but had to do STATS above)         
	  if  words_mode(do_unknowns_only)    then      --  Omit rest of output
		 return;
	  end if;
	  

	  --TEXT_IO.PUT_LINE("PUTting INFLECTIONS");         
	  j := 1;
	  osra := null_sra;
  output_loop:
	  while  dma(j) /= null_dictionary_mnpc_record  loop
		 ----!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!            
		 --            if (J > 1)  and then ((DMA(J-1).D_K = PPP)  or                               --!!!!!!!!!!!!!!!!!!!!!!!!
		 --               (DICTIONARY_FORM(DMA(J).DE) = DICTIONARY_FORM(DMA(J-1).DE)))  then        --!!!!!!!!!!!!!!!!!!!!!!!!
		 --             null;                                                                       --!!!!!!ND mod!!!!!!!!!!!!
		 --            else                                                                         --!!!!!!!!!!!!!!!!!!!!!!!!
		 --              NEW_LINE(OUTPUT);                                                          --!!!!!!!!!!!!!!!!!!!!!!!!
		 --            end if;                                                                      --!!!!!!!!!!!!!!!!!!!!!!!!
		 --                                                                                         --!!!!!!!!!!!!!!!!!!!!!!!!
		 -- --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!     
		 if sraa(j) /= osra  then --  Skips one identical SRA
								  --  no matter what comes next
            
			
			
        put_inflection_array_j:
			for k in sraa(j)'range loop
			   exit when sraa(j)(k) = null_stem_inflection_record;
			   
			   
			   put_inflection(sraa(j)(k), dma(j));
			   if sraa(j)(k).stem(1..3) = "PPL"  then
				  text_io.put_line(output, head(ppp_meaning, mm));
			   end if;
			end loop put_inflection_array_j;
			osra := sraa(j);
		 end if;
		 
		 --TEXT_IO.PUT_LINE("PUTting FORM");         
	 putting_form:
		 begin
            if j = 1  or else
			  dictionary_form(dma(j).de) /= dictionary_form(dma(j-1).de)  then
			   --  Put at first chance, skip duplicates
			   put_form(sraa(j)(1), dma(j));
            end if;
		 end putting_form;
		 
		 
		 --TEXT_IO.PUT_LINE("PUTting MEANING");         
	 putting_meaning:
		 begin
            if (dma(j).d_k in general..unique)  then
			   if (dma(j).de.mean /= dma(j+1).de.mean)  then
				  --  This if handles simple multiple MEAN with same IR and FORM
				  --  by anticipating duplicates and waiting until change
				  put_meaning_line(sraa(j)(1), dma(j));
			   end if;
            else
			   put_meaning_line(sraa(j)(1), dma(j));
            end if;
		 end putting_meaning;
		 
		 
		 
	 do_pause:
		 begin
			if i = pa_last  then
			   text_io.new_line(output);
            elsif (integer(text_io.line(output)) >
					 scroll_line_number + output_screen_size)  then
			   pause(output);
			   scroll_line_number := integer(text_io.line(output));
            end if;
		 end do_pause;                                                                                     
		 --TEXT_IO.PUT_LINE("End of OUTPUT_LOOP with J = " & INTEGER'IMAGE(J));
		 
         
		 j := j + 1;
	  end loop output_loop;
	  --TEXT_IO.PUT_LINE("Finished OUTPUT_LOOP");
	  
	  if trimmed  then
		 put(output, '*');
	  end if;
	  text_io.new_line(output);
	  
      
   exception
	  when others  =>
		 text_io.put_line("Unexpected exception in LIST_STEMS processing " & raw_word);
		 put_stat("EXCEPTION LS at "
					& head(integer'image(line_number), 8) & head(integer'image(word_number), 4)
					& "   " & head(w, 20) & "   "  & pa(i).stem);
   end list_stems;

   
   
   procedure list_entry(output   : text_io.file_type;
						d_k      : dictionary_kind;
						mn       : dict_io.count) is
      de : dictionary_entry;
   begin
      dict_io.read(dict_file(d_k), de, mn);
      text_io.put(output, "=>  ");
      --TEXT_IO.PUT_LINE(OUTPUT, DICTIONARY_FORM(DE));
      put_dictionary_form(output, d_k, mn, de);
      text_io.put_line(output, 
                       trim(head(de.mean, mm)));  --  so it wont line wrap/put CR

   end list_entry;
   
   
   
   
   
   procedure unknown_search(unknown       :  in string;
							unknown_count : out dict_io.count) is
	  
	  use stem_io;
	  
	  d_k : constant dictionary_kind := general;
	  j, j1, j2, jj : stem_io.count := 0;

	  index_on : constant string := unknown;
	  index_first, index_last : stem_io.count := 0;
	  ds : dictionary_stem;
	  first_try, second_try : boolean := true;


	  function first_two(w : string) return string is
         --  'v' could be represented by 'u', like the new Oxford Latin Dictionary
         --  Fixes the first two letters of a word/stem which can be done right
		 s : constant string := lower_case(w);
		 ss : string(w'range) := w;
		 
		 function ui(c : character) return character  is
		 begin
			if (c = 'v')   then
			   return 'u';
			elsif (c = 'V')  then
			   return 'U';
			elsif (c = 'j')  then
			   return 'i';
			elsif (c = 'J')  then
			   return 'I';
			else
			   return c;
			end if;
		 end ui;

	  begin

		 if s'length = 1  then
			ss(s'first) := ui(w(s'first));
		 else
			ss(s'first)   := ui(w(s'first));
			ss(s'first+1) := ui(w(s'first+1));
		 end if;

		 return ss;
	  end first_two;





   begin
	  
	  if dictionary_available(d_k)  then
		 if not is_open(stem_file(d_k))  then
			open(stem_file(d_k), stem_io.in_file,
				 add_file_name_extension(stem_file_name,
										 dictionary_kind'image(d_k)));
		 end if;
		 
         index_first := first_index(first_two(index_on), d_k);
         index_last  := last_index(first_two(index_on), d_k);
         
         if index_first > 0  and then index_first <= index_last then


            j1 := stem_io.count(index_first);    --######################
            j2 := stem_io.count(index_last);
			

			first_try := true;

			second_try := true;

			j := (j1 + j2) / 2;

		binary_search:
			loop

			   if (j1 = j2-1) or (j1 = j2) then
				  if first_try  then
					 j := j1;
					 first_try := false;
				  elsif second_try  then
					 j := j2;
					 second_try := false;
				  else
					 jj := j;
					 exit binary_search;
				  end if;
			   end if;
			   
			   set_index(stem_file(d_k), stem_io.count(j));
			   read(stem_file(d_k), ds);
			   
			   if  ltu(lower_case(ds.stem), unknown)  then
				  j1 := j;
				  j := (j1 + j2) / 2;
			   elsif  gtu(lower_case(ds.stem), unknown)  then
				  j2 := j;
				  j := (j1 + j2) / 2;
			   else
				  for i in reverse j1..j  loop
					 set_index(stem_file(d_k), stem_io.count(i));
					 read(stem_file(d_k), ds);
					 
					 if equ(lower_case(ds.stem), unknown)  then
						jj := i;
						

					 else
						exit;
					 end if;
				  end loop;

				  for i in j+1..j2  loop
					 set_index(stem_file(d_k), stem_io.count(i));
					 read(stem_file(d_k), ds);
					 
					 if equ(lower_case(ds.stem), unknown)  then
						jj := i;

						
					 else
						exit binary_search;
					 end if;
				  end loop;
				  exit binary_search;
				  
			   end if;
			end loop binary_search;
			j1 := jj;
			j2 := stem_io.count(index_last);
			
            
         end if;
         unknown_count := ds.mnpc;
         
		 close(stem_file(d_k));  --??????
	  end if;
	  --TEXT_IO.PUT_LINE("Leaving LIST_NEIGHBORHOOD    UNKNOWN_SEARCH");
   end unknown_search;

   

   
   
   procedure list_neighborhood(output : text_io.file_type; 
							   input_word : string) is
	  
	  d_k : constant dictionary_kind := general;
	  de : dictionary_entry;
	  unk_mnpc : dict_io.count; 

	  
	  
	  
   begin
	  --TEXT_IO.PUT_LINE("Entering LIST_NEIGHBORHOOD");
	  
	  if (text_io.name(output) = 
			text_io.name(text_io.standard_output))  then
		 mm := max_meaning_print_size;   --  to keep from overflowing screen line
	  else
		 mm := max_meaning_size;
	  end if;
	  
	  unknown_search(head(input_word, max_stem_size), unk_mnpc);
	  --TEXT_IO.PUT_LINE("UNK_MNPC = " & INTEGER'IMAGE(INTEGER(UNK_MNPC)));
	  if integer(unk_mnpc) > 0  then
         text_io.put_line(output, 
						  "----------  Entries in GENEAL Dictionary around the UNKNOWN  ----------");
         pause(output);
         for mn in dict_io.count(integer(unk_mnpc)-5).. 
		   dict_io.count(integer(unk_mnpc)+3)  loop
			list_entry(output, d_k, mn);

         end loop;
	  end if;
	  
	  --TEXT_IO.PUT_LINE("Leaving LIST_NEIGHBORHOOD");
	  
   end list_neighborhood;
   
end list_package;