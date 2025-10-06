{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:

let
    profileName = "4k TV";
    inherit ((import ./mkRecyclarrScore.nix) profileName) mkScores mkScore;
in
{

    services.sonarr = {
        enable = true;
        openFirewall = true; # 8989
    };

    sops.secrets."tsumugi/sonarrMainApiKey" = { };

    systemd.services.recyclarr.serviceConfig.LoadCredential = [
        "sonarrMainApiKey:${config.sops.secrets."tsumugi/sonarrMainApiKey".path}"
    ];

    services.recyclarr.configuration.sonarr.sonarrMain = {
        base_url = "http://localhost:8989";
        api_key._secret = "/run/credentials/recyclarr.service/sonarrMainApiKey";
        delete_old_custom_formats = true;
        replace_existing_custom_formats = true;
        quality_definition.type = "series";
        quality_profiles = [
            {
                name = profileName;
                reset_unmatched_scores.enabled = true;
                min_format_score = 0;
                upgrade = {
                    allowed = true;
                    until_quality = "Bluray-2160p Remux";
                    until_score = 10000;
                };
                qualities = [
                    { name = "Bluray-2160p Remux"; }
                    {
                        name = "2160p";
                        qualities = [
                            "WEBDL-2160p"
                            "WEBRip-2160p"
                            "Bluray-2160p"
                            "HDTV-2160p"
                        ];
                    }
                    { name = "Bluray-1080p Remux"; }
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
                    { name = "Bluray-576p"; }
                    {
                        name = "Disc-480p";
                        qualities = [
                            "Bluray-480p"
                            "DVD"
                        ];
                    }
                    {
                        name = "WEB-480p";
                        qualities = [
                            "WEBRip-480p"
                            "WEBDL-480p"
                        ];
                    }
                    {
                        name = "LQ";
                        enabled = false;
                        qualities = [
                            "SDTV"
                            "Unknown"
                            "Raw-HD"
                        ];
                    }
                ];
            }
        ];
        custom_formats = [
            (mkScore "e6258996055b9fbab7e9cb2f75819294" 1700) # WEB Tier 01
            (mkScore "58790d4e2fdcd9733aa7ae68ba2bb503" 1650) # WEB Tier 02
            (mkScore "d0c516558625b04b363fa6c5c2c7cfd4" 1600) # WEB Scene
            (mkScore "d84935abd3f8556dcd51d4f27e22d0a6" 1600) # WEB Tier 03
            (mkScore "7c3a61a9c6cb04f52f1544be6d44a026" 1000) # DV Boost
            (mkScore "505d871304820ba7106b693be6fe4a9e" 500) # HDR
            (mkScore "0c4b99df9206d2cfac3c05ab897dd62a" 100) # HDR10+ Boost
            (mkScore "f67c9ca88f463a48346062e8ad07713f" 100) # ATVP
            (mkScore "89358767a60cc28783cdc3d0be9388a4" 100) # DSNP
            (mkScore "81d1fbf600e2540cee87f3a23f9d3c1c" 90) # MAX
            (mkScore "a880d6abc21e7c16884f3ae393f84179" 80) # HMAX
            (mkScore "d9e511921c8cedc7282e291b0209cdc5" 50) # ATV
            (mkScore "da393fd4e2c0cce7c9dc2669c43e0593" 50) # ROKU
            (mkScore "d660701077794679fd59e8bdf4ce3a29" 70) # AMZN
            (mkScore "d34870697c9db575f17700212167be23" 60) # NF
            (mkScore "1656adc6d7bb2c8cca6acfb6592db421" 60) # PCOK
            (mkScore "c67a75ae4a1715f2bb4d492755ba4195" 60) # PMTP
            (mkScore "1efe8da11bfd74fbbcd4d8117ddb9213" 60) # STAN
            (mkScore "77a7b25585c18af08f60b1547bb9b4fb" 50) # CC
            (mkScore "36b72f59f4ea20aad9316f475f2d9fbb" 50) # DCU
            (mkScore "7a235133c87f7da4c8cccceca7e3c7a6" 50) # HBO
            (mkScore "f6cce30f1733d5c8194222a7507909bb" 50) # Hulu
            (mkScore "0ac24a2a68a9700bcb7eeca8e5cd644c" 50) # iT
            (mkScore "ae58039e1319178e6be73caab5c42166" 50) # SHO
            (mkScore "9623c5c9cac8e939c1b9aedd32f640bf" 50) # SYFY
            (mkScore "43b3cf48cb385cd3eac608ee6bca7f09" 20) # UHD Streaming Boost
            (mkScore "44e7c4de10ae50265753082e5dc76047" 7) # Repack v3
            (mkScore "eb3d5cc0a2be0db205fb823640db6a3c" 6) # Repack v2
            (mkScore "ec8fa7296b64e8cd390a1600981f3923" 5) # Repack/Proper
            (mkScores [
                "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
                "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
            ] 0)
            (mkScores [
                "82d40da2bc6923f41e14394075dd4b03" # No-RlsGroup
                "e1a997ddb54e3ecbfe06341ad323c458" # Obfuscated
                "06d66ab109d4d2eddb2794d21526d140" # Retags
            ] (-10))
            (mkScores [
                "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups
                "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
                "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
                "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
                "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
                "83304f261cf516bb208c18c54c0adf97" # SDR (no WEBDL)
                "9b64dff695c2115facf1b6ea59c9bd07" # x265 (no HDR/DV)
                "9b27ab6498ec0f31a3353992e19434ca" # DV (w/o HDR fallback)
            ] (-10000))
        ];
    };
}
