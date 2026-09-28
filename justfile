_make ARG PROJECT:
    nix develop -c make -C {{PROJECT}} {{ARG}}

build PROJECT: (_make "build" PROJECT)

flash PROJECT: (_make "flash" PROJECT)

clean:
	rm -rf build/