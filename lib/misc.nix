{lib}:
with lib; {
  hasAnyAttrs = l: attr:
    !(lib.mutuallyExclusive l (lib.mapAttrsToList (n: v: n) attr));
}
