#include <string>
#include <map>
#include <vector>
using namespace std;

struct OperatorInfo {
    string op;
    string returnType;
    int paramCount;
};

extern map<string, vector<OperatorInfo>> classTable;

void addOperator(string className, string op, string returnType, int paramCount);
int checkDuplicate(string className, string op);