SKDOS.BIN and DS1NAM.DAT must be copied on the the SD card.

The PIC firmware need some modifications :
- enable disk set 1
- load SKDOS.BIN if disk set 1 selected
- enable 512 bytes per sector in this case.
  
Use hex file provided into PIC directory to install the new firmware.

Even with the modifications CPM 68K is still useable if you select disk set 0.
