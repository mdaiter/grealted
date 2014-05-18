#include "str_opts.cuh"
/*
__device__ __host__ int strlen(char* s){
	int c = 0;
	while(*(s+c)){
		c++;
	}
	return c;
}

__device__ __host__ int strcmp(char* str1, char* str2){
	if (str1 == NULL || str2 == NULL){
		return -1;
	}
	char* i = str1;
	char* j = str2;
	int i_len = strlen(str1);
	int j_len = strlen(str2);
	if (i_len != j_len){
		return -1;
	}
	
	for(int x = 0;  x < i_len && x < j_len; x++){
		if ((int)i[x] > (int)j[x]){
			return 1;
		}
		else if ((int)i[x] < (int)j[x]){
			return -1;
		}
		//i++;
		//j++;
	}
	return 0;
}
*/
