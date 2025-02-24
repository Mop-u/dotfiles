{inputs}:
{
    setTarget = override: rec {
        inherit override;
        system = override.system or "x86_64-linux";
    };
}