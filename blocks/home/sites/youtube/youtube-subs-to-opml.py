# youtube-subs-to-opml.py -- Convert YouTube subscriptions exported
# via Google Takeout into OPML
#
# See reddit.com/r/youtube/comments/jqlks2/where_did_opml_export_go/gcdii2n
#   1. Go to youtube homepage
#   2. Click top right icon, "Your Data in Youtube"
#   3. Click "Show More"
#   4. Click "Download Youtube data"
#   5. This takes you to a similar screen as the other google takeout one,
#   but only for youtube data. The subscription info here is more up to date.
#
# Usage:
# python3 youtube-subs-to-opml.py 'subscriptions.json'  > yt-subs.opml


def json_parse(filename):
    import json
    from xml.sax.saxutils import escape

    channels = []

    with open(filename, "r+") as fp:
        subs = json.load(fp.read())
        for sub in subs:
            channels.append(
                (
                    escape(sub["snippet"]["title"]),
                    escape(sub["snippet"]["resourceId"]["channelId"]),
                )
            )

    return channels


def csv_parse(filename):
    import csv
    from xml.sax.saxutils import escape

    channels = []

    with open(filename, "r+") as fp:
        reader = csv.reader(fp, delimiter=",", quotechar='"')
        next(reader)
        for row in reader:
            if row:
                channels.append((escape(row[2]), escape(row[0])))

    return channels


if __name__ == "__main__":
    from argparse import ArgumentParser
    from os import path

    parser = ArgumentParser(description="Generate youtube subscriptions OPML")
    parser.add_argument("file", help="filename to parse")
    args = parser.parse_args()

    ext = path.splitext(args.file)[-1].lower()

    if ext == ".csv":
        channels = csv_parse(args.file)
    elif ext == ".json":
        channels = json_parse(args.file)
    else:
        print(f"Error, unknown extension in provided filename: {args.file}")

    print(
        """<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
<body>
    <outline title="YouTube" text="YouTube">
"""
    )

    for channel in channels:
        print(
            f"""        <outline title="{channel[0]}"
            text="{channel[0]}"
            xmlUrl="https://www.youtube.com/feeds/videos.xml?channel_id={channel[1]}"
            htmlUrl="https://www.youtube.com/channel/{channel[1]}" />
"""
        )

    print(
        """
    </outline>
</body>
</opml>
"""
    )


# Open source under BSD-2-Clause
# <https://opensource.org/licenses/BSD-2-Clause>
#
# Copyright 2021 Richard Brooksby <rptb1>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
