{
  # inputs.toolchain.url = "github:openXC7/toolchain-nix/bd648f4";
  inputs.toolchain.url = "github:openXC7/toolchain-nix/bd648f4";

  outputs = { toolchain, ... }: {
    devShells.x86_64-linux.default = toolchain.devShells.x86_64-linux.default;
  };
}