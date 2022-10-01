#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <spawn.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>

//David Bogoslavsky

#define MAX_COMMAND_LENGTH	103
#define MAX_NUMBER_OF_COMMANDS  100

struct command_info {
	char command[MAX_COMMAND_LENGTH];
	pid_t pid;
};
static struct command_info history[MAX_NUMBER_OF_COMMANDS];
int proccessed_commands = 0;

void process_command(char *command)
{
	//add the command to history
	strcpy(history[proccessed_commands].command, command);
	if (!strcmp(command, "history")) {
		int i;
		history[proccessed_commands].pid = 0;
		proccessed_commands++;
		for (i = 0; i < proccessed_commands; ++i)
			printf("%d\t %s\n", history[i].pid, history[i].command);
	} else if ((command[0] == 'c') && (command[1] == 'd') && (command[2] == ' ')) {
		history[proccessed_commands].pid = 0;
		proccessed_commands++;
		if (chdir(command + 3) != 0)
			perror("chdir failed");
	} else {
		char *argv[100];
		int tokens_num;
		char* token;
		pid_t child_pid = fork();
		switch (child_pid) {
			case 0:
				// We're the child
				tokens_num = 0;
				token = strtok(command, " ");
				while(token != NULL ) {
					argv[tokens_num] = token;
					tokens_num++;
					token = strtok(NULL, " ");
				}
				argv[tokens_num] = NULL;
				if (execvp(argv[0], argv) < 0)
					perror("execvp failed\n");
				exit(0);
				break;
			case -1:
				perror("fork failed\n");
				break;
			default:
				// We're the parent
				history[proccessed_commands].pid = child_pid;
				proccessed_commands++;
				wait(NULL);
				break;
		}
	}
}

int main(int argc, char* argv[])
{
	int stop = 0;
	int i;
	char orig_dir[1024];
	char orig_path[4096];
	char extended_path[4096];
 	char* pathway = getenv("PATH");
	strcpy(orig_path, pathway);
	strcpy(extended_path, pathway);
	for (i = 1; i < argc; i++) {
		strcat(extended_path,":");
		strcat(extended_path, argv[i]);
	}
	setenv("PATH", extended_path, 1);
	getcwd(orig_dir, sizeof(orig_dir));
	do {
		int len;
		char command[MAX_COMMAND_LENGTH + 1];
		printf("$ ");
		fflush(stdout);
		fgets(command, sizeof(command), stdin);
		len = (int)strlen(command);
		if (len > 1) {
			command[strlen(command) - 1] = 0;
			if (!strcmp(command, "exit"))
				stop = 1;
			else
				process_command(command);
		}
	} while (!stop && (proccessed_commands < MAX_NUMBER_OF_COMMANDS));
	chdir(orig_dir);
	setenv("PATH", orig_path, 1);
	return 0;
}
