# Load and Save with KickAssembler

Loading and saving data from and to a D81 image.


## building and Running

The `build.bat` is the windows "makefile", it compiles `main.asm` with kickassembler.
Creates a D81 image with `c1541` from vice and copies the files `main.prg` and `pal0.bin` to it.

Copy the D81 file to the Mega65 (Emu or device) and run the `main.prg`. 

The program will load the `pal0.bin` file to address `$40000` and will then save the data back to 
the image into file `test.bin`.

If you reopen the D81 image there should be another file named `test.bin`, wich will be a copy 
of the `pal0.bin` file. 
