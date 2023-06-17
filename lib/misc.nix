{lib}:
with lib; {
  hasAnyAttrs = l: attr:
    !(lib.mutuallyExclusive l (lib.mapAttrsToList (n: v: n) attr));

  mergeAttrsRecursive = a: b: let
    merge = a: b:
      lib.zipAttrsWith (
        n: v:
          if (builtins.length v) == 1
          then builtins.elemAt v 0
          else if (builtins.length v) == 2
          then let
            v0 = builtins.elemAt v 0;
            v1 = builtins.elemAt v 1;
          in
            if (builtins.isList v0) && (builtins.isList v1)
            then (lib.flatten v)
            else if (builtins.isAttrs v0) && (builtins.isAttrs v1)
            then merge v0 v1
            else v1
          else v
      ) [a b];
  in
    merge a b;
}
