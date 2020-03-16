#include <iostream>

/* Compilation & linking:
 *      g++ -Os helloworld.cpp -o helloworld
 *      strip helloworld  [.exe on MSYS/Cygwin/...]
 *
 * execution:
 *      ./helloworld -?
 *      ./helloworld
 *
 * or Compilation & linking with Debug support:
 *      g++ -ggdb helloworld.cpp -o helloworld
 *
 * debugging:
 *      gdb -ex=l --args ./helloworld -x
 */

int main( int argc, const char *argv[] )
{
	if( argc>1 && (argv[1][0]=='-' || argv[1][0]=='/') )
	{
		switch( argv[1][1] )
		{
			case 'h' :
			case 'H' :
			case '?' :
				std::cerr << "This program sends greetings to the world" << std::endl;
				break;
		}
	}
	else
	{
		std::cout << "Hello World!" << std::endl;
	}
	return 0;
}
