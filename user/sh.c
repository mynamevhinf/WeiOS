#include <include/types.h>
#include <include/malloc.h>
#include <include/user.h>

#define MAXARGS   10
#define CMDLEN    20
#define SHELLBUF  100

#define PATH  "/:/bin/:/usr/bin/:/usr/local/bin/:"

struct cmd {
    int type;          //  ' ' (exec), | (pipe), '<' or '>' for redirection
};

struct execcmd {
    int type;              // ' '
    char *argv[MAXARGS];   // arguments to the command to be exec-ed
};

struct redircmd {
    int type;          // < or >
    struct cmd *cmd;   
    char *file;       
    int mode;         
    int fd;            
};

struct pipecmd {
    int type;          // |
    struct cmd *left;  // left side of pipe
    struct cmd *right; // right side of pipe
};

struct backcmd {
    int type;
    struct cmd *cmd;
}; 

int forkv(void);  // Fork but exits on failure.
void panic(const char *);
struct cmd *parsecmd(char *);

// get PATH's directory one by one.
char *splicingcmd(char *cmd, char *path, char *rs, int *p)
{
    int len;

    if (!cmd || (*p >= strlen(PATH)))
        return 0;
    if (cmd[0] == '/')
        return cmd;
    int e = *p;
    while (PATH[e] != ':')
        e++;
    len = (e - *p) + strlen(cmd) + 1;
    strncpy(rs, &PATH[*p], e - *p);
    strcat(rs, cmd);
    rs[len] = '\0';
    *p = e + 1;

    return rs;
}

void runcmd(struct cmd *cmd)
{
    pid_t pid;
    int px, r, p[2];
    char rscmd[CMDLEN];
    struct execcmd *ecmd;
    struct pipecmd *pcmd;
    struct redircmd *rcmd;
    struct backcmd *bcmd;
    if(!cmd)
        exit();

    switch (cmd->type) {
        case ' ':
            ecmd = (struct execcmd *)cmd;
            if(ecmd->argv[0] == 0)
                exit();
            px = 0;
            while (splicingcmd(ecmd->argv[0], PATH, rscmd, &px))
                if (exec(rscmd, ecmd->argv) == -1)
                    continue;
            printf(1, "Wsh: %s -- command not found!\n", ecmd->argv[0]);
            break;
        case '>':
        case '<':
            rcmd = (struct redircmd *)cmd;
            close(rcmd->fd);
            if (open(rcmd->file, rcmd->mode) < 0)
                panic("open failed!\n");
            runcmd(rcmd->cmd);
            break;

        case '|':
            pcmd = (struct pipecmd *)cmd;
            r = 0;
            if (pipe(p) < 0) 
                panic("Pipe Error!!!\n");
            if ((pid = forkv())) {
                wait();
                close(p[1]);
                dup2(p[0], 0);
                runcmd(pcmd->right);
            }
            close(p[0]);
            dup2(p[1], 1);
            runcmd(pcmd->left);
            break;

        case '&':
            bcmd = (struct backcmd *)cmd;
            if (forkv() == 0)
                runcmd(bcmd->cmd);
            break;

        default:
            panic("runcmd!!!\n");
    }    
    exit();
}

int getcmd(char *buf, int nbytes)
{
    printf(stdout, "Wsh> ");
    memset(buf, 0, nbytes);
    gets(buf, nbytes);
    if (buf[0] == '\0')
        return -1;
    return 0;
}

int wmain(void)
{
    int fd, r, icd;
    static char buf[SHELLBUF];

    WeiOS_welcome();
    while (getcmd(buf, SHELLBUF) >= 0) {
        if (buf[0] == 'c' && buf[1] == 'd') {
            // Clumsy but will have to do for now.
            // Chdir has no effect on the parent if run in the child.
            icd = 2;
            while (buf[icd] == ' ')
                icd++;
            buf[strlen(buf)-1] = 0;
            if (chdir(buf + icd) < 0)
                printf(stderr, "connot cd %s\n", buf + icd);
            continue;
        }
        if(forkv() == 0)
            runcmd(parsecmd(buf));
        wait();
    }
    exit();

    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
    exit();
}

int forkv(void)
{
    int pid;
  
    if ((pid = fork()) < 0)
        panic("fork error!!!\n");
    return pid;
}

struct cmd *execcmd(void)
{
    struct execcmd *cmd;

    cmd = malloc(sizeof(struct execcmd));
    memset(cmd, 0, sizeof(struct execcmd));
    cmd->type = ' ';
    return (struct cmd *)cmd;
}

struct cmd *redircmd(struct cmd *subcmd, char *file, int type)
{
    struct redircmd *cmd;

    cmd = malloc(sizeof(struct redircmd));
    memset(cmd, 0, sizeof(struct redircmd));
    cmd->type = type;
    cmd->cmd = subcmd;
    cmd->file = file;
    cmd->mode = (type == '<') ? (O_RDONLY) : (O_WRONLY|O_CREAT);
    cmd->fd = (type == '<') ? 0 : 1;
    return (struct cmd *)cmd;
}

struct cmd *pipecmd(struct cmd *left, struct cmd *right)
{
    struct pipecmd *cmd;

    cmd = malloc(sizeof(struct pipecmd));
    memset(cmd, 0, sizeof(struct pipecmd));
    cmd->type = '|';
    cmd->left = left;
    cmd->right = right;
    return (struct cmd *)cmd;
}

struct cmd *backcmd(struct cmd *subcmd)
{
    struct backcmd *cmd;

    cmd = malloc(sizeof(struct backcmd));
    memset(cmd, 0, sizeof(struct backcmd));
    cmd->type = '&';
    cmd->cmd = subcmd;
    return (struct cmd *)cmd;
}

// Parsing
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&";

int gettoken(char **ps, char *es, char **q, char **eq)
{
    char *s;
    int ret;
    
    s = *ps;
    while(s < es && strchr(whitespace, *s))
        s++;
    if(q)
        *q = s;
    ret = *s;
    switch (*s) {
        case 0:
            break;
        case '&':
        case '|':
        case '<':
        case '>':
            s++;
            break;

        default:
            ret = 'a';
            while ((s < es) && !strchr(whitespace, *s) && !strchr(symbols, *s))
                s++;
            break;
    }
    if (eq)
        *eq = s;
    
    while ((s < es) && strchr(whitespace, *s))
        s++;
    *ps = s;
    return ret;
}

int peek(char **ps, char *es, char *toks)
{
    char *s;
    
    s = *ps;
    while ((s < es) && strchr(whitespace, *s))
        s++;
    *ps = s;
    return (*s && strchr(toks, *s));
}

// make a copy of the characters in the input buffer, starting from src through des.
// null-terminate the copy to make it a string.
char *safe_copy(char *src, char *des)
{
    int n = des - src;
    char *c = malloc(n+1);
    if (!c)
        panic("safe_copy failed!!!\n");
    strncpy(c, src, n);
    c[n] = 0;
    return c;
}

struct cmd *parseline(char **, char *);
struct cmd *parsepipe(char **, char *);
struct cmd *parseexec(char **, char *);

struct cmd *parsecmd(char *s)
{
    char *es;
    struct cmd *cmd;

    es = s + strlen(s);
    cmd = parseline(&s, es);
    peek(&s, es, "");
    if(s != es)
        panic("parsecmd error!!!\n");
    return cmd;
}

struct cmd *parseline(char **ps, char *es)
{
    struct cmd *cmd;
    cmd = parsepipe(ps, es);
    while (peek(ps, es, "&")) {
        gettoken(ps, es, 0, 0);
        cmd = backcmd(cmd);
    }
    return cmd;
}

struct cmd *parsepipe(char **ps, char *es)
{
    struct cmd *cmd;

    cmd = parseexec(ps, es);
    if (peek(ps, es, "|")) {
        gettoken(ps, es, 0, 0);
        cmd = pipecmd(cmd, parsepipe(ps, es));
    }
    return cmd;
}

struct cmd *parseredirs(struct cmd *cmd, char **ps, char *es)
{
    int tok;
    char *q, *eq;

    while (peek(ps, es, "<>")) {
        tok = gettoken(ps, es, 0, 0);
        if(gettoken(ps, es, &q, &eq) != 'a') 
            panic("missing file for redirection!!!\n");

        switch(tok){
            case '<':
                cmd = redircmd(cmd, safe_copy(q, eq), '<');
                break;
            case '>':
                cmd = redircmd(cmd, safe_copy(q, eq), '>');
                break;
        }
    }
    return cmd;
}

// argv[0] = program's name.
struct cmd *parseexec(char **ps, char *es)
{
    char *q, *eq;
    int tok, argc;
    struct execcmd *cmd;
    struct cmd *ret;
    
    ret = execcmd();
    cmd = (struct execcmd*)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
    while(!peek(ps, es, "|&")){
        if ((tok= gettoken(ps, es, &q, &eq)) == 0)
            break;
        if (tok != 'a') 
            panic("syntax error!!!\n");
        cmd->argv[argc] = safe_copy(q, eq);
        argc++;
        if(argc >= MAXARGS)
            panic("too many args!!!\n");
        ret = parseredirs(ret, ps, es);
    }
    cmd->argv[argc] = 0;
    return ret;
}