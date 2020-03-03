# Quick Guides
Table of Contents

- [VI Editor](#overview)
  * [Moves](#moves)
  * [Basics](#basics)
  * [Copy / Paste](#copypaste)
  * [Quit](#quit)
- [Other](#other)
  * [Other 1](#operating-systems)
  * [Other 2](#local-system-access)
    + [Other 2.1](#zabbix-44)
    + [Other 2.2](#zabbix-42)

# VI Editor

    START VI AND EDIT FILE "FILENAME"			vi filename

## Moves
    MOVE LEFT						h
    MOVE DOWN						j
    MOVE UP							k
    MOVE RIGHT						l
    MOVE ONE PAGE DOWN					d
    MOVE ONE PAGE UP					u
    GO TO END OF LINE					$
    GO TO BEGINNING OF LINE					0
    GO TO LINE # N						nG
    FIND "SOMETHING" FROM CURRENT
     LOCATION FORWARD					/ something
    							(and )
    FIND "SOMETHING" FROM CURRENT
     LOCATION BACKWARD					? something
    							(and )
    REPEAT LAST FIND					n 

## Basics

    INSERT TYPING (TEXT) IN FRONT OF 
    CURRENT LOCATION POINTER (CURSOR)			i
    INSERT TEXT AT BEGINNING OF CURRENT LINE                I
    INSERT TEXT AFTER CURSOR (APPEND)			a
    INSERT TEXT AT END OF CURRENT LINE			A
	
    DELETE CHARACTER AT THE CURSOR				x
    DELETE TO END OF LINE FROM CURSOR			d$
    DELETE WHOLE LINE					dd
    DELETE FROM CURSOR TO CHARACTER	z			dtz
	
    UNDO LAST CHANGE					u

## Copy / Paste
	
    COPY CURRENT LINE					yy
    CUT CURRENT LINE					dd
    PASTE COPIED/CUT LINE					p
    MARK BEGINNING OF BLOCK "a"				ma
    COPY BLOCK FROM MARKER "a" TO CURSOR		        "ay'a
    PASTE BLOCK "a"						"ap

## Quit

    QUIT WITHOUT SAVING					:q!
    SAVE AND QUIT						:wq
    SAVE							:w
    SAVE AS "NAME"						:w name

