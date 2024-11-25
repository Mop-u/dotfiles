{ inputs, config, pkgs, lib, target, ... }: 
{
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.caddy = {
        enable = true;
        virtualHosts = {
            "tsumugi.local:80" = {
                extraConfig = ''
                    
                    redir /sonarr/tv /sonarr/tv/
                    reverse_proxy /sonarr/tv/* {
                        to localhost:8989
                    }

                    redir /radarr/movies /radarr/movies/
                    reverse_proxy /radarr/movies/* {
                        to localhost:7878
                    }

                    redir /sonarr/anime /sonarr/anime/
                    reverse_proxy /sonarr/anime/* {
                        to localhost:8998
                    }

                    redir /radarr/anime-movies /radarr/anime-movies/
                    reverse_proxy /radarr/anime-movies/* {
                        to localhost:7887
                    }
                '';
            };
        };
    };
}