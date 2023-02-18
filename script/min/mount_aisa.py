_B=False
_A=True
import subprocess,threading,time
from getpass import getuser
import PySimpleGUI as sg,requests
CONN_TEST_URL='https://google.com/'
TIMEOUT=500
MAX_TRIES=10**6
TRY_DELAY=1000
XLOGIN='xreznak'
HOST='aisa.fi.muni.cz'
LOCAL_DIR=f"/home/{getuser()}/Aisa/"
REMOTE_DIR=f"{XLOGIN}@{HOST}:/home/{XLOGIN}/"
SHOW_POPUP=_B
POPUP_AUTOCLOSE_DELAY=5
def check_connection():
	try:A=requests.request('GET',CONN_TEST_URL,timeout=TIMEOUT);return _A
	except Exception:return _B
def mount():return subprocess.call(['sshfs',REMOTE_DIR,LOCAL_DIR])
def main():
	for A in range(MAX_TRIES):
		if check_connection():break
		time.sleep(TRY_DELAY/1000)
	if not mount()and SHOW_POPUP:sg.theme('DarkGrey11');Popup()
class Popup(sg.Window):
	SUCCESS_ICON='iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQIC\n    AgIfAhkiAAAAAlwSFlzAAABSQAAAUkBRDzYzwAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBl\n    Lm9yZ5vuPBoAAAOvSURBVFiFvZdNTBxlGMd/zzuzuB8UMF6AtgRQINVYST/QSkyAGCwsrcak4UB\n    S60FjPFBumpSsWy9CENKDifHYgzFpbLQGtjSN7QY0NPUgxXgygTW0hUILJLAIO8u8HmC3BHbZFX\n    b9n2bmed7n95+Zd973GSFN1f3wTkHEYbUo0Q0aXgZKgQJAAwtASLSM2nBL1oyBX9/+aTGdupIq4\n    dVA0wFTix9oA5xp+l0GvjNs1T10qv+vXRlovNHoCUfNTuA84EoTvFUWcMnhXvYF64MraRt4rd97\n    yBR9VcOhXYK36o4y1t4dPnljKqWB2oHmY4geRMtzGYLHQPdF2d7hpsGxpAZqr50uxozeBfZnEv6\n    Uph/aa0bNyKn+B7FLKnZw4soZF2b0x6zBAbQUK2VfO3HlTHxOxQ0YnnAXcDxr8Kc6qnKXPo2dCM\n    AbgaYXbS1jgPE/GAAtSw7RFUFvYFoB2Fo+yST8eXcVHxzswBRH4gTRuVEtPgA5evPNfGckZ4rdf\n    +tb4JW0l3biVE7+XLzH15M9WHYkUWqYqFmkXJGc05mDV8XhAC/te4XWonPJ0j04rGYF1GcGXkl7\n    6YU4HGBmdZr+me+TjtHQoDQczgy8cxu8N+RnwZpLOk60HFZA2U7FDUzO7v+IUtcLSeBV2+CPVqf\n    oDX22I3xD5QrYlyxqismHJR3UPttAR1kn5a7KLfDEj70vdJEFaz4VHCBfsb6fJ1Rr0Tmq82oAcC\n    k37WUXKHdXbsD3dOdxGSVtFecBd6Lgw5VJqvOO4zY8ADjEwbH814nYK7x34ONt8L6QP907j2lOA\n    RPJok+sWXom/MxGHsWvOZWT1qL39/LYN2tciZbRnTLmrcf0TlxkJjKdMJ7ObN9B95QNt1JlzVuP\n    6UtgYo9wRMvPKscT7gfCqU08oWfcx9Tqg4zAgbDpCV83QpdDkZK2inLgSKoRq/YKo4u/UfhMMd9\n    Mfrmbdx6XaLk89NbNqwrAsFU36w1kSi1Yc3z1d9ee4EAE6IKNhmSjdb60l4r/UX2/tAyMxw0AON\n    zLPuBO1tGiR/JE++Onm2N1A82FFtwFDmYJnrwpBQh6A9NK2S0C97OAn7S1nNwM32YAYLhpcExEH\n    wGGMoYWPeKAmhFv4I+toW0GAIabr8/miW5E9OeksUbsoAjwRR7UB72BhEtpyp/TuoHmwqgWnxZ9\n    FvCkCQ5r0d8qW3XHZnsypTQQN3K7Ltf6x+VFSz1QzXojU7ARXmB9U/sduO1wLweC9cGldOr+Cwr\n    rcL47XmAgAAAAAElFTkSuQmCC'
	def __init__(A):B='Any 9 italic bold';C=[[sg.Text('Success!',font='Any 13 bold',pad=((0,0),(10,10)))],[sg.Image(data=A.SUCCESS_ICON,pad=((0,0),(0,10)))],[sg.Text('Successfully mounted')],[sg.Text(REMOTE_DIR,font=B)],[sg.Text('to local dir')],[sg.Text(LOCAL_DIR,font=B)],[sg.Button('Ok',pad=((0,0),(10,10)))]];super().__init__('AutoMount',size=(300,270),layout=C,auto_close=_A,auto_close_duration=POPUP_AUTOCLOSE_DELAY,element_justification='c',text_justification='c',use_custom_titlebar=_A,modal=_A,keep_on_top=_A,resizable=_B,disable_close=_A);A.read()
if __name__=='__main__':threading.Thread(target=main,daemon=_B).start()