from libqtile import hook, layout
from libqtile.config import Match

from groups import groups, layout_style
from screens import screens


floating_layout = layout.Floating(**layout_style, 
        float_rules=[
            # Run the utility of `xprop` to see the wm class and name of an X client.
            # *layout.Floating.default_float_rules,
            Match(wm_type='utility'),
            Match(wm_type='notification'),
            Match(wm_type='toolbar'),
            Match(wm_type='splash'),
            Match(wm_type='dialog'),
            Match(wm_class='file_progress'),
            Match(wm_class='confirm'),
            Match(wm_class='dialog'),
            Match(wm_class='download'),
            Match(wm_class='error'),
            Match(wm_class='notification'),
            Match(wm_class='splash'),
            Match(wm_class='toolbar'),
            Match(func=lambda c: c.has_fixed_size()),
            Match(func=lambda c: c.has_fixed_ratio()),
            Match(wm_class='confirmreset'),
            Match(wm_class='confirm'),
            Match(wm_class='download'),
            Match(wm_class='error'),
            Match(wm_class='notification'),
            Match(wm_class='popup_menu'),
            Match(wm_class='makebranch'),
            Match(wm_class='maketag'),
            Match(wm_class='ssh-askpass'),
            Match(wm_class='.blueman-manager-wrapped'),
            Match(title='branchdialog'),
            Match(title='pinentry'),
            Match(title='Steam Guard - Computer Authorization Required'),
        ]
)

