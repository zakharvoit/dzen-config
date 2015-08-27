#!/usr/bin/env python3

from sys import argv, stdout, stderr, exit
import select

if len(argv) != 4:
    stderr.write("Usage ./status.py config_file screen_width font_size\n")
    exit(1)

def parse(format_str):
    result = []
    i = 0
    start_pipe = -1
    files = []
    while i < len(format_str):
        if format_str[i] == '$' \
           and i < len(format_str) - 1 \
           and format_str[i + 1] == '(':
            i += 1
            start_pipe = i + 1
        elif format_str[i] == ')' and start_pipe != -1:
            name = format_str[start_pipe:i]
            f = open(name, "r")
            files.append(f)
            result.append("$(" + str(f.fileno()) + ")")
            start_pipe = -1
        elif start_pipe == -1:
            result.append(format_str[i])
        i += 1
    return (files, "".join(result))

filename = argv[1]
screen_width = int(argv[2])
font_size = int(argv[3])
with open(filename, "r") as config:
    format_str = config.readline().strip()
    files, left_format_str = parse(format_str)
    format_str = config.readline().strip()
    files_right, right_format_str = parse(format_str)
    files += files_right

epoll = select.epoll()
by_fileno = {}
status = {}
for f in files:
    by_fileno[f.fileno()] = f
    epoll.register(f.fileno(), select.EPOLLIN | select.EPOLLET)

def real_len(s):
    in_tag = False
    i = 0
    ans = 0
    while i < len(s):
        if s[i] == '^':
            i += 1
            while i < len(s) and ('a' <= s[i] <= 'z'):
                i += 1
                if i < len(s) and s[i] == '(':
                    in_tag = True
        elif not in_tag:
            ans += 1
        elif s[i] == ')':
            in_tag = False
        i += 1
    return ans

def print_status():
    status_left = left_format_str
    status_right = right_format_str
    for f in files:
        s = status[f.fileno()] if f.fileno() in status else "..."
        status_left = status_left.replace("$(" + str(f.fileno()) + ")", s)
        status_right = status_right.replace("$(" + str(f.fileno()) + ")", s)
    align = screen_width - font_size * real_len(status_left) \
            - font_size * real_len(status_right)
    print(status_left + "^p(" + str(align) + ")" + status_right)
    stdout.flush()

while True:
    print_status()
    events = epoll.poll(1)
    for fileno, event in events:
        if event & select.EPOLLIN:
            status[fileno] = by_fileno[fileno].readline().strip()
