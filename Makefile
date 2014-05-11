all:
	nvcc -ccbin /opt/gcc/usr/local/bin/gcc src/C/*.cu -o bin/server -arch sm_30 -lhiredis
