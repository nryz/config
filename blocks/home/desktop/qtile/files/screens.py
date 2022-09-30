from libqtile import bar, layout, widget
from libqtile.config import Screen
from libqtile.log_utils import logger
from libqtile.widget import base

from math import log
from typing import Tuple

import theme

import psutil
import subprocess



class Net(base.ThreadPoolText):
    """
    Displays interface down and up speed


    Widget requirements: psutil_.

    .. _psutil: https://pypi.org/project/psutil/
    """
    orientations = base.ORIENTATION_HORIZONTAL
    defaults = [
        ('format', '{interface}: {down} \u2193\u2191 {up}',
         'Display format of down/upload/total speed of given interfaces'),
        ('interface', None, 'List of interfaces or single NIC as string to monitor, \
            None to display all active NICs combined'),
        ('update_interval', 1, 'The update interval.'),
        ('use_bits', False, 'Use bits instead of bytes per second?'),
        ('prefix', None, 'Use a specific prefix for the unit of the speed.'),
    ]

    def __init__(self, **config):
        base.ThreadPoolText.__init__(self, "", **config)
        self.add_defaults(Net.defaults)

        self.factor = 1000.0
        self.allowed_prefixes = ["", "k", "M", "G", "T", "P", "E", "Z", "Y"]

        if self.use_bits:
            self.base_unit = "b"
            self.byte_multiplier = 8
        else:
            self.base_unit = "B"
            self.byte_multiplier = 1

        self.units = list(map(lambda p: p + self.base_unit, self.allowed_prefixes))

        if not isinstance(self.interface, list):
            if self.interface is None:
                self.interface = ["all"]
            elif isinstance(self.interface, str):
                self.interface = [self.interface]
            else:
                raise AttributeError("Invalid Argument passed: %s\nAllowed Types: List, String, None" % self.interface)
        self.stats = self.get_stats()

    def convert_b(self, num_bytes: float) -> Tuple[float, str]:
        """Converts the number of bytes to the correct unit"""

        num_bytes *= self.byte_multiplier

        if self.prefix is None:
            if num_bytes > 0:
                power = int(log(num_bytes) / log(self.factor))
                power = min(power, len(self.units) - 1)
            else:
                power = 0
        else:
            power = self.allowed_prefixes.index(self.prefix)

        converted_bytes = num_bytes / self.factor**power
        unit = self.units[power]

        return converted_bytes, unit

    def get_stats(self):
        interfaces = {}
        if self.interface == ["all"]:
            net = psutil.net_io_counters(pernic=False)
            interfaces["all"] = {
                    'down': net.bytes_recv,
                    'up': net.bytes_sent,
                    'total': net.bytes_recv + net.bytes_sent,
                }
            return interfaces
        else:
            net = psutil.net_io_counters(pernic=True)
            for iface in net:
                down = net[iface].bytes_recv
                up = net[iface].bytes_sent
                interfaces[iface] = {
                        'down': down,
                        'up': up,
                        'total': down + up,
                    }
            return interfaces

    def _format(self, down, down_letter, up, up_letter, total, total_letter):
        max_len_down = 7 - len(down_letter)
        max_len_up = 7 - len(up_letter)
        max_len_total = 7 - len(total_letter)
        down = '{val:{max_len}.2f}'.format(val=down, max_len=max_len_down)
        up = '{val:{max_len}.2f}'.format(val=up, max_len=max_len_up)
        total = '{val:{max_len}.2f}'.format(val=total, max_len=max_len_total)
        return down[:max_len_down], up[:max_len_up], total[:max_len_total]

    def poll(self):
        ret_stat = []
        try:
            new_stats = self.get_stats()
            for intf in self.interface:
                down = new_stats[intf]['down'] - \
                    self.stats[intf]['down']
                up = new_stats[intf]['up'] - \
                    self.stats[intf]['up']
                total = new_stats[intf]['total'] - \
                    self.stats[intf]['total']

                down = down / self.update_interval
                up = up / self.update_interval
                total = total / self.update_interval
                down, down_letter = self.convert_b(down)
                up, up_letter = self.convert_b(up)
                total, total_letter = self.convert_b(total)
                down, up, total = self._format(
                        down, down_letter,
                        up, up_letter,
                        total, total_letter
                    )
                self.stats[intf] = new_stats[intf]
                ret_stat.append(
                    self.format.format(
                        **{
                            'interface': intf,
                            'down': down + down_letter,
                            'up': up + up_letter,
                            'total': total + total_letter,
                        }))

            return " ".join(ret_stat)
        except Exception as excp:
            logger.error('%s: Caught Exception:\n%s',
                         self.__class__.__name__, excp)




def getMEM():
    return subprocess.check_output(["free | grep Mem | awk '{printf \"%.0f\", $3/$2 * 100.0}'"], shell=True).decode('utf-8').strip() + '%'

def getCPU():
    return "{:.0f}".format(round(psutil.cpu_percent(), 0)) + '%'

def getVolume():
    return subprocess.run("GetVolume", capture_output=True).stdout.decode('utf-8').strip()

#wnet = Net(update_interval=1, prefix='M', format='NET {down}')

screens = [
    Screen(
        top=bar.Bar(
            [ 
                #left
                widget.GroupBox(
                    padding=0,
                    padding_x=4,
                    borderwidth=2,
                    rounded=False,
                    highlight_method='line',

                    foreground=theme.base05,
                    background=theme.barBg,

                    active=theme.base05,
                    inactive=theme.base03,

                    block_highlight_text_color=theme.base05,
                    highlight_color=theme.base08,

                    this_screen_border=theme.barBg,
                    this_current_screen_border=theme.barBg,
                    other_current_screen_border=theme.base03,
                    other_screen_border=theme.base03,

                    urgent_alert_method='text',
                    urgent_border=theme.base0E,
                ),
                widget.CurrentLayout(
                    padding=5,
                    fmt = '[{}]',
                    foreground=theme.base05,
                    background=theme.barBg
                ),
                widget.Chord(
                    foreground=theme.base0A,
                    background=theme.barBg,
                ),


                #centre
                widget.Spacer(), 
                widget.Clock(
                    format='%a %d %b, %H:%M',
                    background=theme.barBg,
                    foreground=theme.base05
                ),
                widget.Spacer(),           


                widget.Spacer(10),
                widget.TextBox(
                    "",
                    fontsize=20,
                    foreground=theme.base05,
                ),
                # widget.Volume(
                #     fmt="{}", 
                #     padding=2, 
                #     max_chars=6,
                #     foreground=theme.base05,
                #     background=theme.barBg,
                #     get_volume_command="GetVolume",
                #     volume_down_command="DecreaseVolume",
                #     volume_up_command="IncreaseVolume",
                # ), 
                widget.GenPollText(
                    fmt="{}",
                    func=getVolume, 
                    update_interval=0.2,
                    padding=2,
                    foreground=theme.base05,
                    background=theme.barBg
                ),
                widget.Spacer(10),

                widget.Spacer(10),
                widget.TextBox(
                    "",
                    fontsize=20,
                    foreground=theme.base05,
                ),
                widget.GenPollText(
                    fmt="{}",
                    func=getCPU, 
                    update_interval=1,
                    padding=2,
                    foreground=theme.base05,
                    background=theme.barBg
                ),
                widget.Spacer(10),

                widget.Spacer(10),
                widget.TextBox(
                    '',
                    fontsize=20,
                    foreground=theme.base05,
                ),
                widget.GenPollText(
                    fmt="{}",
                    func=getMEM, 
                    padding=2,
                    update_interval=1,
                    foreground=theme.base05,
                    background=theme.barBg,
                ),
                widget.Spacer(10),
            ],
            theme.barSize,
            background=theme.barBg,
            margin=[0, 0, 0, 0],
            border_width=[0, 0, 2, 0],
            border_color=theme.barBorderBg,
        ),
    ),
]

widget_defaults = dict(
    font='Fira Code',
    fontsize=12,
    padding=5,
)
extension_defaults = widget_defaults.copy()
