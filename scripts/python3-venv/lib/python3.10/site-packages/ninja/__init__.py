# -*- coding: utf-8 -*-
import argparse
from datetime import datetime
import os
import platform
import subprocess
import sys

from ._version import get_versions

from mongo_tooling_metrics.lib.top_level_metrics import NinjaToolingMetrics

__version__ = get_versions()['version']
del get_versions

try:
    from .ninja_syntax import Writer, escape, expand  # noqa: F401
except ImportError:
    # Support importing `ninja_syntax` from the source tree
    if not os.path.exists(
            os.path.join(os.path.dirname(__file__), 'ninja_syntax.py')):
        sys.path.insert(0, os.path.abspath(os.path.join(
            os.path.dirname(__file__), '../../Ninja-src/misc')))
    from ninja_syntax import Writer, escape, expand  # noqa: F401

DATA = os.path.join(os.path.dirname(__file__), 'data')

# Support running tests from the source tree
if not os.path.exists(DATA):
    from skbuild.constants import CMAKE_INSTALL_DIR as SKBUILD_CMAKE_INSTALL_DIR
    from skbuild.constants import set_skbuild_plat_name

    if platform.system().lower() == "darwin":
        # Since building the project specifying --plat-name or CMAKE_OSX_* variables
        # leads to different SKBUILD_DIR, the code below attempt to guess the most
        # likely plat-name.
        _skbuild_dirs = os.listdir(os.path.join(os.path.dirname(__file__), '..', '..', '_skbuild'))
        if _skbuild_dirs:
            _likely_plat_name = '-'.join(_skbuild_dirs[0].split('-')[:3])
            set_skbuild_plat_name(_likely_plat_name)

    _data = os.path.abspath(os.path.join(
        os.path.dirname(__file__), '..', '..', SKBUILD_CMAKE_INSTALL_DIR(), 'src/ninja/data'))
    if os.path.exists(_data):
        DATA = _data

BIN_DIR = os.path.join(DATA, 'bin')


def _program(name, args):
    return subprocess.call([os.path.join(BIN_DIR, name)] + args, close_fds=False)

def get_ninja_parser():
    """Return a clone ninja command-line parser for this version of ninja."""
    parser = argparse.ArgumentParser()

    # Flags
    parser.add_argument('--version', action='store_true')
    parser.add_argument('-v', '--verbose', action='store_true')
    parser.add_argument('--quiet', action='store_true')

    parser.add_argument('-n', action='store_true')

    # Options
    parser.add_argument('-C')
    parser.add_argument('-f')

    parser.add_argument('-j')
    parser.add_argument('-k')
    parser.add_argument('-l')

    # Options that can be specified multiple times
    parser.add_argument('-d', action='append')
    parser.add_argument('-t', action='append')
    parser.add_argument('-w', action='append')

    return parser

def ninja():
    parser=get_ninja_parser()
    known_args, unknown_args = parser.parse_known_args(sys.argv[1:]) if isinstance(
                parser, argparse.ArgumentParser) else parser.parse_args(sys.argv[1:])
    with open(".ninja_last_command_line_targets.txt", 'w') as f:
        f.write('\n'.join(unknown_args))
    NinjaToolingMetrics.register_metrics(utc_starttime=datetime.utcnow(), parser=get_ninja_parser())
    raise SystemExit(_program('ninja', sys.argv[1:]))
