#ifndef hash_gpu_h
#define hash_gpu_h

struct entry_s{
	char* key;
	char* value;
	struct entry_s *next;
};

typedef struct entry_s entry_t;

struct hashtable_s {
	int size;
	entry_t **table;
};

typedef struct hashtable_s hashtable_t;

hashtable_t* ht_create(int);

void ht_set(hashtable_t*, char*, char*);

char* ht_get( hashtable_t*, char* );

int ht_hash( hashtable_t*,  char* );

#endif
