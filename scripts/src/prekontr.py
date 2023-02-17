import contextlib
import enum
import io
import os
import string
import subprocess
import sys
from types import TracebackType
from typing import Dict, List, Tuple, Callable, Union, Optional, Type

import click
import colorama
from colorama import Fore, Style

GCC_FLAGS = [
    "-std=c99",
    "-pedantic",
    "-Wall",
    "-g",
    "-o ${out}",
    "${in}"
]

VALGRIND_FLAGS = [
    "--leak-check=full",
    "--show-reachable=yes",
    "-q",
    "./${in}"
]

CLANG_TIDY_FLAGS = [
    "-checks='*'",
    "-quiet",
    "${in}",
    "--"
]

CHAR_SUCCESS = "✔"
CHAR_WARNING = "⚠"
CHAR_ERROR = "✕"

CODING_STYLE = {
    'Language': 'Cpp',
    'BreakBeforeBraces': 'Custom',
    'BraceWrapping': {
        'AfterClass': True,
        'AfterControlStatement': False,
        'AfterEnum': True,
        'AfterFunction': True,
        'AfterNamespace': True,
        'AfterObjCDeclaration': True,
        'AfterStruct': True,
        'AfterUnion': True,
        'BeforeCatch': False,
        'BeforeElse': False,
        'IndentBraces': False
    },
    'ColumnLimit': 0,
    'ContinuationIndentWidth': 8,
    'IndentWidth': 4,
    'TabWidth': 4,
    'IndentCaseLabels': False,
    'PointerAlignment': 'Right',
    'DerivePointerAlignment': False,
    'SpacesInParentheses': False,
    'SpacesInSquareBrackets': False,
    'SpaceBeforeAssignmentOperators': True,
    'SpaceBeforeParens': 'ControlStatements',
    'SpaceInEmptyParentheses': False,
    'SpaceAfterCStyleCast': True,
    'SpacesBeforeTrailingComments': 1,
    'SpacesInContainerLiterals': False,
    'SpacesInCStyleCastParentheses': False,
    'AllowShortBlocksOnASingleLine': False,
    'AllowShortCaseLabelsOnASingleLine': False,
    'AllowShortFunctionsOnASingleLine': 'None',
    'AllowShortIfStatementsOnASingleLine': False,
    'AllowShortLoopsOnASingleLine': False,
    'UseTab': 'Never',
    'AlignAfterOpenBracket': 'DontAlign',
    'AlignConsecutiveAssignments': False,
    'AlignConsecutiveDeclarations': False,
    'Cpp11BracedListStyle': False,
    'AlignEscapedNewlinesLeft': True,
    'AlignOperands': False,
    'AlignTrailingComments': True,
    'AllowAllParametersOfDeclarationOnNextLine': True,
    'AlwaysBreakAfterReturnType': 'None',
    'AlwaysBreakBeforeMultilineStrings': False,
    'AlwaysBreakTemplateDeclarations': True,
    'BinPackArguments': False,
    'BinPackParameters': False,
    'ExperimentalAutoDetectBinPacking': True,
    'IndentWrappedFunctionNames': False,
    'KeepEmptyLinesAtTheStartOfBlocks': False,
    'MaxEmptyLinesToKeep': 1,
    'NamespaceIndentation': 'None',
    'ReflowComments': False,
    'SortIncludes': False,
    'Standard': 'Auto'
}


class Status(enum.Enum):
    SUCCESS = 0
    ERROR = 1
    WARNING = 2


class FailedTestError(Exception):
    pass


def build_cmd(flags: List[str], vars_: Dict[str, str]) -> str:
    return " ".join(string.Template(f).substitute(vars_) for f in flags)


def build_paths(input: str, output: str) -> Dict[str, Union[Dict[str, str], str]]:
    return {
        "gcc": {"in": input, "out": output or os.path.splitext(input)[0]},
        "valgrind": {"in": output or os.path.splitext(input)[0]},
        "clang-tidy": {"in": input}
    }


class ansi_format:
    def __init__(self, *args: str) -> None:
        self.codes = args

    def __enter__(self) -> None:
        for code in self.codes:
            sys.stdout.write(code)

    def __exit__(
            self,
            exc_type: Optional[Type[BaseException]],
            exc_val: Optional[BaseException],
            exc_tb: Optional[TracebackType]
    ) -> None:
        sys.stdout.write(colorama.Style.RESET_ALL)


def gcc_compile(flags: List[str], vars_: Dict[str, str]) -> Tuple[Status, str]:
    cmd = "gcc " + build_cmd(flags, vars_)
    p = subprocess.run(cmd, text=True, shell=True, capture_output=True)

    if not p.returncode and not p.stderr:
        return Status.SUCCESS, ""

    if not p.returncode:
        return Status.WARNING, p.stderr

    return Status.ERROR, p.stderr


def valgrind(flags: List[str], vars_: Dict[str, str]) -> Tuple[Status, str]:
    cmd = f"valgrind --log-fd=9 {build_cmd(flags, vars_)} " \
          f"9>&1 1>/dev/null 2>/dev/null"
    p = subprocess.run(cmd, text=True, shell=True, capture_output=True)
    return (Status.SUCCESS if not p.stdout else Status.ERROR), p.stdout


def clang_tidy(flags: List[str], vars_: Dict[str, str]) -> Tuple[Status, str]:
    cmd = f"clang-tidy {build_cmd(flags, vars_)}"
    p = subprocess.run(cmd, text=True, shell=True, capture_output=True)
    stdout = "\n".join(line.replace(os.getcwd() + "/", "") for line in p.stdout.split("\n"))
    return (Status.WARNING if p.stdout else Status.SUCCESS), stdout


def run_test(
        msg: str,
        test_f: Callable[[List[str], Dict[str, str]], Tuple[Status, str]],
        args: Dict[str, Union[List[str], Dict[str, str]]],
        critical: bool = False,
) -> Status:
    with ansi_format(Fore.MAGENTA, Style.BRIGHT):
        print(msg, end="")
    status, output = test_f(**args)

    if status == Status.SUCCESS:
        with ansi_format(Fore.GREEN, Style.BRIGHT):
            print(CHAR_SUCCESS)

    if status == Status.WARNING:
        with ansi_format(Fore.YELLOW, Style.BRIGHT):
            print(CHAR_WARNING, "\n")

        with ansi_format(Fore.YELLOW):
            for line in output.split("\n"):
                print(f"    {line}")

    if status == Status.ERROR:
        with ansi_format(Fore.RED, Style.BRIGHT):
            print(CHAR_ERROR, "\n")

        with ansi_format(Fore.LIGHTRED_EX):
            for line in output.split("\n"):
                print(f"    {line}")

    if critical and status == Status.ERROR:
        raise FailedTestError

    return status


def run_all(filename: str, output: str, error: bool) -> bool:
    paths = build_paths(filename, output)

    tests = [
        {
            "_name": "GCC",
            "msg": "Compiling with GCC... ",
            "test_f": gcc_compile,
            "args": {
                "flags": GCC_FLAGS,
                "vars_": paths["gcc"]
            },
            "critical": True
        },
        {
            "_name": "Valgrind",
            "msg": "Checking with Valgrind... ",
            "test_f": valgrind,
            "args": {
                "flags": VALGRIND_FLAGS,
                "vars_": paths["valgrind"]
            },
        },
        {
            "_name": "Clang-Tidy",
            "msg": "Checking with Clang-Tidy... ",
            "test_f": clang_tidy,
            "args": {
                "flags": CLANG_TIDY_FLAGS,
                "vars_": paths["clang-tidy"]
            },
        }
    ]

    with ansi_format(Fore.BLUE, Style.BRIGHT):
        print(f"\nTests to run: ", end="")

    with ansi_format(Fore.GREEN, Style.BRIGHT):
        print(', '.join(str(t['_name']) for t in tests))

    with ansi_format(Fore.BLUE, Style.BRIGHT):
        print(f"File: ", end="")

    with ansi_format(Fore.GREEN, Style.BRIGHT):
        print(f"{filename}\n")

    success = True

    for i, test in enumerate(tests, start=1):
        with ansi_format(Fore.YELLOW, Style.BRIGHT):
            print(f"{i}. ", end="")
        try:
            status = run_test(**{k: v for k, v in test.items() if not k.startswith("_")})
            status = Status.ERROR if error and status == Status.WARNING else status

        except FailedTestError:
            name = test.get('_name', '<unnamed>')
            with ansi_format(Fore.CYAN, Style.BRIGHT):
                print(f"Critical test {name} failed, skipping other tests...")
            success = False
            break

        if status == Status.ERROR:
            success = False

    if success:
        with ansi_format(Fore.LIGHTGREEN_EX, Style.BRIGHT):
            print("\n**Test passed!**\n")
    else:
        with ansi_format(Fore.RED, Style.BRIGHT):
            print("\n**Test failed!**\n")

    return success


@click.command()
@click.argument("filename")
@click.option("-o", "--output")
@click.option("-s", "--silent", is_flag=True)
@click.option("-e", "--error", is_flag=True)
def main(filename: str, output: str, silent: bool, error: bool) -> None:
    if silent:
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            success = run_all(filename, output, error)
        if not success:
            print(out.getvalue(), end="")
    else:
        run_all(filename, output, error)


if __name__ == '__main__':
    main()
