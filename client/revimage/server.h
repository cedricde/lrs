struct cmd_s {
    char *name;
    int numargs;
    char *(*func) (int argc, char **argv);
};

int server_loop(int port, struct cmd_s *commands);
