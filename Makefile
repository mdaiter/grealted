all:
	nvcc -ccbin /opt/gcc/usr/local/bin/g++ src/C/*.c src/C/*.cu examples/test.cu -o bin/example -arch sm_30 -g -lhiredis
