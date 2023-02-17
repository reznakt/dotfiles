import os,shutil,subprocess,tempfile,sys,time
CODES={132:'SIGILL',133:'SIGTRAP',134:'SIGABRT',136:'SIGFPE',138:'SIGBUS',139:'SIGSEGV',158:'SIGXCPU',159:'SIGXFSZ'}
def main():
	G='tmp';F='tmp.o';E='tmp.asm';C=True
	if len(sys.argv)!=2:print('Error: Invalid arguments');return
	D=sys.argv[1]
	if not os.path.isfile(D):print('Error: file not found');return
	with tempfile.TemporaryDirectory()as A:
		shutil.copy(D,os.path.join(A,E));subprocess.call(f"nasm -f elf64 -Wall -Werror -o {os.path.join(A,F)} {os.path.join(A,E)}",shell=C);subprocess.call(f"ld {os.path.join(A,F)} -o {os.path.join(A,G)}",shell=C);H=time.perf_counter();B=subprocess.call(f"{os.path.join(A,G)}",shell=C);print(f"[Finished in {(time.perf_counter()-H)*1000:.2f} ms with exit code {B}",end='')
		if B in CODES:print(f" (interrupted by signal: {CODES[B]})]")
		else:print(']')
if __name__=='__main__':
	try:main()
	except KeyboardInterrupt:pass