# devshell.nix
{ pkgs }:

pkgs.mkShell {
  # Add nodejs and any other development tools you need
  packages = with pkgs; [
    nodejs # The latest LTS version
    # yarn
  ];

  # This hook runs automatically when you enter the shell with 'nix develop'
  shellHook = ''
    echo "🚀 Entering Node.js Development Shell. Node $(node -v). NPM $(npm -v)."
    
    if [ -f package.json ]; then
      echo "Running 'npm install' to ensure local dependencies are available..."
      npm install
    fi
  '';
}