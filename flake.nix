{
  inputs = {
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.05.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      devShells = {
        default = pkgs.mkShell {
        buildInputs = with pkgs; [
          docker
            ansible
            terraform
            python3
            qemu
            qemu_kvm
            libvirt
            virt-manager
            shellcheck
            yamllint
            markdownlint-cli
            kcl
            tflint
            cdrtools
            tigervnc
        ];

        shellHook = ''
          export HELPER_SCRIPTS="$PWD/_scripts"
          export PATH="$HELPER_SCRIPTS:$PATH"

          if [ -f "$HELPER_SCRIPTS/helper.sh" ]; then
            source "$HELPER_SCRIPTS/helper.sh"
          fi

          function terminate() {
            if [ -n "$IN_NIX_SHELL" ]; then
              bash -c "$(declare -f shutdown_docker); shutdown_docker"
            fi
          }

          # Wrap trap setup with interactive shell check
          if [[ $- == *i* ]]; then
            trap 'echo "EXIT trap: status=$? line=$LINENO"; terminate;' SIGTERM SIGINT EXIT
          fi

          echo ""
          echo "Working in nix-shell environment, usage:"
          echo -e "   start_docker:\t\tStarts the docker daemon"
          echo -e "   generate_ssh_key:\tGenerates an SSH key to ./ssh"

          # TODO: aliases for running lengthy ansible and terraform commands, with instructions printed here
          '';
        };
      };
    }
  );
}
