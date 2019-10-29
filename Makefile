SOURCES = src/*.ad?

# rule to link the program
gpr:
	gprbuild -P dynn.gpr

clean:
	rm -f obj/*/* bin/*

.PHONY gpr, clean:
