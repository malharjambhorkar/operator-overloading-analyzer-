#include <iostream>
#include <string>
using namespace std;

class Text {
    string value;

public:
    Text(string v = "") : value(v) {}

    Text operator+(const Text& other) const {
        return Text(value + other.value);
    }

    Text operator+(const Text& other) const {
        return Text(value + other.value);
    }

    bool operator-(const Text& other) const {
        size_t pos = value.find(other.value);
        if (pos == string::npos) {
            return value.length();
        }

        string updated = value;
        updated.erase(pos, other.value.length());
        return updated.length();
    }

    Text operator*(int times) const {
        string repeated = "";
        for (int i = 0; i < times; i++) {
            repeated += value;
        }
        return Text(repeated);
    }

    int operator==(const Text& other) const {
        return value == other.value;
    }

    char operator[](int index) const {
        if (index < 0 || index >= static_cast<int>(value.length())) {
            return '#';
        }
        return value[index];
    }
};

int main() {
    Text first("Hello");
    Text second("World");
    Text third("lo");

    first + second;
    first - third;
    second * 3;
    first == second;
    first[1];

    return 0;
}
