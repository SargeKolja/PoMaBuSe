#include <iostream>

#include "helppage.h"

/* Compilation & linking:
 *
 * execution:
 *      ./helloworld -?
 *      ./helloworld
 *
 * or Compilation & linking with Debug support:
 *
 * debugging:
 *      gdb -ex=l --args ./helloworld -x
 */

int main( int argc, const char *argv[] )
{
	if( argc>1 && (argv[1][0]=='-' || argv[1][0]=='/') )
	{
        int minus=1;
        if( argv[1][1]=='-' )
            minus++;
		switch( argv[1][minus] )
		{
			case 'h' :
			case 'H' :
			case '?' :
				return helppage( argv[1], (argc>2) ? argv[2] : NULL );
            default :
				return helppage( argv[1], "" );
		}
	}
	else
	{
		std::cout << "Hello World!" << std::endl;
	}
	return 0;
}
