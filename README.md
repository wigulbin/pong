This is a pong game I created with help of the tutorial that can be found here: 
http://nintendoage.com/pub/faq/NA/index.html?load=nerdy_nights_out.html

I referenced the tutorial for things such as setting up for running on NES emulator and variables.
I've marked the sections that I did not create (mostly at the start of the file and end of the file), rest was done without referencing
the tutorial files, therefore things such as sprite creation are most likely done inefficiently.


Playing the game:
Included in the github is:
* pong.asm - Contains source code
* pongchr.nes - Contains sprites for the game
* pong.fns  - Compiled game file, compiled with NESASM3 
* pong.nes  - Compiled game file, compiled with NESASM3 

You can download pong.asm + pongchr.nes and compile yourself with 'nesasm pong.asm' or just download the pong.fns\pong.nes file

Then you can use an emulator to run it, I used FCEUXD SP 1.07 for running, you load up the game and press the spacebar to start.

Player 1 uses W to move up and S to move down
Player 2 uses UP ARROW to move up and DOWN ARROW to move down

NOTE: Purpose of this was to see if I could create something using 6502 assembly, because of that and the fact that this is the first game I've tried to create/recreate it's missing some quality of life game features such as the ball speeding up as the game goes on.
