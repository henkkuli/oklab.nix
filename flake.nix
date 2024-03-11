{
  description = "A perceptual color space for image processing";

  inputs = {
    math.url = "github:henkkuli/math.nix";
  };
  outputs = { self, ... }@inputs: import ./oklab.nix inputs;
}
