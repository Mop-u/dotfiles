{ inputs, config, pkgs, lib, target, ... }: 
{
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.caddy = {
        enable = false;
        virtualHosts = {
            "tsumugi.local" = {
                extraConfig = ''
                    
                    redir /sonarr/tv /sonarr/tv/
                    reverse_proxy /sonarr/tv/* {
                        to :8989
                    }

                    redir /radarr/movies /radarr/movies/
                    reverse_proxy /radarr/movies/* {
                        to :7878
                    }

                    redir /sonarr/anime /sonarr/anime/
                    reverse_proxy /sonarr/anime/* {
                        to 192.168.1.10:8998
                    }

                    redir /radarr/anime-movies /radarr/anime-movies/
                    reverse_proxy /radarr/anime-movies/* {
                        to 192.168.2.10:7887
                    }

                    redir /prowlarr /prowlarr/
                    reverse_proxy /prowlarr/* {
                        to :9696
                    }

                    redir /bazarr /bazarr/
                    reverse_proxy /bazarr/* {
                        to :6767
                    }
                '';
            };
        };
    };
}