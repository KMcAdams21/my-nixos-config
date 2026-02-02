{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_22
    yarn
    typescript
  ];

  shellHook = ''
    echo "------------------------------------------------"
    echo "Welcome to your JavaScript Development Shell!"
    echo "Node Version: $(node --version)"
    echo "npm Version: $(npm --version)"
    echo "Yarn Version: $(yarn --version)"
    echo "------------------------------------------------"
  '';
}
