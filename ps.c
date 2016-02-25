#include "types.h"
#include "user.h"
#include "MMps.h"

#define MAX 10

void
printTableEntry(struct uproc* t)
{
  printf(2, "pid: %d, name: %s\n      uid: %d  gid: %d   ppid: %d  state: %s  size: %d\n",
        t->pid, t->name, t->uid, t->gid, t->ppid,
        t->state, t->size);
  return;
}

int
main(int argc, char* argv[]) {
  int i, rc;
  struct uproc table[MAX];

  rc = getprocs(MAX, table);

  if (rc < 0) {
    printf(2, "Error: getprocs call failed. %s at line %d\n", __FILE__, __LINE__);
    exit();
  }

  for (i=0; i<rc; i++) {
    printTableEntry(&table[i]);
  }





  exit();
}