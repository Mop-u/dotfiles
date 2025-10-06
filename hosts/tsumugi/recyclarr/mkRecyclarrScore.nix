profileName:
let
    mkScorer = profile: ids: score: {
        trash_ids = ids;
        assign_scores_to = [
            {
                name = profile;
                score = score;
            }
        ];
    };
in
rec {
    mkScores = mkScorer profileName;
    mkScore = id: (mkScores [ id ]);
}
