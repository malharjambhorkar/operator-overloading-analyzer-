#include "symtab.h"

map<string, vector<OperatorInfo>> classTable;

void addOperator(string className, string op, string returnType, int paramCount) {
    classTable[className].push_back({op, returnType, paramCount});
}

int checkDuplicate(string className, string op) {
    int count = 0;
    for(auto &o : classTable[className]) {
        if(o.op == op) count++;
    }
    return count > 1;
}