/*
 * File Name    : hash.c
 * Description  : An implementation file for the hash table.
 * 
 * Course       : Introduction to Compilers
 * Dept. of Electrical and Computer Engineering, Seoul National University
 */

#include "subc.h"
#include "subc.tab.h"
#include <stdlib.h>
#include <string.h>

#define  HASH_TABLE_SIZE   101

typedef struct nlist {
  struct nlist *next;
  id *data;
} nlist;

static nlist *hashTable[HASH_TABLE_SIZE];

void init_hash(void){
  // Define reserved keywords
  char *keyword[] = { 
    "int", "char", "struct", "NULL", "return",
    "if", "else", "while", "for", "break", "continue",
    NULL 
  };
  int tokentype[] = { 
    TYPE, TYPE, STRUCT, SYM_NULL, RETURN,
    IF, ELSE, WHILE, FOR, BREAK, CONTINUE,
    0 
  };

  // Initialize the hash table
  for(int i=0; keyword[i] != NULL; i++) {
    enter(tokentype[i], keyword[i], strlen(keyword[i]));
  }
}

// hash function using djb2 algorithm
unsigned int hf(char *p){
  unsigned long res = 5381;
  while (*p){
    res = (res << 5) + res + (*p);
    p++;
  } 
  res = res % HASH_TABLE_SIZE;
  return res;
}

nlist *mknode(int tokenType, char *name, int length){
  // Copy symbol name
  char *symname = (char *)malloc(length+1);
  strncpy(symname, name, length);
  symname[length] = 0;

  // Make a node data
  id *hdata = (id *)malloc(sizeof(id));
  hdata->tokenType = tokenType;
  hdata->name = symname;
  hdata->count = 1;
  
  // Make a hash node
  nlist *node = (nlist *)malloc(sizeof(nlist));
  node->data = hdata;
  node->next = 0;
  return node;
}

id *enter(int tokenType, char *name, int length) {
  // TODO: Implement this function
  unsigned int key = hf(name);
  nlist *node = hashTable[key];
  id *hdata;
  while (node){
    hdata = node->data;
    if (!strcmp(hdata->name, name)){
      // Found the target symbol
      hdata->count++;
      return hdata;
    }
    else if (node->next == NULL){
      // no existing symbol -> allocate & link a new nlist
      nlist *newnode = mknode(tokenType, name, length);
      node->next = newnode;
      return newnode->data;
    }
    else 
      node = node->next;
  }

  // no existing hash table entry 
  // -> allocate a new nlist & insert it into hashTable
  nlist *newnode = mknode(tokenType, name, length);
  hashTable[key] = newnode;
  return newnode->data;
}
