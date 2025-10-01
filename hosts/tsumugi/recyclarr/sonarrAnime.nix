{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:

let
    profileName = "1080p Anime";

    mkScorer = profile: ids: score: {
        trash_ids = ids;
        assign_scores_to = [
            {
                name = profile;
                score = score;
            }
        ];
    };
    mkScores = mkScorer profileName;
    mkScore = id: (mkScores [ id ]);
in

{

    sops.secrets."tsumugi/sonarrAnimeApiKey" = { };

    systemd.services.recyclarr.serviceConfig.LoadCredential = [
        "sonarrAnimeApiKey:${config.sops.secrets."tsumugi/sonarrAnimeApiKey".path}"
    ];

    services.recyclarr.configuration.sonarr.sonarrAnime = {
        base_url = "http://10.0.4.2:8998";
        api_key._secret = "/run/credentials/recyclarr.service/sonarrAnimeApiKey";
        delete_old_custom_formats = true;
        replace_existing_custom_formats = true;
        quality_definition.type = "anime";
        quality_profiles = [
            {
                name = profileName;
                reset_unmatched_scores.enabled = true;
                min_format_score = 0;
                upgrade = {
                    allowed = true;
                    until_quality = "Bluray-1080p";
                    until_score = 10000;
                };
                qualities = [
                    {
                        name = "Bluray-1080p";
                        qualities = [
                            "Bluray-1080p Remux"
                            "Bluray-1080p"
                        ];
                    }
                    {
                        name = "1080p";
                        qualities = [
                            "WEBRip-1080p"
                            "WEBDL-1080p"
                            "HDTV-1080p"
                        ];
                    }
                    { name = "Bluray-720p"; }
                    {
                        name = "720p";
                        qualities = [
                            "WEBRip-720p"
                            "WEBDL-720p"
                            "HDTV-720p"
                        ];
                    }
                    { name = "Bluray-576p"; }
                    { name = "Bluray-480p"; }
                    {
                        name = "480p";
                        qualities = [
                            "WEBRip-480p"
                            "WEBDL-480p"
                        ];
                    }
                    { name = "DVD"; }
                    { name = "SDTV"; }
                    {
                        name = "LQ";
                        enabled = false;
                        qualities = [
                            "Bluray-2160p Remux"
                            "Bluray-2160p"
                            "WEBRip-2160p"
                            "WEBDL-2160p"
                            "HDTV-2160p"
                            "Unknown"
                            "Raw-HD"
                        ];
                    }
                ];
            }
        ];
        custom_formats = [
            (mkScore "418f50b10f1907201b6cfdf881f467b7" 2000) # Anime Dual Audio
            (mkScore "949c16fe0a8147f50ba82cc2df9411c9" 1400) # Anime BD Tier 01 (Top SeaDex Muxers)
            (mkScore "ed7f1e315e000aef424a58517fa48727" 1300) # Anime BD Tier 02 (SeaDex Muxers)
            (mkScore "096e406c92baa713da4a72d88030b815" 1200) # Anime BD Tier 03 (SeaDex Muxers)
            (mkScore "30feba9da3030c5ed1e0f7d610bcadc4" 1100) # Anime BD Tier 04 (SeaDex Muxers)
            (mkScore "9965a052eb87b0d10313b1cea89eb451" 1050) # Remux Tier 01
            (mkScore "545a76b14ddc349b8b185a6344e28b04" 1000) # Anime BD Tier 05 (Remuxes)
            (mkScore "8a1d0c3d7497e741736761a1da866a2e" 1000) # Remux Tier 02
            (mkScore "25d2afecab632b1582eaf03b63055f72" 900) # Anime BD Tier 06 (FanSubs)
            (mkScore "0329044e3d9137b08502a9f84a7e58db" 800) # Anime BD Tier 07 (P2P/Scene)
            (mkScore "c81bbfb47fed3d5a3ad027d077f889de" 700) # Anime BD Tier 08 (Mini Encodes)
            (mkScore "e0014372773c8f0e1bef8824f00c7dc4" 600) # Anime Web Tier 01 (Muxers)
            (mkScore "19180499de5ef2b84b6ec59aae444696" 500) # Anime Web Tier 02 (Top FanSubs)
            (mkScore "c27f2ae6a4e82373b0f1da094e2489ad" 400) # Anime Web Tier 03 (Official Subs)
            (mkScore "e6258996055b9fbab7e9cb2f75819294" 350) # WEB Tier 01
            (mkScore "4fd5528a3a8024e6b49f9c67053ea5f3" 300) # Anime Web Tier 04 (Official Subs)
            (mkScore "29c2a13d091144f63307e4a8ce963a39" 200) # Anime Web Tier 05 (FanSubs)
            (mkScores [
                "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
            ] 150)
            (mkScore "026d5aadd1a6b4e550b134cb6c72b3ca" 101) # Uncensored
            (mkScore "dc262f88d74c651b12e9d90b39f6c753" 100) # Anime Web Tier 06 (FanSubs)
            (mkScore "3e0b26604165f463f3e8e192261e7284" 6) # CR
            (mkScore "89358767a60cc28783cdc3d0be9388a4" 5) # DSNP
            (mkScores [
                "4fc15eeb8f2f9a749f918217d4234ad8" # v4
                "d34870697c9db575f17700212167be23" # NF
            ] 4)
            (mkScores [
                "0e5833d3af2cc5fa96a0c29cd4477feb" # v3
                "d660701077794679fd59e8bdf4ce3a29" # AMZN
                "44a8ee6403071dd7b8a3a8dd3fe8cb20" # VRV
            ] 3)
            (mkScores [
                "228b8ee9aa0a609463efca874524a6b8" # v2
                "1284d18e693de8efe0fe7d6b3e0b9170" # FUNi
            ] 2)
            (mkScores [
                "273bd326df95955e1b6c26527d1df89b" # v1
                "a370d974bc7b80374de1d9ba7519760b" # ABEMA
                "d54cd2bf1326287275b56bccedb72ee2" # ADN
            ] 1)
            (mkScores [
                "b2550eb333d27b75833e25b8c2557b38" # 10bit
                "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
                "7dd31f3dee6d2ef8eeaa156e23c3857e" # B-Global
                "4c67ff059210182b59cdd41697b8cb08" # Bilibili
                "570b03b3145a25011bf073274a407259" # HIDIVE
            ] 0)
            (mkScore "d2d7b8a9d39413da5f44054080e028a3" (-51)) # v0
            (mkScores [
                "e3515e519f3b1360cbfc17651944354c" # Anime LQ Groups
                "b4a1b3d705159cdca36d71e57ca86871" # Anime Raws
                "9c14d194486c4014d422adc64092d794" # Dubs Only
                "07a32f77690263bb9fda1842db7e273f" # VOSTFR
            ] (-10000))
        ];
    };
}
