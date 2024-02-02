/*
if [ "$#" -ne 2 ]; then
    echo "Error: 2 arguments are required"
    echo " The first argument is a file name, including the path, which will be created"
    echo " The second argument is a text string which will be written to that file"
    exit 1
fi

DIRECTORY=$(dirname $1)
FILE=$(basename $1)

if [ ! -d $DIRECTORY ]; then
    mkdir -p $DIRECTORY
fi

if [ ! -d $DIRECTORY ]; then
    echo "Error creating path"
    exit 1
fi

touch $1

if [ ! -f $1 ]; then
    echo "Error creating file"
    exit 1
fi

echo $2 > $1


*/

#include <stdio.h>
#include <string.h>
#include <syslog.h>	// https://stackoverflow.com/questions/8485333/syslog-command-in-c-code
#include <errno.h>

int main(int argc, char **argv){
	FILE *file;

	if(argc < (1 + 2)){    // first parameter is command used to invoke this
		printf("Error: 2 arguments are required\n");
		printf(" The first argument is a file name, including the path, which will be created\n");
		printf(" The second argument is a text string which will be written to that file\n");
		openlog("Logs", LOG_PID, LOG_USER);
		syslog(LOG_ERR, "Less than 2 arguments were included when invoking this program");
		closelog();
		return 1;
        }

	
	// https://stackoverflow.com/questions/5745649/how-to-write-into-a-file-at-particular-path-in-linux-using-c
	file = fopen(argv[1], "w");

        if(file == NULL){
        	//if(errno != 0){
		//	printf("Errno = %d", errno);
		//}
        
		printf("Error creating file\n");
		openlog("Logs", LOG_PID, LOG_USER);
		syslog(LOG_ERR, "Unable to create file");
		closelog();
		return 1;
        }
        else{
		openlog("Logs", LOG_PID, LOG_USER);
		syslog(LOG_DEBUG, "Writing %s to %s", argv[2], argv[1]);

                // https://stackoverflow.com/questions/2008267/how-to-write-a-file-with-c-in-linux
                int result = fputs(argv[2], file);

		fclose(file);

		if(result == EOF){
			printf("Error writing to file\n");
			syslog(LOG_ERR, "Writing to file failed");
			closelog();
                	return 1;
		}

		closelog();

        }

        return 0;

}
