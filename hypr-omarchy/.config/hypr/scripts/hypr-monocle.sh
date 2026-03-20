#!/usr/bin/env bash
# Toggles between a tiled layout and a "monocle" layout (grouped tabs) for all windows on the active workspace

WS=$(hyprctl activewindow -j | jq '.workspace.id')
if [[ "$WS" == "null" || -z "$WS" ]]; then
    exit 0
fi

# Check if any window in the current workspace is grouped
IS_GROUPED=$(hyprctl clients -j | jq -e "[.[] | select(.workspace.id == $WS and (.grouped | length) > 0)] | length > 0")

if [[ "$IS_GROUPED" == "true" ]]; then
    # Ungroup everything
    for addr in $(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $WS and (.grouped | length) > 0) | .address"); do
        hyprctl dispatch focuswindow address:$addr
        hyprctl dispatch moveoutofgroup
    done
else
    # Group all windows
    ACTIVE_ADDR=$(hyprctl activewindow -j | jq -r '.address')
    
    # Toggle active window into a group
    hyprctl dispatch togglegroup
    
    # Drag all other windows into the group
    # We loop up to 5 times trying all directions to catch windows in complex dwindle trees
    for i in {1..5}; do
        OTHER_ADDRS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $WS and (.grouped | length) == 0 and .mapped == true) | .address")
        if [[ -z "$OTHER_ADDRS" ]]; then
            break
        fi
        
        for addr in $OTHER_ADDRS; do
            hyprctl dispatch focuswindow address:$addr
            hyprctl dispatch moveintogroup l
            hyprctl dispatch moveintogroup r
            hyprctl dispatch moveintogroup u
            hyprctl dispatch moveintogroup d
        done
    done
    
    # Return focus to the originally active window
    hyprctl dispatch focuswindow address:$ACTIVE_ADDR
fi
