{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:

let
    profileName = "4k Movie";

    mkScores = ids: score: {
        trash_ids = ids;
        assign_scores_to = [
            {
                name = profileName;
                score = score;
            }
        ];
    };
    mkScore = id: score: (mkScores [ id ] score);
in

{

    sops.secrets."tsumugi/radarrMainApiKey" = { };

    systemd.services.recyclarr.serviceConfig.LoadCredential = [
        "radarrMainApiKey:${config.sops.secrets."tsumugi/radarrMainApiKey".path}"
    ];

    services.recyclarr.configuration.radarr.radarrMain = {
        base_url = "http://localhost:7878";
        api_key._secret = "/run/credentials/recyclarr.service/radarrMainApiKey";
        delete_old_custom_formats = true;
        replace_existing_custom_formats = true;
        quality_definition.type = "movie";
        quality_profiles = [
            {
                name = profileName;
                reset_unmatched_scores.enabled = true;
                min_format_score = 0;
                upgrade = {
                    allowed = true;
                    until_quality = "Remux-2160p";
                    until_score = 10000;
                };
                qualities = [
                    { name = "Remux-2160p"; }
                    {
                        name = "2160p";
                        qualities = [
                            "Bluray-2160p"
                            "WEBRip-2160p"
                            "WEBDL-2160p"
                            "HDTV-2160p"
                        ];
                    }
                    { name = "Remux-1080p"; }
                    {
                        name = "1080p";
                        qualities = [
                            "Bluray-1080p"
                            "WEBRip-1080p"
                            "WEBDL-1080p"
                            "HDTV-1080p"
                        ];
                    }
                    {
                        name = "720p";
                        qualities = [
                            "Bluray-720p"
                            "WEBRip-720p"
                            "WEBDL-720p"
                            "HDTV-720p"
                        ];
                    }
                    {
                        name = "LQ";
                        enabled = false;
                        qualities = [
                            "Bluray-576p"
                            "Bluray-480p"
                            "WEBRip-480p"
                            "WEBDL-480p"
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
            (mkScore "496f355514737f7d83bf7aa4d24f8169" 5000) # TrueHD ATMOS
            (mkScore "2f22d89048b01681dde8afe203bf2e95" 4500) # DTS X
            (mkScores [
                "417804f7f2c4308c1f4c5d380d4c4475" # ATMOS (undefined)
                "1af239278386be2919e1bcee0bde047e" # DD+ ATMOS
            ] 3000)
            (mkScore "3cafb66171b47f226146a0770576870f" 2750) # TrueHD
            (mkScore "dcf3ec6938fa32445f590a4da84256cd" 2500) # DTS-HD MA
            (mkScores [
                "a570d4a0e56a2874b64e5bfa55202a1b" # FLAC
                "e7c2fcae07cbada050a0af3357491d7b" # PCM
            ] 2250)
            (mkScore "8e109e50e0a0b83a5098b056e13bf6db" 2000) # DTS-HD HRA
            (mkScore "3a3ff47579026e76d6504ebea39390de" 1950) # Remux Tier 01
            (mkScore "9f98181fe5a3fbeb0cc29340da2a468a" 1900) # Remux Tier 02
            (mkScore "8baaf0b3142bf4d94c42a724f034e27a" 1850) # Remux Tier 03
            (mkScores [
                "4d74ac4c4db0b64bff6ce0cffef99bf0" # UHD Bluray Tier 01
                "ed27ebfef2f323e964fb1f61391bcb35" # HD Bluray Tier 01
            ] 1800)
            (mkScores [
                "a58f517a70193f8e578056642178419d" # UHD Bluray Tier 02
                "c20c8647f2746a1f4c4262b0fbbeeeae" # HD Bluray Tier 02
                "185f1dd7264c4562b9022d963ac37424" # DD+
            ] 1750)
            (mkScores [
                "e71939fae578037e7aed3ee219bbe7c1" # UHD Bluray Tier 03
                "5608c71bcebba0a5e666223bae8c9227" # HD Bluray Tier 03
                "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
            ] 1700)
            (mkScore "403816d65392c79236dcb6dd591aeda4" 1650) # WEB Tier 02
            (mkScore "af94e0fe497124d1f9ce732069ec8c3b" 1600) # WEB Tier 03
            (mkScore "f9f847ac70a0af62ea4a08280b859636" 1500) # DTS-ES
            (mkScore "1c1a4c5e823891c75bc50380a6866f73" 1250) # DTS
            (mkScores [
                "240770601cc226190c367ef59aba7463" # AAC
                "b337d6812e06c200ec9a2d3cfa9d20a7" # DV Boost
            ] 1000)
            (mkScores [
                "eecf3a857724171f968a66cb5719e152" # IMAX
                "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
            ] 800)
            (mkScore "c2998bd0d90ed5621d8df281e839436e" 750) # DD

            (mkScore "493b6d1dbec3c3364c59d7607f7e3405" 500) # HDR
            (mkScore "957d0f44b592285f26449575e8b1167e" 125) # Special Edition
            (mkScores [
                "caa37d0df9c348912df1fb1d88f9273a" # HDR10+ Boost
                "0f12c086e289cf966fa5948eac571f44" # Hybrid
            ] 100)
            (mkScores [
                "eca37840c13c6ef2dd0262b141a5482f" # 4k Remaster
                "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
                "9d27d9d2181838f76dee150882bdc58c" # Masters of Cinema
                "570bc9ebecd92723d2d21500f4be314c" # Remaster
                "db9b4c4b53d312a3ca5f1378f6440fc9" # Vinegar Syndrome
            ] 25)
            (mkScores [
                "16622a6911d1ab5d5b8b713d5b0036d4" # CRiT
                "2a6039655313bf5dab1e43523b62c374" # MA
            ] 20)
            (mkScore "cc5e51a9e85a6296ceefe097a77f12f4" 15) # BCORE
            (mkScore "5caaaa1c08c1742aa4342d8c4cc463f2" 7) # Repack3
            (mkScore "ae43b294509409a6a13919dedd4764c4" 6) # Repack2
            (mkScore "e7718d7a3ce595f289bfee26adc178f5" 5) # Repack / Proper
            (mkScores [
                "b3b3a6ac74ecbd56bcdbefa4799fb9df" # AMZN
                "40e9380490e748672c2522eaaeb692f7" # ATVP
                "cae4ca30163749b891686f95532519bd" # AV1
                "84272245b2988854bfb76a16e60baea5" # DSNP
                "509e5f41146e278f9eab1ddaceb34515" # HBO
                "5763d1b0ce84aff3b21038eea8e9b8ad" # HMAX
                "526d445d4c16214309f0fd2b3be18a89" # Hulu
                "e0ec9672be6cac914ffad34a6b077209" # iT
                "6a061313d22e51e0f25b7cd4dc065233" # MAX
                "170b1d363bd8516fbf3a3eb05d4faff6" # NF
                "c9fd353f8f5f1baf56dc601c4cb29920" # PCOK
                "e36a0ba1bc902b26ee40818a1d59b8bd" # PMTP
                "c2863d2a50c9acad1fb50e53ece60817" # STAN
                "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
            ] 0)
            (mkScores [
                "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # No-RlsGroup
                "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated
                "5c44f52a8714fdd79bb4d98e2673be1f" # Retags
            ] (-10))
            (mkScores [
                "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
                "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
                "ed38b889b31be83fda192888e2286d83" # BR-DISK
                "e6886871085226c3da1830830146846c" # Generated Dynamic HDR
                "712d74cd88bceb883ee32f773656b1f5" # Sing-Along Versions
                "0a3f082873eb454bde444150b70253cc" # Extras
                "90a6f9a284dff5103f6346090e6280c8" # LQ
                "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
                "25c12f78430a3a23413652cbd1d48d77" # SDR (no WEBDL)
                "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
                "839bea857ed2c0a8e084f3cbdbd65ecb" # x265 (no HDR/DV)
                "923b6abef9b17f937fab56cfcf89e1f1" # DV (w/o HDR fallback)
            ] (-10000))
        ];
    };
}
