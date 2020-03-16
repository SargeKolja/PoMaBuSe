#include <stdio.h>

/* == a simple Demo ==
 * Compilation & linking:
 *      gcc -Os helloworld.c -o helloworld
 *      strip helloworld  [.exe on MSYS/Cygwin/...]
 *
 * execution:
 *      ./helloworld -?
 *      ./helloworld
 *
 * or Compilation & linking with Debug support:
 *      gcc -ggdb helloworld.c -o helloworld
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
				fprintf(stderr, "This program sends greetings to the world\n" );
				break;
		}
	}
	else
	{
		puts( "Hello World!\n" );
	}
	return 0;
}
