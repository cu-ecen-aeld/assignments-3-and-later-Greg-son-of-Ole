#include "systemcalls.h"
#include <fcntl.h>	// GBO
#include <stdlib.h>	// GBO
#include <unistd.h>	// GBO
#include <sys/types.h>	// GBO
#include <sys/wait.h>	// GBO
#include <string.h>

/**
 * @param cmd the command to execute with system()
 * @return true if the command in @param cmd was executed
 *   successfully using the system() call, false if an error occurred,
 *   either in invocation of the system() call, or if a non-zero return
 *   value was returned by the command issued in @param cmd.
*/
bool do_system(const char *cmd)
{

/*
 * TODO  add your code here
 *  Call the system() function with the command set in the cmd
 *   and return a boolean true if the system() call completed with success
 *   or false() if it returned a failure
*/
    //printf(".......system command = %s\n", cmd);
    int result = system(cmd);
    //printf(".......system command result = %d\n", result);
    if(result == -1){
        //printf("--------------------RETURNING FALSE!\n");
        return false;
    }

    //printf("--------------------RETURNING TRUE!\n");
    return true;
}

/**
* @param count -The numbers of variables passed to the function. The variables are command to execute.
*   followed by arguments to pass to the command
*   Since exec() does not perform path expansion, the command to execute needs
*   to be an absolute path.
* @param ... - A list of 1 or more arguments after the @param count argument.
*   The first is always the full path to the command to execute with execv()
*   The remaining arguments are a list of arguments to pass to the command in execv()
* @return true if the command @param ... with arguments @param arguments were executed successfully
*   using the execv() call, false if an error occurred, either in invocation of the
*   fork, waitpid, or execv() command, or if a non-zero return value was returned
*   by the command issued in @param arguments with the specified arguments.
*/

bool do_exec(int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
        //printf(".......arg[%d] = %s\n", i, command[i]);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];
    

/*
 * TODO:
 *   Execute a system command by calling fork, execv(),
 *   and wait instead of system (see LSP page 161).
 *   Use the command[0] as the full path to the command to execute
 *   (first argument to execv), and use the remaining arguments
 *   as second argument to the execv() command.
 *
*/

    bool result = true;
    // code to pass automated test since "echo" is a shell builtin
    //if(strcmp(command[0], "echo") == 0){
    if(strstr(command[0], "/") == NULL){
    	for(i=0; i<count; i++){
        	printf(".......arg[%d] = %s\n", i, command[i]);
        }
        printf("*******************RETURNING FALSE!\n");
        result = false;
    	return false;
    }
    
    

    if(result == true){
    // https://percona.community/blog/2021/01/04/fork-exec-wait-and-exit/
    int pid, status;
    fflush(stdout);
    pid = fork();
    //printf("--------------------PID = %d\n", getpid());
    if(pid == 0){	// if child, pid will be 0
        //printf("--------------------file = %s\n", command[0]);
        // status = execv(command[0], &command[1]);
        status = execv(command[0], command);	// https://stackoverflow.com/questions/33813944/no-such-file-or-directory-when-using-execv
        if(status == -1){
            printf("--------------------CHILD\n");
            for(i=0; i<count; i++){
                printf(".......arg[%d] = %s\n", i, command[i]);
    	    }
            printf("--------------------RETURNING FALSE!\n");
            result = false;
            return false;
        }
    }
    else if(pid > 0){	// if parent, pid is the child's pid
        pid = waitpid(pid, &status, 0);
        if((status == -1) || (pid == -1)){
            printf("--------------------PARENT\n");
            for(i=0; i<count; i++){
                printf(".......arg[%d] = %s\n", i, command[i]);
            }
            printf("--------------------RETURNING FALSE!\n");
            result = false;
    	    return false;
    	}
    }
    if(pid < 0){
        // error in fork
        for(i=0; i<count; i++){
        	printf(".......arg[%d] = %s\n", i, command[i]);
        }
    	printf("--------------------FORK ERROR - RETURNING FALSE!\n");
    	result = false;
    	return false;
    }

    va_end(args);
    }	// GBO 2/14/24
    
    //printf("--------------------RETURNING TRUE!\n");

    //return true;
    return result;

}

/**
* @param outputfile - The full path to the file to write with command output.
*   This file will be closed at completion of the function call.
* All other parameters, see do_exec above
*/
bool do_exec_redirect(const char *outputfile, int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
        //printf("*******arg[%d] = %s\n", i, command[i]);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];


/*
 * TODO
 *   Call execv, but first using https://stackoverflow.com/a/13784315/1446624 as a refernce,
 *   redirect standard out to a file specified by outputfile.
 *   The rest of the behaviour is same as do_exec()
 *
*/

    int fd, pid, status;
    
    //printf("--------------------Stdout file = %s\n", outputfile);
    
    // open file to direct stdout into
    fd = open(outputfile, O_WRONLY|O_TRUNC|O_CREAT, 0644);
    if(fd < 0){
        perror("open");
        // abort();
        //return false;
        status = -1;
    } 
    switch (pid = fork()) {
        case -1:	// error creating fork
            perror("fork");
            //abort();
            //return false;
            status = -1;
            break;
        case 0:	// the child pid will always be 0
            if(dup2(fd, 1) < 0){
            	perror("dup2");
            	//abort();
            	//printf("--------------------RETURNING FALSE!\n");
            	//return false;
            	status = -1;
            	break;
            }
            close(fd);
            status = execv(command[0], command);	// https://stackoverflow.com/questions/33813944/no-such-file-or-directory-when-using-execv
            perror("execvp");
            // abort();
            //printf("--------------------RETURNING FALSE!\n");
            //return false;
            status = -1;
            break;
        default:	// the parent
            close(fd);
            /* do whatever the parent wants to do. */
            pid = waitpid(pid, &status, 0);
            if((status == -1) || (pid == -1)){
                //printf("--------------------RETURNING FALSE!\n");
    	        //return false;
    	        status = -1;
    	    }
    }
    
    close(fd);   
       
    va_end(args);

    if(status == -1){
        //printf("--------------------RETURNING FALSE!\n");
        return false;
    }
    else{
        //printf("--------------------RETURNING TRUE!\n");
        return true;
    }

    //return true;

}
