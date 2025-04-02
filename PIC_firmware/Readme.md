Here is the modified PIC firmware.

Modifications are :

- enable disk set 1
- load SKDOS.BIN if disk set 1 selected
- enable 512 bytes per sector in this case.

Use hex file provided into PIC directory to flash the new firmware into the PIC.

Even with the modifications CPM 68K is still useable if you select disk set 0.

"main.c" is the only one modified file into source tree.

Replace original "main.c" by this one if you want compile yourself this firmware.
I have used up to date (02/04/2025) MPLAB + XC8.
To do so the original project need other modifications.
Mainly a rebuild of all makefiles using MPLAB command line "prjMakefileGenerator.bat" tool.

