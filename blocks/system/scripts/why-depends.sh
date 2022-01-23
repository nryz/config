#! /usr/bin/env nix-shell
#! nix-shell -i bash -p graphviz imagemagick coreutils fzf

# Drv that depends on the thing in question is the first argument
DRV="$1"
# Write the graph into a tempfile for further processing
GRAPH_FILE="$( mktemp )"
nix-store -q --graph "$DRV" > "$GRAPH_FILE"

# Dependency is either the second argument or specified interactively. Use sed
# to find all drvs mentioned in the graph file, fzf to fuzzy-filter the list.
DEPENDENCY="${2:-$(sed -n 's/^"\([^"]*\)".*/\1/p' "$GRAPH_FILE" | sort | uniq | fzf)}"
echo "Searching for paths from $DEPENDENCY to $DRV in $GRAPH_FILE"

# Use dijkstra to find the paths, dot to render and imagemagick to display.
# https://github.com/NixOS/nix/issues/1918
dijkstra -da "$DEPENDENCY" "$GRAPH_FILE" | gvpr -c 'N[dist>1000.0]{delete(NULL, $)}' | dot -Tsvg | display
rm "$GRAPH_FILE"

