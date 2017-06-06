"""
This script will build the Scavenge and Survive gamemode and handle incrementing the build number
while developing. It's important that if you're an end-user that you do not increment the build
number as you'll get out of sync with the main repository.

This script requires Python 3 so if you plan on using it, make sure you have that installed first.
"""

import argparse
import io
import os
import json
import re
import subprocess


# NOTE:
#
# Scroll down to "def main():" to follow the script in chronological order.
#


def build_project(config, increment=True):
    """
    build_project will compile the main source file, the `increment` arg will determine whether
    or not to increment the build number. Most of the time you'll want to increment your build
    numbers every time so this is rarely used.
    """

    print("Building project...", flush=True)

    # open up the BUILD_NUMBER file and read the build number, this should only
    # ever be changed by this script and never by hand or another program.
    build_number = 0
    with io.open("BUILD_NUMBER", 'r') as filehandle:
        build_number = int(filehandle.read())

    if increment:
        build_number = build_number + 1
        with io.open("BUILD_NUMBER", 'w') as filehandle:
            filehandle.write(str(build_number))

    cmd = config["cmd"]
    constants = config["constants"]

    print("BUILD", build_number, flush=True)
    print("COMPILER", cmd, flush=True)
    print("CONSTANTS", constants, flush=True)

    # This is the part that actually runs the compiler, the compiler is called
    # pawncc NOT Pawno! Pawno is the IDE but you can compile scripts without
    # ever touching Pawno because the compilation is actually always performed
    # by pawncc which is a simple terminal application with a variety of args.
    # The arguments being passed here include:
    # '-D': tells the compiler the working directory
    # 'ScavengeSurvive.pwn': the source file we want to compile
    # '-;+': enforces the use of semicolons, just a SA:MP tradition really!
    # '-(+': enforces the use of open brackets on functions and if statements
    # '-\+': defines the escape character as '\', pretty standard
    # '-d3': sets the debug output as level 3, mostly just for crashdetect
    # '-e': tells the compiler to write all output to a file instead of stdout
    # (that ^last one^ is important!)
    ret = subprocess.call(
        cmd +
        ["-e../errors"] +
        [k + "=" + v for k, v in constants])

    # This extra part at the end will iterate the `constants` list and add them
    # to the command with a '=' after each. This is because pawncc accepts
    # definitions in the command such as "MY_CONSTANT=3" then if you have a
    # compile-time check in your source code such as "#if MY_CONSTANT == 3"
    # then this suddenly becomes very useful for passing external values and
    # flags directly into source code at compile time *without* needing to
    # modify the source code itself.

    # Remember that -e flag that's important? Here's why:
    # Sublime Text will extract file paths and line numbers from compilation
    # output so you can double-click the errors in the output console to jump
    # to the specific file and line and now it even shows inline messages in
    # the code which is super useful!
    # The problem is that because pawncc context is inside the ./gamemodes/
    # directory so all the errors and warnings are relative to that directory
    # but the Sublime Text context is in the project directory so the output
    # from the compiler will contain paths that don't start from the correct
    # directory.

    # The fix for this is to write all errors out to the file then after
    # compilation, read that file and correct the path. There is also a check
    # here that ensures the missing directory isn't added incorrectly as
    # warnings and errors from external includes will have the full directory
    # path (such as C:\Pawno\include\foreach.inc)
    if os.path.exists("errors"):
        with io.open("errors", 'r') as filehandle:
            print("Build result:", ret)
            for line in filehandle:
                if re.match("[a-zA-Z]:\\.*", line):
                    print(line, end='')

                else:
                    print("gamemodes/" + line, end='')
        os.remove("errors")

    else:
        print("Build successful!")


def load_config():
    """
    Loads the build configuraion JSON file. If it's not found, the defaults below are used.
    """

    config = {
        "cmd": [
            "pawncc",
            "-Dgamemodes/",
            "ScavengeSurvive.pwn",
            "-i/home/southclaws/bin/include",
            "-Z",
            "-;+",
            "-(+",
            "-\\+",
            "-d3"
        ],
        "branch": "master",
        "constants": {
            "BUILD_MINIMAL": "",
        }
    }

    try:
        with io.open("build-config.json") as filehandle:
            config = json.load(filehandle)

    except IOError:
        print("Could not load build-config.json")

    return config


def main():
    """
    Script entry point.
    Here, some arguments are set up:
    - mode: whether the script should compile the entire project or a single file
    - increment: should the script increment the build number?
    - input: if 'mode' is 'file' then this arg specifies the file to compile
    then the script calls either build_project or build_file.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('mode', help="mode: project|file")
    parser.add_argument('--increment', action="store_true")
    parser.add_argument('--input', type=str, default='')
    args = parser.parse_args()

    config = load_config()

    if args.mode == "project":
        build_project(config, args.increment)

    else:
        print("the current only supported mode is 'project'")


if __name__ == '__main__':
    main()
