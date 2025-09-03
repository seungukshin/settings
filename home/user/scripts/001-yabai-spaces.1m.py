#!/usr/bin/env python3

# <xbar.title>Yabai Spaces</xbar.title>
# <xbar.author>Seunguk Shin</xbar.author>
# <xbar.version>v0.1</xbar.version>

import subprocess
import json

shorten = {
    'MSTeams': 'Teams',
    'Microsoft Teams': 'Teams',
    'Microsoft Outlook': 'Outlook',
    'Hammerspoon': 'HS',
}

def main() -> None:
    try:
        stdout = subprocess.check_output(['/opt/homebrew/bin/yabai', '-m', 'query', '--spaces']).decode("utf-8")
    except CalledProcessError as e:
        print(e)
    spaces = json.loads(stdout)
    labels = {}
    for s in spaces:
        labels[s['label']] = s['index']
    labels = dict(sorted(labels.items()))

    try:
        stdout = subprocess.check_output(['/opt/homebrew/bin/yabai', '-m', 'query', '--windows']).decode("utf-8")
    except CalledProcessError as e:
        print(e)
    windows = json.loads(stdout)
    apps = {}
    for w in windows:
        space = w['space']
        if not space in apps:
            apps[space] = []
        apps[space].append(w['app'])

    output = ''
    for l in labels:
        output = output + l.split('-')[1] + '['
        space = labels[l]
        first = True
        if space in apps:
            for a in apps[space]:
                if first:
                    first = False
                else:
                    output = output + ','
                if a in shorten:
                    output = output + shorten[a]
                else:
                    output = output + a
        output = output + ']'
    print(output)
    return

main()
