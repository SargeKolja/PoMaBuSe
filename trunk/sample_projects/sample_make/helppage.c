#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

int helppage( const char* command, const char* subcommand )
{
    if( command && ((0==strcmp( command, "--Help" )) || 
                    (0==strcmp( command, "--help" )) || 
                    (0==strcmp( command, "-Help" )) || 
                    (0==strcmp( command, "-help" )) || 
                    (0==strcmp( command, "/Help" )) || 
                    (0==strcmp( command, "/help" )) ) )
    {
        if( subcommand && *subcommand )
        {
            fprintf(stderr, "don't have sub commands, so don't have help on \"%s\"\n", subcommand );
            return 0;
        }
        fprintf(stderr, "This program sends greetings to the world\n" );
        return 1;
    }
    else if( command && ((0==strcmp( command, "-?" )) || 
                         (0==strcmp( command, "/?" )) ) )
    {
        fprintf(stderr, "This program is still nonsense and sending greetings to the world\n" );
        return 2;
    }
    else
    {
        fprintf(stderr, "WTF?\n" );
        exit(3);
    }
	return 0;
}


#ifdef __cplusplus
}
#endif