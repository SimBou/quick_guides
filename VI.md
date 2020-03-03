# VI Editor

## Table of Contents
  - [Moves](VI.md/#moves)
  - [Finds](VI.mg/#finds)
  - [Inserts](VI.md/#inserts)
  - [Deletes](VI.md/#deletes)
  - [Changes](VI.md/#changes)
  - [Copy / Paste](VI.md/#copy--paste)
  - [Substitutions](VI.md/#substitution)
  - [Registers](VI.md/#registers)
  - [Regular Expresions](VI.md/#regular-expressions)
  - [Files](VI.md/#files)
  - [Quit](VI.md/#quit)


    START VI AND EDIT FILE "FILENAME"                       vi filename

## Moves
    MOVE LEFT                                               h
    MOVE DOWN                                               j
    MOVE UP                                                 k
    MOVE RIGHT                                              l
    MOVE ONE PAGE DOWN                                      d
    MOVE ONE PAGE UP                                        u
    GO TO END OF LINE                                       $
    GO TO BEGINNING OF LINE                                 0
    GO TO LINE # N                                          nG
    GO TO BOTTOM OF FILE                                    G
    GO TO BOTTOM OF SCREEN                                  L
    GO TO TOP OF SCREEN                                     H
    GO FORWARD A WORD, COUNTING PUNCTUATION                 w
    GO BACKWARD A WORD, COUNTING PUNCTUATION                b
    GO FORWARD A WORD, NOT COUNTING PUNCTUATION             W
    GO BACKWARD A WORD, NOT COUNTING PUNCTUATION            B

## Finds

    FIND "SOMETHING" FROM CURRENT LOCATION FORWARD          / something
    FIND "SOMETHING" FROM CURRENT LOCATION BACKWARD         ? something
    REPEAT LAST FIND                                        n 

## Inserts

    INSERT TEXT IN FRONT OF CURSOR                          i
    INSERT TEXT AT BEGINNING OF CURRENT LINE                I
    INSERT TEXT AFTER CURSOR (APPEND)                       a
    INSERT TEXT AT END OF CURRENT LINE                      A
	
## Deletes
	
    DELETE CHARACTER AT THE CURSOR                          x
    DELETE CHARACTER TO THE LEFT OF THE CURSOR              X
    DELETE TO END OF LINE FROM CURSOR                       d$
    DELETE WHOLE LINE                                       dd
    CUT CURRENT LINE                                        dd
    DELETE FROM CURSOR TO CHARACTER	z                       dtz
    DELETES TO BOTTOM OF SCREEN                             dL
    DELETES FROM CURRENT CURSOR POSITION TO END OF FILE     dG
    DELETE CURRENT WORD, COUNTING PUNCTUATION               dw
    DELETE FROM BEGINNING OF FILE TO CURSOR                 d1G
    DELETE LINES 1 TO 4                                     :1,4 d 
    
## Changes
    
    CHANGE CURRENT WORD, COUNTING PUNCTUATION               cw
    CHANGE TO END OF LINE                                   C
    CHANGE CURRENT LINE (entirely)                          cc 
    COMBINE (``join'') NEXT LINE WITH THIS ONE              J
    CHANGE CURRENT CHARACTER                                r
    CHANGE CASE (upper-, lower-) OF CURRENT CHARACTER       ~
    TRANSPOSE CHARACTER CURSOR AND CHARACTER TO RIGHT       xp
    UNDO LAST CHANGE                                        u
    UNDO ALL CHANGES TO CURRENT LINE                        U

## Copy / Paste
	
    COPY CURRENT LINE                                       yy
    COPY CURRENT WORD                                       yw
    COPY TO THE END OF LINE                                 Y	
    COPY 4 LINES                                            4yy or y4y
    PASTE COPIED/CUT LINE BELOW CURRENT LINE                p
    PASTE COPIED/CUT LINE ABOVE CURRENT LINE                P
    COPY LINES 1-2 AND PUT AFTER LINE 3                     :1,2 co 3 
    MOVE LINES 4-6 AND PUT AFTER LINE 7                     :4,6 m 7

## Substitutions

    REPLACE (the 1st) s1 IN THIS LINE BY s2                 :s/s1/s2
    REPLACE ALL INSTANCES OF s1 BY s2 IN THE FILE           :%s/s1/s2/g

## Registers

    MARK BEGINNING OF BLOCK "b"                             mb
    DELETES A WORD INTO REGISTER a                          "adw
    COPY BLOCK FROM MARKER "b" TO CURSOR INTO REGISTER "a"  "ay'b
    PASTE REGISTER "a"                                      "ap
    DELETE EVERYTHING FROM THE MARKED POSITION TO HERE      d`b
    
## Regular Expressions

    ANY SINGLE CHARACTER EXCEPT NEWLINE                     . (dot)
    ZERO OR MORE REPEATS                                    *
    ANY CHARACTER IN SET                                    [...]
    ANY CHARACTER NOT IN SET                                [^ ...]
    BEGINNING, END OF LINE                                  ^ , $
    BEGINNING, END OF WORD                                  \< , \>
    GROUPING                                                \(. . . \)
    CONTENTS OF nth GROUPING                                \n
    
## Exec Mode

    WRITE FILE (current file if no name given)              :w file
    APPEND FILE (current file if no name given)             :w >>file
    INSERT (read) FILE AFTER LINE                           :r file
    INSERT (read) PROGRAM OUTPUT                            :r !program
    INSERT (read) FILE AFTER LINE 34                        :34 r file
    NEXT FILE                                               :n
    PREVIOUS FILE                                           :p
    EDIT NEW FILE                                           :e file
    REPLACE LINE WITH PROGRAM OUTPUT                        :.!program
    SHOW ALL OPTIONS                                        :set all
    SET OPTION                                              :set <option>
    UNSET OPTION                                            :set no<option>
    
## Quit

    QUIT WITHOUT SAVING                                     :q!
    SAVE AND QUIT                                           :wq
    SAVE                                                    :w
    SAVE AS "NAME"                                          :w name

