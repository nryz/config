from libqtile import layout
from libqtile.config import Group, Match, ScratchPad, DropDown

import theme
from defaults import terminal

from custom.layout.max import Max


dropdown_opacity=0.9

layout_style = {
    #'font': 'font',
    'margin': theme.gapSize,
    'border_width': theme.borderSize,
    'border_normal': theme.base02,
    'border_focus': theme.base08,
    'single_border_width': theme.borderSize,
    'single_margin': theme.gapSize,
}

monad_style = {
    'new_client_position': 'bottom',
}

layouts = [
    layout.MonadTall( **layout_style, **monad_style),
    #layout.Max(**layout_style),
    Max(**layout_style),
    layout.Floating(**layout_style),
]


groups = [Group("1")]
groups += [Group("2", layout="max", matches=[Match(wm_class=["mpv"])])]
groups += [Group(i) for i in "3456789"]


groups += [ ScratchPad("scratchpad", [ 
    DropDown(
        "sway-launcher-desktop", 
        terminal + " -e sway-launcher-desktop",
        x=0.35,
        y=0.25,
        width=0.3,
        height=0.5,
        opacity=dropdown_opacity,
        ),
    DropDown(
        "term", 
        terminal,
        x=0.2,
        y=0.25,
        width=0.6,
        height=0.5,
        opacity=dropdown_opacity,
        ),
    DropDown(
        "passwords", 
        terminal + " -e fzfPassage show --clip",
        x=0.35,
        y=0.3,
        width=0.3,
        height=0.4,
        opacity=dropdown_opacity,
        ),
])]
