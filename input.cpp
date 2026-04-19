class A {
public:
    A operator+(A obj);
    A operator+(A obj);   // duplicate
    int operator-(A obj); // wrong return type
    A operator==(A obj);
    A operator[](int i);
};