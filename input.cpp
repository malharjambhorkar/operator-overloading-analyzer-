class Text {
    string value;

public:
    Text operator+(Text t);
    Text operator+(Text t);     // duplicate
    int operator-(Text t);      // wrong return type
    Text operator*(int times);
    int operator==(Text t);     // wrong return type
    char operator[](int index);
};
