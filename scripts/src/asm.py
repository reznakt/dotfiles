import os
import shutil
import subprocess
import tempfile

import sys
import time

CODES = {
    132: "SIGILL",
    133: "SIGTRAP",
    134: "SIGABRT",
    136: "SIGFPE",
    138: "SIGBUS",
    139: "SIGSEGV",
    158: "SIGXCPU",
    159: "SIGXFSZ"
}


def main() -> None:
    if len(sys.argv) != 2:
        print("Error: Invalid arguments")
        return

    path = sys.argv[1]

    if not os.path.isfile(path):
        print("Error: file not found")
        return

    with tempfile.TemporaryDirectory() as tmpdir:
        shutil.copy(path, os.path.join(tmpdir, "tmp.asm"))

        subprocess.call(f"nasm -f elf64 -Wall -Werror -o {os.path.join(tmpdir, 'tmp.o')} "
                        f"{os.path.join(tmpdir, 'tmp.asm')}", shell=True)

        subprocess.call(f"ld {os.path.join(tmpdir, 'tmp.o')} "
                        f"-o {os.path.join(tmpdir, 'tmp')}", shell=True)

        timer = time.perf_counter()
        exit_c = subprocess.call(f"{os.path.join(tmpdir, 'tmp')}", shell=True)
        print(
            f"[Finished in {(time.perf_counter() - timer)*1000:.2f} ms with "
            f"exit code {exit_c}", end="")
        if exit_c in CODES:
            print(f" (interrupted by signal: {CODES[exit_c]})]")
        else:
            print("]")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
