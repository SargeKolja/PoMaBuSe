#include <Sub2.h>
#include "string.h"

int Sub2_foo( const char* DummyText )
{
    return (DummyText) ? strlen(DummyText) : 0;
}
