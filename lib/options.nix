{lib}:
with lib; rec {
  mkOpt = type: default:
    mkOption {
      inherit type default;
    };

  mkOpt' = type:
    mkOption {
      inherit type;
    };

  mkOptColour = default:
    mkOption {
      inherit default;
      type = types.str;
    };

  mkOptColour' = mkOption {
    type = types.str;
  };
}
