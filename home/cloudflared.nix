# cloudflared binary and its config file (~/.cloudflared/config.yml).
#
# Only config.yml is managed here. Secrets stay out of the repo:
# `cloudflared tunnel login` writes ~/.cloudflared/cert.pem, and
# `cloudflared tunnel create` writes ~/.cloudflared/<tunnel-id>.json.
# Both remain ordinary files on each device.
{ pkgs, ... }:

{
  home.packages = [ pkgs.cloudflared ];

  home.file.".cloudflared/config.yml".text = ''
    # Managed by home-manager. Edit home/cloudflared.nix, not this file.

    # Nix manages the binary, so cloudflared shouldn't replace itself.
    no-autoupdate: true
    loglevel: info

    # To run a named tunnel, uncomment and fill in the lines below. The tunnel
    # ID isn't secret, but the credentials file it points at is.
    #
    # tunnel: <tunnel-id>
    # credentials-file: ~/.cloudflared/<tunnel-id>.json
    #
    # ingress:
    #   - hostname: app.example.com
    #     service: http://localhost:8080
    #   - service: http_status:404
  '';
}
