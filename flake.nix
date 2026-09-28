{
  inputs = {
    toolchain.url = "github:openXC7/toolchain-nix";
  };

  outputs = { toolchain, ... }: {
    devShells.x86_64-linux.default = toolchain.devShell.x86_64-linux;
  };
}