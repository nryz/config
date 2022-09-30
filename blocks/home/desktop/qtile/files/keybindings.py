from libqtile import layout
from libqtile.config import Click, Drag, Key, KeyChord, ScratchPad
from libqtile.lazy import lazy

import os

from groups import groups 
from screens import screens

from defaults import terminal 

mod = "mod4"

def makeWindowModeKeybindings():
    bindings = []

    bindings += [
            Key([], "Super_L", lazy.ungrab_all_chords()),

            Key([], "h", lazy.screen.prev_group(),      desc="Move to next group"),
            Key([], "l", lazy.screen.next_group(),      desc="Move to prev group"),

            Key([], "t", lazy.next_layout(),            desc="Toggle between layouts"),
            Key(["shift"], "t", lazy.prev_layout(),     desc="Toggle between layouts"),
            
            Key([], "u", lazy.next_urgent,                          desc="Move focus to next urgent window"),

            Key([], "g", lazy.layout.grow(),                        desc="Grow window"),
            Key([], "s", lazy.layout.shrink(),                      desc="Shrink window"),
            Key([], "n", lazy.layout.normalize(),                   desc="Reset all window sizes"),
            Key([], "m", lazy.layout.maximize(),                    desc="Reset all window sizes"),

            Key([], "Return", lazy.window.toggle_fullscreen()),
            Key([], "f", lazy.window.toggle_floating()),

            Key([], "o", lazy.window.down_opacity(),                        desc="Decrease the windows opacity"),
            Key([], "p", lazy.window.up_opacity(),                        desc="Increase the windows opacity"),
        ] 
    return bindings

keys = [
    #media
    Key([], "XF86AudioMute", lazy.spawn("ToggleVolume"), desc="Toggle mute"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("DecreaseVolume"), desc="Lower volume"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("IncreaseVolume"), desc="Raise volume"),

    # Key([], "XF86AudioMute", lazy.spawn("amixer -q set Master toggle"), desc="Toggle mute"),
    # Key([], "XF86AudioLowerVolume", lazy.spawn("amixer set Master 5%-"), desc="Lower volume"),
    # Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer set Master 5%+"), desc="Raise volume"),

    Key([mod], "u", lazy.group['scratchpad'].dropdown_toggle('sway-launcher-desktop'), desc="Spawn launcher"),
    Key([mod], "t", lazy.group['scratchpad'].dropdown_toggle('term')),
    Key([mod], "p", lazy.group['scratchpad'].dropdown_toggle('passwords')),

    Key([mod], "i", lazy.next_layout(),            desc="Toggle between layouts"),
    Key([mod, "shift"], "i", lazy.prev_layout(),     desc="Toggle between layouts"),

    Key([mod], "space", lazy.screen.toggle_group(),         desc="Toggle last visited group"),

    Key([mod], "Tab", lazy.group.focus_back(),                      desc="Move focus to other window"),

    Key([mod], "Return", lazy.spawn(terminal),     desc="Launch terminal"),

    Key([mod], "h", lazy.layout.left(),            desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(),           desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(),            desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(),              desc="Move focus up"),

    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),         desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),         desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(),           desc="Move window up"),

    Key([mod], "w", lazy.window.kill(),            desc="Kill focused window"),

    Key([mod], "z", lazy.to_screen(0),            desc="Go to screen 0"),
    Key([mod], "x", lazy.to_screen(1),            desc="Go to screen 1"),


    KeyChord([mod], "e", makeWindowModeKeybindings(), mode=True, name="[window]"),
]


for i in groups:
    if i.name.isdigit():
        keys.extend([
            Key([mod], i.name, lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name)),

            Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
                 desc="move focused window to group {}".format(i.name)),
        ])

# for g in groups:
#     if g.position >= 0 and g.position <= 9:
#         keys += [Key([mod], str(g.position), lazy.group[g.name].toscreen(), desc="Switch to group {}".format(g.name))]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]
