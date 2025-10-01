{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:

let
    profileName = "1080p Anime Movie";

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

    sops.secrets."tsumugi/radarrAnimeApiKey" = { };

    systemd.services.recyclarr.serviceConfig.LoadCredential = [
        "radarrAnimeApiKey:${config.sops.secrets."tsumugi/radarrAnimeApiKey".path}"
    ];

    services.recyclarr.configuration.radarr.radarrAnime = {
        base_url = "http://10.0.4.2:7887";
        api_key._secret = "/run/credentials/recyclarr.service/radarrAnimeApiKey";
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
                    until_quality = "Remux-1080p";
                    until_score = 10000;
                };
                qualities = [
                    {
                        name = "Remux-1080p";
                        qualities = [
                            "Remux-1080p"
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
                    {
                        name = "LQ";
                        enabled = false;
                        qualities = [
                            "Remux-2160p"
                            "Bluray-2160p"
                            "WEBRip-2160p"
                            "WEBDL-2160p"
                            "HDTV-2160p"
                            "DVD-R"
                            "DVD"
                            "SDTV"
                            "DVDSCR"
                            "REGIONAL"
                            "TELECINE"
                            "TELESYNC"
                            "CAM"
                            "WORKPRINT"
                            "Unknown"
                            "BR-DISK"
                            "Raw-HD"
                        ];
                    }
                ];
            }
        ];
        custom_formats = [
            (mkScore "4a3b087eea2ce012fcc1ce319259a3be" 2000) # Anime Dual Audio
            (mkScore "fb3ccc5d5cc8f77c9055d4cb4561dded" 1400) # Anime BD Tier 01 (Top SeaDex Muxers)
            (mkScore "66926c8fa9312bc74ab71bf69aae4f4a" 1300) # Anime BD Tier 02 (SeaDex Muxers)
            (mkScore "fa857662bad28d5ff21a6e611869a0ff" 1200) # Anime BD Tier 03 (SeaDex Muxers)
            (mkScore "f262f1299d99b1a2263375e8fa2ddbb3" 1100) # Anime BD Tier 04 (SeaDex Muxers)
            (mkScore "3a3ff47579026e76d6504ebea39390de" 1050) # Remux Tier 01
            (mkScore "ca864ed93c7b431150cc6748dc34875d" 1000) # Anime BD Tier 05 (Remuxes)
            (mkScore "9f98181fe5a3fbeb0cc29340da2a468a" 1000) # Remux Tier 02
            (mkScore "8baaf0b3142bf4d94c42a724f034e27a" 950) # Remux Tier 03
            (mkScore "9dce189b960fddf47891b7484ee886ca" 900) # Anime BD Tier 06 (FanSubs)
            (mkScore "1ef101b3a82646b40e0cab7fc92cd896" 800) # Anime BD Tier 07 (P2P/Scene)
            (mkScore "6115ccd6640b978234cc47f2c1f2cadc" 700) # Anime BD Tier 08 (Mini Encodes)
            (mkScore "8167cffba4febfb9a6988ef24f274e7e" 600) # Anime Web Tier 01 (Muxers)
            (mkScore "8526c54e36b4962d340fce52ef030e76" 500) # Anime Web Tier 02 (Top FanSubs)
            (mkScore "de41e72708d2c856fa261094c85e965d" 400) # Anime Web Tier 03 (Official Subs)
            (mkScore "c20f169ef63c5f40c2def54abaf4438e" 350) # WEB Tier 01
            (mkScore "9edaeee9ea3bcd585da9b7c0ac3fc54f" 300) # Anime Web Tier 04 (Official Subs)
            (mkScore "403816d65392c79236dcb6dd591aeda4" 250) # WEB Tier 02
            (mkScore "22d953bbe897857b517928f3652b8dd3" 200) # Anime Web Tier 05 (FanSubs)
            (mkScore "af94e0fe497124d1f9ce732069ec8c3b" 150) # WEB Tier 03
            (mkScore "064af5f084a0a24458cc8ecd3220f93f" 101) # Uncensored
            (mkScore "a786fbc0eae05afe3bb51aee3c83a9d4" 100) # Anime Web Tier 06 (FanSubs)
            (mkScore "60f6d50cbd3cfc3e9a8c00e3a30c3114" 10) # VRV
            (mkScore "d4e5e842fad129a3c097bdb2d20d31a0" 4) # v4
            (mkScore "db92c27ba606996b146b57fbe6d09186" 3) # v3
            (mkScore "3df5e6dfef4b09bb6002f732bed5b774" 2) # v2
            (mkScore "5f400539421b8fcf71d51e6384434573" 1) # v1
            (mkScores [
                "a5d148168c4506b55cf53984107c396e" # 10bit
                "cae4ca30163749b891686f95532519bd" # AV1
            ] 0)
            (mkScore "c259005cbaeb5ab44c06eddb4751e70c" (-51)) # v0
            (mkScores [
                "b0fdc5897f68c9a68c70c25169f77447" # Anime LQ Groups
                "06b6542a47037d1e33b15aa3677c2365" # Anime Raws
                "b23eae459cc960816f2d6ba84af45055" # Dubs Only
                "9172b2f683f6223e3a1846427b417a3d" # VOSTFR
            ] (-10000))
        ];
    };
}
