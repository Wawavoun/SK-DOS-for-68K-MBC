02/04/2025

These are the disk images to use as DS1N00.DSK and DS1N01.DSK on SD card.

It is possible to use 8 images (DS1N00 --> DS1N07) into SK*DOS.

!!! Disk images size is fixed and must not be changed !!!

Use "DRIVE" command to map disk image into SK*DOS logical drive.

Some points to remember :
- Directories are a very different concept that under msdos/windows/linux... Read carefully the manual ! 
- C compiler "cc68k" is on disk 0 but library files (required to compile something) are on disk 1 subdirectory L
- Disk 1 subdirectory V contain VED full screen editor source files. !!! VED compile but dont work at this moment !!!
- Learn to use "asm" the assembler will strongly help you for using this os.
- "tmodem" can transfer (xmodem protocol) files to and from your windows/linux computer.
  "tmodem ?" will give you a short help. Be patient for transfer startup !
  
