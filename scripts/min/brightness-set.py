import string,subprocess,sys
SET_CMD='gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.freedesktop.DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightness "<int32 $level>"'
def set_brightness(level):
	A=level
	if not 0<=A<=100:raise ValueError('Level must be between 0 and 100')
	B=subprocess.Popen(args=string.Template(SET_CMD).substitute({'level':A}),stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True);return B.stdout.read()==b'()\n'and not B.stderr.read()
if __name__=='__main__':
	try:set_brightness(int(sys.argv[1]))
	except Exception as e:print(e)