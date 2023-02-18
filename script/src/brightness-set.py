import string
import subprocess
import sys

SET_CMD = 'gdbus call --session --dest org.gnome.SettingsDaemon.Power --obje' \
          'ct-path /org/gnome/SettingsDaemon/Power --method org.freedesktop.' \
          'DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightn' \
          'ess "<int32 $level>"'


def set_brightness(level: int) -> bool:
    if not 0 <= level <= 100:
        raise ValueError("Level must be between 0 and 100")

    process = subprocess.Popen(
        args=string.Template(SET_CMD).substitute({"level": level}),
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)

    return process.stdout.read() == b"()\n" and not process.stderr.read()


if __name__ == '__main__':
    try:
        set_brightness(int(sys.argv[1]))
    except Exception as e:
        print(e)
