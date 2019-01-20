# Create an object file
ca65 game.asm \
  -o game.o
  # As well as a listing file. It looks like this is useful for debugging?
  # -l game.lst
# Run the linker with the configuration file
ld65 -C linker.cfg \
  game.o \
  -o game.nes
