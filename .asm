
_sh:     file format elf32-i386


Disassembly of section .text:

08048000 <_ustart>:
#include <include/trap.h>

.text
.globl _ustart
_ustart:
	call wmain
 8048000:	e8 db 09 00 00       	call   80489e0 <wmain>
	addl $8, %esp
 8048005:	83 c4 08             	add    $0x8,%esp

  	movl $SYS_exit, %eax
 8048008:	b8 01 00 00 00       	mov    $0x1,%eax
 804800d:	cd 80                	int    $0x80
 804800f:	90                   	nop

08048010 <forkv.part.1>:
{
    printf(stderr, s);
    exit();
}

int forkv(void)
 8048010:	55                   	push   %ebp
 8048011:	89 e5                	mov    %esp,%ebp
 8048013:	83 ec 10             	sub    $0x10,%esp
    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
 8048016:	68 1c a0 04 08       	push   $0x804a01c
 804801b:	6a 02                	push   $0x2
 804801d:	e8 7e 0c 00 00       	call   8048ca0 <printf>
    exit();
 8048022:	83 c4 10             	add    $0x10,%esp
    int pid;
  
    if ((pid = fork()) < 0)
        panic("fork error!!!\n");
    return pid;
}
 8048025:	c9                   	leave  
}

void panic(const char *s)
{
    printf(stderr, s);
    exit();
 8048026:	e9 f5 11 00 00       	jmp    8049220 <exit>
 804802b:	90                   	nop
 804802c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

08048030 <splicingcmd>:
void panic(const char *);
struct cmd *parsecmd(char *);

// get PATH's directory one by one.
char *splicingcmd(char *cmd, char *path, char *rs, int *p)
{
 8048030:	55                   	push   %ebp
 8048031:	89 e5                	mov    %esp,%ebp
 8048033:	57                   	push   %edi
 8048034:	56                   	push   %esi
 8048035:	53                   	push   %ebx
 8048036:	83 ec 1c             	sub    $0x1c,%esp
 8048039:	8b 5d 08             	mov    0x8(%ebp),%ebx
 804803c:	8b 75 14             	mov    0x14(%ebp),%esi
    int len;

    if (!cmd || (*p >= strlen(PATH)))
 804803f:	85 db                	test   %ebx,%ebx
 8048041:	0f 84 9e 00 00 00    	je     80480e5 <splicingcmd+0xb5>
 8048047:	83 ec 0c             	sub    $0xc,%esp
 804804a:	8b 3e                	mov    (%esi),%edi
 804804c:	68 bc a0 04 08       	push   $0x804a0bc
 8048051:	e8 5a 0e 00 00       	call   8048eb0 <strlen>
 8048056:	83 c4 10             	add    $0x10,%esp
 8048059:	39 c7                	cmp    %eax,%edi
 804805b:	0f 8d 84 00 00 00    	jge    80480e5 <splicingcmd+0xb5>
        return 0;
    if (cmd[0] == '/')
 8048061:	80 3b 2f             	cmpb   $0x2f,(%ebx)
 8048064:	74 75                	je     80480db <splicingcmd+0xab>
        return cmd;
    int e = *p;
 8048066:	8b 06                	mov    (%esi),%eax
    while (PATH[e] != ':')
 8048068:	80 b8 bc a0 04 08 3a 	cmpb   $0x3a,0x804a0bc(%eax)
 804806f:	89 c7                	mov    %eax,%edi
 8048071:	74 7c                	je     80480ef <splicingcmd+0xbf>
 8048073:	90                   	nop
 8048074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        e++;
 8048078:	83 c7 01             	add    $0x1,%edi
    if (!cmd || (*p >= strlen(PATH)))
        return 0;
    if (cmd[0] == '/')
        return cmd;
    int e = *p;
    while (PATH[e] != ':')
 804807b:	80 bf bc a0 04 08 3a 	cmpb   $0x3a,0x804a0bc(%edi)
 8048082:	75 f4                	jne    8048078 <splicingcmd+0x48>
 8048084:	89 fa                	mov    %edi,%edx
 8048086:	29 c2                	sub    %eax,%edx
 8048088:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        e++;
    len = (e - *p) + strlen(cmd) + 1;
 804808b:	83 ec 0c             	sub    $0xc,%esp
 804808e:	53                   	push   %ebx
 804808f:	e8 1c 0e 00 00       	call   8048eb0 <strlen>
 8048094:	89 45 e0             	mov    %eax,-0x20(%ebp)
    strncpy(rs, &PATH[*p], e - *p);
 8048097:	8b 06                	mov    (%esi),%eax
 8048099:	89 f9                	mov    %edi,%ecx
 804809b:	83 c4 0c             	add    $0xc,%esp
 804809e:	29 c1                	sub    %eax,%ecx
 80480a0:	05 bc a0 04 08       	add    $0x804a0bc,%eax
 80480a5:	51                   	push   %ecx
 80480a6:	50                   	push   %eax
 80480a7:	ff 75 10             	pushl  0x10(%ebp)
 80480aa:	e8 31 0f 00 00       	call   8048fe0 <strncpy>
    strcat(rs, cmd);
 80480af:	58                   	pop    %eax
 80480b0:	5a                   	pop    %edx
 80480b1:	53                   	push   %ebx
 80480b2:	ff 75 10             	pushl  0x10(%ebp)
 80480b5:	e8 76 0f 00 00       	call   8049030 <strcat>
    rs[len] = '\0';
 80480ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
 80480bd:	03 45 10             	add    0x10(%ebp),%eax
    *p = e + 1;
 80480c0:	83 c4 10             	add    $0x10,%esp
    while (PATH[e] != ':')
        e++;
    len = (e - *p) + strlen(cmd) + 1;
    strncpy(rs, &PATH[*p], e - *p);
    strcat(rs, cmd);
    rs[len] = '\0';
 80480c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 80480c6:	c6 44 02 01 00       	movb   $0x0,0x1(%edx,%eax,1)
    *p = e + 1;
 80480cb:	8d 57 01             	lea    0x1(%edi),%edx
 80480ce:	8b 45 10             	mov    0x10(%ebp),%eax
 80480d1:	89 16                	mov    %edx,(%esi)

    return rs;
}
 80480d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 80480d6:	5b                   	pop    %ebx
 80480d7:	5e                   	pop    %esi
 80480d8:	5f                   	pop    %edi
 80480d9:	5d                   	pop    %ebp
 80480da:	c3                   	ret    
 80480db:	8d 65 f4             	lea    -0xc(%ebp),%esp
 80480de:	89 d8                	mov    %ebx,%eax
 80480e0:	5b                   	pop    %ebx
 80480e1:	5e                   	pop    %esi
 80480e2:	5f                   	pop    %edi
 80480e3:	5d                   	pop    %ebp
 80480e4:	c3                   	ret    
 80480e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
char *splicingcmd(char *cmd, char *path, char *rs, int *p)
{
    int len;

    if (!cmd || (*p >= strlen(PATH)))
        return 0;
 80480e8:	31 c0                	xor    %eax,%eax
    strcat(rs, cmd);
    rs[len] = '\0';
    *p = e + 1;

    return rs;
}
 80480ea:	5b                   	pop    %ebx
 80480eb:	5e                   	pop    %esi
 80480ec:	5f                   	pop    %edi
 80480ed:	5d                   	pop    %ebp
 80480ee:	c3                   	ret    
    if (!cmd || (*p >= strlen(PATH)))
        return 0;
    if (cmd[0] == '/')
        return cmd;
    int e = *p;
    while (PATH[e] != ':')
 80480ef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 80480f6:	eb 93                	jmp    804808b <splicingcmd+0x5b>
 80480f8:	90                   	nop
 80480f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

08048100 <runcmd>:

    return rs;
}

void runcmd(struct cmd *cmd)
{
 8048100:	55                   	push   %ebp
 8048101:	89 e5                	mov    %esp,%ebp
 8048103:	57                   	push   %edi
 8048104:	56                   	push   %esi
 8048105:	53                   	push   %ebx
 8048106:	83 ec 3c             	sub    $0x3c,%esp
 8048109:	8b 5d 08             	mov    0x8(%ebp),%ebx
    char rscmd[CMDLEN];
    struct execcmd *ecmd;
    struct pipecmd *pcmd;
    struct redircmd *rcmd;
    struct backcmd *bcmd;
    if(!cmd)
 804810c:	85 db                	test   %ebx,%ebx
 804810e:	0f 84 d4 01 00 00    	je     80482e8 <runcmd+0x1e8>
        exit();

    switch (cmd->type) {
 8048114:	8b 03                	mov    (%ebx),%eax
 8048116:	83 f8 3c             	cmp    $0x3c,%eax
 8048119:	0f 84 49 01 00 00    	je     8048268 <runcmd+0x168>
 804811f:	0f 8f ab 00 00 00    	jg     80481d0 <runcmd+0xd0>
 8048125:	83 f8 20             	cmp    $0x20,%eax
 8048128:	74 36                	je     8048160 <runcmd+0x60>
 804812a:	83 f8 26             	cmp    $0x26,%eax
 804812d:	0f 85 0d 01 00 00    	jne    8048240 <runcmd+0x140>

int forkv(void)
{
    int pid;
  
    if ((pid = fork()) < 0)
 8048133:	e8 c8 10 00 00       	call   8049200 <fork>
 8048138:	85 c0                	test   %eax,%eax
 804813a:	0f 88 b8 01 00 00    	js     80482f8 <runcmd+0x1f8>
            runcmd(pcmd->left);
            break;

        case '&':
            bcmd = (struct backcmd *)cmd;
            if (forkv() == 0)
 8048140:	75 79                	jne    80481bb <runcmd+0xbb>
                runcmd(bcmd->cmd);
 8048142:	83 ec 0c             	sub    $0xc,%esp
 8048145:	ff 73 04             	pushl  0x4(%ebx)
 8048148:	e8 b3 ff ff ff       	call   8048100 <runcmd>
 804814d:	83 c4 10             	add    $0x10,%esp
            break;

        default:
            panic("runcmd!!!\n");
    }    
    exit();
 8048150:	e8 cb 10 00 00       	call   8049220 <exit>
}
 8048155:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048158:	5b                   	pop    %ebx
 8048159:	5e                   	pop    %esi
 804815a:	5f                   	pop    %edi
 804815b:	5d                   	pop    %ebp
 804815c:	c3                   	ret    
 804815d:	8d 76 00             	lea    0x0(%esi),%esi
        exit();

    switch (cmd->type) {
        case ' ':
            ecmd = (struct execcmd *)cmd;
            if(ecmd->argv[0] == 0)
 8048160:	8b 43 04             	mov    0x4(%ebx),%eax
 8048163:	85 c0                	test   %eax,%eax
 8048165:	0f 84 b9 01 00 00    	je     8048324 <runcmd+0x224>
                exit();
            px = 0;
            while (splicingcmd(ecmd->argv[0], PATH, rscmd, &px))
                if (exec(rscmd, ecmd->argv) == -1)
 804816b:	8d 53 04             	lea    0x4(%ebx),%edx
    switch (cmd->type) {
        case ' ':
            ecmd = (struct execcmd *)cmd;
            if(ecmd->argv[0] == 0)
                exit();
            px = 0;
 804816e:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
 8048175:	8d 7d c8             	lea    -0x38(%ebp),%edi
 8048178:	8d 75 d4             	lea    -0x2c(%ebp),%esi
            while (splicingcmd(ecmd->argv[0], PATH, rscmd, &px))
                if (exec(rscmd, ecmd->argv) == -1)
 804817b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
        case ' ':
            ecmd = (struct execcmd *)cmd;
            if(ecmd->argv[0] == 0)
                exit();
            px = 0;
            while (splicingcmd(ecmd->argv[0], PATH, rscmd, &px))
 804817e:	eb 12                	jmp    8048192 <runcmd+0x92>
                if (exec(rscmd, ecmd->argv) == -1)
 8048180:	83 ec 08             	sub    $0x8,%esp
 8048183:	ff 75 c4             	pushl  -0x3c(%ebp)
 8048186:	56                   	push   %esi
 8048187:	e8 34 11 00 00       	call   80492c0 <exec>
 804818c:	8b 43 04             	mov    0x4(%ebx),%eax
 804818f:	83 c4 10             	add    $0x10,%esp
        case ' ':
            ecmd = (struct execcmd *)cmd;
            if(ecmd->argv[0] == 0)
                exit();
            px = 0;
            while (splicingcmd(ecmd->argv[0], PATH, rscmd, &px))
 8048192:	57                   	push   %edi
 8048193:	56                   	push   %esi
 8048194:	68 bc a0 04 08       	push   $0x804a0bc
 8048199:	50                   	push   %eax
 804819a:	e8 91 fe ff ff       	call   8048030 <splicingcmd>
 804819f:	83 c4 10             	add    $0x10,%esp
 80481a2:	85 c0                	test   %eax,%eax
 80481a4:	75 da                	jne    8048180 <runcmd+0x80>
                if (exec(rscmd, ecmd->argv) == -1)
                    continue;
            printf(1, "Wsh: %s -- command not found!\n", ecmd->argv[0]);
 80481a6:	83 ec 04             	sub    $0x4,%esp
 80481a9:	ff 73 04             	pushl  0x4(%ebx)
 80481ac:	68 e0 a0 04 08       	push   $0x804a0e0
 80481b1:	6a 01                	push   $0x1
 80481b3:	e8 e8 0a 00 00       	call   8048ca0 <printf>
            break;
 80481b8:	83 c4 10             	add    $0x10,%esp
            break;

        default:
            panic("runcmd!!!\n");
    }    
    exit();
 80481bb:	e8 60 10 00 00       	call   8049220 <exit>
}
 80481c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 80481c3:	5b                   	pop    %ebx
 80481c4:	5e                   	pop    %esi
 80481c5:	5f                   	pop    %edi
 80481c6:	5d                   	pop    %ebp
 80481c7:	c3                   	ret    
 80481c8:	90                   	nop
 80481c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct redircmd *rcmd;
    struct backcmd *bcmd;
    if(!cmd)
        exit();

    switch (cmd->type) {
 80481d0:	83 f8 3e             	cmp    $0x3e,%eax
 80481d3:	0f 84 8f 00 00 00    	je     8048268 <runcmd+0x168>
 80481d9:	83 f8 7c             	cmp    $0x7c,%eax
 80481dc:	75 62                	jne    8048240 <runcmd+0x140>
            break;

        case '|':
            pcmd = (struct pipecmd *)cmd;
            r = 0;
            if (pipe(p) < 0) 
 80481de:	8d 45 cc             	lea    -0x34(%ebp),%eax
 80481e1:	83 ec 0c             	sub    $0xc,%esp
 80481e4:	50                   	push   %eax
 80481e5:	e8 f6 10 00 00       	call   80492e0 <pipe>
 80481ea:	83 c4 10             	add    $0x10,%esp
 80481ed:	85 c0                	test   %eax,%eax
 80481ef:	0f 88 13 01 00 00    	js     8048308 <runcmd+0x208>

int forkv(void)
{
    int pid;
  
    if ((pid = fork()) < 0)
 80481f5:	e8 06 10 00 00       	call   8049200 <fork>
 80481fa:	85 c0                	test   %eax,%eax
 80481fc:	0f 88 ae 00 00 00    	js     80482b0 <runcmd+0x1b0>
        case '|':
            pcmd = (struct pipecmd *)cmd;
            r = 0;
            if (pipe(p) < 0) 
                panic("Pipe Error!!!\n");
            if ((pid = forkv())) {
 8048202:	0f 85 ad 00 00 00    	jne    80482b5 <runcmd+0x1b5>
                wait();
                close(p[1]);
                dup2(p[0], 0);
                runcmd(pcmd->right);
            }
            close(p[0]);
 8048208:	83 ec 0c             	sub    $0xc,%esp
 804820b:	ff 75 cc             	pushl  -0x34(%ebp)
 804820e:	e8 6d 11 00 00       	call   8049380 <close>
            dup2(p[1], 1);
 8048213:	58                   	pop    %eax
 8048214:	5a                   	pop    %edx
 8048215:	6a 01                	push   $0x1
 8048217:	ff 75 d0             	pushl  -0x30(%ebp)
 804821a:	e8 01 11 00 00       	call   8049320 <dup2>
            runcmd(pcmd->left);
 804821f:	59                   	pop    %ecx
 8048220:	ff 73 04             	pushl  0x4(%ebx)
 8048223:	e8 d8 fe ff ff       	call   8048100 <runcmd>
            break;
 8048228:	83 c4 10             	add    $0x10,%esp
            break;

        default:
            panic("runcmd!!!\n");
    }    
    exit();
 804822b:	e8 f0 0f 00 00       	call   8049220 <exit>
}
 8048230:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048233:	5b                   	pop    %ebx
 8048234:	5e                   	pop    %esi
 8048235:	5f                   	pop    %edi
 8048236:	5d                   	pop    %ebp
 8048237:	c3                   	ret    
 8048238:	90                   	nop
 8048239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
 8048240:	83 ec 08             	sub    $0x8,%esp
 8048243:	68 48 a0 04 08       	push   $0x804a048
 8048248:	6a 02                	push   $0x2
 804824a:	e8 51 0a 00 00       	call   8048ca0 <printf>
    exit();
 804824f:	e8 cc 0f 00 00       	call   8049220 <exit>
 8048254:	83 c4 10             	add    $0x10,%esp
            break;

        default:
            panic("runcmd!!!\n");
    }    
    exit();
 8048257:	e8 c4 0f 00 00       	call   8049220 <exit>
}
 804825c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 804825f:	5b                   	pop    %ebx
 8048260:	5e                   	pop    %esi
 8048261:	5f                   	pop    %edi
 8048262:	5d                   	pop    %ebp
 8048263:	c3                   	ret    
 8048264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
            printf(1, "Wsh: %s -- command not found!\n", ecmd->argv[0]);
            break;
        case '>':
        case '<':
            rcmd = (struct redircmd *)cmd;
            close(rcmd->fd);
 8048268:	83 ec 0c             	sub    $0xc,%esp
 804826b:	ff 73 10             	pushl  0x10(%ebx)
 804826e:	e8 0d 11 00 00       	call   8049380 <close>
            if (open(rcmd->file, rcmd->mode) < 0)
 8048273:	58                   	pop    %eax
 8048274:	5a                   	pop    %edx
 8048275:	ff 73 0c             	pushl  0xc(%ebx)
 8048278:	ff 73 08             	pushl  0x8(%ebx)
 804827b:	e8 80 11 00 00       	call   8049400 <open>
 8048280:	83 c4 10             	add    $0x10,%esp
 8048283:	85 c0                	test   %eax,%eax
 8048285:	0f 89 b7 fe ff ff    	jns    8048142 <runcmd+0x42>
    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
 804828b:	83 ec 08             	sub    $0x8,%esp
 804828e:	68 2b a0 04 08       	push   $0x804a02b
 8048293:	6a 02                	push   $0x2
 8048295:	e8 06 0a 00 00       	call   8048ca0 <printf>
    exit();
 804829a:	e8 81 0f 00 00       	call   8049220 <exit>
 804829f:	83 c4 10             	add    $0x10,%esp
 80482a2:	e9 9b fe ff ff       	jmp    8048142 <runcmd+0x42>
 80482a7:	89 f6                	mov    %esi,%esi
 80482a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
 80482b0:	e8 5b fd ff ff       	call   8048010 <forkv.part.1>
            pcmd = (struct pipecmd *)cmd;
            r = 0;
            if (pipe(p) < 0) 
                panic("Pipe Error!!!\n");
            if ((pid = forkv())) {
                wait();
 80482b5:	e8 c6 0f 00 00       	call   8049280 <wait>
                close(p[1]);
 80482ba:	83 ec 0c             	sub    $0xc,%esp
 80482bd:	ff 75 d0             	pushl  -0x30(%ebp)
 80482c0:	e8 bb 10 00 00       	call   8049380 <close>
                dup2(p[0], 0);
 80482c5:	5e                   	pop    %esi
 80482c6:	5f                   	pop    %edi
 80482c7:	6a 00                	push   $0x0
 80482c9:	ff 75 cc             	pushl  -0x34(%ebp)
 80482cc:	e8 4f 10 00 00       	call   8049320 <dup2>
                runcmd(pcmd->right);
 80482d1:	58                   	pop    %eax
 80482d2:	ff 73 08             	pushl  0x8(%ebx)
 80482d5:	e8 26 fe ff ff       	call   8048100 <runcmd>
 80482da:	83 c4 10             	add    $0x10,%esp
 80482dd:	e9 26 ff ff ff       	jmp    8048208 <runcmd+0x108>
 80482e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    struct execcmd *ecmd;
    struct pipecmd *pcmd;
    struct redircmd *rcmd;
    struct backcmd *bcmd;
    if(!cmd)
        exit();
 80482e8:	e8 33 0f 00 00       	call   8049220 <exit>
 80482ed:	e9 22 fe ff ff       	jmp    8048114 <runcmd+0x14>
 80482f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 80482f8:	e8 13 fd ff ff       	call   8048010 <forkv.part.1>
 80482fd:	e9 b9 fe ff ff       	jmp    80481bb <runcmd+0xbb>
 8048302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
 8048308:	83 ec 08             	sub    $0x8,%esp
 804830b:	68 39 a0 04 08       	push   $0x804a039
 8048310:	6a 02                	push   $0x2
 8048312:	e8 89 09 00 00       	call   8048ca0 <printf>
    exit();
 8048317:	e8 04 0f 00 00       	call   8049220 <exit>
 804831c:	83 c4 10             	add    $0x10,%esp
 804831f:	e9 d1 fe ff ff       	jmp    80481f5 <runcmd+0xf5>

    switch (cmd->type) {
        case ' ':
            ecmd = (struct execcmd *)cmd;
            if(ecmd->argv[0] == 0)
                exit();
 8048324:	e8 f7 0e 00 00       	call   8049220 <exit>
 8048329:	8b 43 04             	mov    0x4(%ebx),%eax
 804832c:	e9 3a fe ff ff       	jmp    804816b <runcmd+0x6b>
 8048331:	eb 0d                	jmp    8048340 <getcmd>
 8048333:	90                   	nop
 8048334:	90                   	nop
 8048335:	90                   	nop
 8048336:	90                   	nop
 8048337:	90                   	nop
 8048338:	90                   	nop
 8048339:	90                   	nop
 804833a:	90                   	nop
 804833b:	90                   	nop
 804833c:	90                   	nop
 804833d:	90                   	nop
 804833e:	90                   	nop
 804833f:	90                   	nop

08048340 <getcmd>:
    }    
    exit();
}

int getcmd(char *buf, int nbytes)
{
 8048340:	55                   	push   %ebp
 8048341:	89 e5                	mov    %esp,%ebp
 8048343:	56                   	push   %esi
 8048344:	53                   	push   %ebx
 8048345:	8b 75 0c             	mov    0xc(%ebp),%esi
 8048348:	8b 5d 08             	mov    0x8(%ebp),%ebx
    printf(stdout, "Wsh> ");
 804834b:	83 ec 08             	sub    $0x8,%esp
 804834e:	68 53 a0 04 08       	push   $0x804a053
 8048353:	6a 01                	push   $0x1
 8048355:	e8 46 09 00 00       	call   8048ca0 <printf>
    memset(buf, 0, nbytes);
 804835a:	83 c4 0c             	add    $0xc,%esp
 804835d:	56                   	push   %esi
 804835e:	6a 00                	push   $0x0
 8048360:	53                   	push   %ebx
 8048361:	e8 ba 0d 00 00       	call   8049120 <memset>
    gets(buf, nbytes);
 8048366:	58                   	pop    %eax
 8048367:	5a                   	pop    %edx
 8048368:	56                   	push   %esi
 8048369:	53                   	push   %ebx
 804836a:	e8 c1 08 00 00       	call   8048c30 <gets>
 804836f:	83 c4 10             	add    $0x10,%esp
 8048372:	31 c0                	xor    %eax,%eax
 8048374:	80 3b 00             	cmpb   $0x0,(%ebx)
 8048377:	0f 94 c0             	sete   %al
    if (buf[0] == '\0')
        return -1;
    return 0;
}
 804837a:	8d 65 f8             	lea    -0x8(%ebp),%esp
 804837d:	f7 d8                	neg    %eax
 804837f:	5b                   	pop    %ebx
 8048380:	5e                   	pop    %esi
 8048381:	5d                   	pop    %ebp
 8048382:	c3                   	ret    
 8048383:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 8048389:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08048390 <panic>:

    return 0;
}

void panic(const char *s)
{
 8048390:	55                   	push   %ebp
 8048391:	89 e5                	mov    %esp,%ebp
 8048393:	83 ec 10             	sub    $0x10,%esp
    printf(stderr, s);
 8048396:	ff 75 08             	pushl  0x8(%ebp)
 8048399:	6a 02                	push   $0x2
 804839b:	e8 00 09 00 00       	call   8048ca0 <printf>
    exit();
 80483a0:	83 c4 10             	add    $0x10,%esp
}
 80483a3:	c9                   	leave  
}

void panic(const char *s)
{
    printf(stderr, s);
    exit();
 80483a4:	e9 77 0e 00 00       	jmp    8049220 <exit>
 80483a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

080483b0 <forkv>:
}

int forkv(void)
{
 80483b0:	55                   	push   %ebp
 80483b1:	89 e5                	mov    %esp,%ebp
 80483b3:	53                   	push   %ebx
 80483b4:	83 ec 04             	sub    $0x4,%esp
    int pid;
  
    if ((pid = fork()) < 0)
 80483b7:	e8 44 0e 00 00       	call   8049200 <fork>
 80483bc:	85 c0                	test   %eax,%eax
 80483be:	89 c3                	mov    %eax,%ebx
 80483c0:	78 0e                	js     80483d0 <forkv+0x20>
        panic("fork error!!!\n");
    return pid;
}
 80483c2:	83 c4 04             	add    $0x4,%esp
 80483c5:	89 d8                	mov    %ebx,%eax
 80483c7:	5b                   	pop    %ebx
 80483c8:	5d                   	pop    %ebp
 80483c9:	c3                   	ret    
 80483ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 80483d0:	e8 3b fc ff ff       	call   8048010 <forkv.part.1>
 80483d5:	83 c4 04             	add    $0x4,%esp
 80483d8:	89 d8                	mov    %ebx,%eax
 80483da:	5b                   	pop    %ebx
 80483db:	5d                   	pop    %ebp
 80483dc:	c3                   	ret    
 80483dd:	8d 76 00             	lea    0x0(%esi),%esi

080483e0 <execcmd>:

struct cmd *execcmd(void)
{
 80483e0:	55                   	push   %ebp
 80483e1:	89 e5                	mov    %esp,%ebp
 80483e3:	53                   	push   %ebx
 80483e4:	83 ec 10             	sub    $0x10,%esp
    struct execcmd *cmd;

    cmd = malloc(sizeof(struct execcmd));
 80483e7:	6a 2c                	push   $0x2c
 80483e9:	e8 82 11 00 00       	call   8049570 <malloc>
    memset(cmd, 0, sizeof(struct execcmd));
 80483ee:	83 c4 0c             	add    $0xc,%esp

struct cmd *execcmd(void)
{
    struct execcmd *cmd;

    cmd = malloc(sizeof(struct execcmd));
 80483f1:	89 c3                	mov    %eax,%ebx
    memset(cmd, 0, sizeof(struct execcmd));
 80483f3:	6a 2c                	push   $0x2c
 80483f5:	6a 00                	push   $0x0
 80483f7:	50                   	push   %eax
 80483f8:	e8 23 0d 00 00       	call   8049120 <memset>
    cmd->type = ' ';
 80483fd:	c7 03 20 00 00 00    	movl   $0x20,(%ebx)
    return (struct cmd *)cmd;
}
 8048403:	89 d8                	mov    %ebx,%eax
 8048405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 8048408:	c9                   	leave  
 8048409:	c3                   	ret    
 804840a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

08048410 <redircmd>:

struct cmd *redircmd(struct cmd *subcmd, char *file, int type)
{
 8048410:	55                   	push   %ebp
 8048411:	89 e5                	mov    %esp,%ebp
 8048413:	56                   	push   %esi
 8048414:	53                   	push   %ebx
 8048415:	8b 75 10             	mov    0x10(%ebp),%esi
    struct redircmd *cmd;

    cmd = malloc(sizeof(struct redircmd));
 8048418:	83 ec 0c             	sub    $0xc,%esp
 804841b:	6a 14                	push   $0x14
 804841d:	e8 4e 11 00 00       	call   8049570 <malloc>
    memset(cmd, 0, sizeof(struct redircmd));
 8048422:	83 c4 0c             	add    $0xc,%esp

struct cmd *redircmd(struct cmd *subcmd, char *file, int type)
{
    struct redircmd *cmd;

    cmd = malloc(sizeof(struct redircmd));
 8048425:	89 c3                	mov    %eax,%ebx
    memset(cmd, 0, sizeof(struct redircmd));
 8048427:	6a 14                	push   $0x14
 8048429:	6a 00                	push   $0x0
 804842b:	50                   	push   %eax
 804842c:	e8 ef 0c 00 00       	call   8049120 <memset>
    cmd->type = type;
    cmd->cmd = subcmd;
 8048431:	8b 45 08             	mov    0x8(%ebp),%eax
    cmd->file = file;
    cmd->mode = (type == '<') ? (O_RDONLY) : (O_WRONLY|O_CREAT);
 8048434:	83 c4 10             	add    $0x10,%esp
{
    struct redircmd *cmd;

    cmd = malloc(sizeof(struct redircmd));
    memset(cmd, 0, sizeof(struct redircmd));
    cmd->type = type;
 8048437:	89 33                	mov    %esi,(%ebx)
    cmd->cmd = subcmd;
 8048439:	89 43 04             	mov    %eax,0x4(%ebx)
    cmd->file = file;
 804843c:	8b 45 0c             	mov    0xc(%ebp),%eax
 804843f:	89 43 08             	mov    %eax,0x8(%ebx)
    cmd->mode = (type == '<') ? (O_RDONLY) : (O_WRONLY|O_CREAT);
 8048442:	31 c0                	xor    %eax,%eax
 8048444:	83 fe 3c             	cmp    $0x3c,%esi
 8048447:	0f 95 c0             	setne  %al
 804844a:	8d 44 c0 01          	lea    0x1(%eax,%eax,8),%eax
 804844e:	89 43 0c             	mov    %eax,0xc(%ebx)
    cmd->fd = (type == '<') ? 0 : 1;
 8048451:	0f 95 c0             	setne  %al
 8048454:	0f b6 c0             	movzbl %al,%eax
 8048457:	89 43 10             	mov    %eax,0x10(%ebx)
    return (struct cmd *)cmd;
}
 804845a:	8d 65 f8             	lea    -0x8(%ebp),%esp
 804845d:	89 d8                	mov    %ebx,%eax
 804845f:	5b                   	pop    %ebx
 8048460:	5e                   	pop    %esi
 8048461:	5d                   	pop    %ebp
 8048462:	c3                   	ret    
 8048463:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 8048469:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08048470 <pipecmd>:

struct cmd *pipecmd(struct cmd *left, struct cmd *right)
{
 8048470:	55                   	push   %ebp
 8048471:	89 e5                	mov    %esp,%ebp
 8048473:	53                   	push   %ebx
 8048474:	83 ec 10             	sub    $0x10,%esp
    struct pipecmd *cmd;

    cmd = malloc(sizeof(struct pipecmd));
 8048477:	6a 0c                	push   $0xc
 8048479:	e8 f2 10 00 00       	call   8049570 <malloc>
    memset(cmd, 0, sizeof(struct pipecmd));
 804847e:	83 c4 0c             	add    $0xc,%esp

struct cmd *pipecmd(struct cmd *left, struct cmd *right)
{
    struct pipecmd *cmd;

    cmd = malloc(sizeof(struct pipecmd));
 8048481:	89 c3                	mov    %eax,%ebx
    memset(cmd, 0, sizeof(struct pipecmd));
 8048483:	6a 0c                	push   $0xc
 8048485:	6a 00                	push   $0x0
 8048487:	50                   	push   %eax
 8048488:	e8 93 0c 00 00       	call   8049120 <memset>
    cmd->type = '|';
    cmd->left = left;
 804848d:	8b 45 08             	mov    0x8(%ebp),%eax
{
    struct pipecmd *cmd;

    cmd = malloc(sizeof(struct pipecmd));
    memset(cmd, 0, sizeof(struct pipecmd));
    cmd->type = '|';
 8048490:	c7 03 7c 00 00 00    	movl   $0x7c,(%ebx)
    cmd->left = left;
 8048496:	89 43 04             	mov    %eax,0x4(%ebx)
    cmd->right = right;
 8048499:	8b 45 0c             	mov    0xc(%ebp),%eax
 804849c:	89 43 08             	mov    %eax,0x8(%ebx)
    return (struct cmd *)cmd;
}
 804849f:	89 d8                	mov    %ebx,%eax
 80484a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 80484a4:	c9                   	leave  
 80484a5:	c3                   	ret    
 80484a6:	8d 76 00             	lea    0x0(%esi),%esi
 80484a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

080484b0 <backcmd>:

struct cmd *backcmd(struct cmd *subcmd)
{
 80484b0:	55                   	push   %ebp
 80484b1:	89 e5                	mov    %esp,%ebp
 80484b3:	53                   	push   %ebx
 80484b4:	83 ec 10             	sub    $0x10,%esp
    struct backcmd *cmd;

    cmd = malloc(sizeof(struct backcmd));
 80484b7:	6a 08                	push   $0x8
 80484b9:	e8 b2 10 00 00       	call   8049570 <malloc>
    memset(cmd, 0, sizeof(struct backcmd));
 80484be:	83 c4 0c             	add    $0xc,%esp

struct cmd *backcmd(struct cmd *subcmd)
{
    struct backcmd *cmd;

    cmd = malloc(sizeof(struct backcmd));
 80484c1:	89 c3                	mov    %eax,%ebx
    memset(cmd, 0, sizeof(struct backcmd));
 80484c3:	6a 08                	push   $0x8
 80484c5:	6a 00                	push   $0x0
 80484c7:	50                   	push   %eax
 80484c8:	e8 53 0c 00 00       	call   8049120 <memset>
    cmd->type = '&';
    cmd->cmd = subcmd;
 80484cd:	8b 45 08             	mov    0x8(%ebp),%eax
{
    struct backcmd *cmd;

    cmd = malloc(sizeof(struct backcmd));
    memset(cmd, 0, sizeof(struct backcmd));
    cmd->type = '&';
 80484d0:	c7 03 26 00 00 00    	movl   $0x26,(%ebx)
    cmd->cmd = subcmd;
 80484d6:	89 43 04             	mov    %eax,0x4(%ebx)
    return (struct cmd *)cmd;
}
 80484d9:	89 d8                	mov    %ebx,%eax
 80484db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 80484de:	c9                   	leave  
 80484df:	c3                   	ret    

080484e0 <gettoken>:
// Parsing
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&";

int gettoken(char **ps, char *es, char **q, char **eq)
{
 80484e0:	55                   	push   %ebp
 80484e1:	89 e5                	mov    %esp,%ebp
 80484e3:	57                   	push   %edi
 80484e4:	56                   	push   %esi
 80484e5:	53                   	push   %ebx
 80484e6:	83 ec 0c             	sub    $0xc,%esp
    char *s;
    int ret;
    
    s = *ps;
 80484e9:	8b 45 08             	mov    0x8(%ebp),%eax
// Parsing
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&";

int gettoken(char **ps, char *es, char **q, char **eq)
{
 80484ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 80484ef:	8b 7d 10             	mov    0x10(%ebp),%edi
    char *s;
    int ret;
    
    s = *ps;
 80484f2:	8b 30                	mov    (%eax),%esi
    while(s < es && strchr(whitespace, *s))
 80484f4:	39 de                	cmp    %ebx,%esi
 80484f6:	72 13                	jb     804850b <gettoken+0x2b>
 80484f8:	eb 29                	jmp    8048523 <gettoken+0x43>
 80484fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        s++;
 8048500:	83 c6 01             	add    $0x1,%esi
{
    char *s;
    int ret;
    
    s = *ps;
    while(s < es && strchr(whitespace, *s))
 8048503:	39 f3                	cmp    %esi,%ebx
 8048505:	0f 84 f5 00 00 00    	je     8048600 <gettoken+0x120>
 804850b:	0f be 06             	movsbl (%esi),%eax
 804850e:	83 ec 08             	sub    $0x8,%esp
 8048511:	50                   	push   %eax
 8048512:	68 b8 ae 04 08       	push   $0x804aeb8
 8048517:	e8 c4 0b 00 00       	call   80490e0 <strchr>
 804851c:	83 c4 10             	add    $0x10,%esp
 804851f:	85 c0                	test   %eax,%eax
 8048521:	75 dd                	jne    8048500 <gettoken+0x20>
        s++;
    if(q)
 8048523:	85 ff                	test   %edi,%edi
 8048525:	74 02                	je     8048529 <gettoken+0x49>
        *q = s;
 8048527:	89 37                	mov    %esi,(%edi)
    ret = *s;
 8048529:	0f be 06             	movsbl (%esi),%eax
    switch (*s) {
 804852c:	3c 3c                	cmp    $0x3c,%al
    s = *ps;
    while(s < es && strchr(whitespace, *s))
        s++;
    if(q)
        *q = s;
    ret = *s;
 804852e:	89 c7                	mov    %eax,%edi
    switch (*s) {
 8048530:	0f 84 ba 00 00 00    	je     80485f0 <gettoken+0x110>
 8048536:	0f 8f ac 00 00 00    	jg     80485e8 <gettoken+0x108>
 804853c:	84 c0                	test   %al,%al
 804853e:	75 50                	jne    8048590 <gettoken+0xb0>
            ret = 'a';
            while ((s < es) && !strchr(whitespace, *s) && !strchr(symbols, *s))
                s++;
            break;
    }
    if (eq)
 8048540:	8b 55 14             	mov    0x14(%ebp),%edx
 8048543:	85 d2                	test   %edx,%edx
 8048545:	74 05                	je     804854c <gettoken+0x6c>
        *eq = s;
 8048547:	8b 45 14             	mov    0x14(%ebp),%eax
 804854a:	89 30                	mov    %esi,(%eax)
    
    while ((s < es) && strchr(whitespace, *s))
 804854c:	39 f3                	cmp    %esi,%ebx
 804854e:	77 0f                	ja     804855f <gettoken+0x7f>
 8048550:	eb 25                	jmp    8048577 <gettoken+0x97>
 8048552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        s++;
 8048558:	83 c6 01             	add    $0x1,%esi
            break;
    }
    if (eq)
        *eq = s;
    
    while ((s < es) && strchr(whitespace, *s))
 804855b:	39 f3                	cmp    %esi,%ebx
 804855d:	74 18                	je     8048577 <gettoken+0x97>
 804855f:	0f be 06             	movsbl (%esi),%eax
 8048562:	83 ec 08             	sub    $0x8,%esp
 8048565:	50                   	push   %eax
 8048566:	68 b8 ae 04 08       	push   $0x804aeb8
 804856b:	e8 70 0b 00 00       	call   80490e0 <strchr>
 8048570:	83 c4 10             	add    $0x10,%esp
 8048573:	85 c0                	test   %eax,%eax
 8048575:	75 e1                	jne    8048558 <gettoken+0x78>
        s++;
    *ps = s;
 8048577:	8b 45 08             	mov    0x8(%ebp),%eax
 804857a:	89 30                	mov    %esi,(%eax)
    return ret;
}
 804857c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 804857f:	89 f8                	mov    %edi,%eax
 8048581:	5b                   	pop    %ebx
 8048582:	5e                   	pop    %esi
 8048583:	5f                   	pop    %edi
 8048584:	5d                   	pop    %ebp
 8048585:	c3                   	ret    
 8048586:	8d 76 00             	lea    0x0(%esi),%esi
 8048589:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    while(s < es && strchr(whitespace, *s))
        s++;
    if(q)
        *q = s;
    ret = *s;
    switch (*s) {
 8048590:	3c 26                	cmp    $0x26,%al
 8048592:	74 5c                	je     80485f0 <gettoken+0x110>
            s++;
            break;

        default:
            ret = 'a';
            while ((s < es) && !strchr(whitespace, *s) && !strchr(symbols, *s))
 8048594:	39 f3                	cmp    %esi,%ebx
 8048596:	77 2a                	ja     80485c2 <gettoken+0xe2>
 8048598:	eb 6f                	jmp    8048609 <gettoken+0x129>
 804859a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 80485a0:	0f be 06             	movsbl (%esi),%eax
 80485a3:	83 ec 08             	sub    $0x8,%esp
 80485a6:	50                   	push   %eax
 80485a7:	68 b0 ae 04 08       	push   $0x804aeb0
 80485ac:	e8 2f 0b 00 00       	call   80490e0 <strchr>
 80485b1:	83 c4 10             	add    $0x10,%esp
 80485b4:	85 c0                	test   %eax,%eax
 80485b6:	75 1f                	jne    80485d7 <gettoken+0xf7>
                s++;
 80485b8:	83 c6 01             	add    $0x1,%esi
            s++;
            break;

        default:
            ret = 'a';
            while ((s < es) && !strchr(whitespace, *s) && !strchr(symbols, *s))
 80485bb:	39 f3                	cmp    %esi,%ebx
 80485bd:	74 48                	je     8048607 <gettoken+0x127>
 80485bf:	0f be 06             	movsbl (%esi),%eax
 80485c2:	83 ec 08             	sub    $0x8,%esp
 80485c5:	50                   	push   %eax
 80485c6:	68 b8 ae 04 08       	push   $0x804aeb8
 80485cb:	e8 10 0b 00 00       	call   80490e0 <strchr>
 80485d0:	83 c4 10             	add    $0x10,%esp
 80485d3:	85 c0                	test   %eax,%eax
 80485d5:	74 c9                	je     80485a0 <gettoken+0xc0>
        case '>':
            s++;
            break;

        default:
            ret = 'a';
 80485d7:	bf 61 00 00 00       	mov    $0x61,%edi
 80485dc:	e9 5f ff ff ff       	jmp    8048540 <gettoken+0x60>
 80485e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    while(s < es && strchr(whitespace, *s))
        s++;
    if(q)
        *q = s;
    ret = *s;
    switch (*s) {
 80485e8:	3c 3e                	cmp    $0x3e,%al
 80485ea:	74 04                	je     80485f0 <gettoken+0x110>
 80485ec:	3c 7c                	cmp    $0x7c,%al
 80485ee:	75 a4                	jne    8048594 <gettoken+0xb4>
            break;
        case '&':
        case '|':
        case '<':
        case '>':
            s++;
 80485f0:	83 c6 01             	add    $0x1,%esi
            break;
 80485f3:	e9 48 ff ff ff       	jmp    8048540 <gettoken+0x60>
 80485f8:	90                   	nop
 80485f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 8048600:	89 de                	mov    %ebx,%esi
 8048602:	e9 1c ff ff ff       	jmp    8048523 <gettoken+0x43>
 8048607:	89 de                	mov    %ebx,%esi
            ret = 'a';
            while ((s < es) && !strchr(whitespace, *s) && !strchr(symbols, *s))
                s++;
            break;
    }
    if (eq)
 8048609:	8b 45 14             	mov    0x14(%ebp),%eax
 804860c:	bf 61 00 00 00       	mov    $0x61,%edi
 8048611:	85 c0                	test   %eax,%eax
 8048613:	0f 85 2e ff ff ff    	jne    8048547 <gettoken+0x67>
 8048619:	e9 59 ff ff ff       	jmp    8048577 <gettoken+0x97>
 804861e:	66 90                	xchg   %ax,%ax

08048620 <peek>:
    *ps = s;
    return ret;
}

int peek(char **ps, char *es, char *toks)
{
 8048620:	55                   	push   %ebp
 8048621:	89 e5                	mov    %esp,%ebp
 8048623:	57                   	push   %edi
 8048624:	56                   	push   %esi
 8048625:	53                   	push   %ebx
 8048626:	83 ec 0c             	sub    $0xc,%esp
 8048629:	8b 7d 08             	mov    0x8(%ebp),%edi
 804862c:	8b 75 0c             	mov    0xc(%ebp),%esi
    char *s;
    
    s = *ps;
 804862f:	8b 1f                	mov    (%edi),%ebx
    while ((s < es) && strchr(whitespace, *s))
 8048631:	39 f3                	cmp    %esi,%ebx
 8048633:	72 12                	jb     8048647 <peek+0x27>
 8048635:	eb 28                	jmp    804865f <peek+0x3f>
 8048637:	89 f6                	mov    %esi,%esi
 8048639:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
        s++;
 8048640:	83 c3 01             	add    $0x1,%ebx
int peek(char **ps, char *es, char *toks)
{
    char *s;
    
    s = *ps;
    while ((s < es) && strchr(whitespace, *s))
 8048643:	39 de                	cmp    %ebx,%esi
 8048645:	74 18                	je     804865f <peek+0x3f>
 8048647:	0f be 03             	movsbl (%ebx),%eax
 804864a:	83 ec 08             	sub    $0x8,%esp
 804864d:	50                   	push   %eax
 804864e:	68 b8 ae 04 08       	push   $0x804aeb8
 8048653:	e8 88 0a 00 00       	call   80490e0 <strchr>
 8048658:	83 c4 10             	add    $0x10,%esp
 804865b:	85 c0                	test   %eax,%eax
 804865d:	75 e1                	jne    8048640 <peek+0x20>
        s++;
    *ps = s;
 804865f:	89 1f                	mov    %ebx,(%edi)
    return (*s && strchr(toks, *s));
 8048661:	0f be 13             	movsbl (%ebx),%edx
 8048664:	31 c0                	xor    %eax,%eax
 8048666:	84 d2                	test   %dl,%dl
 8048668:	74 17                	je     8048681 <peek+0x61>
 804866a:	83 ec 08             	sub    $0x8,%esp
 804866d:	52                   	push   %edx
 804866e:	ff 75 10             	pushl  0x10(%ebp)
 8048671:	e8 6a 0a 00 00       	call   80490e0 <strchr>
 8048676:	83 c4 10             	add    $0x10,%esp
 8048679:	85 c0                	test   %eax,%eax
 804867b:	0f 95 c0             	setne  %al
 804867e:	0f b6 c0             	movzbl %al,%eax
}
 8048681:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048684:	5b                   	pop    %ebx
 8048685:	5e                   	pop    %esi
 8048686:	5f                   	pop    %edi
 8048687:	5d                   	pop    %ebp
 8048688:	c3                   	ret    
 8048689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

08048690 <safe_copy>:

// make a copy of the characters in the input buffer, starting from src through des.
// null-terminate the copy to make it a string.
char *safe_copy(char *src, char *des)
{
 8048690:	55                   	push   %ebp
 8048691:	89 e5                	mov    %esp,%ebp
 8048693:	57                   	push   %edi
 8048694:	56                   	push   %esi
 8048695:	53                   	push   %ebx
 8048696:	83 ec 18             	sub    $0x18,%esp
 8048699:	8b 7d 08             	mov    0x8(%ebp),%edi
    int n = des - src;
 804869c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 804869f:	29 fb                	sub    %edi,%ebx
    char *c = malloc(n+1);
 80486a1:	8d 43 01             	lea    0x1(%ebx),%eax
 80486a4:	50                   	push   %eax
 80486a5:	e8 c6 0e 00 00       	call   8049570 <malloc>
    if (!c)
 80486aa:	83 c4 10             	add    $0x10,%esp
 80486ad:	85 c0                	test   %eax,%eax
// make a copy of the characters in the input buffer, starting from src through des.
// null-terminate the copy to make it a string.
char *safe_copy(char *src, char *des)
{
    int n = des - src;
    char *c = malloc(n+1);
 80486af:	89 c6                	mov    %eax,%esi
    if (!c)
 80486b1:	74 1d                	je     80486d0 <safe_copy+0x40>
        panic("safe_copy failed!!!\n");
    strncpy(c, src, n);
 80486b3:	83 ec 04             	sub    $0x4,%esp
 80486b6:	53                   	push   %ebx
 80486b7:	57                   	push   %edi
 80486b8:	56                   	push   %esi
 80486b9:	e8 22 09 00 00       	call   8048fe0 <strncpy>
    c[n] = 0;
 80486be:	c6 04 1e 00          	movb   $0x0,(%esi,%ebx,1)
    return c;
}
 80486c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
 80486c5:	89 f0                	mov    %esi,%eax
 80486c7:	5b                   	pop    %ebx
 80486c8:	5e                   	pop    %esi
 80486c9:	5f                   	pop    %edi
 80486ca:	5d                   	pop    %ebp
 80486cb:	c3                   	ret    
 80486cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
 80486d0:	83 ec 08             	sub    $0x8,%esp
 80486d3:	68 59 a0 04 08       	push   $0x804a059
 80486d8:	6a 02                	push   $0x2
 80486da:	e8 c1 05 00 00       	call   8048ca0 <printf>
    exit();
 80486df:	e8 3c 0b 00 00       	call   8049220 <exit>
 80486e4:	83 c4 10             	add    $0x10,%esp
 80486e7:	eb ca                	jmp    80486b3 <safe_copy+0x23>
 80486e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

080486f0 <parseredirs>:
    }
    return cmd;
}

struct cmd *parseredirs(struct cmd *cmd, char **ps, char *es)
{
 80486f0:	55                   	push   %ebp
 80486f1:	89 e5                	mov    %esp,%ebp
 80486f3:	57                   	push   %edi
 80486f4:	56                   	push   %esi
 80486f5:	53                   	push   %ebx
 80486f6:	83 ec 1c             	sub    $0x1c,%esp
 80486f9:	8b 75 0c             	mov    0xc(%ebp),%esi
 80486fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
 80486ff:	90                   	nop
    int tok;
    char *q, *eq;

    while (peek(ps, es, "<>")) {
 8048700:	83 ec 04             	sub    $0x4,%esp
 8048703:	68 6e a0 04 08       	push   $0x804a06e
 8048708:	53                   	push   %ebx
 8048709:	56                   	push   %esi
 804870a:	e8 11 ff ff ff       	call   8048620 <peek>
 804870f:	83 c4 10             	add    $0x10,%esp
 8048712:	85 c0                	test   %eax,%eax
 8048714:	0f 84 8e 00 00 00    	je     80487a8 <parseredirs+0xb8>
        tok = gettoken(ps, es, 0, 0);
 804871a:	6a 00                	push   $0x0
 804871c:	6a 00                	push   $0x0
 804871e:	53                   	push   %ebx
 804871f:	56                   	push   %esi
 8048720:	e8 bb fd ff ff       	call   80484e0 <gettoken>
 8048725:	89 c7                	mov    %eax,%edi
        if(gettoken(ps, es, &q, &eq) != 'a') 
 8048727:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 804872a:	50                   	push   %eax
 804872b:	8d 45 e0             	lea    -0x20(%ebp),%eax
 804872e:	50                   	push   %eax
 804872f:	53                   	push   %ebx
 8048730:	56                   	push   %esi
 8048731:	e8 aa fd ff ff       	call   80484e0 <gettoken>
 8048736:	83 c4 20             	add    $0x20,%esp
 8048739:	83 f8 61             	cmp    $0x61,%eax
 804873c:	74 17                	je     8048755 <parseredirs+0x65>
    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
 804873e:	83 ec 08             	sub    $0x8,%esp
 8048741:	68 00 a1 04 08       	push   $0x804a100
 8048746:	6a 02                	push   $0x2
 8048748:	e8 53 05 00 00       	call   8048ca0 <printf>
    exit();
 804874d:	e8 ce 0a 00 00       	call   8049220 <exit>
 8048752:	83 c4 10             	add    $0x10,%esp
    while (peek(ps, es, "<>")) {
        tok = gettoken(ps, es, 0, 0);
        if(gettoken(ps, es, &q, &eq) != 'a') 
            panic("missing file for redirection!!!\n");

        switch(tok){
 8048755:	83 ff 3c             	cmp    $0x3c,%edi
 8048758:	74 36                	je     8048790 <parseredirs+0xa0>
 804875a:	83 ff 3e             	cmp    $0x3e,%edi
 804875d:	75 a1                	jne    8048700 <parseredirs+0x10>
            case '<':
                cmd = redircmd(cmd, safe_copy(q, eq), '<');
                break;
            case '>':
                cmd = redircmd(cmd, safe_copy(q, eq), '>');
 804875f:	83 ec 08             	sub    $0x8,%esp
 8048762:	ff 75 e4             	pushl  -0x1c(%ebp)
 8048765:	ff 75 e0             	pushl  -0x20(%ebp)
 8048768:	e8 23 ff ff ff       	call   8048690 <safe_copy>
 804876d:	83 c4 0c             	add    $0xc,%esp
 8048770:	6a 3e                	push   $0x3e
 8048772:	50                   	push   %eax
 8048773:	ff 75 08             	pushl  0x8(%ebp)
 8048776:	e8 95 fc ff ff       	call   8048410 <redircmd>
                break;
 804877b:	83 c4 10             	add    $0x10,%esp
        switch(tok){
            case '<':
                cmd = redircmd(cmd, safe_copy(q, eq), '<');
                break;
            case '>':
                cmd = redircmd(cmd, safe_copy(q, eq), '>');
 804877e:	89 45 08             	mov    %eax,0x8(%ebp)
                break;
 8048781:	e9 7a ff ff ff       	jmp    8048700 <parseredirs+0x10>
 8048786:	8d 76 00             	lea    0x0(%esi),%esi
 8048789:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
        if(gettoken(ps, es, &q, &eq) != 'a') 
            panic("missing file for redirection!!!\n");

        switch(tok){
            case '<':
                cmd = redircmd(cmd, safe_copy(q, eq), '<');
 8048790:	83 ec 08             	sub    $0x8,%esp
 8048793:	ff 75 e4             	pushl  -0x1c(%ebp)
 8048796:	ff 75 e0             	pushl  -0x20(%ebp)
 8048799:	e8 f2 fe ff ff       	call   8048690 <safe_copy>
 804879e:	83 c4 0c             	add    $0xc,%esp
 80487a1:	6a 3c                	push   $0x3c
 80487a3:	eb cd                	jmp    8048772 <parseredirs+0x82>
 80487a5:	8d 76 00             	lea    0x0(%esi),%esi
                cmd = redircmd(cmd, safe_copy(q, eq), '>');
                break;
        }
    }
    return cmd;
}
 80487a8:	8b 45 08             	mov    0x8(%ebp),%eax
 80487ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
 80487ae:	5b                   	pop    %ebx
 80487af:	5e                   	pop    %esi
 80487b0:	5f                   	pop    %edi
 80487b1:	5d                   	pop    %ebp
 80487b2:	c3                   	ret    
 80487b3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 80487b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

080487c0 <parseexec>:

// argv[0] = program's name.
struct cmd *parseexec(char **ps, char *es)
{
 80487c0:	55                   	push   %ebp
 80487c1:	89 e5                	mov    %esp,%ebp
 80487c3:	57                   	push   %edi
 80487c4:	56                   	push   %esi
 80487c5:	53                   	push   %ebx
    struct cmd *ret;
    
    ret = execcmd();
    cmd = (struct execcmd*)ret;

    argc = 0;
 80487c6:	31 db                	xor    %ebx,%ebx
    return cmd;
}

// argv[0] = program's name.
struct cmd *parseexec(char **ps, char *es)
{
 80487c8:	83 ec 2c             	sub    $0x2c,%esp
 80487cb:	8b 75 08             	mov    0x8(%ebp),%esi
 80487ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
    char *q, *eq;
    int tok, argc;
    struct execcmd *cmd;
    struct cmd *ret;
    
    ret = execcmd();
 80487d1:	e8 0a fc ff ff       	call   80483e0 <execcmd>
    cmd = (struct execcmd*)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
 80487d6:	83 ec 04             	sub    $0x4,%esp
    char *q, *eq;
    int tok, argc;
    struct execcmd *cmd;
    struct cmd *ret;
    
    ret = execcmd();
 80487d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cmd = (struct execcmd*)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
 80487dc:	57                   	push   %edi
 80487dd:	56                   	push   %esi
 80487de:	50                   	push   %eax
 80487df:	e8 0c ff ff ff       	call   80486f0 <parseredirs>
    while(!peek(ps, es, "|&")){
 80487e4:	83 c4 10             	add    $0x10,%esp
    
    ret = execcmd();
    cmd = (struct execcmd*)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
 80487e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while(!peek(ps, es, "|&")){
 80487ea:	eb 17                	jmp    8048803 <parseexec+0x43>
 80487ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
            panic("syntax error!!!\n");
        cmd->argv[argc] = safe_copy(q, eq);
        argc++;
        if(argc >= MAXARGS)
            panic("too many args!!!\n");
        ret = parseredirs(ret, ps, es);
 80487f0:	83 ec 04             	sub    $0x4,%esp
 80487f3:	57                   	push   %edi
 80487f4:	56                   	push   %esi
 80487f5:	ff 75 d4             	pushl  -0x2c(%ebp)
 80487f8:	e8 f3 fe ff ff       	call   80486f0 <parseredirs>
 80487fd:	83 c4 10             	add    $0x10,%esp
 8048800:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    ret = execcmd();
    cmd = (struct execcmd*)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
    while(!peek(ps, es, "|&")){
 8048803:	83 ec 04             	sub    $0x4,%esp
 8048806:	68 94 a0 04 08       	push   $0x804a094
 804880b:	57                   	push   %edi
 804880c:	56                   	push   %esi
 804880d:	e8 0e fe ff ff       	call   8048620 <peek>
 8048812:	83 c4 10             	add    $0x10,%esp
 8048815:	85 c0                	test   %eax,%eax
 8048817:	75 77                	jne    8048890 <parseexec+0xd0>
        if ((tok= gettoken(ps, es, &q, &eq)) == 0)
 8048819:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 804881c:	50                   	push   %eax
 804881d:	8d 45 e0             	lea    -0x20(%ebp),%eax
 8048820:	50                   	push   %eax
 8048821:	57                   	push   %edi
 8048822:	56                   	push   %esi
 8048823:	e8 b8 fc ff ff       	call   80484e0 <gettoken>
 8048828:	83 c4 10             	add    $0x10,%esp
 804882b:	85 c0                	test   %eax,%eax
 804882d:	74 61                	je     8048890 <parseexec+0xd0>
            break;
        if (tok != 'a') 
 804882f:	83 f8 61             	cmp    $0x61,%eax
 8048832:	74 17                	je     804884b <parseexec+0x8b>
    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
 8048834:	83 ec 08             	sub    $0x8,%esp
 8048837:	68 71 a0 04 08       	push   $0x804a071
 804883c:	6a 02                	push   $0x2
 804883e:	e8 5d 04 00 00       	call   8048ca0 <printf>
    exit();
 8048843:	e8 d8 09 00 00       	call   8049220 <exit>
 8048848:	83 c4 10             	add    $0x10,%esp
    while(!peek(ps, es, "|&")){
        if ((tok= gettoken(ps, es, &q, &eq)) == 0)
            break;
        if (tok != 'a') 
            panic("syntax error!!!\n");
        cmd->argv[argc] = safe_copy(q, eq);
 804884b:	83 ec 08             	sub    $0x8,%esp
 804884e:	ff 75 e4             	pushl  -0x1c(%ebp)
 8048851:	ff 75 e0             	pushl  -0x20(%ebp)
 8048854:	e8 37 fe ff ff       	call   8048690 <safe_copy>
 8048859:	8b 55 d0             	mov    -0x30(%ebp),%edx
        argc++;
        if(argc >= MAXARGS)
 804885c:	83 c4 10             	add    $0x10,%esp
    while(!peek(ps, es, "|&")){
        if ((tok= gettoken(ps, es, &q, &eq)) == 0)
            break;
        if (tok != 'a') 
            panic("syntax error!!!\n");
        cmd->argv[argc] = safe_copy(q, eq);
 804885f:	89 44 9a 04          	mov    %eax,0x4(%edx,%ebx,4)
        argc++;
 8048863:	83 c3 01             	add    $0x1,%ebx
        if(argc >= MAXARGS)
 8048866:	83 fb 09             	cmp    $0x9,%ebx
 8048869:	7e 85                	jle    80487f0 <parseexec+0x30>
    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
 804886b:	83 ec 08             	sub    $0x8,%esp
 804886e:	68 82 a0 04 08       	push   $0x804a082
 8048873:	6a 02                	push   $0x2
 8048875:	e8 26 04 00 00       	call   8048ca0 <printf>
    exit();
 804887a:	e8 a1 09 00 00       	call   8049220 <exit>
 804887f:	83 c4 10             	add    $0x10,%esp
 8048882:	e9 69 ff ff ff       	jmp    80487f0 <parseexec+0x30>
 8048887:	89 f6                	mov    %esi,%esi
 8048889:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
        argc++;
        if(argc >= MAXARGS)
            panic("too many args!!!\n");
        ret = parseredirs(ret, ps, es);
    }
    cmd->argv[argc] = 0;
 8048890:	8b 45 d0             	mov    -0x30(%ebp),%eax
 8048893:	c7 44 98 04 00 00 00 	movl   $0x0,0x4(%eax,%ebx,4)
 804889a:	00 
    return ret;
 804889b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 804889e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 80488a1:	5b                   	pop    %ebx
 80488a2:	5e                   	pop    %esi
 80488a3:	5f                   	pop    %edi
 80488a4:	5d                   	pop    %ebp
 80488a5:	c3                   	ret    
 80488a6:	8d 76 00             	lea    0x0(%esi),%esi
 80488a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

080488b0 <parsepipe>:
    }
    return cmd;
}

struct cmd *parsepipe(char **ps, char *es)
{
 80488b0:	55                   	push   %ebp
 80488b1:	89 e5                	mov    %esp,%ebp
 80488b3:	57                   	push   %edi
 80488b4:	56                   	push   %esi
 80488b5:	53                   	push   %ebx
 80488b6:	83 ec 14             	sub    $0x14,%esp
 80488b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
 80488bc:	8b 75 0c             	mov    0xc(%ebp),%esi
    struct cmd *cmd;

    cmd = parseexec(ps, es);
 80488bf:	56                   	push   %esi
 80488c0:	53                   	push   %ebx
 80488c1:	e8 fa fe ff ff       	call   80487c0 <parseexec>
    if (peek(ps, es, "|")) {
 80488c6:	83 c4 0c             	add    $0xc,%esp

struct cmd *parsepipe(char **ps, char *es)
{
    struct cmd *cmd;

    cmd = parseexec(ps, es);
 80488c9:	89 c7                	mov    %eax,%edi
    if (peek(ps, es, "|")) {
 80488cb:	68 97 a0 04 08       	push   $0x804a097
 80488d0:	56                   	push   %esi
 80488d1:	53                   	push   %ebx
 80488d2:	e8 49 fd ff ff       	call   8048620 <peek>
 80488d7:	83 c4 10             	add    $0x10,%esp
 80488da:	85 c0                	test   %eax,%eax
 80488dc:	75 12                	jne    80488f0 <parsepipe+0x40>
        gettoken(ps, es, 0, 0);
        cmd = pipecmd(cmd, parsepipe(ps, es));
    }
    return cmd;
}
 80488de:	8d 65 f4             	lea    -0xc(%ebp),%esp
 80488e1:	89 f8                	mov    %edi,%eax
 80488e3:	5b                   	pop    %ebx
 80488e4:	5e                   	pop    %esi
 80488e5:	5f                   	pop    %edi
 80488e6:	5d                   	pop    %ebp
 80488e7:	c3                   	ret    
 80488e8:	90                   	nop
 80488e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
    struct cmd *cmd;

    cmd = parseexec(ps, es);
    if (peek(ps, es, "|")) {
        gettoken(ps, es, 0, 0);
 80488f0:	6a 00                	push   $0x0
 80488f2:	6a 00                	push   $0x0
 80488f4:	56                   	push   %esi
 80488f5:	53                   	push   %ebx
 80488f6:	e8 e5 fb ff ff       	call   80484e0 <gettoken>
        cmd = pipecmd(cmd, parsepipe(ps, es));
 80488fb:	58                   	pop    %eax
 80488fc:	5a                   	pop    %edx
 80488fd:	56                   	push   %esi
 80488fe:	53                   	push   %ebx
 80488ff:	e8 ac ff ff ff       	call   80488b0 <parsepipe>
 8048904:	89 7d 08             	mov    %edi,0x8(%ebp)
 8048907:	89 45 0c             	mov    %eax,0xc(%ebp)
 804890a:	83 c4 10             	add    $0x10,%esp
    }
    return cmd;
}
 804890d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048910:	5b                   	pop    %ebx
 8048911:	5e                   	pop    %esi
 8048912:	5f                   	pop    %edi
 8048913:	5d                   	pop    %ebp
    struct cmd *cmd;

    cmd = parseexec(ps, es);
    if (peek(ps, es, "|")) {
        gettoken(ps, es, 0, 0);
        cmd = pipecmd(cmd, parsepipe(ps, es));
 8048914:	e9 57 fb ff ff       	jmp    8048470 <pipecmd>
 8048919:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

08048920 <parseline>:
        panic("parsecmd error!!!\n");
    return cmd;
}

struct cmd *parseline(char **ps, char *es)
{
 8048920:	55                   	push   %ebp
 8048921:	89 e5                	mov    %esp,%ebp
 8048923:	57                   	push   %edi
 8048924:	56                   	push   %esi
 8048925:	53                   	push   %ebx
 8048926:	83 ec 14             	sub    $0x14,%esp
 8048929:	8b 5d 08             	mov    0x8(%ebp),%ebx
 804892c:	8b 75 0c             	mov    0xc(%ebp),%esi
    struct cmd *cmd;
    cmd = parsepipe(ps, es);
 804892f:	56                   	push   %esi
 8048930:	53                   	push   %ebx
 8048931:	e8 7a ff ff ff       	call   80488b0 <parsepipe>
    while (peek(ps, es, "&")) {
 8048936:	83 c4 10             	add    $0x10,%esp
}

struct cmd *parseline(char **ps, char *es)
{
    struct cmd *cmd;
    cmd = parsepipe(ps, es);
 8048939:	89 c7                	mov    %eax,%edi
    while (peek(ps, es, "&")) {
 804893b:	eb 1b                	jmp    8048958 <parseline+0x38>
 804893d:	8d 76 00             	lea    0x0(%esi),%esi
        gettoken(ps, es, 0, 0);
 8048940:	6a 00                	push   $0x0
 8048942:	6a 00                	push   $0x0
 8048944:	56                   	push   %esi
 8048945:	53                   	push   %ebx
 8048946:	e8 95 fb ff ff       	call   80484e0 <gettoken>
        cmd = backcmd(cmd);
 804894b:	89 3c 24             	mov    %edi,(%esp)
 804894e:	e8 5d fb ff ff       	call   80484b0 <backcmd>
 8048953:	83 c4 10             	add    $0x10,%esp
 8048956:	89 c7                	mov    %eax,%edi

struct cmd *parseline(char **ps, char *es)
{
    struct cmd *cmd;
    cmd = parsepipe(ps, es);
    while (peek(ps, es, "&")) {
 8048958:	83 ec 04             	sub    $0x4,%esp
 804895b:	68 95 a0 04 08       	push   $0x804a095
 8048960:	56                   	push   %esi
 8048961:	53                   	push   %ebx
 8048962:	e8 b9 fc ff ff       	call   8048620 <peek>
 8048967:	83 c4 10             	add    $0x10,%esp
 804896a:	85 c0                	test   %eax,%eax
 804896c:	75 d2                	jne    8048940 <parseline+0x20>
        gettoken(ps, es, 0, 0);
        cmd = backcmd(cmd);
    }
    return cmd;
}
 804896e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048971:	89 f8                	mov    %edi,%eax
 8048973:	5b                   	pop    %ebx
 8048974:	5e                   	pop    %esi
 8048975:	5f                   	pop    %edi
 8048976:	5d                   	pop    %ebp
 8048977:	c3                   	ret    
 8048978:	90                   	nop
 8048979:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

08048980 <parsecmd>:
struct cmd *parseline(char **, char *);
struct cmd *parsepipe(char **, char *);
struct cmd *parseexec(char **, char *);

struct cmd *parsecmd(char *s)
{
 8048980:	55                   	push   %ebp
 8048981:	89 e5                	mov    %esp,%ebp
 8048983:	56                   	push   %esi
 8048984:	53                   	push   %ebx
    char *es;
    struct cmd *cmd;

    es = s + strlen(s);
 8048985:	8b 5d 08             	mov    0x8(%ebp),%ebx
 8048988:	83 ec 0c             	sub    $0xc,%esp
 804898b:	53                   	push   %ebx
 804898c:	e8 1f 05 00 00       	call   8048eb0 <strlen>
 8048991:	01 c3                	add    %eax,%ebx
    cmd = parseline(&s, es);
 8048993:	58                   	pop    %eax
 8048994:	8d 45 08             	lea    0x8(%ebp),%eax
 8048997:	5a                   	pop    %edx
 8048998:	53                   	push   %ebx
 8048999:	50                   	push   %eax
 804899a:	e8 81 ff ff ff       	call   8048920 <parseline>
 804899f:	89 c6                	mov    %eax,%esi
    peek(&s, es, "");
 80489a1:	8d 45 08             	lea    0x8(%ebp),%eax
 80489a4:	83 c4 0c             	add    $0xc,%esp
 80489a7:	68 6d a0 04 08       	push   $0x804a06d
 80489ac:	53                   	push   %ebx
 80489ad:	50                   	push   %eax
 80489ae:	e8 6d fc ff ff       	call   8048620 <peek>
    if(s != es)
 80489b3:	83 c4 10             	add    $0x10,%esp
 80489b6:	3b 5d 08             	cmp    0x8(%ebp),%ebx
 80489b9:	74 17                	je     80489d2 <parsecmd+0x52>
    return 0;
}

void panic(const char *s)
{
    printf(stderr, s);
 80489bb:	83 ec 08             	sub    $0x8,%esp
 80489be:	68 99 a0 04 08       	push   $0x804a099
 80489c3:	6a 02                	push   $0x2
 80489c5:	e8 d6 02 00 00       	call   8048ca0 <printf>
    exit();
 80489ca:	e8 51 08 00 00       	call   8049220 <exit>
 80489cf:	83 c4 10             	add    $0x10,%esp
    cmd = parseline(&s, es);
    peek(&s, es, "");
    if(s != es)
        panic("parsecmd error!!!\n");
    return cmd;
}
 80489d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
 80489d5:	89 f0                	mov    %esi,%eax
 80489d7:	5b                   	pop    %ebx
 80489d8:	5e                   	pop    %esi
 80489d9:	5d                   	pop    %ebp
 80489da:	c3                   	ret    
 80489db:	90                   	nop
 80489dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

080489e0 <wmain>:
        return -1;
    return 0;
}

int wmain(void)
{
 80489e0:	55                   	push   %ebp
 80489e1:	89 e5                	mov    %esp,%ebp
 80489e3:	53                   	push   %ebx
 80489e4:	83 ec 04             	sub    $0x4,%esp
    int fd, r, icd;
    static char buf[SHELLBUF];

    WeiOS_welcome();
 80489e7:	e8 24 0b 00 00       	call   8049510 <WeiOS_welcome>
 80489ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while (getcmd(buf, SHELLBUF) >= 0) {
 80489f0:	83 ec 08             	sub    $0x8,%esp
 80489f3:	6a 64                	push   $0x64
 80489f5:	68 e0 ae 04 08       	push   $0x804aee0
 80489fa:	e8 41 f9 ff ff       	call   8048340 <getcmd>
 80489ff:	83 c4 10             	add    $0x10,%esp
 8048a02:	85 c0                	test   %eax,%eax
 8048a04:	0f 88 b0 00 00 00    	js     8048aba <wmain+0xda>
        if (buf[0] == 'c' && buf[1] == 'd') {
 8048a0a:	80 3d e0 ae 04 08 63 	cmpb   $0x63,0x804aee0
 8048a11:	75 09                	jne    8048a1c <wmain+0x3c>
 8048a13:	80 3d e1 ae 04 08 64 	cmpb   $0x64,0x804aee1
 8048a1a:	74 34                	je     8048a50 <wmain+0x70>

int forkv(void)
{
    int pid;
  
    if ((pid = fork()) < 0)
 8048a1c:	e8 df 07 00 00       	call   8049200 <fork>
 8048a21:	85 c0                	test   %eax,%eax
 8048a23:	0f 88 8a 00 00 00    	js     8048ab3 <wmain+0xd3>
            buf[strlen(buf)-1] = 0;
            if (chdir(buf + icd) < 0)
                printf(stderr, "connot cd %s\n", buf + icd);
            continue;
        }
        if(forkv() == 0)
 8048a29:	75 18                	jne    8048a43 <wmain+0x63>
            runcmd(parsecmd(buf));
 8048a2b:	83 ec 0c             	sub    $0xc,%esp
 8048a2e:	68 e0 ae 04 08       	push   $0x804aee0
 8048a33:	e8 48 ff ff ff       	call   8048980 <parsecmd>
 8048a38:	89 04 24             	mov    %eax,(%esp)
 8048a3b:	e8 c0 f6 ff ff       	call   8048100 <runcmd>
 8048a40:	83 c4 10             	add    $0x10,%esp
        wait();
 8048a43:	e8 38 08 00 00       	call   8049280 <wait>
 8048a48:	eb a6                	jmp    80489f0 <wmain+0x10>
 8048a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while (getcmd(buf, SHELLBUF) >= 0) {
        if (buf[0] == 'c' && buf[1] == 'd') {
            // Clumsy but will have to do for now.
            // Chdir has no effect on the parent if run in the child.
            icd = 2;
            while (buf[icd] == ' ')
 8048a50:	80 3d e2 ae 04 08 20 	cmpb   $0x20,0x804aee2
 8048a57:	75 6d                	jne    8048ac6 <wmain+0xe6>
 8048a59:	b8 02 00 00 00       	mov    $0x2,%eax
 8048a5e:	66 90                	xchg   %ax,%ax
                icd++;
 8048a60:	83 c0 01             	add    $0x1,%eax
    while (getcmd(buf, SHELLBUF) >= 0) {
        if (buf[0] == 'c' && buf[1] == 'd') {
            // Clumsy but will have to do for now.
            // Chdir has no effect on the parent if run in the child.
            icd = 2;
            while (buf[icd] == ' ')
 8048a63:	80 b8 e0 ae 04 08 20 	cmpb   $0x20,0x804aee0(%eax)
 8048a6a:	89 c3                	mov    %eax,%ebx
 8048a6c:	74 f2                	je     8048a60 <wmain+0x80>
                icd++;
            buf[strlen(buf)-1] = 0;
 8048a6e:	83 ec 0c             	sub    $0xc,%esp
            if (chdir(buf + icd) < 0)
 8048a71:	81 c3 e0 ae 04 08    	add    $0x804aee0,%ebx
            // Clumsy but will have to do for now.
            // Chdir has no effect on the parent if run in the child.
            icd = 2;
            while (buf[icd] == ' ')
                icd++;
            buf[strlen(buf)-1] = 0;
 8048a77:	68 e0 ae 04 08       	push   $0x804aee0
 8048a7c:	e8 2f 04 00 00       	call   8048eb0 <strlen>
            if (chdir(buf + icd) < 0)
 8048a81:	89 1c 24             	mov    %ebx,(%esp)
            // Clumsy but will have to do for now.
            // Chdir has no effect on the parent if run in the child.
            icd = 2;
            while (buf[icd] == ' ')
                icd++;
            buf[strlen(buf)-1] = 0;
 8048a84:	c6 80 df ae 04 08 00 	movb   $0x0,0x804aedf(%eax)
            if (chdir(buf + icd) < 0)
 8048a8b:	e8 e0 09 00 00       	call   8049470 <chdir>
 8048a90:	83 c4 10             	add    $0x10,%esp
 8048a93:	85 c0                	test   %eax,%eax
 8048a95:	0f 89 55 ff ff ff    	jns    80489f0 <wmain+0x10>
                printf(stderr, "connot cd %s\n", buf + icd);
 8048a9b:	83 ec 04             	sub    $0x4,%esp
 8048a9e:	53                   	push   %ebx
 8048a9f:	68 ac a0 04 08       	push   $0x804a0ac
 8048aa4:	6a 02                	push   $0x2
 8048aa6:	e8 f5 01 00 00       	call   8048ca0 <printf>
 8048aab:	83 c4 10             	add    $0x10,%esp
 8048aae:	e9 3d ff ff ff       	jmp    80489f0 <wmain+0x10>
 8048ab3:	e8 58 f5 ff ff       	call   8048010 <forkv.part.1>
 8048ab8:	eb 89                	jmp    8048a43 <wmain+0x63>
        }
        if(forkv() == 0)
            runcmd(parsecmd(buf));
        wait();
    }
    exit();
 8048aba:	e8 61 07 00 00       	call   8049220 <exit>

    return 0;
}
 8048abf:	31 c0                	xor    %eax,%eax
 8048ac1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 8048ac4:	c9                   	leave  
 8048ac5:	c3                   	ret    
    while (getcmd(buf, SHELLBUF) >= 0) {
        if (buf[0] == 'c' && buf[1] == 'd') {
            // Clumsy but will have to do for now.
            // Chdir has no effect on the parent if run in the child.
            icd = 2;
            while (buf[icd] == ' ')
 8048ac6:	bb 02 00 00 00       	mov    $0x2,%ebx
 8048acb:	eb a1                	jmp    8048a6e <wmain+0x8e>
 8048acd:	66 90                	xchg   %ax,%ax
 8048acf:	90                   	nop

08048ad0 <printf_write_radix>:
    return count;
}

// combine screen_write_dec and screen_write_oct
static int printf_write_radix(int fd, uint32_t n, uint32_t radix)
{
 8048ad0:	55                   	push   %ebp
 8048ad1:	89 e5                	mov    %esp,%ebp
 8048ad3:	57                   	push   %edi
 8048ad4:	56                   	push   %esi
 8048ad5:	53                   	push   %ebx
 8048ad6:	31 ff                	xor    %edi,%edi
 8048ad8:	89 c6                	mov    %eax,%esi
 8048ada:	89 d0                	mov    %edx,%eax
 8048adc:	83 ec 4c             	sub    $0x4c,%esp
    int count = 0;
    int num_stack[12];

    if (!n) {
 8048adf:	85 d2                	test   %edx,%edx
 8048ae1:	75 07                	jne    8048aea <printf_write_radix+0x1a>
 8048ae3:	eb 4b                	jmp    8048b30 <printf_write_radix+0x60>
 8048ae5:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, 0x30 & 0xff);
        return 1; 
    }

    while (n) {
        num_stack[count++] = n % radix;
 8048ae8:	89 df                	mov    %ebx,%edi
 8048aea:	31 d2                	xor    %edx,%edx
 8048aec:	8d 5f 01             	lea    0x1(%edi),%ebx
 8048aef:	f7 f1                	div    %ecx
    if (!n) {
        putc(fd, 0x30 & 0xff);
        return 1; 
    }

    while (n) {
 8048af1:	85 c0                	test   %eax,%eax
        num_stack[count++] = n % radix;
 8048af3:	89 54 9d b4          	mov    %edx,-0x4c(%ebp,%ebx,4)
    if (!n) {
        putc(fd, 0x30 & 0xff);
        return 1; 
    }

    while (n) {
 8048af7:	75 ef                	jne    8048ae8 <printf_write_radix+0x18>
 8048af9:	8d 7c bd b4          	lea    -0x4c(%ebp,%edi,4),%edi
 8048afd:	eb 06                	jmp    8048b05 <printf_write_radix+0x35>
 8048aff:	90                   	nop
 8048b00:	8b 17                	mov    (%edi),%edx
 8048b02:	83 ef 04             	sub    $0x4,%edi
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048b05:	8d 45 b7             	lea    -0x49(%ebp),%eax
 8048b08:	83 ec 04             	sub    $0x4,%esp
 8048b0b:	83 ca 30             	or     $0x30,%edx
 8048b0e:	6a 01                	push   $0x1
 8048b10:	88 55 b7             	mov    %dl,-0x49(%ebp)
 8048b13:	50                   	push   %eax
 8048b14:	56                   	push   %esi
 8048b15:	e8 46 08 00 00       	call   8049360 <write>

    while (n) {
        num_stack[count++] = n % radix;
        n /= radix;
    }
    for (int i = count-1; i >= 0; i--)
 8048b1a:	8d 45 b4             	lea    -0x4c(%ebp),%eax
 8048b1d:	83 c4 10             	add    $0x10,%esp
 8048b20:	39 c7                	cmp    %eax,%edi
 8048b22:	75 dc                	jne    8048b00 <printf_write_radix+0x30>
        putc(fd, (num_stack[i] | 0x30) & 0xff);
    return count;
}
 8048b24:	8d 65 f4             	lea    -0xc(%ebp),%esp
        putc(fd, 0x30 & 0xff);
        return 1; 
    }

    while (n) {
        num_stack[count++] = n % radix;
 8048b27:	89 d8                	mov    %ebx,%eax
        n /= radix;
    }
    for (int i = count-1; i >= 0; i--)
        putc(fd, (num_stack[i] | 0x30) & 0xff);
    return count;
}
 8048b29:	5b                   	pop    %ebx
 8048b2a:	5e                   	pop    %esi
 8048b2b:	5f                   	pop    %edi
 8048b2c:	5d                   	pop    %ebp
 8048b2d:	c3                   	ret    
 8048b2e:	66 90                	xchg   %ax,%ax
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048b30:	8d 45 b8             	lea    -0x48(%ebp),%eax
 8048b33:	83 ec 04             	sub    $0x4,%esp
 8048b36:	c6 45 b8 30          	movb   $0x30,-0x48(%ebp)
 8048b3a:	6a 01                	push   $0x1
 8048b3c:	50                   	push   %eax
 8048b3d:	56                   	push   %esi
 8048b3e:	e8 1d 08 00 00       	call   8049360 <write>
 8048b43:	83 c4 10             	add    $0x10,%esp
        n /= radix;
    }
    for (int i = count-1; i >= 0; i--)
        putc(fd, (num_stack[i] | 0x30) & 0xff);
    return count;
}
 8048b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048b49:	b8 01 00 00 00       	mov    $0x1,%eax
        n /= radix;
    }
    for (int i = count-1; i >= 0; i--)
        putc(fd, (num_stack[i] | 0x30) & 0xff);
    return count;
}
 8048b4e:	5b                   	pop    %ebx
 8048b4f:	5e                   	pop    %esi
 8048b50:	5f                   	pop    %edi
 8048b51:	5d                   	pop    %ebp
 8048b52:	c3                   	ret    
 8048b53:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 8048b59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08048b60 <printf_write_hex>:
	return cnt;
}

// i copy it from WeiOS/lib/printfmt.c directly
static int printf_write_hex(int fd, uint32_t n)
{
 8048b60:	55                   	push   %ebp
 8048b61:	89 e5                	mov    %esp,%ebp
 8048b63:	57                   	push   %edi
 8048b64:	56                   	push   %esi
 8048b65:	53                   	push   %ebx
 8048b66:	31 f6                	xor    %esi,%esi
 8048b68:	89 c3                	mov    %eax,%ebx
 8048b6a:	83 ec 3c             	sub    $0x3c,%esp
    int count = 0;
    int num_stack[8];
    static char hex_map[16] = {'0', '1', '2', '3', '4', '5', '6',
                                '7', '8', '9', 'A', 'B', 'C', 'D',
                                'E', 'F'};
    if (!n) {
 8048b6d:	85 d2                	test   %edx,%edx
 8048b6f:	75 09                	jne    8048b7a <printf_write_hex+0x1a>
 8048b71:	eb 5d                	jmp    8048bd0 <printf_write_hex+0x70>
 8048b73:	90                   	nop
 8048b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        putc(fd, '0');
        return 1;
    }

    while (n) {
        num_stack[count++] = n % 16;
 8048b78:	89 fe                	mov    %edi,%esi
 8048b7a:	89 d0                	mov    %edx,%eax
 8048b7c:	8d 7e 01             	lea    0x1(%esi),%edi
        n /= 16;
 8048b7f:	c1 ea 04             	shr    $0x4,%edx
        putc(fd, '0');
        return 1;
    }

    while (n) {
        num_stack[count++] = n % 16;
 8048b82:	83 e0 0f             	and    $0xf,%eax
    if (!n) {
        putc(fd, '0');
        return 1;
    }

    while (n) {
 8048b85:	85 d2                	test   %edx,%edx
        num_stack[count++] = n % 16;
 8048b87:	89 44 bd c4          	mov    %eax,-0x3c(%ebp,%edi,4)
    if (!n) {
        putc(fd, '0');
        return 1;
    }

    while (n) {
 8048b8b:	75 eb                	jne    8048b78 <printf_write_hex+0x18>
 8048b8d:	8d 74 b5 c8          	lea    -0x38(%ebp,%esi,4),%esi
 8048b91:	eb 07                	jmp    8048b9a <printf_write_hex+0x3a>
 8048b93:	90                   	nop
 8048b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 8048b98:	8b 06                	mov    (%esi),%eax
 8048b9a:	0f b6 80 7c a1 04 08 	movzbl 0x804a17c(%eax),%eax
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048ba1:	83 ec 04             	sub    $0x4,%esp
 8048ba4:	83 ee 04             	sub    $0x4,%esi
 8048ba7:	6a 01                	push   $0x1
 8048ba9:	88 45 c7             	mov    %al,-0x39(%ebp)
 8048bac:	8d 45 c7             	lea    -0x39(%ebp),%eax
 8048baf:	50                   	push   %eax
 8048bb0:	53                   	push   %ebx
 8048bb1:	e8 aa 07 00 00       	call   8049360 <write>

    while (n) {
        num_stack[count++] = n % 16;
        n /= 16;
    }
    for (int i = count-1; i >= 0; i--)
 8048bb6:	8d 45 c4             	lea    -0x3c(%ebp),%eax
 8048bb9:	83 c4 10             	add    $0x10,%esp
 8048bbc:	39 c6                	cmp    %eax,%esi
 8048bbe:	75 d8                	jne    8048b98 <printf_write_hex+0x38>
        putc(fd, hex_map[num_stack[i]]);
    return count;
}
 8048bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
        putc(fd, '0');
        return 1;
    }

    while (n) {
        num_stack[count++] = n % 16;
 8048bc3:	89 f8                	mov    %edi,%eax
        n /= 16;
    }
    for (int i = count-1; i >= 0; i--)
        putc(fd, hex_map[num_stack[i]]);
    return count;
}
 8048bc5:	5b                   	pop    %ebx
 8048bc6:	5e                   	pop    %esi
 8048bc7:	5f                   	pop    %edi
 8048bc8:	5d                   	pop    %ebp
 8048bc9:	c3                   	ret    
 8048bca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048bd0:	8d 45 c8             	lea    -0x38(%ebp),%eax
 8048bd3:	83 ec 04             	sub    $0x4,%esp
 8048bd6:	c6 45 c8 30          	movb   $0x30,-0x38(%ebp)
 8048bda:	6a 01                	push   $0x1
 8048bdc:	50                   	push   %eax
 8048bdd:	53                   	push   %ebx
 8048bde:	e8 7d 07 00 00       	call   8049360 <write>
 8048be3:	83 c4 10             	add    $0x10,%esp
        n /= 16;
    }
    for (int i = count-1; i >= 0; i--)
        putc(fd, hex_map[num_stack[i]]);
    return count;
}
 8048be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048be9:	b8 01 00 00 00       	mov    $0x1,%eax
        n /= 16;
    }
    for (int i = count-1; i >= 0; i--)
        putc(fd, hex_map[num_stack[i]]);
    return count;
}
 8048bee:	5b                   	pop    %ebx
 8048bef:	5e                   	pop    %esi
 8048bf0:	5f                   	pop    %edi
 8048bf1:	5d                   	pop    %ebp
 8048bf2:	c3                   	ret    
 8048bf3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 8048bf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08048c00 <getc>:
#include <include/types.h>
#include <include/stdarg.h>
#include <include/user.h>

char getc(void)
{
 8048c00:	55                   	push   %ebp
 8048c01:	89 e5                	mov    %esp,%ebp
 8048c03:	83 ec 1c             	sub    $0x1c,%esp
	char c;
	if (read(stdin, &c, 1) < 0)
 8048c06:	8d 45 f7             	lea    -0x9(%ebp),%eax
 8048c09:	6a 01                	push   $0x1
 8048c0b:	50                   	push   %eax
 8048c0c:	6a 00                	push   $0x0
 8048c0e:	e8 2d 07 00 00       	call   8049340 <read>
 8048c13:	83 c4 10             	add    $0x10,%esp
		return 0;
	return c;
 8048c16:	85 c0                	test   %eax,%eax
 8048c18:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
 8048c1c:	ba 00 00 00 00       	mov    $0x0,%edx
}
 8048c21:	c9                   	leave  
char getc(void)
{
	char c;
	if (read(stdin, &c, 1) < 0)
		return 0;
	return c;
 8048c22:	0f 48 c2             	cmovs  %edx,%eax
}
 8048c25:	c3                   	ret    
 8048c26:	8d 76 00             	lea    0x0(%esi),%esi
 8048c29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08048c30 <gets>:

char *gets(char *buf, int max)
{
 8048c30:	55                   	push   %ebp
 8048c31:	89 e5                	mov    %esp,%ebp
 8048c33:	57                   	push   %edi
 8048c34:	56                   	push   %esi
 8048c35:	53                   	push   %ebx
  	int i, cc;
  	char c;

  	for (i = 0; i+1 < max; ) {
 8048c36:	31 f6                	xor    %esi,%esi
    	cc = read(stdin, &c, 1);
 8048c38:	8d 7d e7             	lea    -0x19(%ebp),%edi
		return 0;
	return c;
}

char *gets(char *buf, int max)
{
 8048c3b:	83 ec 1c             	sub    $0x1c,%esp
  	int i, cc;
  	char c;

  	for (i = 0; i+1 < max; ) {
 8048c3e:	eb 29                	jmp    8048c69 <gets+0x39>
    	cc = read(stdin, &c, 1);
 8048c40:	83 ec 04             	sub    $0x4,%esp
 8048c43:	6a 01                	push   $0x1
 8048c45:	57                   	push   %edi
 8048c46:	6a 00                	push   $0x0
 8048c48:	e8 f3 06 00 00       	call   8049340 <read>
	    if (cc < 1)
 8048c4d:	83 c4 10             	add    $0x10,%esp
 8048c50:	85 c0                	test   %eax,%eax
 8048c52:	7e 1d                	jle    8048c71 <gets+0x41>
	      	break;
	    buf[i++] = c;
 8048c54:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 8048c58:	8b 55 08             	mov    0x8(%ebp),%edx
 8048c5b:	89 de                	mov    %ebx,%esi
	    if(c == '\n' || c == '\r')
 8048c5d:	3c 0a                	cmp    $0xa,%al

  	for (i = 0; i+1 < max; ) {
    	cc = read(stdin, &c, 1);
	    if (cc < 1)
	      	break;
	    buf[i++] = c;
 8048c5f:	88 44 1a ff          	mov    %al,-0x1(%edx,%ebx,1)
	    if(c == '\n' || c == '\r')
 8048c63:	74 1b                	je     8048c80 <gets+0x50>
 8048c65:	3c 0d                	cmp    $0xd,%al
 8048c67:	74 17                	je     8048c80 <gets+0x50>
char *gets(char *buf, int max)
{
  	int i, cc;
  	char c;

  	for (i = 0; i+1 < max; ) {
 8048c69:	8d 5e 01             	lea    0x1(%esi),%ebx
 8048c6c:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 8048c6f:	7c cf                	jl     8048c40 <gets+0x10>
	      	break;
	    buf[i++] = c;
	    if(c == '\n' || c == '\r')
	      	break;
    }
	buf[i] = '\0';
 8048c71:	8b 45 08             	mov    0x8(%ebp),%eax
 8048c74:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)
	return buf;
}
 8048c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048c7b:	5b                   	pop    %ebx
 8048c7c:	5e                   	pop    %esi
 8048c7d:	5f                   	pop    %edi
 8048c7e:	5d                   	pop    %ebp
 8048c7f:	c3                   	ret    
	      	break;
	    buf[i++] = c;
	    if(c == '\n' || c == '\r')
	      	break;
    }
	buf[i] = '\0';
 8048c80:	8b 45 08             	mov    0x8(%ebp),%eax
char *gets(char *buf, int max)
{
  	int i, cc;
  	char c;

  	for (i = 0; i+1 < max; ) {
 8048c83:	89 de                	mov    %ebx,%esi
	      	break;
	    buf[i++] = c;
	    if(c == '\n' || c == '\r')
	      	break;
    }
	buf[i] = '\0';
 8048c85:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)
	return buf;
}
 8048c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048c8c:	5b                   	pop    %ebx
 8048c8d:	5e                   	pop    %esi
 8048c8e:	5f                   	pop    %edi
 8048c8f:	5d                   	pop    %ebp
 8048c90:	c3                   	ret    
 8048c91:	eb 0d                	jmp    8048ca0 <printf>
 8048c93:	90                   	nop
 8048c94:	90                   	nop
 8048c95:	90                   	nop
 8048c96:	90                   	nop
 8048c97:	90                   	nop
 8048c98:	90                   	nop
 8048c99:	90                   	nop
 8048c9a:	90                   	nop
 8048c9b:	90                   	nop
 8048c9c:	90                   	nop
 8048c9d:	90                   	nop
 8048c9e:	90                   	nop
 8048c9f:	90                   	nop

08048ca0 <printf>:
	}
	*count = cnt;  
}

int printf(int fd, const char *str, ...)
{
 8048ca0:	55                   	push   %ebp
 8048ca1:	89 e5                	mov    %esp,%ebp
 8048ca3:	57                   	push   %edi
 8048ca4:	56                   	push   %esi
 8048ca5:	53                   	push   %ebx
 8048ca6:	83 ec 2c             	sub    $0x2c,%esp
 8048ca9:	8b 7d 0c             	mov    0xc(%ebp),%edi
 8048cac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	char c;
	int cnt;
    int d_num;
    uint32_t u_num;

	if (!s)
 8048caf:	85 ff                	test   %edi,%edi
 8048cb1:	74 37                	je     8048cea <printf+0x4a>
 8048cb3:	8d 75 10             	lea    0x10(%ebp),%esi
 8048cb6:	8d 76 00             	lea    0x0(%esi),%esi
 8048cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
		return ;

	while ((c = *s++) != '\0') {
 8048cc0:	0f b6 07             	movzbl (%edi),%eax
 8048cc3:	84 c0                	test   %al,%al
 8048cc5:	74 23                	je     8048cea <printf+0x4a>
		if (c != '%') {
 8048cc7:	3c 25                	cmp    $0x25,%al
 8048cc9:	74 35                	je     8048d00 <printf+0x60>
 8048ccb:	88 45 e7             	mov    %al,-0x19(%ebp)
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048cce:	8d 45 e7             	lea    -0x19(%ebp),%eax
 8048cd1:	83 ec 04             	sub    $0x4,%esp
 8048cd4:	6a 01                	push   $0x1
    uint32_t u_num;

	if (!s)
		return ;

	while ((c = *s++) != '\0') {
 8048cd6:	83 c7 01             	add    $0x1,%edi
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048cd9:	50                   	push   %eax
 8048cda:	53                   	push   %ebx
 8048cdb:	e8 80 06 00 00       	call   8049360 <write>
    uint32_t u_num;

	if (!s)
		return ;

	while ((c = *s++) != '\0') {
 8048ce0:	0f b6 07             	movzbl (%edi),%eax
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048ce3:	83 c4 10             	add    $0x10,%esp
    uint32_t u_num;

	if (!s)
		return ;

	while ((c = *s++) != '\0') {
 8048ce6:	84 c0                	test   %al,%al
 8048ce8:	75 dd                	jne    8048cc7 <printf+0x27>
    va_start(ap, str);
    printfmt(fd, str, &count, ap);
    va_end(ap);

    return count;
 8048cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
 8048ced:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 8048cf2:	5b                   	pop    %ebx
 8048cf3:	5e                   	pop    %esi
 8048cf4:	5f                   	pop    %edi
 8048cf5:	5d                   	pop    %ebp
 8048cf6:	c3                   	ret    
 8048cf7:	89 f6                	mov    %esi,%esi
 8048cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
 8048d00:	0f b6 57 01          	movzbl 0x1(%edi),%edx
 8048d04:	8d 47 02             	lea    0x2(%edi),%eax
 8048d07:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (c) {
 8048d0a:	8d 42 9d             	lea    -0x63(%edx),%eax
 8048d0d:	3c 15                	cmp    $0x15,%al
 8048d0f:	0f 87 53 01 00 00    	ja     8048e68 <printf+0x1c8>
 8048d15:	0f b6 c0             	movzbl %al,%eax
 8048d18:	ff 24 85 24 a1 04 08 	jmp    *0x804a124(,%eax,4)
 8048d1f:	90                   	nop
            case 'u':
                u_num = va_arg(ap, uint32_t);
                cnt += printf_write_radix(fd, u_num, 10);
                break;
            case 'x':
                cnt += printf_write_hex(fd, va_arg(ap, uint32_t));
 8048d20:	8b 16                	mov    (%esi),%edx
 8048d22:	8d 7e 04             	lea    0x4(%esi),%edi
 8048d25:	89 d8                	mov    %ebx,%eax
 8048d27:	89 fe                	mov    %edi,%esi
 8048d29:	e8 32 fe ff ff       	call   8048b60 <printf_write_hex>
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
 8048d2e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 8048d31:	eb 8d                	jmp    8048cc0 <printf+0x20>
 8048d33:	90                   	nop
 8048d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
                }
                cnt += printf_write_radix(fd, d_num, 10);
                break;
            case 'u':
                u_num = va_arg(ap, uint32_t);
                cnt += printf_write_radix(fd, u_num, 10);
 8048d38:	8b 16                	mov    (%esi),%edx
                    d_num &= (~0x80000000);
                }
                cnt += printf_write_radix(fd, d_num, 10);
                break;
            case 'u':
                u_num = va_arg(ap, uint32_t);
 8048d3a:	8d 7e 04             	lea    0x4(%esi),%edi
                cnt += printf_write_radix(fd, u_num, 10);
 8048d3d:	b9 0a 00 00 00       	mov    $0xa,%ecx
 8048d42:	89 d8                	mov    %ebx,%eax
                    d_num &= (~0x80000000);
                }
                cnt += printf_write_radix(fd, d_num, 10);
                break;
            case 'u':
                u_num = va_arg(ap, uint32_t);
 8048d44:	89 fe                	mov    %edi,%esi
                cnt += printf_write_radix(fd, u_num, 10);
 8048d46:	e8 85 fd ff ff       	call   8048ad0 <printf_write_radix>
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
 8048d4b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 8048d4e:	e9 6d ff ff ff       	jmp    8048cc0 <printf+0x20>
 8048d53:	90                   	nop
 8048d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
                putc(fd, '0');
                putc(fd, 'x');
                cnt += (printf_write_hex(fd, va_arg(ap, uint32_t))+2);
                break;
            case 's':
                cnt += puts(fd, va_arg(ap, const char *));
 8048d58:	8b 3e                	mov    (%esi),%edi
 8048d5a:	8d 46 04             	lea    0x4(%esi),%eax
 8048d5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
}

static int puts(int fd, const char *str)
{
	int cnt = 0;
	while (*str) {
 8048d60:	0f b6 07             	movzbl (%edi),%eax
 8048d63:	84 c0                	test   %al,%al
 8048d65:	74 25                	je     8048d8c <printf+0xec>
 8048d67:	8d 75 e2             	lea    -0x1e(%ebp),%esi
 8048d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048d70:	83 ec 04             	sub    $0x4,%esp

static int puts(int fd, const char *str)
{
	int cnt = 0;
	while (*str) {
		putc(fd, *str++);
 8048d73:	83 c7 01             	add    $0x1,%edi
 8048d76:	88 45 e2             	mov    %al,-0x1e(%ebp)
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048d79:	6a 01                	push   $0x1
 8048d7b:	56                   	push   %esi
 8048d7c:	53                   	push   %ebx
 8048d7d:	e8 de 05 00 00       	call   8049360 <write>
}

static int puts(int fd, const char *str)
{
	int cnt = 0;
	while (*str) {
 8048d82:	0f b6 07             	movzbl (%edi),%eax
 8048d85:	83 c4 10             	add    $0x10,%esp
 8048d88:	84 c0                	test   %al,%al
 8048d8a:	75 e4                	jne    8048d70 <printf+0xd0>
                putc(fd, '0');
                putc(fd, 'x');
                cnt += (printf_write_hex(fd, va_arg(ap, uint32_t))+2);
                break;
            case 's':
                cnt += puts(fd, va_arg(ap, const char *));
 8048d8c:	8b 75 d0             	mov    -0x30(%ebp),%esi
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
 8048d8f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 8048d92:	e9 29 ff ff ff       	jmp    8048cc0 <printf+0x20>
 8048d97:	89 f6                	mov    %esi,%esi
 8048d99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048da0:	8d 45 e3             	lea    -0x1d(%ebp),%eax
 8048da3:	83 ec 04             	sub    $0x4,%esp
 8048da6:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
 8048daa:	6a 01                	push   $0x1
                cnt += printf_write_hex(fd, va_arg(ap, uint32_t));
                break;
            case 'p':
                putc(fd, '0');
                putc(fd, 'x');
                cnt += (printf_write_hex(fd, va_arg(ap, uint32_t))+2);
 8048dac:	8d 7e 04             	lea    0x4(%esi),%edi
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048daf:	50                   	push   %eax
 8048db0:	53                   	push   %ebx
 8048db1:	e8 aa 05 00 00       	call   8049360 <write>
 8048db6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 8048db9:	83 c4 0c             	add    $0xc,%esp
 8048dbc:	c6 45 e4 78          	movb   $0x78,-0x1c(%ebp)
 8048dc0:	6a 01                	push   $0x1
 8048dc2:	50                   	push   %eax
 8048dc3:	53                   	push   %ebx
 8048dc4:	e8 97 05 00 00       	call   8049360 <write>
                cnt += printf_write_hex(fd, va_arg(ap, uint32_t));
                break;
            case 'p':
                putc(fd, '0');
                putc(fd, 'x');
                cnt += (printf_write_hex(fd, va_arg(ap, uint32_t))+2);
 8048dc9:	8b 16                	mov    (%esi),%edx
 8048dcb:	89 d8                	mov    %ebx,%eax
 8048dcd:	89 fe                	mov    %edi,%esi
 8048dcf:	e8 8c fd ff ff       	call   8048b60 <printf_write_hex>
 8048dd4:	83 c4 10             	add    $0x10,%esp
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
 8048dd7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 8048dda:	e9 e1 fe ff ff       	jmp    8048cc0 <printf+0x20>
 8048ddf:	90                   	nop
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048de0:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 8048de3:	83 ec 04             	sub    $0x4,%esp
 8048de6:	c6 45 e6 30          	movb   $0x30,-0x1a(%ebp)
 8048dea:	6a 01                	push   $0x1
		c = *s++;
		switch (c) {
			case 'o':
                putc(fd, '0');
                cnt++;
                cnt += printf_write_radix(fd, va_arg(ap, uint32_t), 8);
 8048dec:	8d 7e 04             	lea    0x4(%esi),%edi
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048def:	50                   	push   %eax
 8048df0:	53                   	push   %ebx
 8048df1:	e8 6a 05 00 00       	call   8049360 <write>
		c = *s++;
		switch (c) {
			case 'o':
                putc(fd, '0');
                cnt++;
                cnt += printf_write_radix(fd, va_arg(ap, uint32_t), 8);
 8048df6:	8b 16                	mov    (%esi),%edx
 8048df8:	b9 08 00 00 00       	mov    $0x8,%ecx
 8048dfd:	89 d8                	mov    %ebx,%eax
 8048dff:	89 fe                	mov    %edi,%esi
 8048e01:	e8 ca fc ff ff       	call   8048ad0 <printf_write_radix>
 8048e06:	83 c4 10             	add    $0x10,%esp
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
 8048e09:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 8048e0c:	e9 af fe ff ff       	jmp    8048cc0 <printf+0x20>
 8048e11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
                putc(fd, '0');
                cnt++;
                cnt += printf_write_radix(fd, va_arg(ap, uint32_t), 8);
                break;
            case 'd':
                d_num = va_arg(ap, int32_t);
 8048e18:	8b 16                	mov    (%esi),%edx
 8048e1a:	8d 7e 04             	lea    0x4(%esi),%edi
                if (d_num < 0) {
 8048e1d:	85 d2                	test   %edx,%edx
 8048e1f:	78 64                	js     8048e85 <printf+0x1e5>
                    putc(fd, '-');
                    d_num &= (~0x80000000);
                }
                cnt += printf_write_radix(fd, d_num, 10);
 8048e21:	b9 0a 00 00 00       	mov    $0xa,%ecx
 8048e26:	89 d8                	mov    %ebx,%eax
                putc(fd, '0');
                cnt++;
                cnt += printf_write_radix(fd, va_arg(ap, uint32_t), 8);
                break;
            case 'd':
                d_num = va_arg(ap, int32_t);
 8048e28:	89 fe                	mov    %edi,%esi
                if (d_num < 0) {
                    putc(fd, '-');
                    d_num &= (~0x80000000);
                }
                cnt += printf_write_radix(fd, d_num, 10);
 8048e2a:	e8 a1 fc ff ff       	call   8048ad0 <printf_write_radix>
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
 8048e2f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 8048e32:	e9 89 fe ff ff       	jmp    8048cc0 <printf+0x20>
 8048e37:	89 f6                	mov    %esi,%esi
 8048e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
 8048e40:	8b 06                	mov    (%esi),%eax
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048e42:	83 ec 04             	sub    $0x4,%esp
                break;
            case 's':
                cnt += puts(fd, va_arg(ap, const char *));
                break;       
            case 'c':
                putc(fd, va_arg(ap, uint32_t));
 8048e45:	8d 7e 04             	lea    0x4(%esi),%edi
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048e48:	6a 01                	push   $0x1
                break;
            case 's':
                cnt += puts(fd, va_arg(ap, const char *));
                break;       
            case 'c':
                putc(fd, va_arg(ap, uint32_t));
 8048e4a:	89 fe                	mov    %edi,%esi
 8048e4c:	88 45 e1             	mov    %al,-0x1f(%ebp)
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048e4f:	8d 45 e1             	lea    -0x1f(%ebp),%eax
 8048e52:	50                   	push   %eax
 8048e53:	53                   	push   %ebx
 8048e54:	e8 07 05 00 00       	call   8049360 <write>
 8048e59:	83 c4 10             	add    $0x10,%esp
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
 8048e5c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 8048e5f:	e9 5c fe ff ff       	jmp    8048cc0 <printf+0x20>
 8048e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048e68:	8d 45 e0             	lea    -0x20(%ebp),%eax
 8048e6b:	83 ec 04             	sub    $0x4,%esp
 8048e6e:	88 55 e0             	mov    %dl,-0x20(%ebp)
 8048e71:	6a 01                	push   $0x1
 8048e73:	50                   	push   %eax
 8048e74:	53                   	push   %ebx
 8048e75:	e8 e6 04 00 00       	call   8049360 <write>
 8048e7a:	83 c4 10             	add    $0x10,%esp
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
 8048e7d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 8048e80:	e9 3b fe ff ff       	jmp    8048cc0 <printf+0x20>
}
*/

static void putc(int fd, char c)
{
	write(fd, &c, 1);
 8048e85:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 8048e88:	83 ec 04             	sub    $0x4,%esp
 8048e8b:	89 55 d0             	mov    %edx,-0x30(%ebp)
 8048e8e:	6a 01                	push   $0x1
 8048e90:	c6 45 e5 2d          	movb   $0x2d,-0x1b(%ebp)
 8048e94:	50                   	push   %eax
 8048e95:	53                   	push   %ebx
 8048e96:	e8 c5 04 00 00       	call   8049360 <write>
                break;
            case 'd':
                d_num = va_arg(ap, int32_t);
                if (d_num < 0) {
                    putc(fd, '-');
                    d_num &= (~0x80000000);
 8048e9b:	8b 55 d0             	mov    -0x30(%ebp),%edx
 8048e9e:	83 c4 10             	add    $0x10,%esp
 8048ea1:	81 e2 ff ff ff 7f    	and    $0x7fffffff,%edx
 8048ea7:	e9 75 ff ff ff       	jmp    8048e21 <printf+0x181>
 8048eac:	66 90                	xchg   %ax,%ax
 8048eae:	66 90                	xchg   %ax,%ax

08048eb0 <strlen>:
#include <include/types.h>
#include <include/user.h>

int strlen(char *s)
{
 8048eb0:	55                   	push   %ebp
 8048eb1:	89 e5                	mov    %esp,%ebp
 8048eb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
    if (!s)
 8048eb6:	85 c9                	test   %ecx,%ecx
 8048eb8:	74 1a                	je     8048ed4 <strlen+0x24>
 8048eba:	31 c0                	xor    %eax,%eax
        return -1;

    int i = 0;
    while (s[i++] != '\0')
 8048ebc:	8d 50 01             	lea    0x1(%eax),%edx
 8048ebf:	80 7c 11 ff 00       	cmpb   $0x0,-0x1(%ecx,%edx,1)
 8048ec4:	74 0c                	je     8048ed2 <strlen+0x22>
 8048ec6:	89 d0                	mov    %edx,%eax
 8048ec8:	8d 50 01             	lea    0x1(%eax),%edx
 8048ecb:	80 7c 11 ff 00       	cmpb   $0x0,-0x1(%ecx,%edx,1)
 8048ed0:	75 f4                	jne    8048ec6 <strlen+0x16>
        continue;
    return i-1;
}
 8048ed2:	5d                   	pop    %ebp
 8048ed3:	c3                   	ret    
#include <include/user.h>

int strlen(char *s)
{
    if (!s)
        return -1;
 8048ed4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

    int i = 0;
    while (s[i++] != '\0')
        continue;
    return i-1;
}
 8048ed9:	5d                   	pop    %ebp
 8048eda:	c3                   	ret    
 8048edb:	90                   	nop
 8048edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

08048ee0 <strcmp>:

int strcmp(const char *str1, const char *str2)
{
 8048ee0:	55                   	push   %ebp
 8048ee1:	89 e5                	mov    %esp,%ebp
 8048ee3:	56                   	push   %esi
 8048ee4:	53                   	push   %ebx
 8048ee5:	8b 55 08             	mov    0x8(%ebp),%edx
 8048ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    while (*str1 && (*str1 == *str2)) {
 8048eeb:	0f b6 02             	movzbl (%edx),%eax
 8048eee:	0f b6 19             	movzbl (%ecx),%ebx
 8048ef1:	84 c0                	test   %al,%al
 8048ef3:	75 1e                	jne    8048f13 <strcmp+0x33>
 8048ef5:	eb 29                	jmp    8048f20 <strcmp+0x40>
 8048ef7:	89 f6                	mov    %esi,%esi
 8048ef9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
        str1++;
 8048f00:	83 c2 01             	add    $0x1,%edx
    return i-1;
}

int strcmp(const char *str1, const char *str2)
{
    while (*str1 && (*str1 == *str2)) {
 8048f03:	0f b6 02             	movzbl (%edx),%eax
        str1++;
        str2++;
 8048f06:	8d 71 01             	lea    0x1(%ecx),%esi
    return i-1;
}

int strcmp(const char *str1, const char *str2)
{
    while (*str1 && (*str1 == *str2)) {
 8048f09:	0f b6 59 01          	movzbl 0x1(%ecx),%ebx
 8048f0d:	84 c0                	test   %al,%al
 8048f0f:	74 0f                	je     8048f20 <strcmp+0x40>
 8048f11:	89 f1                	mov    %esi,%ecx
 8048f13:	38 d8                	cmp    %bl,%al
 8048f15:	74 e9                	je     8048f00 <strcmp+0x20>
        str1++;
        str2++;
    }
    return (int)((uchar)*str1 - (uchar)*str2);
 8048f17:	29 d8                	sub    %ebx,%eax
}
 8048f19:	5b                   	pop    %ebx
 8048f1a:	5e                   	pop    %esi
 8048f1b:	5d                   	pop    %ebp
 8048f1c:	c3                   	ret    
 8048f1d:	8d 76 00             	lea    0x0(%esi),%esi
    return i-1;
}

int strcmp(const char *str1, const char *str2)
{
    while (*str1 && (*str1 == *str2)) {
 8048f20:	31 c0                	xor    %eax,%eax
        str1++;
        str2++;
    }
    return (int)((uchar)*str1 - (uchar)*str2);
 8048f22:	29 d8                	sub    %ebx,%eax
}
 8048f24:	5b                   	pop    %ebx
 8048f25:	5e                   	pop    %esi
 8048f26:	5d                   	pop    %ebp
 8048f27:	c3                   	ret    
 8048f28:	90                   	nop
 8048f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

08048f30 <strncmp>:

int strncmp(const char *str1, const char *str2, int n)
{
 8048f30:	55                   	push   %ebp
 8048f31:	89 e5                	mov    %esp,%ebp
 8048f33:	57                   	push   %edi
 8048f34:	56                   	push   %esi
 8048f35:	8b 55 10             	mov    0x10(%ebp),%edx
 8048f38:	53                   	push   %ebx
 8048f39:	8b 4d 08             	mov    0x8(%ebp),%ecx
 8048f3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
    while ((n > 0) && (*str1) && (*str1 == *str2)) {
 8048f3f:	83 fa 00             	cmp    $0x0,%edx
 8048f42:	7e 40                	jle    8048f84 <strncmp+0x54>
 8048f44:	0f b6 01             	movzbl (%ecx),%eax
 8048f47:	0f b6 37             	movzbl (%edi),%esi
 8048f4a:	84 c0                	test   %al,%al
 8048f4c:	74 3e                	je     8048f8c <strncmp+0x5c>
 8048f4e:	89 f3                	mov    %esi,%ebx
 8048f50:	38 d8                	cmp    %bl,%al
 8048f52:	74 1e                	je     8048f72 <strncmp+0x42>
 8048f54:	eb 36                	jmp    8048f8c <strncmp+0x5c>
 8048f56:	8d 76 00             	lea    0x0(%esi),%esi
 8048f59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
 8048f60:	0f b6 01             	movzbl (%ecx),%eax
 8048f63:	84 c0                	test   %al,%al
 8048f65:	74 39                	je     8048fa0 <strncmp+0x70>
 8048f67:	0f b6 33             	movzbl (%ebx),%esi
 8048f6a:	89 df                	mov    %ebx,%edi
 8048f6c:	89 f3                	mov    %esi,%ebx
 8048f6e:	38 d8                	cmp    %bl,%al
 8048f70:	75 1a                	jne    8048f8c <strncmp+0x5c>
        n--;
        str1++;
 8048f72:	83 c1 01             	add    $0x1,%ecx
    return (int)((uchar)*str1 - (uchar)*str2);
}

int strncmp(const char *str1, const char *str2, int n)
{
    while ((n > 0) && (*str1) && (*str1 == *str2)) {
 8048f75:	83 ea 01             	sub    $0x1,%edx
        n--;
        str1++;
        str2++;
 8048f78:	8d 5f 01             	lea    0x1(%edi),%ebx
    return (int)((uchar)*str1 - (uchar)*str2);
}

int strncmp(const char *str1, const char *str2, int n)
{
    while ((n > 0) && (*str1) && (*str1 == *str2)) {
 8048f7b:	75 e3                	jne    8048f60 <strncmp+0x30>
        str2++;
    }
    if (!n)
        return 0;
    return (uchar)(*str1) - (uchar)(*str2);
}
 8048f7d:	5b                   	pop    %ebx
        n--;
        str1++;
        str2++;
    }
    if (!n)
        return 0;
 8048f7e:	31 c0                	xor    %eax,%eax
    return (uchar)(*str1) - (uchar)(*str2);
}
 8048f80:	5e                   	pop    %esi
 8048f81:	5f                   	pop    %edi
 8048f82:	5d                   	pop    %ebp
 8048f83:	c3                   	ret    
    while ((n > 0) && (*str1) && (*str1 == *str2)) {
        n--;
        str1++;
        str2++;
    }
    if (!n)
 8048f84:	74 f7                	je     8048f7d <strncmp+0x4d>
 8048f86:	0f b6 01             	movzbl (%ecx),%eax
 8048f89:	0f b6 37             	movzbl (%edi),%esi
        return 0;
    return (uchar)(*str1) - (uchar)(*str2);
 8048f8c:	89 f2                	mov    %esi,%edx
 8048f8e:	0f b6 f2             	movzbl %dl,%esi
}
 8048f91:	5b                   	pop    %ebx
        str1++;
        str2++;
    }
    if (!n)
        return 0;
    return (uchar)(*str1) - (uchar)(*str2);
 8048f92:	29 f0                	sub    %esi,%eax
}
 8048f94:	5e                   	pop    %esi
 8048f95:	5f                   	pop    %edi
 8048f96:	5d                   	pop    %ebp
 8048f97:	c3                   	ret    
 8048f98:	90                   	nop
 8048f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 8048fa0:	0f b6 77 01          	movzbl 0x1(%edi),%esi
 8048fa4:	eb e6                	jmp    8048f8c <strncmp+0x5c>
 8048fa6:	8d 76 00             	lea    0x0(%esi),%esi
 8048fa9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08048fb0 <strcpy>:

char *strcpy(char *des, const char *src)
{
 8048fb0:	55                   	push   %ebp
 8048fb1:	89 e5                	mov    %esp,%ebp
 8048fb3:	53                   	push   %ebx
 8048fb4:	8b 45 08             	mov    0x8(%ebp),%eax
 8048fb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (!des || !src)
 8048fba:	85 c0                	test   %eax,%eax
 8048fbc:	74 1a                	je     8048fd8 <strcpy+0x28>
 8048fbe:	85 db                	test   %ebx,%ebx
 8048fc0:	74 16                	je     8048fd8 <strcpy+0x28>
 8048fc2:	31 d2                	xor    %edx,%edx
        return 0;

    char *r = des;
    while ((*des++ = *src++) != '\0') 
 8048fc4:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 8048fc8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 8048fcb:	83 c2 01             	add    $0x1,%edx
 8048fce:	84 c9                	test   %cl,%cl
 8048fd0:	75 f2                	jne    8048fc4 <strcpy+0x14>
        continue;
    return r;
}
 8048fd2:	5b                   	pop    %ebx
 8048fd3:	5d                   	pop    %ebp
 8048fd4:	c3                   	ret    
 8048fd5:	8d 76 00             	lea    0x0(%esi),%esi
}

char *strcpy(char *des, const char *src)
{
    if (!des || !src)
        return 0;
 8048fd8:	31 c0                	xor    %eax,%eax

    char *r = des;
    while ((*des++ = *src++) != '\0') 
        continue;
    return r;
}
 8048fda:	5b                   	pop    %ebx
 8048fdb:	5d                   	pop    %ebp
 8048fdc:	c3                   	ret    
 8048fdd:	8d 76 00             	lea    0x0(%esi),%esi

08048fe0 <strncpy>:

char *strncpy(char *des, const char *src, int n)
{
 8048fe0:	55                   	push   %ebp
 8048fe1:	89 e5                	mov    %esp,%ebp
 8048fe3:	56                   	push   %esi
 8048fe4:	53                   	push   %ebx
 8048fe5:	8b 75 08             	mov    0x8(%ebp),%esi
 8048fe8:	8b 55 0c             	mov    0xc(%ebp),%edx
 8048feb:	8b 4d 10             	mov    0x10(%ebp),%ecx
    if (!des || !src)
 8048fee:	85 f6                	test   %esi,%esi
 8048ff0:	74 2e                	je     8049020 <strncpy+0x40>
 8048ff2:	85 d2                	test   %edx,%edx
 8048ff4:	74 2a                	je     8049020 <strncpy+0x40>
        return 0;

    while (((*des++ = *src++) != '\0') && --n > 0)
 8048ff6:	83 c2 01             	add    $0x1,%edx
 8048ff9:	0f b6 5a ff          	movzbl -0x1(%edx),%ebx
 8048ffd:	8d 46 01             	lea    0x1(%esi),%eax
 8049000:	84 db                	test   %bl,%bl
 8049002:	88 58 ff             	mov    %bl,-0x1(%eax)
 8049005:	74 11                	je     8049018 <strncpy+0x38>
 8049007:	83 e9 01             	sub    $0x1,%ecx
 804900a:	85 c9                	test   %ecx,%ecx
 804900c:	7e 0a                	jle    8049018 <strncpy+0x38>
 804900e:	89 c6                	mov    %eax,%esi
 8049010:	eb e4                	jmp    8048ff6 <strncpy+0x16>
 8049012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        continue;
    *des = '\0';
 8049018:	c6 46 01 00          	movb   $0x0,0x1(%esi)
    return des;
}
 804901c:	5b                   	pop    %ebx
 804901d:	5e                   	pop    %esi
 804901e:	5d                   	pop    %ebp
 804901f:	c3                   	ret    
 8049020:	5b                   	pop    %ebx
}

char *strncpy(char *des, const char *src, int n)
{
    if (!des || !src)
        return 0;
 8049021:	31 c0                	xor    %eax,%eax

    while (((*des++ = *src++) != '\0') && --n > 0)
        continue;
    *des = '\0';
    return des;
}
 8049023:	5e                   	pop    %esi
 8049024:	5d                   	pop    %ebp
 8049025:	c3                   	ret    
 8049026:	8d 76 00             	lea    0x0(%esi),%esi
 8049029:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08049030 <strcat>:

char *strcat(char *des, char *src)
{
 8049030:	55                   	push   %ebp
 8049031:	89 e5                	mov    %esp,%ebp
 8049033:	53                   	push   %ebx
 8049034:	8b 45 08             	mov    0x8(%ebp),%eax
 8049037:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#include <include/types.h>
#include <include/user.h>

int strlen(char *s)
{
    if (!s)
 804903a:	85 c0                	test   %eax,%eax
 804903c:	74 32                	je     8049070 <strcat+0x40>
 804903e:	89 c1                	mov    %eax,%ecx
        return -1;

    int i = 0;
    while (s[i++] != '\0')
 8049040:	89 ca                	mov    %ecx,%edx
 8049042:	83 c1 01             	add    $0x1,%ecx
 8049045:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
 8049049:	75 f5                	jne    8049040 <strcat+0x10>
    return (uchar)(*str1) - (uchar)(*str2);
}

char *strcpy(char *des, const char *src)
{
    if (!des || !src)
 804904b:	85 d2                	test   %edx,%edx
 804904d:	74 15                	je     8049064 <strcat+0x34>
 804904f:	85 db                	test   %ebx,%ebx
 8049051:	74 11                	je     8049064 <strcat+0x34>
        return 0;

    char *r = des;
    while ((*des++ = *src++) != '\0') 
 8049053:	83 c3 01             	add    $0x1,%ebx
 8049056:	0f b6 4b ff          	movzbl -0x1(%ebx),%ecx
 804905a:	83 c2 01             	add    $0x1,%edx
 804905d:	84 c9                	test   %cl,%cl
 804905f:	88 4a ff             	mov    %cl,-0x1(%edx)
 8049062:	75 ef                	jne    8049053 <strcat+0x23>
char *strcat(char *des, char *src)
{
    int len = strlen(des);
    strcpy(des+len, src);
    return des;
}
 8049064:	5b                   	pop    %ebx
 8049065:	5d                   	pop    %ebp
 8049066:	c3                   	ret    
 8049067:	89 f6                	mov    %esi,%esi
 8049069:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
#include <include/types.h>
#include <include/user.h>

int strlen(char *s)
{
    if (!s)
 8049070:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 8049075:	eb d4                	jmp    804904b <strcat+0x1b>
 8049077:	89 f6                	mov    %esi,%esi
 8049079:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08049080 <strncat>:
    strcpy(des+len, src);
    return des;
}

char *strncat(char *des, const char *src, int nbytes)
{
 8049080:	55                   	push   %ebp
 8049081:	89 e5                	mov    %esp,%ebp
 8049083:	57                   	push   %edi
 8049084:	56                   	push   %esi
 8049085:	8b 45 08             	mov    0x8(%ebp),%eax
 8049088:	53                   	push   %ebx
 8049089:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 804908c:	8b 75 10             	mov    0x10(%ebp),%esi
#include <include/types.h>
#include <include/user.h>

int strlen(char *s)
{
    if (!s)
 804908f:	85 c0                	test   %eax,%eax
 8049091:	74 45                	je     80490d8 <strncat+0x58>
 8049093:	89 c3                	mov    %eax,%ebx
        return -1;

    int i = 0;
    while (s[i++] != '\0')
 8049095:	89 da                	mov    %ebx,%edx
 8049097:	83 c3 01             	add    $0x1,%ebx
 804909a:	80 7b ff 00          	cmpb   $0x0,-0x1(%ebx)
 804909e:	75 f5                	jne    8049095 <strncat+0x15>
    return r;
}

char *strncpy(char *des, const char *src, int n)
{
    if (!des || !src)
 80490a0:	85 d2                	test   %edx,%edx
 80490a2:	74 28                	je     80490cc <strncat+0x4c>
 80490a4:	85 c9                	test   %ecx,%ecx
 80490a6:	74 24                	je     80490cc <strncat+0x4c>
        return 0;

    while (((*des++ = *src++) != '\0') && --n > 0)
 80490a8:	83 c1 01             	add    $0x1,%ecx
 80490ab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
 80490af:	8d 7a 01             	lea    0x1(%edx),%edi
 80490b2:	84 db                	test   %bl,%bl
 80490b4:	88 5f ff             	mov    %bl,-0x1(%edi)
 80490b7:	74 0f                	je     80490c8 <strncat+0x48>
 80490b9:	83 ee 01             	sub    $0x1,%esi
 80490bc:	85 f6                	test   %esi,%esi
 80490be:	7e 08                	jle    80490c8 <strncat+0x48>
 80490c0:	89 fa                	mov    %edi,%edx
 80490c2:	eb e4                	jmp    80490a8 <strncat+0x28>
 80490c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        continue;
    *des = '\0';
 80490c8:	c6 42 01 00          	movb   $0x0,0x1(%edx)
char *strncat(char *des, const char *src, int nbytes)
{
    int len = strlen(des);
    strncpy(des+len, src, nbytes);
    return des;
}
 80490cc:	5b                   	pop    %ebx
 80490cd:	5e                   	pop    %esi
 80490ce:	5f                   	pop    %edi
 80490cf:	5d                   	pop    %ebp
 80490d0:	c3                   	ret    
 80490d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
#include <include/types.h>
#include <include/user.h>

int strlen(char *s)
{
    if (!s)
 80490d8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 80490dd:	eb c1                	jmp    80490a0 <strncat+0x20>
 80490df:	90                   	nop

080490e0 <strchr>:
    strncpy(des+len, src, nbytes);
    return des;
}

char *strchr(char *s, char c)
{
 80490e0:	55                   	push   %ebp
 80490e1:	89 e5                	mov    %esp,%ebp
 80490e3:	53                   	push   %ebx
 80490e4:	8b 45 08             	mov    0x8(%ebp),%eax
 80490e7:	8b 55 0c             	mov    0xc(%ebp),%edx
    if (!s)
 80490ea:	85 c0                	test   %eax,%eax
 80490ec:	74 20                	je     804910e <strchr+0x2e>
        return 0;

    while (*s) {
 80490ee:	0f b6 18             	movzbl (%eax),%ebx
 80490f1:	84 db                	test   %bl,%bl
 80490f3:	74 19                	je     804910e <strchr+0x2e>
        if (*s == c)
 80490f5:	38 da                	cmp    %bl,%dl
 80490f7:	89 d1                	mov    %edx,%ecx
 80490f9:	75 09                	jne    8049104 <strchr+0x24>
 80490fb:	eb 13                	jmp    8049110 <strchr+0x30>
 80490fd:	8d 76 00             	lea    0x0(%esi),%esi
 8049100:	38 ca                	cmp    %cl,%dl
 8049102:	74 0c                	je     8049110 <strchr+0x30>
            return s;
        s++;
 8049104:	83 c0 01             	add    $0x1,%eax
char *strchr(char *s, char c)
{
    if (!s)
        return 0;

    while (*s) {
 8049107:	0f b6 10             	movzbl (%eax),%edx
 804910a:	84 d2                	test   %dl,%dl
 804910c:	75 f2                	jne    8049100 <strchr+0x20>
}

char *strchr(char *s, char c)
{
    if (!s)
        return 0;
 804910e:	31 c0                	xor    %eax,%eax
        if (*s == c)
            return s;
        s++;
    }
    return 0;
}
 8049110:	5b                   	pop    %ebx
 8049111:	5d                   	pop    %ebp
 8049112:	c3                   	ret    
 8049113:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 8049119:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08049120 <memset>:

void *memset(void *s, char ch, size_t n)
{
 8049120:	55                   	push   %ebp
 8049121:	89 e5                	mov    %esp,%ebp
 8049123:	56                   	push   %esi
 8049124:	53                   	push   %ebx
 8049125:	8b 75 10             	mov    0x10(%ebp),%esi
 8049128:	8b 45 08             	mov    0x8(%ebp),%eax
 804912b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
    char *ts = s;
    for (int i = 0; i < n; i++)
 804912f:	85 f6                	test   %esi,%esi
 8049131:	8d 0c 30             	lea    (%eax,%esi,1),%ecx
 8049134:	74 14                	je     804914a <memset+0x2a>
 8049136:	89 c2                	mov    %eax,%edx
 8049138:	90                   	nop
 8049139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        *ts++ = ch;
 8049140:	83 c2 01             	add    $0x1,%edx
 8049143:	88 5a ff             	mov    %bl,-0x1(%edx)
}

void *memset(void *s, char ch, size_t n)
{
    char *ts = s;
    for (int i = 0; i < n; i++)
 8049146:	39 d1                	cmp    %edx,%ecx
 8049148:	75 f6                	jne    8049140 <memset+0x20>
        *ts++ = ch;
    return s;
}
 804914a:	5b                   	pop    %ebx
 804914b:	5e                   	pop    %esi
 804914c:	5d                   	pop    %ebp
 804914d:	c3                   	ret    
 804914e:	66 90                	xchg   %ax,%ax

08049150 <memmove>:

void *memmove(void *dst, const void *src, size_t n)
{
 8049150:	55                   	push   %ebp
 8049151:	89 e5                	mov    %esp,%ebp
 8049153:	56                   	push   %esi
 8049154:	53                   	push   %ebx
 8049155:	8b 45 08             	mov    0x8(%ebp),%eax
 8049158:	8b 75 0c             	mov    0xc(%ebp),%esi
 804915b:	8b 5d 10             	mov    0x10(%ebp),%ebx
    const char *s = src;
    char *d = dst;

    if (s < d && (s + n > d)) {
 804915e:	39 c6                	cmp    %eax,%esi
 8049160:	73 2e                	jae    8049190 <memmove+0x40>
 8049162:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
 8049165:	39 c8                	cmp    %ecx,%eax
 8049167:	73 27                	jae    8049190 <memmove+0x40>
        s += n;
        d += n;
        while (n-- > 0)
 8049169:	85 db                	test   %ebx,%ebx
 804916b:	8d 53 ff             	lea    -0x1(%ebx),%edx
 804916e:	74 17                	je     8049187 <memmove+0x37>
            *--d = *--s;
 8049170:	29 d9                	sub    %ebx,%ecx
 8049172:	89 cb                	mov    %ecx,%ebx
 8049174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 8049178:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 804917c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    char *d = dst;

    if (s < d && (s + n > d)) {
        s += n;
        d += n;
        while (n-- > 0)
 804917f:	83 ea 01             	sub    $0x1,%edx
 8049182:	83 fa ff             	cmp    $0xffffffff,%edx
 8049185:	75 f1                	jne    8049178 <memmove+0x28>
    } else {
        while (n-- > 0)
            *d++ = *s++;
    }
    return dst;
}
 8049187:	5b                   	pop    %ebx
 8049188:	5e                   	pop    %esi
 8049189:	5d                   	pop    %ebp
 804918a:	c3                   	ret    
 804918b:	90                   	nop
 804918c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        s += n;
        d += n;
        while (n-- > 0)
            *--d = *--s;
    } else {
        while (n-- > 0)
 8049190:	31 d2                	xor    %edx,%edx
 8049192:	85 db                	test   %ebx,%ebx
 8049194:	74 f1                	je     8049187 <memmove+0x37>
 8049196:	8d 76 00             	lea    0x0(%esi),%esi
 8049199:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
            *d++ = *s++;
 80491a0:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 80491a4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 80491a7:	83 c2 01             	add    $0x1,%edx
        s += n;
        d += n;
        while (n-- > 0)
            *--d = *--s;
    } else {
        while (n-- > 0)
 80491aa:	39 d3                	cmp    %edx,%ebx
 80491ac:	75 f2                	jne    80491a0 <memmove+0x50>
            *d++ = *s++;
    }
    return dst;
}
 80491ae:	5b                   	pop    %ebx
 80491af:	5e                   	pop    %esi
 80491b0:	5d                   	pop    %ebp
 80491b1:	c3                   	ret    
 80491b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 80491b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

080491c0 <atoi>:

int atoi(const char *s)
{
 80491c0:	55                   	push   %ebp
 80491c1:	89 e5                	mov    %esp,%ebp
 80491c3:	53                   	push   %ebx
 80491c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 80491c7:	0f be 11             	movsbl (%ecx),%edx
 80491ca:	8d 42 d0             	lea    -0x30(%edx),%eax
 80491cd:	3c 09                	cmp    $0x9,%al
 80491cf:	b8 00 00 00 00       	mov    $0x0,%eax
 80491d4:	77 1f                	ja     80491f5 <atoi+0x35>
 80491d6:	8d 76 00             	lea    0x0(%esi),%esi
 80491d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    n = n*10 + *s++ - '0';
 80491e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
 80491e3:	83 c1 01             	add    $0x1,%ecx
 80491e6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
int atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 80491ea:	0f be 11             	movsbl (%ecx),%edx
 80491ed:	8d 5a d0             	lea    -0x30(%edx),%ebx
 80491f0:	80 fb 09             	cmp    $0x9,%bl
 80491f3:	76 eb                	jbe    80491e0 <atoi+0x20>
    n = n*10 + *s++ - '0';
  return n;
 80491f5:	5b                   	pop    %ebx
 80491f6:	5d                   	pop    %ebp
 80491f7:	c3                   	ret    
 80491f8:	66 90                	xchg   %ax,%ax
 80491fa:	66 90                	xchg   %ax,%ax
 80491fc:	66 90                	xchg   %ax,%ax
 80491fe:	66 90                	xchg   %ax,%ax

08049200 <fork>:
#include <include/types.h>
#include <include/user.h>

int fork(void)
{
 8049200:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049201:	31 d2                	xor    %edx,%edx
 8049203:	b8 0f 00 00 00       	mov    $0xf,%eax
 8049208:	89 d1                	mov    %edx,%ecx
#include <include/types.h>
#include <include/user.h>

int fork(void)
{
 804920a:	89 e5                	mov    %esp,%ebp
 804920c:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804920d:	89 d7                	mov    %edx,%edi
#include <include/types.h>
#include <include/user.h>

int fork(void)
{
 804920f:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049210:	89 d6                	mov    %edx,%esi
#include <include/types.h>
#include <include/user.h>

int fork(void)
{
 8049212:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049213:	89 d3                	mov    %edx,%ebx
 8049215:	cd 80                	int    $0x80
#include <include/user.h>

int fork(void)
{
	return usyscall(SYS_fork, 0, 0, 0, 0, 0);
}
 8049217:	5b                   	pop    %ebx
 8049218:	5e                   	pop    %esi
 8049219:	5f                   	pop    %edi
 804921a:	5d                   	pop    %ebp
 804921b:	c3                   	ret    
 804921c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

08049220 <exit>:

int exit(void)
{
 8049220:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049221:	31 d2                	xor    %edx,%edx
 8049223:	b8 01 00 00 00       	mov    $0x1,%eax
 8049228:	89 d1                	mov    %edx,%ecx
{
	return usyscall(SYS_fork, 0, 0, 0, 0, 0);
}

int exit(void)
{
 804922a:	89 e5                	mov    %esp,%ebp
 804922c:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804922d:	89 d7                	mov    %edx,%edi
{
	return usyscall(SYS_fork, 0, 0, 0, 0, 0);
}

int exit(void)
{
 804922f:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049230:	89 d6                	mov    %edx,%esi
{
	return usyscall(SYS_fork, 0, 0, 0, 0, 0);
}

int exit(void)
{
 8049232:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049233:	89 d3                	mov    %edx,%ebx
 8049235:	cd 80                	int    $0x80
}

int exit(void)
{
	return usyscall(SYS_exit, 0, 0, 0, 0, 0);
}
 8049237:	5b                   	pop    %ebx
 8049238:	5e                   	pop    %esi
 8049239:	5f                   	pop    %edi
 804923a:	5d                   	pop    %ebp
 804923b:	c3                   	ret    
 804923c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

08049240 <sbrk>:

void *sbrk(int n)
{
 8049240:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049241:	31 c9                	xor    %ecx,%ecx
 8049243:	b8 13 00 00 00       	mov    $0x13,%eax
{
	return usyscall(SYS_exit, 0, 0, 0, 0, 0);
}

void *sbrk(int n)
{
 8049248:	89 e5                	mov    %esp,%ebp
 804924a:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804924b:	89 cf                	mov    %ecx,%edi
{
	return usyscall(SYS_exit, 0, 0, 0, 0, 0);
}

void *sbrk(int n)
{
 804924d:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804924e:	8b 55 08             	mov    0x8(%ebp),%edx
 8049251:	89 ce                	mov    %ecx,%esi
{
	return usyscall(SYS_exit, 0, 0, 0, 0, 0);
}

void *sbrk(int n)
{
 8049253:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049254:	89 cb                	mov    %ecx,%ebx
 8049256:	cd 80                	int    $0x80
}

void *sbrk(int n)
{
	return (void *)usyscall(SYS_sbrk, (uint32_t)n, 0, 0, 0, 0);
}
 8049258:	5b                   	pop    %ebx
 8049259:	5e                   	pop    %esi
 804925a:	5f                   	pop    %edi
 804925b:	5d                   	pop    %ebp
 804925c:	c3                   	ret    
 804925d:	8d 76 00             	lea    0x0(%esi),%esi

08049260 <brk>:

int brk(void *heap_brk)
{
 8049260:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049261:	31 c9                	xor    %ecx,%ecx
 8049263:	b8 25 00 00 00       	mov    $0x25,%eax
{
	return (void *)usyscall(SYS_sbrk, (uint32_t)n, 0, 0, 0, 0);
}

int brk(void *heap_brk)
{
 8049268:	89 e5                	mov    %esp,%ebp
 804926a:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804926b:	89 cf                	mov    %ecx,%edi
{
	return (void *)usyscall(SYS_sbrk, (uint32_t)n, 0, 0, 0, 0);
}

int brk(void *heap_brk)
{
 804926d:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804926e:	8b 55 08             	mov    0x8(%ebp),%edx
 8049271:	89 ce                	mov    %ecx,%esi
{
	return (void *)usyscall(SYS_sbrk, (uint32_t)n, 0, 0, 0, 0);
}

int brk(void *heap_brk)
{
 8049273:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049274:	89 cb                	mov    %ecx,%ebx
 8049276:	cd 80                	int    $0x80
}

int brk(void *heap_brk)
{
	return usyscall(SYS_brk, (uint32_t)heap_brk, 0, 0, 0, 0);
}
 8049278:	5b                   	pop    %ebx
 8049279:	5e                   	pop    %esi
 804927a:	5f                   	pop    %edi
 804927b:	5d                   	pop    %ebp
 804927c:	c3                   	ret    
 804927d:	8d 76 00             	lea    0x0(%esi),%esi

08049280 <wait>:

ushort wait(void)
{
 8049280:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049281:	31 d2                	xor    %edx,%edx
 8049283:	b8 02 00 00 00       	mov    $0x2,%eax
 8049288:	89 d1                	mov    %edx,%ecx
{
	return usyscall(SYS_brk, (uint32_t)heap_brk, 0, 0, 0, 0);
}

ushort wait(void)
{
 804928a:	89 e5                	mov    %esp,%ebp
 804928c:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804928d:	89 d7                	mov    %edx,%edi
{
	return usyscall(SYS_brk, (uint32_t)heap_brk, 0, 0, 0, 0);
}

ushort wait(void)
{
 804928f:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049290:	89 d6                	mov    %edx,%esi
{
	return usyscall(SYS_brk, (uint32_t)heap_brk, 0, 0, 0, 0);
}

ushort wait(void)
{
 8049292:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049293:	89 d3                	mov    %edx,%ebx
 8049295:	cd 80                	int    $0x80
}

ushort wait(void)
{
	return usyscall(SYS_wait, 0, 0, 0, 0, 0);
}
 8049297:	5b                   	pop    %ebx
 8049298:	5e                   	pop    %esi
 8049299:	5f                   	pop    %edi
 804929a:	5d                   	pop    %ebp
 804929b:	c3                   	ret    
 804929c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

080492a0 <kill>:

int kill(pid_t pid)
{
 80492a0:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492a1:	31 c9                	xor    %ecx,%ecx
 80492a3:	b8 03 00 00 00       	mov    $0x3,%eax
{
	return usyscall(SYS_wait, 0, 0, 0, 0, 0);
}

int kill(pid_t pid)
{
 80492a8:	89 e5                	mov    %esp,%ebp
 80492aa:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492ab:	89 cf                	mov    %ecx,%edi
{
	return usyscall(SYS_wait, 0, 0, 0, 0, 0);
}

int kill(pid_t pid)
{
 80492ad:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492ae:	8b 55 08             	mov    0x8(%ebp),%edx
 80492b1:	89 ce                	mov    %ecx,%esi
{
	return usyscall(SYS_wait, 0, 0, 0, 0, 0);
}

int kill(pid_t pid)
{
 80492b3:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492b4:	89 cb                	mov    %ecx,%ebx
 80492b6:	cd 80                	int    $0x80
}

int kill(pid_t pid)
{
	return usyscall(SYS_kill, pid, 0, 0, 0, 0);
}
 80492b8:	5b                   	pop    %ebx
 80492b9:	5e                   	pop    %esi
 80492ba:	5f                   	pop    %edi
 80492bb:	5d                   	pop    %ebp
 80492bc:	c3                   	ret    
 80492bd:	8d 76 00             	lea    0x0(%esi),%esi

080492c0 <exec>:

int exec(char *pathname, char **argv)
{
 80492c0:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492c1:	b8 21 00 00 00       	mov    $0x21,%eax
{
	return usyscall(SYS_kill, pid, 0, 0, 0, 0);
}

int exec(char *pathname, char **argv)
{
 80492c6:	89 e5                	mov    %esp,%ebp
 80492c8:	57                   	push   %edi
 80492c9:	56                   	push   %esi
 80492ca:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492cb:	31 db                	xor    %ebx,%ebx
 80492cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 80492d0:	8b 55 08             	mov    0x8(%ebp),%edx
 80492d3:	89 df                	mov    %ebx,%edi
 80492d5:	89 de                	mov    %ebx,%esi
 80492d7:	cd 80                	int    $0x80
}

int exec(char *pathname, char **argv)
{
	return usyscall(SYS_exec, (uint32_t)pathname, (uint32_t)argv, 0, 0, 0);
}
 80492d9:	5b                   	pop    %ebx
 80492da:	5e                   	pop    %esi
 80492db:	5f                   	pop    %edi
 80492dc:	5d                   	pop    %ebp
 80492dd:	c3                   	ret    
 80492de:	66 90                	xchg   %ax,%ax

080492e0 <pipe>:

int pipe(int fd[2])
{
 80492e0:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492e1:	31 c9                	xor    %ecx,%ecx
 80492e3:	b8 14 00 00 00       	mov    $0x14,%eax
{
	return usyscall(SYS_exec, (uint32_t)pathname, (uint32_t)argv, 0, 0, 0);
}

int pipe(int fd[2])
{
 80492e8:	89 e5                	mov    %esp,%ebp
 80492ea:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492eb:	89 cf                	mov    %ecx,%edi
{
	return usyscall(SYS_exec, (uint32_t)pathname, (uint32_t)argv, 0, 0, 0);
}

int pipe(int fd[2])
{
 80492ed:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492ee:	8b 55 08             	mov    0x8(%ebp),%edx
 80492f1:	89 ce                	mov    %ecx,%esi
{
	return usyscall(SYS_exec, (uint32_t)pathname, (uint32_t)argv, 0, 0, 0);
}

int pipe(int fd[2])
{
 80492f3:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80492f4:	89 cb                	mov    %ecx,%ebx
 80492f6:	cd 80                	int    $0x80
}

int pipe(int fd[2])
{
	return usyscall(SYS_pipe, (uint32_t)fd, 0, 0, 0, 0);
}
 80492f8:	5b                   	pop    %ebx
 80492f9:	5e                   	pop    %esi
 80492fa:	5f                   	pop    %edi
 80492fb:	5d                   	pop    %ebp
 80492fc:	c3                   	ret    
 80492fd:	8d 76 00             	lea    0x0(%esi),%esi

08049300 <dup>:

int dup(int fd)
{
 8049300:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049301:	31 c9                	xor    %ecx,%ecx
 8049303:	b8 15 00 00 00       	mov    $0x15,%eax
{
	return usyscall(SYS_pipe, (uint32_t)fd, 0, 0, 0, 0);
}

int dup(int fd)
{
 8049308:	89 e5                	mov    %esp,%ebp
 804930a:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804930b:	89 cf                	mov    %ecx,%edi
{
	return usyscall(SYS_pipe, (uint32_t)fd, 0, 0, 0, 0);
}

int dup(int fd)
{
 804930d:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804930e:	8b 55 08             	mov    0x8(%ebp),%edx
 8049311:	89 ce                	mov    %ecx,%esi
{
	return usyscall(SYS_pipe, (uint32_t)fd, 0, 0, 0, 0);
}

int dup(int fd)
{
 8049313:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049314:	89 cb                	mov    %ecx,%ebx
 8049316:	cd 80                	int    $0x80
}

int dup(int fd)
{
	return usyscall(SYS_dup, (uint32_t)fd, 0, 0, 0, 0);
}
 8049318:	5b                   	pop    %ebx
 8049319:	5e                   	pop    %esi
 804931a:	5f                   	pop    %edi
 804931b:	5d                   	pop    %ebp
 804931c:	c3                   	ret    
 804931d:	8d 76 00             	lea    0x0(%esi),%esi

08049320 <dup2>:

int dup2(int oldfd, int newfd)
{
 8049320:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049321:	b8 16 00 00 00       	mov    $0x16,%eax
{
	return usyscall(SYS_dup, (uint32_t)fd, 0, 0, 0, 0);
}

int dup2(int oldfd, int newfd)
{
 8049326:	89 e5                	mov    %esp,%ebp
 8049328:	57                   	push   %edi
 8049329:	56                   	push   %esi
 804932a:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804932b:	31 db                	xor    %ebx,%ebx
 804932d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 8049330:	8b 55 08             	mov    0x8(%ebp),%edx
 8049333:	89 df                	mov    %ebx,%edi
 8049335:	89 de                	mov    %ebx,%esi
 8049337:	cd 80                	int    $0x80
}

int dup2(int oldfd, int newfd)
{
	return usyscall(SYS_dup2, (uint32_t)oldfd, (uint32_t)newfd, 0, 0, 0);
}
 8049339:	5b                   	pop    %ebx
 804933a:	5e                   	pop    %esi
 804933b:	5f                   	pop    %edi
 804933c:	5d                   	pop    %ebp
 804933d:	c3                   	ret    
 804933e:	66 90                	xchg   %ax,%ax

08049340 <read>:

int read(int fd, char *des, uint32_t nbytes)
{
 8049340:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049341:	b8 17 00 00 00       	mov    $0x17,%eax
{
	return usyscall(SYS_dup2, (uint32_t)oldfd, (uint32_t)newfd, 0, 0, 0);
}

int read(int fd, char *des, uint32_t nbytes)
{
 8049346:	89 e5                	mov    %esp,%ebp
 8049348:	57                   	push   %edi
 8049349:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804934a:	31 f6                	xor    %esi,%esi
{
	return usyscall(SYS_dup2, (uint32_t)oldfd, (uint32_t)newfd, 0, 0, 0);
}

int read(int fd, char *des, uint32_t nbytes)
{
 804934c:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804934d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 8049350:	8b 55 08             	mov    0x8(%ebp),%edx
 8049353:	8b 5d 10             	mov    0x10(%ebp),%ebx
 8049356:	89 f7                	mov    %esi,%edi
 8049358:	cd 80                	int    $0x80
}

int read(int fd, char *des, uint32_t nbytes)
{
	return usyscall(SYS_read, (uint32_t)fd, (uint32_t)des, (uint32_t)nbytes, 0, 0);
}
 804935a:	5b                   	pop    %ebx
 804935b:	5e                   	pop    %esi
 804935c:	5f                   	pop    %edi
 804935d:	5d                   	pop    %ebp
 804935e:	c3                   	ret    
 804935f:	90                   	nop

08049360 <write>:

int write(int fd, char *src, uint32_t nbytes)
{
 8049360:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049361:	b8 18 00 00 00       	mov    $0x18,%eax
{
	return usyscall(SYS_read, (uint32_t)fd, (uint32_t)des, (uint32_t)nbytes, 0, 0);
}

int write(int fd, char *src, uint32_t nbytes)
{
 8049366:	89 e5                	mov    %esp,%ebp
 8049368:	57                   	push   %edi
 8049369:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804936a:	31 f6                	xor    %esi,%esi
{
	return usyscall(SYS_read, (uint32_t)fd, (uint32_t)des, (uint32_t)nbytes, 0, 0);
}

int write(int fd, char *src, uint32_t nbytes)
{
 804936c:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804936d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 8049370:	8b 55 08             	mov    0x8(%ebp),%edx
 8049373:	8b 5d 10             	mov    0x10(%ebp),%ebx
 8049376:	89 f7                	mov    %esi,%edi
 8049378:	cd 80                	int    $0x80
}

int write(int fd, char *src, uint32_t nbytes)
{
	return usyscall(SYS_write, (uint32_t)fd, (uint32_t)src, (uint32_t)nbytes, 0, 0);	
}
 804937a:	5b                   	pop    %ebx
 804937b:	5e                   	pop    %esi
 804937c:	5f                   	pop    %edi
 804937d:	5d                   	pop    %ebp
 804937e:	c3                   	ret    
 804937f:	90                   	nop

08049380 <close>:

int close(int fd)
{
 8049380:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049381:	31 c9                	xor    %ecx,%ecx
 8049383:	b8 19 00 00 00       	mov    $0x19,%eax
{
	return usyscall(SYS_write, (uint32_t)fd, (uint32_t)src, (uint32_t)nbytes, 0, 0);	
}

int close(int fd)
{
 8049388:	89 e5                	mov    %esp,%ebp
 804938a:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804938b:	89 cf                	mov    %ecx,%edi
{
	return usyscall(SYS_write, (uint32_t)fd, (uint32_t)src, (uint32_t)nbytes, 0, 0);	
}

int close(int fd)
{
 804938d:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804938e:	8b 55 08             	mov    0x8(%ebp),%edx
 8049391:	89 ce                	mov    %ecx,%esi
{
	return usyscall(SYS_write, (uint32_t)fd, (uint32_t)src, (uint32_t)nbytes, 0, 0);	
}

int close(int fd)
{
 8049393:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049394:	89 cb                	mov    %ecx,%ebx
 8049396:	cd 80                	int    $0x80
}

int close(int fd)
{
	return usyscall(SYS_close, (uint32_t)fd, 0, 0, 0, 0);
}
 8049398:	5b                   	pop    %ebx
 8049399:	5e                   	pop    %esi
 804939a:	5f                   	pop    %edi
 804939b:	5d                   	pop    %ebp
 804939c:	c3                   	ret    
 804939d:	8d 76 00             	lea    0x0(%esi),%esi

080493a0 <fstat>:

int fstat(int fd, struct stat *sbuf)
{
 80493a0:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493a1:	31 c9                	xor    %ecx,%ecx
 80493a3:	b8 1a 00 00 00       	mov    $0x1a,%eax
{
	return usyscall(SYS_close, (uint32_t)fd, 0, 0, 0, 0);
}

int fstat(int fd, struct stat *sbuf)
{
 80493a8:	89 e5                	mov    %esp,%ebp
 80493aa:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493ab:	89 cf                	mov    %ecx,%edi
{
	return usyscall(SYS_close, (uint32_t)fd, 0, 0, 0, 0);
}

int fstat(int fd, struct stat *sbuf)
{
 80493ad:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493ae:	8b 55 0c             	mov    0xc(%ebp),%edx
 80493b1:	89 ce                	mov    %ecx,%esi
{
	return usyscall(SYS_close, (uint32_t)fd, 0, 0, 0, 0);
}

int fstat(int fd, struct stat *sbuf)
{
 80493b3:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493b4:	89 cb                	mov    %ecx,%ebx
 80493b6:	cd 80                	int    $0x80
}

int fstat(int fd, struct stat *sbuf)
{
	return usyscall(SYS_fstat, (uint32_t)sbuf, 0, 0, 0, 0);
}
 80493b8:	5b                   	pop    %ebx
 80493b9:	5e                   	pop    %esi
 80493ba:	5f                   	pop    %edi
 80493bb:	5d                   	pop    %ebp
 80493bc:	c3                   	ret    
 80493bd:	8d 76 00             	lea    0x0(%esi),%esi

080493c0 <link>:

int link(char *oldpname, char *newpname)
{
 80493c0:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493c1:	b8 1b 00 00 00       	mov    $0x1b,%eax
{
	return usyscall(SYS_fstat, (uint32_t)sbuf, 0, 0, 0, 0);
}

int link(char *oldpname, char *newpname)
{
 80493c6:	89 e5                	mov    %esp,%ebp
 80493c8:	57                   	push   %edi
 80493c9:	56                   	push   %esi
 80493ca:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493cb:	31 db                	xor    %ebx,%ebx
 80493cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 80493d0:	8b 55 08             	mov    0x8(%ebp),%edx
 80493d3:	89 df                	mov    %ebx,%edi
 80493d5:	89 de                	mov    %ebx,%esi
 80493d7:	cd 80                	int    $0x80
}

int link(char *oldpname, char *newpname)
{
	return usyscall(SYS_link, (uint32_t)oldpname, (uint32_t)newpname, 0, 0, 0);
}
 80493d9:	5b                   	pop    %ebx
 80493da:	5e                   	pop    %esi
 80493db:	5f                   	pop    %edi
 80493dc:	5d                   	pop    %ebp
 80493dd:	c3                   	ret    
 80493de:	66 90                	xchg   %ax,%ax

080493e0 <unlink>:
int unlink(char *pathname)
{
 80493e0:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493e1:	31 c9                	xor    %ecx,%ecx
 80493e3:	b8 1c 00 00 00       	mov    $0x1c,%eax
int link(char *oldpname, char *newpname)
{
	return usyscall(SYS_link, (uint32_t)oldpname, (uint32_t)newpname, 0, 0, 0);
}
int unlink(char *pathname)
{
 80493e8:	89 e5                	mov    %esp,%ebp
 80493ea:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493eb:	89 cf                	mov    %ecx,%edi
int link(char *oldpname, char *newpname)
{
	return usyscall(SYS_link, (uint32_t)oldpname, (uint32_t)newpname, 0, 0, 0);
}
int unlink(char *pathname)
{
 80493ed:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493ee:	8b 55 08             	mov    0x8(%ebp),%edx
 80493f1:	89 ce                	mov    %ecx,%esi
int link(char *oldpname, char *newpname)
{
	return usyscall(SYS_link, (uint32_t)oldpname, (uint32_t)newpname, 0, 0, 0);
}
int unlink(char *pathname)
{
 80493f3:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80493f4:	89 cb                	mov    %ecx,%ebx
 80493f6:	cd 80                	int    $0x80
	return usyscall(SYS_link, (uint32_t)oldpname, (uint32_t)newpname, 0, 0, 0);
}
int unlink(char *pathname)
{
	return usyscall(SYS_unlink, (uint32_t)pathname, 0, 0, 0, 0);
}
 80493f8:	5b                   	pop    %ebx
 80493f9:	5e                   	pop    %esi
 80493fa:	5f                   	pop    %edi
 80493fb:	5d                   	pop    %ebp
 80493fc:	c3                   	ret    
 80493fd:	8d 76 00             	lea    0x0(%esi),%esi

08049400 <open>:
int open(char *pathname, int flag)
{
 8049400:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049401:	b8 1d 00 00 00       	mov    $0x1d,%eax
int unlink(char *pathname)
{
	return usyscall(SYS_unlink, (uint32_t)pathname, 0, 0, 0, 0);
}
int open(char *pathname, int flag)
{
 8049406:	89 e5                	mov    %esp,%ebp
 8049408:	57                   	push   %edi
 8049409:	56                   	push   %esi
 804940a:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804940b:	31 db                	xor    %ebx,%ebx
 804940d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 8049410:	8b 55 08             	mov    0x8(%ebp),%edx
 8049413:	89 df                	mov    %ebx,%edi
 8049415:	89 de                	mov    %ebx,%esi
 8049417:	cd 80                	int    $0x80
	return usyscall(SYS_unlink, (uint32_t)pathname, 0, 0, 0, 0);
}
int open(char *pathname, int flag)
{
	return usyscall(SYS_open, (uint32_t)pathname, (uint32_t)flag, 0, 0, 0);
}
 8049419:	5b                   	pop    %ebx
 804941a:	5e                   	pop    %esi
 804941b:	5f                   	pop    %edi
 804941c:	5d                   	pop    %ebp
 804941d:	c3                   	ret    
 804941e:	66 90                	xchg   %ax,%ax

08049420 <mknod>:

int mknod(char *pathname, ushort major, ushort minor)
{
 8049420:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049421:	b8 22 00 00 00       	mov    $0x22,%eax
{
	return usyscall(SYS_open, (uint32_t)pathname, (uint32_t)flag, 0, 0, 0);
}

int mknod(char *pathname, ushort major, ushort minor)
{
 8049426:	89 e5                	mov    %esp,%ebp
 8049428:	57                   	push   %edi
 8049429:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804942a:	31 f6                	xor    %esi,%esi
{
	return usyscall(SYS_open, (uint32_t)pathname, (uint32_t)flag, 0, 0, 0);
}

int mknod(char *pathname, ushort major, ushort minor)
{
 804942c:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804942d:	0f b7 4d 0c          	movzwl 0xc(%ebp),%ecx
 8049431:	0f b7 5d 10          	movzwl 0x10(%ebp),%ebx
 8049435:	8b 55 08             	mov    0x8(%ebp),%edx
 8049438:	89 f7                	mov    %esi,%edi
 804943a:	cd 80                	int    $0x80

int mknod(char *pathname, ushort major, ushort minor)
{
	return usyscall(SYS_mknod, (uint32_t)pathname, 
					(uint32_t)major, (uint32_t)minor, 0, 0);
}
 804943c:	5b                   	pop    %ebx
 804943d:	5e                   	pop    %esi
 804943e:	5f                   	pop    %edi
 804943f:	5d                   	pop    %ebp
 8049440:	c3                   	ret    
 8049441:	eb 0d                	jmp    8049450 <mkdir>
 8049443:	90                   	nop
 8049444:	90                   	nop
 8049445:	90                   	nop
 8049446:	90                   	nop
 8049447:	90                   	nop
 8049448:	90                   	nop
 8049449:	90                   	nop
 804944a:	90                   	nop
 804944b:	90                   	nop
 804944c:	90                   	nop
 804944d:	90                   	nop
 804944e:	90                   	nop
 804944f:	90                   	nop

08049450 <mkdir>:

int mkdir(char *pathname)
{
 8049450:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049451:	31 c9                	xor    %ecx,%ecx
 8049453:	b8 1e 00 00 00       	mov    $0x1e,%eax
	return usyscall(SYS_mknod, (uint32_t)pathname, 
					(uint32_t)major, (uint32_t)minor, 0, 0);
}

int mkdir(char *pathname)
{
 8049458:	89 e5                	mov    %esp,%ebp
 804945a:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804945b:	89 cf                	mov    %ecx,%edi
	return usyscall(SYS_mknod, (uint32_t)pathname, 
					(uint32_t)major, (uint32_t)minor, 0, 0);
}

int mkdir(char *pathname)
{
 804945d:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804945e:	8b 55 08             	mov    0x8(%ebp),%edx
 8049461:	89 ce                	mov    %ecx,%esi
	return usyscall(SYS_mknod, (uint32_t)pathname, 
					(uint32_t)major, (uint32_t)minor, 0, 0);
}

int mkdir(char *pathname)
{
 8049463:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049464:	89 cb                	mov    %ecx,%ebx
 8049466:	cd 80                	int    $0x80
}

int mkdir(char *pathname)
{
	return usyscall(SYS_mkdir, (uint32_t)pathname, 0, 0, 0, 0);
}
 8049468:	5b                   	pop    %ebx
 8049469:	5e                   	pop    %esi
 804946a:	5f                   	pop    %edi
 804946b:	5d                   	pop    %ebp
 804946c:	c3                   	ret    
 804946d:	8d 76 00             	lea    0x0(%esi),%esi

08049470 <chdir>:

int chdir(char *pathname)
{
 8049470:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049471:	31 c9                	xor    %ecx,%ecx
 8049473:	b8 1f 00 00 00       	mov    $0x1f,%eax
{
	return usyscall(SYS_mkdir, (uint32_t)pathname, 0, 0, 0, 0);
}

int chdir(char *pathname)
{
 8049478:	89 e5                	mov    %esp,%ebp
 804947a:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804947b:	89 cf                	mov    %ecx,%edi
{
	return usyscall(SYS_mkdir, (uint32_t)pathname, 0, 0, 0, 0);
}

int chdir(char *pathname)
{
 804947d:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804947e:	8b 55 08             	mov    0x8(%ebp),%edx
 8049481:	89 ce                	mov    %ecx,%esi
{
	return usyscall(SYS_mkdir, (uint32_t)pathname, 0, 0, 0, 0);
}

int chdir(char *pathname)
{
 8049483:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049484:	89 cb                	mov    %ecx,%ebx
 8049486:	cd 80                	int    $0x80
}

int chdir(char *pathname)
{
	return usyscall(SYS_chdir, (uint32_t)pathname, 0, 0, 0, 0);
}
 8049488:	5b                   	pop    %ebx
 8049489:	5e                   	pop    %esi
 804948a:	5f                   	pop    %edi
 804948b:	5d                   	pop    %ebp
 804948c:	c3                   	ret    
 804948d:	8d 76 00             	lea    0x0(%esi),%esi

08049490 <ipc_try_send>:

int ipc_try_send(pid_t pid, uint32_t value, void *srcva, int32_t perm)
{
 8049490:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049491:	b8 10 00 00 00       	mov    $0x10,%eax
{
	return usyscall(SYS_chdir, (uint32_t)pathname, 0, 0, 0, 0);
}

int ipc_try_send(pid_t pid, uint32_t value, void *srcva, int32_t perm)
{
 8049496:	89 e5                	mov    %esp,%ebp
 8049498:	57                   	push   %edi
 8049499:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804949a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
{
	return usyscall(SYS_chdir, (uint32_t)pathname, 0, 0, 0, 0);
}

int ipc_try_send(pid_t pid, uint32_t value, void *srcva, int32_t perm)
{
 804949d:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804949e:	31 f6                	xor    %esi,%esi
 80494a0:	8b 55 08             	mov    0x8(%ebp),%edx
 80494a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
 80494a6:	8b 7d 14             	mov    0x14(%ebp),%edi
 80494a9:	cd 80                	int    $0x80

int ipc_try_send(pid_t pid, uint32_t value, void *srcva, int32_t perm)
{
	return usyscall(SYS_ipc_try_send, pid, value, 
					(uint32_t)srcva, (uint32_t)perm, 0);
}
 80494ab:	5b                   	pop    %ebx
 80494ac:	5e                   	pop    %esi
 80494ad:	5f                   	pop    %edi
 80494ae:	5d                   	pop    %ebp
 80494af:	c3                   	ret    

080494b0 <ipc_send>:

int ipc_send(pid_t to_proc, uint32_t val, void *pg, int32_t perm)
{
 80494b0:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80494b1:	b8 11 00 00 00       	mov    $0x11,%eax
	return usyscall(SYS_ipc_try_send, pid, value, 
					(uint32_t)srcva, (uint32_t)perm, 0);
}

int ipc_send(pid_t to_proc, uint32_t val, void *pg, int32_t perm)
{
 80494b6:	89 e5                	mov    %esp,%ebp
 80494b8:	57                   	push   %edi
 80494b9:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80494ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	return usyscall(SYS_ipc_try_send, pid, value, 
					(uint32_t)srcva, (uint32_t)perm, 0);
}

int ipc_send(pid_t to_proc, uint32_t val, void *pg, int32_t perm)
{
 80494bd:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80494be:	31 f6                	xor    %esi,%esi
 80494c0:	8b 55 08             	mov    0x8(%ebp),%edx
 80494c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
 80494c6:	8b 7d 14             	mov    0x14(%ebp),%edi
 80494c9:	cd 80                	int    $0x80

int ipc_send(pid_t to_proc, uint32_t val, void *pg, int32_t perm)
{
	return usyscall(SYS_ipc_send, to_proc, val, 
					(uint32_t)pg, (uint32_t)perm, 0);
}
 80494cb:	5b                   	pop    %ebx
 80494cc:	5e                   	pop    %esi
 80494cd:	5f                   	pop    %edi
 80494ce:	5d                   	pop    %ebp
 80494cf:	c3                   	ret    

080494d0 <ipc_recv>:

int ipc_recv(void *pg)
{
 80494d0:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80494d1:	31 c9                	xor    %ecx,%ecx
 80494d3:	b8 12 00 00 00       	mov    $0x12,%eax
	return usyscall(SYS_ipc_send, to_proc, val, 
					(uint32_t)pg, (uint32_t)perm, 0);
}

int ipc_recv(void *pg)
{
 80494d8:	89 e5                	mov    %esp,%ebp
 80494da:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80494db:	89 cf                	mov    %ecx,%edi
	return usyscall(SYS_ipc_send, to_proc, val, 
					(uint32_t)pg, (uint32_t)perm, 0);
}

int ipc_recv(void *pg)
{
 80494dd:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80494de:	8b 55 08             	mov    0x8(%ebp),%edx
 80494e1:	89 ce                	mov    %ecx,%esi
	return usyscall(SYS_ipc_send, to_proc, val, 
					(uint32_t)pg, (uint32_t)perm, 0);
}

int ipc_recv(void *pg)
{
 80494e3:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80494e4:	89 cb                	mov    %ecx,%ebx
 80494e6:	cd 80                	int    $0x80
}

int ipc_recv(void *pg)
{
	return usyscall(SYS_ipc_recv, (uint32_t)pg, 0, 0, 0, 0);
}
 80494e8:	5b                   	pop    %ebx
 80494e9:	5e                   	pop    %esi
 80494ea:	5f                   	pop    %edi
 80494eb:	5d                   	pop    %ebp
 80494ec:	c3                   	ret    
 80494ed:	8d 76 00             	lea    0x0(%esi),%esi

080494f0 <getpid>:

int getpid(void)
{
 80494f0:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80494f1:	31 d2                	xor    %edx,%edx
 80494f3:	b8 04 00 00 00       	mov    $0x4,%eax
 80494f8:	89 d1                	mov    %edx,%ecx
{
	return usyscall(SYS_ipc_recv, (uint32_t)pg, 0, 0, 0, 0);
}

int getpid(void)
{
 80494fa:	89 e5                	mov    %esp,%ebp
 80494fc:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 80494fd:	89 d7                	mov    %edx,%edi
{
	return usyscall(SYS_ipc_recv, (uint32_t)pg, 0, 0, 0, 0);
}

int getpid(void)
{
 80494ff:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049500:	89 d6                	mov    %edx,%esi
{
	return usyscall(SYS_ipc_recv, (uint32_t)pg, 0, 0, 0, 0);
}

int getpid(void)
{
 8049502:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049503:	89 d3                	mov    %edx,%ebx
 8049505:	cd 80                	int    $0x80
}

int getpid(void)
{
	return usyscall(SYS_getpid, 0, 0, 0, 0, 0);
}
 8049507:	5b                   	pop    %ebx
 8049508:	5e                   	pop    %esi
 8049509:	5f                   	pop    %edi
 804950a:	5d                   	pop    %ebp
 804950b:	c3                   	ret    
 804950c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

08049510 <WeiOS_welcome>:

int WeiOS_welcome(void)
{
 8049510:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049511:	31 d2                	xor    %edx,%edx
 8049513:	b8 23 00 00 00       	mov    $0x23,%eax
 8049518:	89 d1                	mov    %edx,%ecx
{
	return usyscall(SYS_getpid, 0, 0, 0, 0, 0);
}

int WeiOS_welcome(void)
{
 804951a:	89 e5                	mov    %esp,%ebp
 804951c:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804951d:	89 d7                	mov    %edx,%edi
{
	return usyscall(SYS_getpid, 0, 0, 0, 0, 0);
}

int WeiOS_welcome(void)
{
 804951f:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049520:	89 d6                	mov    %edx,%esi
{
	return usyscall(SYS_getpid, 0, 0, 0, 0, 0);
}

int WeiOS_welcome(void)
{
 8049522:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049523:	89 d3                	mov    %edx,%ebx
 8049525:	cd 80                	int    $0x80
}

int WeiOS_welcome(void)
{
	return usyscall(SYS_welcome, 0, 0, 0, 0, 0);
}
 8049527:	5b                   	pop    %ebx
 8049528:	5e                   	pop    %esi
 8049529:	5f                   	pop    %edi
 804952a:	5d                   	pop    %ebp
 804952b:	c3                   	ret    
 804952c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

08049530 <ls>:

int ls(const char *path)
{
 8049530:	55                   	push   %ebp
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049531:	31 c9                	xor    %ecx,%ecx
 8049533:	b8 24 00 00 00       	mov    $0x24,%eax
{
	return usyscall(SYS_welcome, 0, 0, 0, 0, 0);
}

int ls(const char *path)
{
 8049538:	89 e5                	mov    %esp,%ebp
 804953a:	57                   	push   %edi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804953b:	89 cf                	mov    %ecx,%edi
{
	return usyscall(SYS_welcome, 0, 0, 0, 0, 0);
}

int ls(const char *path)
{
 804953d:	56                   	push   %esi
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 804953e:	8b 55 08             	mov    0x8(%ebp),%edx
 8049541:	89 ce                	mov    %ecx,%esi
{
	return usyscall(SYS_welcome, 0, 0, 0, 0, 0);
}

int ls(const char *path)
{
 8049543:	53                   	push   %ebx
int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
 8049544:	89 cb                	mov    %ecx,%ebx
 8049546:	cd 80                	int    $0x80
}

int ls(const char *path)
{
	return usyscall(SYS_lsdir, (uint32_t)path, 0, 0, 0, 0);
}
 8049548:	5b                   	pop    %ebx
 8049549:	5e                   	pop    %esi
 804954a:	5f                   	pop    %edi
 804954b:	5d                   	pop    %ebp
 804954c:	c3                   	ret    
 804954d:	8d 76 00             	lea    0x0(%esi),%esi

08049550 <usyscall>:

int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
 8049550:	55                   	push   %ebp
 8049551:	89 e5                	mov    %esp,%ebp
 8049553:	57                   	push   %edi
 8049554:	56                   	push   %esi
	int32_t ret;
	asm volatile("int %1\n"
 8049555:	8b 4d 10             	mov    0x10(%ebp),%ecx
}

int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
 8049558:	53                   	push   %ebx
	int32_t ret;
	asm volatile("int %1\n"
 8049559:	8b 55 0c             	mov    0xc(%ebp),%edx
 804955c:	8b 45 08             	mov    0x8(%ebp),%eax
 804955f:	8b 5d 14             	mov    0x14(%ebp),%ebx
 8049562:	8b 7d 18             	mov    0x18(%ebp),%edi
 8049565:	8b 75 1c             	mov    0x1c(%ebp),%esi
 8049568:	cd 80                	int    $0x80
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	return ret;
 804956a:	5b                   	pop    %ebx
 804956b:	5e                   	pop    %esi
 804956c:	5f                   	pop    %edi
 804956d:	5d                   	pop    %ebp
 804956e:	c3                   	ret    
 804956f:	90                   	nop

08049570 <malloc>:
    // left == 0
    return RBNodeSucceeder(T, Ty);
}

void *malloc(uint32_t size)
{
 8049570:	55                   	push   %ebp
 8049571:	89 e5                	mov    %esp,%ebp
 8049573:	57                   	push   %edi
 8049574:	56                   	push   %esi
 8049575:	53                   	push   %ebx
 8049576:	83 ec 1c             	sub    $0x1c,%esp
    RBNode trb;
    uint32_t tsize;
    struct mm_node *MN, *SMN;

    static int firsttime = 1;
    if (firsttime) {
 8049579:	8b 35 c0 ae 04 08    	mov    0x804aec0,%esi
    // left == 0
    return RBNodeSucceeder(T, Ty);
}

void *malloc(uint32_t size)
{
 804957f:	8b 5d 08             	mov    0x8(%ebp),%ebx
    RBNode trb;
    uint32_t tsize;
    struct mm_node *MN, *SMN;

    static int firsttime = 1;
    if (firsttime) {
 8049582:	85 f6                	test   %esi,%esi
 8049584:	0f 85 10 01 00 00    	jne    804969a <malloc+0x12a>
        }
        MN->busy = 1;
        return (void *)(MN + 1);
    }

    tsize = ROUNDUP(size+MMSIZE, PGSIZE);
 804958a:	8d 83 1f 10 00 00    	lea    0x101f(%ebx),%eax
 8049590:	89 45 e0             	mov    %eax,-0x20(%ebp)
 8049593:	25 ff 0f 00 00       	and    $0xfff,%eax
 8049598:	89 45 dc             	mov    %eax,-0x24(%ebp)
 804959b:	90                   	nop
 804959c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
// Unfinished
static RBNode MallocSearch(RBTree T, uint32_t key)
{
    int left;       // 1 - left son, 0 - right son
    RBNode Ty;
    RBNode Tx = T->root;
 80495a0:	a1 4c af 04 08       	mov    0x804af4c,%eax
    
    if (T->root == &T->nil)
 80495a5:	3d 50 af 04 08       	cmp    $0x804af50,%eax
 80495aa:	75 13                	jne    80495bf <malloc+0x4f>
 80495ac:	eb 7a                	jmp    8049628 <malloc+0xb8>
 80495ae:	66 90                	xchg   %ax,%ax
        return &T->nil;
    while (Tx != &T->nil) {
        Ty = Tx;
        if (key > Tx->key) {
            left = 0;
            Tx = Tx->right;
 80495b0:	8b 50 0c             	mov    0xc(%eax),%edx
    if (T->root == &T->nil)
        return &T->nil;
    while (Tx != &T->nil) {
        Ty = Tx;
        if (key > Tx->key) {
            left = 0;
 80495b3:	31 c9                	xor    %ecx,%ecx
    RBNode Ty;
    RBNode Tx = T->root;
    
    if (T->root == &T->nil)
        return &T->nil;
    while (Tx != &T->nil) {
 80495b5:	81 fa 50 af 04 08    	cmp    $0x804af50,%edx
 80495bb:	74 19                	je     80495d6 <malloc+0x66>
 80495bd:	89 d0                	mov    %edx,%eax
        Ty = Tx;
        if (key > Tx->key) {
 80495bf:	3b 58 04             	cmp    0x4(%eax),%ebx
 80495c2:	77 ec                	ja     80495b0 <malloc+0x40>
            left = 0;
            Tx = Tx->right;
        } else if (key < Tx->key) {
 80495c4:	73 14                	jae    80495da <malloc+0x6a>
            left = 1;
            Tx = Tx->left;
 80495c6:	8b 50 08             	mov    0x8(%eax),%edx
        Ty = Tx;
        if (key > Tx->key) {
            left = 0;
            Tx = Tx->right;
        } else if (key < Tx->key) {
            left = 1;
 80495c9:	b9 01 00 00 00       	mov    $0x1,%ecx
    RBNode Ty;
    RBNode Tx = T->root;
    
    if (T->root == &T->nil)
        return &T->nil;
    while (Tx != &T->nil) {
 80495ce:	81 fa 50 af 04 08    	cmp    $0x804af50,%edx
 80495d4:	75 e7                	jne    80495bd <malloc+0x4d>
            Tx = Tx->left;
        } else
            return Tx; 
    }

    if (left)
 80495d6:	85 c9                	test   %ecx,%ecx
 80495d8:	74 36                	je     8049610 <malloc+0xa0>
        firsttime = 0;
    }

Search:
    if ((trb = MallocSearch(&mm_rbtree, size)) != &mm_rbtree.nil) {
        RBTreeDeleteNode(&mm_rbtree, trb);  // Delete the node from tree.
 80495da:	83 ec 08             	sub    $0x8,%esp
    while (Tx != &T->nil) {
        Ty = Tx;
        if (key > Tx->key) {
            left = 0;
            Tx = Tx->right;
        } else if (key < Tx->key) {
 80495dd:	89 c6                	mov    %eax,%esi
        firsttime = 0;
    }

Search:
    if ((trb = MallocSearch(&mm_rbtree, size)) != &mm_rbtree.nil) {
        RBTreeDeleteNode(&mm_rbtree, trb);  // Delete the node from tree.
 80495df:	50                   	push   %eax
 80495e0:	68 4c af 04 08       	push   $0x804af4c
 80495e5:	e8 16 06 00 00       	call   8049c00 <RBTreeDeleteNode>
        MN = container_of(trb, struct mm_node, rb);
        if ((size+MMSIZE) < trb->key) {
 80495ea:	8d 43 20             	lea    0x20(%ebx),%eax
 80495ed:	83 c4 10             	add    $0x10,%esp
 80495f0:	3b 46 04             	cmp    0x4(%esi),%eax
 80495f3:	0f 82 d7 00 00 00    	jb     80496d0 <malloc+0x160>
            rbnode_init(&mm_rbtree, &SMN->rb, trb->key-size-MMSIZE, RED);
            list_add(&SMN->list_node, &MN->list_node);
            RBTreeInsert(&mm_rbtree, &SMN->rb);
            trb->key -= (SMN->rb.key + MMSIZE);
        }
        MN->busy = 1;
 80495f9:	c7 46 fc 01 00 00 00 	movl   $0x1,-0x4(%esi)
    MN->busy = 0;
    rbnode_init(&mm_rbtree, &MN->rb, tsize-MMSIZE, RED);
    list_add_tail(&MN->list_node, &list_head);
    RBTreeInsert(&mm_rbtree, &MN->rb);
    goto Search;
}
 8049600:	8d 65 f4             	lea    -0xc(%ebp),%esp
            list_add(&SMN->list_node, &MN->list_node);
            RBTreeInsert(&mm_rbtree, &SMN->rb);
            trb->key -= (SMN->rb.key + MMSIZE);
        }
        MN->busy = 1;
        return (void *)(MN + 1);
 8049603:	8d 46 1c             	lea    0x1c(%esi),%eax
    MN->busy = 0;
    rbnode_init(&mm_rbtree, &MN->rb, tsize-MMSIZE, RED);
    list_add_tail(&MN->list_node, &list_head);
    RBTreeInsert(&mm_rbtree, &MN->rb);
    goto Search;
}
 8049606:	5b                   	pop    %ebx
 8049607:	5e                   	pop    %esi
 8049608:	5f                   	pop    %edi
 8049609:	5d                   	pop    %ebp
 804960a:	c3                   	ret    
 804960b:	90                   	nop
 804960c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }

    if (left)
        return Ty;
    // left == 0
    return RBNodeSucceeder(T, Ty);
 8049610:	83 ec 08             	sub    $0x8,%esp
 8049613:	50                   	push   %eax
 8049614:	68 4c af 04 08       	push   $0x804af4c
 8049619:	e8 52 03 00 00       	call   8049970 <RBNodeSucceeder>
        LIST_HEAD_INIT(list_head);
        firsttime = 0;
    }

Search:
    if ((trb = MallocSearch(&mm_rbtree, size)) != &mm_rbtree.nil) {
 804961e:	83 c4 10             	add    $0x10,%esp
 8049621:	3d 50 af 04 08       	cmp    $0x804af50,%eax
 8049626:	75 b2                	jne    80495da <malloc+0x6a>
        }
        MN->busy = 1;
        return (void *)(MN + 1);
    }

    tsize = ROUNDUP(size+MMSIZE, PGSIZE);
 8049628:	8b 55 e0             	mov    -0x20(%ebp),%edx
 804962b:	2b 55 dc             	sub    -0x24(%ebp),%edx
    if (!(MN = (struct mm_node *)sbrk(tsize))) 
 804962e:	83 ec 0c             	sub    $0xc,%esp
 8049631:	52                   	push   %edx
 8049632:	89 55 e4             	mov    %edx,-0x1c(%ebp)
 8049635:	e8 06 fc ff ff       	call   8049240 <sbrk>
 804963a:	83 c4 10             	add    $0x10,%esp
 804963d:	85 c0                	test   %eax,%eax
 804963f:	89 c6                	mov    %eax,%esi
 8049641:	74 4d                	je     8049690 <malloc+0x120>
        return NULL;
    MN->busy = 0;
    rbnode_init(&mm_rbtree, &MN->rb, tsize-MMSIZE, RED);
 8049643:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 8049646:	8d 78 04             	lea    0x4(%eax),%edi
    }

    tsize = ROUNDUP(size+MMSIZE, PGSIZE);
    if (!(MN = (struct mm_node *)sbrk(tsize))) 
        return NULL;
    MN->busy = 0;
 8049649:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    rbnode_init(&mm_rbtree, &MN->rb, tsize-MMSIZE, RED);
 804964f:	6a 00                	push   $0x0
 8049651:	83 ea 20             	sub    $0x20,%edx
 8049654:	52                   	push   %edx
 8049655:	57                   	push   %edi
 8049656:	68 4c af 04 08       	push   $0x804af4c
 804965b:	e8 50 02 00 00       	call   80498b0 <rbnode_init>
}

static void list_add_tail(struct list_head *new_node, struct list_head *head)
{
    new_node->next = head;
    new_node->prev = head->prev;
 8049660:	8b 0d 48 af 04 08    	mov    0x804af48,%ecx
    list_add_tail(&MN->list_node, &list_head);
 8049666:	8d 56 18             	lea    0x18(%esi),%edx
    new_node->prev = head; 
}

static void list_add_tail(struct list_head *new_node, struct list_head *head)
{
    new_node->next = head;
 8049669:	c7 46 18 44 af 04 08 	movl   $0x804af44,0x18(%esi)
    new_node->prev = head->prev;
 8049670:	89 4e 1c             	mov    %ecx,0x1c(%esi)
    new_node->prev->next = new_node;
 8049673:	89 11                	mov    %edx,(%ecx)
    head->prev = new_node;
 8049675:	89 15 48 af 04 08    	mov    %edx,0x804af48
    RBTreeInsert(&mm_rbtree, &MN->rb);
 804967b:	58                   	pop    %eax
 804967c:	5a                   	pop    %edx
 804967d:	57                   	push   %edi
 804967e:	68 4c af 04 08       	push   $0x804af4c
 8049683:	e8 28 03 00 00       	call   80499b0 <RBTreeInsert>
    goto Search;
 8049688:	83 c4 10             	add    $0x10,%esp
 804968b:	e9 10 ff ff ff       	jmp    80495a0 <malloc+0x30>
}
 8049690:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return (void *)(MN + 1);
    }

    tsize = ROUNDUP(size+MMSIZE, PGSIZE);
    if (!(MN = (struct mm_node *)sbrk(tsize))) 
        return NULL;
 8049693:	31 c0                	xor    %eax,%eax
    MN->busy = 0;
    rbnode_init(&mm_rbtree, &MN->rb, tsize-MMSIZE, RED);
    list_add_tail(&MN->list_node, &list_head);
    RBTreeInsert(&mm_rbtree, &MN->rb);
    goto Search;
}
 8049695:	5b                   	pop    %ebx
 8049696:	5e                   	pop    %esi
 8049697:	5f                   	pop    %edi
 8049698:	5d                   	pop    %ebp
 8049699:	c3                   	ret    
    uint32_t tsize;
    struct mm_node *MN, *SMN;

    static int firsttime = 1;
    if (firsttime) {
        rbtree_init(&mm_rbtree);
 804969a:	83 ec 0c             	sub    $0xc,%esp
 804969d:	68 4c af 04 08       	push   $0x804af4c
 80496a2:	e8 39 02 00 00       	call   80498e0 <rbtree_init>
        LIST_HEAD_INIT(list_head);
 80496a7:	c7 05 44 af 04 08 44 	movl   $0x804af44,0x804af44
 80496ae:	af 04 08 
 80496b1:	c7 05 48 af 04 08 44 	movl   $0x804af44,0x804af48
 80496b8:	af 04 08 
        firsttime = 0;
 80496bb:	83 c4 10             	add    $0x10,%esp
 80496be:	c7 05 c0 ae 04 08 00 	movl   $0x0,0x804aec0
 80496c5:	00 00 00 
 80496c8:	e9 bd fe ff ff       	jmp    804958a <malloc+0x1a>
 80496cd:	8d 76 00             	lea    0x0(%esi),%esi
Search:
    if ((trb = MallocSearch(&mm_rbtree, size)) != &mm_rbtree.nil) {
        RBTreeDeleteNode(&mm_rbtree, trb);  // Delete the node from tree.
        MN = container_of(trb, struct mm_node, rb);
        if ((size+MMSIZE) < trb->key) {
            SMN = (struct mm_node *)((char *)(MN + 1) + size); 
 80496d0:	8d 7c 1e 1c          	lea    0x1c(%esi,%ebx,1),%edi
            SMN->busy = 0;
 80496d4:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
            rbnode_init(&mm_rbtree, &SMN->rb, trb->key-size-MMSIZE, RED);
 80496da:	6a 00                	push   $0x0
 80496dc:	8d 57 04             	lea    0x4(%edi),%edx
 80496df:	8b 46 04             	mov    0x4(%esi),%eax
 80496e2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
 80496e5:	83 e8 20             	sub    $0x20,%eax
 80496e8:	29 d8                	sub    %ebx,%eax
 80496ea:	50                   	push   %eax
 80496eb:	52                   	push   %edx
 80496ec:	68 4c af 04 08       	push   $0x804af4c
 80496f1:	e8 ba 01 00 00       	call   80498b0 <rbnode_init>
    return (head->next == head);
}

static void list_add(struct list_head *new_node, struct list_head *head)
{
    new_node->next = head->next;
 80496f6:	8b 4e 14             	mov    0x14(%esi),%ecx
            list_add(&SMN->list_node, &MN->list_node);
 80496f9:	8d 47 18             	lea    0x18(%edi),%eax
            RBTreeInsert(&mm_rbtree, &SMN->rb);
 80496fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 80496ff:	89 4f 18             	mov    %ecx,0x18(%edi)
    head->next->prev = new_node;    
 8049702:	8b 4e 14             	mov    0x14(%esi),%ecx
 8049705:	89 41 04             	mov    %eax,0x4(%ecx)
    head->next = new_node;
 8049708:	89 46 14             	mov    %eax,0x14(%esi)
        MN = container_of(trb, struct mm_node, rb);
        if ((size+MMSIZE) < trb->key) {
            SMN = (struct mm_node *)((char *)(MN + 1) + size); 
            SMN->busy = 0;
            rbnode_init(&mm_rbtree, &SMN->rb, trb->key-size-MMSIZE, RED);
            list_add(&SMN->list_node, &MN->list_node);
 804970b:	8d 46 14             	lea    0x14(%esi),%eax
 804970e:	89 47 1c             	mov    %eax,0x1c(%edi)
            RBTreeInsert(&mm_rbtree, &SMN->rb);
 8049711:	59                   	pop    %ecx
 8049712:	5b                   	pop    %ebx
 8049713:	52                   	push   %edx
 8049714:	68 4c af 04 08       	push   $0x804af4c
 8049719:	e8 92 02 00 00       	call   80499b0 <RBTreeInsert>
            trb->key -= (SMN->rb.key + MMSIZE);
 804971e:	8b 46 04             	mov    0x4(%esi),%eax
 8049721:	83 c4 10             	add    $0x10,%esp
 8049724:	83 e8 20             	sub    $0x20,%eax
 8049727:	2b 47 08             	sub    0x8(%edi),%eax
 804972a:	89 46 04             	mov    %eax,0x4(%esi)
 804972d:	e9 c7 fe ff ff       	jmp    80495f9 <malloc+0x89>
 8049732:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 8049739:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08049740 <find_siblings>:
    RBTreeInsert(&mm_rbtree, &MN->rb);
    goto Search;
}

struct mm_node *find_siblings(struct mm_node *MN)
{
 8049740:	55                   	push   %ebp
 8049741:	89 e5                	mov    %esp,%ebp
 8049743:	53                   	push   %ebx
 8049744:	8b 55 08             	mov    0x8(%ebp),%edx
    struct mm_node *SMN;
    struct list_head *LN;

    // left first
    LN = MN->list_node.prev;
 8049747:	8b 42 1c             	mov    0x1c(%edx),%eax
    if (LN != &list_head) {
 804974a:	3d 44 af 04 08       	cmp    $0x804af44,%eax
 804974f:	74 0b                	je     804975c <find_siblings+0x1c>
        SMN = container_of(LN, struct mm_node, list_node); 
        if (IS_LEFT_SIBLING(MN, SMN) && (SMN->busy == 0))
 8049751:	8b 48 f0             	mov    -0x10(%eax),%ecx
 8049754:	8d 4c 08 08          	lea    0x8(%eax,%ecx,1),%ecx
 8049758:	39 ca                	cmp    %ecx,%edx
 804975a:	74 2c                	je     8049788 <find_siblings+0x48>
            return SMN;
    }

    // right next
    LN = MN->list_node.next;
 804975c:	8b 4a 18             	mov    0x18(%edx),%ecx
    if (LN != &list_head) {
 804975f:	81 f9 44 af 04 08    	cmp    $0x804af44,%ecx
 8049765:	74 31                	je     8049798 <find_siblings+0x58>
        SMN = container_of(LN, struct mm_node, list_node); 
        if (IS_RIGHT_SIBLING(MN, SMN) && (SMN->busy == 0))
 8049767:	89 c8                	mov    %ecx,%eax
 8049769:	2b 42 08             	sub    0x8(%edx),%eax
 804976c:	8d 58 c8             	lea    -0x38(%eax),%ebx
            return SMN;
    }

    return NULL;
 804976f:	31 c0                	xor    %eax,%eax

    // right next
    LN = MN->list_node.next;
    if (LN != &list_head) {
        SMN = container_of(LN, struct mm_node, list_node); 
        if (IS_RIGHT_SIBLING(MN, SMN) && (SMN->busy == 0))
 8049771:	39 da                	cmp    %ebx,%edx
 8049773:	75 0b                	jne    8049780 <find_siblings+0x40>
            return SMN;
 8049775:	8d 51 e8             	lea    -0x18(%ecx),%edx
 8049778:	8b 49 e8             	mov    -0x18(%ecx),%ecx
 804977b:	85 c9                	test   %ecx,%ecx
 804977d:	0f 44 c2             	cmove  %edx,%eax
    }

    return NULL;
}
 8049780:	5b                   	pop    %ebx
 8049781:	5d                   	pop    %ebp
 8049782:	c3                   	ret    
 8049783:	90                   	nop
 8049784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

    // left first
    LN = MN->list_node.prev;
    if (LN != &list_head) {
        SMN = container_of(LN, struct mm_node, list_node); 
        if (IS_LEFT_SIBLING(MN, SMN) && (SMN->busy == 0))
 8049788:	8b 58 e8             	mov    -0x18(%eax),%ebx
            return SMN;
 804978b:	83 e8 18             	sub    $0x18,%eax

    // left first
    LN = MN->list_node.prev;
    if (LN != &list_head) {
        SMN = container_of(LN, struct mm_node, list_node); 
        if (IS_LEFT_SIBLING(MN, SMN) && (SMN->busy == 0))
 804978e:	85 db                	test   %ebx,%ebx
 8049790:	75 ca                	jne    804975c <find_siblings+0x1c>
 8049792:	eb ec                	jmp    8049780 <find_siblings+0x40>
 8049794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        SMN = container_of(LN, struct mm_node, list_node); 
        if (IS_RIGHT_SIBLING(MN, SMN) && (SMN->busy == 0))
            return SMN;
    }

    return NULL;
 8049798:	31 c0                	xor    %eax,%eax
 804979a:	eb e4                	jmp    8049780 <find_siblings+0x40>
 804979c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

080497a0 <free>:
}

void free(void *ptr)
{
 80497a0:	55                   	push   %ebp
 80497a1:	89 e5                	mov    %esp,%ebp
 80497a3:	57                   	push   %edi
 80497a4:	56                   	push   %esi
 80497a5:	53                   	push   %ebx
 80497a6:	83 ec 0c             	sub    $0xc,%esp
    struct mm_node *MN, *SMN;

    // MN->rb is not in the red-black tree now.
    MN = (struct mm_node *)ptr - 1;
 80497a9:	8b 45 08             	mov    0x8(%ebp),%eax
 80497ac:	8d 70 e0             	lea    -0x20(%eax),%esi
 80497af:	90                   	nop
    while ((SMN = find_siblings(MN))) {
 80497b0:	83 ec 0c             	sub    $0xc,%esp
 80497b3:	56                   	push   %esi
 80497b4:	e8 87 ff ff ff       	call   8049740 <find_siblings>
 80497b9:	83 c4 10             	add    $0x10,%esp
 80497bc:	85 c0                	test   %eax,%eax
 80497be:	89 c3                	mov    %eax,%ebx
 80497c0:	0f 84 ba 00 00 00    	je     8049880 <free+0xe0>
        // Delete SMN->rb_node from tree.
        RBTreeDeleteNode(&mm_rbtree, &SMN->rb);
 80497c6:	8d 7b 04             	lea    0x4(%ebx),%edi
 80497c9:	83 ec 08             	sub    $0x8,%esp
 80497cc:	57                   	push   %edi
 80497cd:	68 4c af 04 08       	push   $0x804af4c
 80497d2:	e8 29 04 00 00       	call   8049c00 <RBTreeDeleteNode>
        if (MN < SMN) {
 80497d7:	83 c4 10             	add    $0x10,%esp
 80497da:	39 de                	cmp    %ebx,%esi
 80497dc:	73 52                	jae    8049830 <free+0x90>
    head->prev = new_node;
}

static void list_del(struct list_head *entry)
{
    entry->prev->next = entry->next;
 80497de:	8b 43 1c             	mov    0x1c(%ebx),%eax
 80497e1:	8b 53 18             	mov    0x18(%ebx),%edx
            // Delete it from double link list.
            list_del(&SMN->list_node); 
            MN->busy = 0;
            MN->rb.color = RED;
            MN->rb.key += (MMSIZE + SMN->rb.key);
            RBTreeInsert(&mm_rbtree, &MN->rb); 
 80497e4:	83 ec 08             	sub    $0x8,%esp
 80497e7:	89 10                	mov    %edx,(%eax)
    entry->next->prev = entry->prev;
 80497e9:	8b 43 18             	mov    0x18(%ebx),%eax
 80497ec:	8b 53 1c             	mov    0x1c(%ebx),%edx
 80497ef:	89 50 04             	mov    %edx,0x4(%eax)
    entry->next = entry->prev = 0;
 80497f2:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
 80497f9:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        // Delete SMN->rb_node from tree.
        RBTreeDeleteNode(&mm_rbtree, &SMN->rb);
        if (MN < SMN) {
            // Delete it from double link list.
            list_del(&SMN->list_node); 
            MN->busy = 0;
 8049800:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
            MN->rb.color = RED;
 8049806:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
            MN->rb.key += (MMSIZE + SMN->rb.key);
 804980d:	8b 43 08             	mov    0x8(%ebx),%eax
 8049810:	03 46 08             	add    0x8(%esi),%eax
 8049813:	83 c0 20             	add    $0x20,%eax
 8049816:	89 46 08             	mov    %eax,0x8(%esi)
            RBTreeInsert(&mm_rbtree, &MN->rb); 
 8049819:	8d 46 04             	lea    0x4(%esi),%eax
 804981c:	50                   	push   %eax
 804981d:	68 4c af 04 08       	push   $0x804af4c
 8049822:	e8 89 01 00 00       	call   80499b0 <RBTreeInsert>
 8049827:	83 c4 10             	add    $0x10,%esp
 804982a:	eb 84                	jmp    80497b0 <free+0x10>
 804982c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    head->prev = new_node;
}

static void list_del(struct list_head *entry)
{
    entry->prev->next = entry->next;
 8049830:	8b 46 1c             	mov    0x1c(%esi),%eax
 8049833:	8b 56 18             	mov    0x18(%esi),%edx
        } else {
            list_del(&MN->list_node); 
            SMN->rb.color = RED; 
            SMN->rb.key += (MMSIZE + MN->rb.key);
            RBTreeInsert(&mm_rbtree, &SMN->rb); 
 8049836:	83 ec 08             	sub    $0x8,%esp
 8049839:	89 10                	mov    %edx,(%eax)
    entry->next->prev = entry->prev;
 804983b:	8b 46 18             	mov    0x18(%esi),%eax
 804983e:	8b 56 1c             	mov    0x1c(%esi),%edx
 8049841:	89 50 04             	mov    %edx,0x4(%eax)
    entry->next = entry->prev = 0;
 8049844:	c7 46 1c 00 00 00 00 	movl   $0x0,0x1c(%esi)
 804984b:	c7 46 18 00 00 00 00 	movl   $0x0,0x18(%esi)
            MN->rb.color = RED;
            MN->rb.key += (MMSIZE + SMN->rb.key);
            RBTreeInsert(&mm_rbtree, &MN->rb); 
        } else {
            list_del(&MN->list_node); 
            SMN->rb.color = RED; 
 8049852:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
            SMN->rb.key += (MMSIZE + MN->rb.key);
 8049859:	8b 46 08             	mov    0x8(%esi),%eax
 804985c:	03 43 08             	add    0x8(%ebx),%eax
            RBTreeInsert(&mm_rbtree, &SMN->rb); 
 804985f:	89 de                	mov    %ebx,%esi
            MN->rb.key += (MMSIZE + SMN->rb.key);
            RBTreeInsert(&mm_rbtree, &MN->rb); 
        } else {
            list_del(&MN->list_node); 
            SMN->rb.color = RED; 
            SMN->rb.key += (MMSIZE + MN->rb.key);
 8049861:	83 c0 20             	add    $0x20,%eax
 8049864:	89 43 08             	mov    %eax,0x8(%ebx)
            RBTreeInsert(&mm_rbtree, &SMN->rb); 
 8049867:	57                   	push   %edi
 8049868:	68 4c af 04 08       	push   $0x804af4c
 804986d:	e8 3e 01 00 00       	call   80499b0 <RBTreeInsert>
 8049872:	83 c4 10             	add    $0x10,%esp
 8049875:	e9 36 ff ff ff       	jmp    80497b0 <free+0x10>
 804987a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
            MN = SMN;
        }
    }

    if (MN->busy) {
 8049880:	8b 06                	mov    (%esi),%eax
 8049882:	85 c0                	test   %eax,%eax
 8049884:	74 1a                	je     80498a0 <free+0x100>
        MN->busy = 0;
 8049886:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        RBTreeInsert(&mm_rbtree, &MN->rb); 
 804988c:	83 ec 08             	sub    $0x8,%esp
 804988f:	83 c6 04             	add    $0x4,%esi
 8049892:	56                   	push   %esi
 8049893:	68 4c af 04 08       	push   $0x804af4c
 8049898:	e8 13 01 00 00       	call   80499b0 <RBTreeInsert>
 804989d:	83 c4 10             	add    $0x10,%esp
    }
}
 80498a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 80498a3:	5b                   	pop    %ebx
 80498a4:	5e                   	pop    %esi
 80498a5:	5f                   	pop    %edi
 80498a6:	5d                   	pop    %ebp
 80498a7:	c3                   	ret    
 80498a8:	66 90                	xchg   %ax,%ax
 80498aa:	66 90                	xchg   %ax,%ax
 80498ac:	66 90                	xchg   %ax,%ax
 80498ae:	66 90                	xchg   %ax,%ax

080498b0 <rbnode_init>:
#include <include/types.h>
#include <include/krbtree.h>

void rbnode_init(RBTree T,  RBNode N,  uint32_t key, int32_t color)
{
 80498b0:	55                   	push   %ebp
 80498b1:	89 e5                	mov    %esp,%ebp
 80498b3:	8b 45 0c             	mov    0xc(%ebp),%eax
    N->key = key;
 80498b6:	8b 55 10             	mov    0x10(%ebp),%edx
    N->left = &T->nil;
 80498b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
#include <include/types.h>
#include <include/krbtree.h>

void rbnode_init(RBTree T,  RBNode N,  uint32_t key, int32_t color)
{
    N->key = key;
 80498bc:	89 50 04             	mov    %edx,0x4(%eax)
    N->left = &T->nil;
 80498bf:	8d 51 04             	lea    0x4(%ecx),%edx
 80498c2:	89 50 08             	mov    %edx,0x8(%eax)
    N->right = &T->nil;
 80498c5:	89 50 0c             	mov    %edx,0xc(%eax)
    N->parent = &T->nil;
 80498c8:	89 50 10             	mov    %edx,0x10(%eax)
    N->color = color;
 80498cb:	8b 55 14             	mov    0x14(%ebp),%edx
 80498ce:	89 10                	mov    %edx,(%eax)
}
 80498d0:	5d                   	pop    %ebp
 80498d1:	c3                   	ret    
 80498d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 80498d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

080498e0 <rbtree_init>:

void rbtree_init(RBTree T)
{
 80498e0:	55                   	push   %ebp
 80498e1:	89 e5                	mov    %esp,%ebp
 80498e3:	8b 45 08             	mov    0x8(%ebp),%eax
    T->root = &T->nil;
 80498e6:	8d 50 04             	lea    0x4(%eax),%edx
#include <include/types.h>
#include <include/krbtree.h>

void rbnode_init(RBTree T,  RBNode N,  uint32_t key, int32_t color)
{
    N->key = key;
 80498e9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    N->left = &T->nil;
    N->right = &T->nil;
    N->parent = &T->nil;
    N->color = color;
 80498f0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
}

void rbtree_init(RBTree T)
{
    T->root = &T->nil;
 80498f7:	89 10                	mov    %edx,(%eax)
#include <include/krbtree.h>

void rbnode_init(RBTree T,  RBNode N,  uint32_t key, int32_t color)
{
    N->key = key;
    N->left = &T->nil;
 80498f9:	89 50 0c             	mov    %edx,0xc(%eax)
    N->right = &T->nil;
 80498fc:	89 50 10             	mov    %edx,0x10(%eax)
    N->parent = &T->nil;
 80498ff:	89 50 14             	mov    %edx,0x14(%eax)

void rbtree_init(RBTree T)
{
    T->root = &T->nil;
    rbnode_init(T, T->root, 0, BLACK);
}
 8049902:	5d                   	pop    %ebp
 8049903:	c3                   	ret    
 8049904:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 804990a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

08049910 <RBTreeMinimum>:

// nil is a struct
// root is a pointer.
RBNode RBTreeMinimum(RBTree T, RBNode N)
{
 8049910:	55                   	push   %ebp
 8049911:	89 e5                	mov    %esp,%ebp
 8049913:	8b 4d 08             	mov    0x8(%ebp),%ecx
 8049916:	8b 45 0c             	mov    0xc(%ebp),%eax
 8049919:	83 c1 04             	add    $0x4,%ecx
    while (N->left != &T->nil)
 804991c:	eb 04                	jmp    8049922 <RBTreeMinimum+0x12>
 804991e:	66 90                	xchg   %ax,%ax
 8049920:	89 d0                	mov    %edx,%eax
 8049922:	8b 50 08             	mov    0x8(%eax),%edx
 8049925:	39 ca                	cmp    %ecx,%edx
 8049927:	75 f7                	jne    8049920 <RBTreeMinimum+0x10>
        N = N->left;
    return N;
}
 8049929:	5d                   	pop    %ebp
 804992a:	c3                   	ret    
 804992b:	90                   	nop
 804992c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

08049930 <RBTreeSearch>:

RBNode RBTreeSearch(RBTree T, uint32_t key)
{
 8049930:	55                   	push   %ebp
 8049931:	89 e5                	mov    %esp,%ebp
 8049933:	8b 45 08             	mov    0x8(%ebp),%eax
 8049936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    RBNode TN = T->root;
 8049939:	8b 10                	mov    (%eax),%edx
 804993b:	83 c0 04             	add    $0x4,%eax
 804993e:	66 90                	xchg   %ax,%ax

    while (TN != &T->nil) {
 8049940:	39 c2                	cmp    %eax,%edx
 8049942:	74 0c                	je     8049950 <RBTreeSearch+0x20>
        if (TN->key > key)
 8049944:	39 4a 04             	cmp    %ecx,0x4(%edx)
 8049947:	76 0f                	jbe    8049958 <RBTreeSearch+0x28>
            TN = TN->left;
 8049949:	8b 52 08             	mov    0x8(%edx),%edx

RBNode RBTreeSearch(RBTree T, uint32_t key)
{
    RBNode TN = T->root;

    while (TN != &T->nil) {
 804994c:	39 c2                	cmp    %eax,%edx
 804994e:	75 f4                	jne    8049944 <RBTreeSearch+0x14>
        else
            return TN;
    }

    return &T->nil;
}
 8049950:	5d                   	pop    %ebp
 8049951:	c3                   	ret    
 8049952:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    RBNode TN = T->root;

    while (TN != &T->nil) {
        if (TN->key > key)
            TN = TN->left;
        else if (TN->key < key)
 8049958:	73 06                	jae    8049960 <RBTreeSearch+0x30>
            TN = TN->right;
 804995a:	8b 52 0c             	mov    0xc(%edx),%edx
 804995d:	eb e1                	jmp    8049940 <RBTreeSearch+0x10>
 804995f:	90                   	nop
 8049960:	89 d0                	mov    %edx,%eax
        else
            return TN;
    }

    return &T->nil;
}
 8049962:	5d                   	pop    %ebp
 8049963:	c3                   	ret    
 8049964:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 804996a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

08049970 <RBNodeSucceeder>:

RBNode RBNodeSucceeder(RBTree T, RBNode N)
{
 8049970:	55                   	push   %ebp
 8049971:	89 e5                	mov    %esp,%ebp
    if ((N != &T->nil) && (N->right != &T->nil))
 8049973:	8b 45 08             	mov    0x8(%ebp),%eax

    return &T->nil;
}

RBNode RBNodeSucceeder(RBTree T, RBNode N)
{
 8049976:	8b 55 0c             	mov    0xc(%ebp),%edx
    if ((N != &T->nil) && (N->right != &T->nil))
 8049979:	8d 48 04             	lea    0x4(%eax),%ecx
 804997c:	39 d1                	cmp    %edx,%ecx
 804997e:	74 17                	je     8049997 <RBNodeSucceeder+0x27>
 8049980:	8b 42 0c             	mov    0xc(%edx),%eax
 8049983:	39 c1                	cmp    %eax,%ecx
 8049985:	74 10                	je     8049997 <RBNodeSucceeder+0x27>
    
    RBNode Tx = N;
    while ((Tx->parent != &T->nil) && (Tx == Tx->parent->right))
        Tx = Tx->parent;
    return Tx->parent;
}
 8049987:	5d                   	pop    %ebp
 8049988:	c3                   	ret    
 8049989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
    if ((N != &T->nil) && (N->right != &T->nil))
        return N->right; 
    
    RBNode Tx = N;
    while ((Tx->parent != &T->nil) && (Tx == Tx->parent->right))
 8049990:	3b 50 0c             	cmp    0xc(%eax),%edx
 8049993:	75 f2                	jne    8049987 <RBNodeSucceeder+0x17>
 8049995:	89 c2                	mov    %eax,%edx
 8049997:	8b 42 10             	mov    0x10(%edx),%eax
 804999a:	39 c1                	cmp    %eax,%ecx
 804999c:	75 f2                	jne    8049990 <RBNodeSucceeder+0x20>
 804999e:	89 c8                	mov    %ecx,%eax
        Tx = Tx->parent;
    return Tx->parent;
}
 80499a0:	5d                   	pop    %ebp
 80499a1:	c3                   	ret    
 80499a2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 80499a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

080499b0 <RBTreeInsert>:
    }
    T->root->color = BLACK;
}

int RBTreeInsert(RBTree T, RBNode N)
{
 80499b0:	55                   	push   %ebp
 80499b1:	89 e5                	mov    %esp,%ebp
 80499b3:	57                   	push   %edi
 80499b4:	56                   	push   %esi
 80499b5:	8b 75 08             	mov    0x8(%ebp),%esi
 80499b8:	53                   	push   %ebx
 80499b9:	8b 55 0c             	mov    0xc(%ebp),%edx
    uint32_t key; 
    RBNode Tp = &T->nil;
    RBNode Tc = T->root;
 80499bc:	8b 0e                	mov    (%esi),%ecx
}

int RBTreeInsert(RBTree T, RBNode N)
{
    uint32_t key; 
    RBNode Tp = &T->nil;
 80499be:	8d 5e 04             	lea    0x4(%esi),%ebx
    RBNode Tc = T->root;

    key = N->key;
 80499c1:	8b 7a 04             	mov    0x4(%edx),%edi
    while (Tc != &T->nil) {
 80499c4:	39 cb                	cmp    %ecx,%ebx
 80499c6:	75 0a                	jne    80499d2 <RBTreeInsert+0x22>
 80499c8:	e9 0a 02 00 00       	jmp    8049bd7 <RBTreeInsert+0x227>
 80499cd:	8d 76 00             	lea    0x0(%esi),%esi
 80499d0:	89 c1                	mov    %eax,%ecx
        Tp = Tc;
        if (key < Tc->key)
            Tc = Tc->left;
        else
            Tc = Tc->right;
 80499d2:	3b 79 04             	cmp    0x4(%ecx),%edi
 80499d5:	8b 41 0c             	mov    0xc(%ecx),%eax
 80499d8:	0f 42 41 08          	cmovb  0x8(%ecx),%eax
    uint32_t key; 
    RBNode Tp = &T->nil;
    RBNode Tc = T->root;

    key = N->key;
    while (Tc != &T->nil) {
 80499dc:	39 c3                	cmp    %eax,%ebx
 80499de:	75 f0                	jne    80499d0 <RBTreeInsert+0x20>
            Tc = Tc->left;
        else
            Tc = Tc->right;
    }
    N->parent = Tp;
    if (Tp == &T->nil)
 80499e0:	39 cb                	cmp    %ecx,%ebx
        if (key < Tc->key)
            Tc = Tc->left;
        else
            Tc = Tc->right;
    }
    N->parent = Tp;
 80499e2:	89 4a 10             	mov    %ecx,0x10(%edx)
    if (Tp == &T->nil)
 80499e5:	0f 84 ef 01 00 00    	je     8049bda <RBTreeInsert+0x22a>
        T->root = N;
    else if (key < Tp->key)
 80499eb:	3b 79 04             	cmp    0x4(%ecx),%edi
 80499ee:	0f 82 8c 01 00 00    	jb     8049b80 <RBTreeInsert+0x1d0>
        Tp->left = N;
    else
        Tp->right = N;
 80499f4:	89 51 0c             	mov    %edx,0xc(%ecx)
 80499f7:	89 f6                	mov    %esi,%esi
 80499f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
}

static void RBTreeInsertFixup(RBTree T, RBNode N)
{
    RBNode Ny;
    while (N->parent->color == RED) {
 8049a00:	8b 42 10             	mov    0x10(%edx),%eax
 8049a03:	8b 08                	mov    (%eax),%ecx
 8049a05:	85 c9                	test   %ecx,%ecx
 8049a07:	75 73                	jne    8049a7c <RBTreeInsert+0xcc>
        if (N->parent == N->parent->parent->left) {
 8049a09:	8b 78 10             	mov    0x10(%eax),%edi
 8049a0c:	8b 4f 08             	mov    0x8(%edi),%ecx
 8049a0f:	39 c8                	cmp    %ecx,%eax
 8049a11:	0f 84 a1 00 00 00    	je     8049ab8 <RBTreeInsert+0x108>
            N->parent->color = BLACK;
            N->parent->parent->color = RED;
            RightRotate(T, N->parent->parent);
        } else {
            Ny = N->parent->parent->left;
            if (Ny->color == RED) {
 8049a17:	83 39 00             	cmpl   $0x0,(%ecx)
 8049a1a:	74 74                	je     8049a90 <RBTreeInsert+0xe0>
                N->parent->color = BLACK;
                Ny->color = BLACK;
                N->parent->parent->color = RED;
                N = N->parent->parent;
                continue;
            } else if (N == N->parent->left) {
 8049a1c:	3b 50 08             	cmp    0x8(%eax),%edx
 8049a1f:	0f 84 fb 00 00 00    	je     8049b20 <RBTreeInsert+0x170>
                N = N->parent;
                RightRotate(T, N);
            }
            N->parent->color = BLACK;
 8049a25:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
            N->parent->parent->color = RED;
 8049a2b:	8b 42 10             	mov    0x10(%edx),%eax
 8049a2e:	8b 40 10             	mov    0x10(%eax),%eax
 8049a31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            LeftRotate(T, N->parent->parent);
 8049a37:	8b 42 10             	mov    0x10(%edx),%eax
 8049a3a:	8b 40 10             	mov    0x10(%eax),%eax
    return Tx->parent;
}

static void LeftRotate(RBTree T, RBNode N)
{
    RBNode M = N->right;
 8049a3d:	8b 48 0c             	mov    0xc(%eax),%ecx
    N->right = M->left;
 8049a40:	8b 79 08             	mov    0x8(%ecx),%edi
 8049a43:	89 78 0c             	mov    %edi,0xc(%eax)
    if (M->left != &T->nil)
 8049a46:	8b 79 08             	mov    0x8(%ecx),%edi
 8049a49:	39 fb                	cmp    %edi,%ebx
 8049a4b:	74 03                	je     8049a50 <RBTreeInsert+0xa0>
        M->left->parent = N;
 8049a4d:	89 47 10             	mov    %eax,0x10(%edi)
    M->parent = N->parent;
 8049a50:	8b 78 10             	mov    0x10(%eax),%edi
 8049a53:	89 79 10             	mov    %edi,0x10(%ecx)
    if (N->parent == &T->nil)
 8049a56:	8b 78 10             	mov    0x10(%eax),%edi
 8049a59:	39 fb                	cmp    %edi,%ebx
 8049a5b:	0f 84 ff 00 00 00    	je     8049b60 <RBTreeInsert+0x1b0>
        T->root = M;
    else if (N == N->parent->left)
 8049a61:	3b 47 08             	cmp    0x8(%edi),%eax
 8049a64:	0f 84 06 01 00 00    	je     8049b70 <RBTreeInsert+0x1c0>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049a6a:	89 4f 0c             	mov    %ecx,0xc(%edi)
    M->left = N;
 8049a6d:	89 41 08             	mov    %eax,0x8(%ecx)
    N->parent = M;
 8049a70:	89 48 10             	mov    %ecx,0x10(%eax)
}

static void RBTreeInsertFixup(RBTree T, RBNode N)
{
    RBNode Ny;
    while (N->parent->color == RED) {
 8049a73:	8b 42 10             	mov    0x10(%edx),%eax
 8049a76:	8b 08                	mov    (%eax),%ecx
 8049a78:	85 c9                	test   %ecx,%ecx
 8049a7a:	74 8d                	je     8049a09 <RBTreeInsert+0x59>
            N->parent->color = BLACK;
            N->parent->parent->color = RED;
            LeftRotate(T, N->parent->parent);
        }
    }
    T->root->color = BLACK;
 8049a7c:	8b 06                	mov    (%esi),%eax
 8049a7e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        Tp->left = N;
    else
        Tp->right = N;
    RBTreeInsertFixup(T, N);
    return 0;
}
 8049a84:	31 c0                	xor    %eax,%eax
 8049a86:	5b                   	pop    %ebx
 8049a87:	5e                   	pop    %esi
 8049a88:	5f                   	pop    %edi
 8049a89:	5d                   	pop    %ebp
 8049a8a:	c3                   	ret    
 8049a8b:	90                   	nop
 8049a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
            N->parent->parent->color = RED;
            RightRotate(T, N->parent->parent);
        } else {
            Ny = N->parent->parent->left;
            if (Ny->color == RED) {
                N->parent->color = BLACK;
 8049a90:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
                Ny->color = BLACK;
 8049a96:	c7 01 01 00 00 00    	movl   $0x1,(%ecx)
                N->parent->parent->color = RED;
 8049a9c:	8b 42 10             	mov    0x10(%edx),%eax
 8049a9f:	8b 40 10             	mov    0x10(%eax),%eax
 8049aa2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                N = N->parent->parent;
 8049aa8:	8b 42 10             	mov    0x10(%edx),%eax
 8049aab:	8b 50 10             	mov    0x10(%eax),%edx
 8049aae:	e9 4d ff ff ff       	jmp    8049a00 <RBTreeInsert+0x50>
 8049ab3:	90                   	nop
 8049ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static void RBTreeInsertFixup(RBTree T, RBNode N)
{
    RBNode Ny;
    while (N->parent->color == RED) {
        if (N->parent == N->parent->parent->left) {
            Ny = N->parent->parent->right;
 8049ab8:	8b 4f 0c             	mov    0xc(%edi),%ecx
            if (Ny->color == RED) {
 8049abb:	83 39 00             	cmpl   $0x0,(%ecx)
 8049abe:	74 d0                	je     8049a90 <RBTreeInsert+0xe0>
                N->parent->color = BLACK;
                Ny->color = BLACK;
                N->parent->parent->color = RED;
                N = N->parent->parent;
                continue;
            } else if (N == N->parent->right) {
 8049ac0:	3b 50 0c             	cmp    0xc(%eax),%edx
 8049ac3:	0f 84 c7 00 00 00    	je     8049b90 <RBTreeInsert+0x1e0>
                N = N->parent;
                LeftRotate(T, N);
            }
            N->parent->color = BLACK;
 8049ac9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
            N->parent->parent->color = RED;
 8049acf:	8b 42 10             	mov    0x10(%edx),%eax
 8049ad2:	8b 40 10             	mov    0x10(%eax),%eax
 8049ad5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            RightRotate(T, N->parent->parent);
 8049adb:	8b 42 10             	mov    0x10(%edx),%eax
 8049ade:	8b 40 10             	mov    0x10(%eax),%eax
    N->parent = M;
}

static void RightRotate(RBTree T, RBNode N)
{
    RBNode M = N->left;
 8049ae1:	8b 48 08             	mov    0x8(%eax),%ecx
    N->left = M->right;
 8049ae4:	8b 79 0c             	mov    0xc(%ecx),%edi
 8049ae7:	89 78 08             	mov    %edi,0x8(%eax)
    if (M->right != &T->nil)
 8049aea:	8b 79 0c             	mov    0xc(%ecx),%edi
 8049aed:	39 fb                	cmp    %edi,%ebx
 8049aef:	74 03                	je     8049af4 <RBTreeInsert+0x144>
        M->right->parent = N;
 8049af1:	89 47 10             	mov    %eax,0x10(%edi)
    M->parent = N->parent;
 8049af4:	8b 78 10             	mov    0x10(%eax),%edi
 8049af7:	89 79 10             	mov    %edi,0x10(%ecx)
    if (N->parent == &T->nil)
 8049afa:	8b 78 10             	mov    0x10(%eax),%edi
 8049afd:	39 fb                	cmp    %edi,%ebx
 8049aff:	0f 84 cb 00 00 00    	je     8049bd0 <RBTreeInsert+0x220>
        T->root = M;
    else if (N == N->parent->left)
 8049b05:	3b 47 08             	cmp    0x8(%edi),%eax
 8049b08:	0f 84 d3 00 00 00    	je     8049be1 <RBTreeInsert+0x231>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049b0e:	89 4f 0c             	mov    %ecx,0xc(%edi)
    M->right = N;
 8049b11:	89 41 0c             	mov    %eax,0xc(%ecx)
    N->parent = M;
 8049b14:	89 48 10             	mov    %ecx,0x10(%eax)
 8049b17:	e9 e4 fe ff ff       	jmp    8049a00 <RBTreeInsert+0x50>
 8049b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}

static void RightRotate(RBTree T, RBNode N)
{
    RBNode M = N->left;
    N->left = M->right;
 8049b20:	8b 4a 0c             	mov    0xc(%edx),%ecx
 8049b23:	89 48 08             	mov    %ecx,0x8(%eax)
    if (M->right != &T->nil)
 8049b26:	8b 4a 0c             	mov    0xc(%edx),%ecx
 8049b29:	39 cb                	cmp    %ecx,%ebx
 8049b2b:	74 06                	je     8049b33 <RBTreeInsert+0x183>
        M->right->parent = N;
 8049b2d:	89 41 10             	mov    %eax,0x10(%ecx)
 8049b30:	8b 78 10             	mov    0x10(%eax),%edi
    M->parent = N->parent;
 8049b33:	89 7a 10             	mov    %edi,0x10(%edx)
    if (N->parent == &T->nil)
 8049b36:	8b 48 10             	mov    0x10(%eax),%ecx
 8049b39:	39 cb                	cmp    %ecx,%ebx
 8049b3b:	0f 84 a8 00 00 00    	je     8049be9 <RBTreeInsert+0x239>
        T->root = M;
    else if (N == N->parent->left)
 8049b41:	3b 41 08             	cmp    0x8(%ecx),%eax
 8049b44:	74 42                	je     8049b88 <RBTreeInsert+0x1d8>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049b46:	89 51 0c             	mov    %edx,0xc(%ecx)
    M->right = N;
    N->parent = M;
 8049b49:	89 d1                	mov    %edx,%ecx
        T->root = M;
    else if (N == N->parent->left)
        N->parent->left = M;
    else
        N->parent->right = M;
    M->right = N;
 8049b4b:	89 42 0c             	mov    %eax,0xc(%edx)
    N->parent = M;
 8049b4e:	89 50 10             	mov    %edx,0x10(%eax)
 8049b51:	89 c2                	mov    %eax,%edx
 8049b53:	89 c8                	mov    %ecx,%eax
 8049b55:	e9 cb fe ff ff       	jmp    8049a25 <RBTreeInsert+0x75>
 8049b5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    N->right = M->left;
    if (M->left != &T->nil)
        M->left->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 8049b60:	89 0e                	mov    %ecx,(%esi)
 8049b62:	e9 06 ff ff ff       	jmp    8049a6d <RBTreeInsert+0xbd>
 8049b67:	89 f6                	mov    %esi,%esi
 8049b69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    else if (N == N->parent->left)
        N->parent->left = M;
 8049b70:	89 4f 08             	mov    %ecx,0x8(%edi)
 8049b73:	e9 f5 fe ff ff       	jmp    8049a6d <RBTreeInsert+0xbd>
 8049b78:	90                   	nop
 8049b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
    N->parent = Tp;
    if (Tp == &T->nil)
        T->root = N;
    else if (key < Tp->key)
        Tp->left = N;
 8049b80:	89 51 08             	mov    %edx,0x8(%ecx)
 8049b83:	e9 78 fe ff ff       	jmp    8049a00 <RBTreeInsert+0x50>
        M->right->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
    else if (N == N->parent->left)
        N->parent->left = M;
 8049b88:	89 51 08             	mov    %edx,0x8(%ecx)
 8049b8b:	eb bc                	jmp    8049b49 <RBTreeInsert+0x199>
 8049b8d:	8d 76 00             	lea    0x0(%esi),%esi
}

static void LeftRotate(RBTree T, RBNode N)
{
    RBNode M = N->right;
    N->right = M->left;
 8049b90:	8b 4a 08             	mov    0x8(%edx),%ecx
 8049b93:	89 48 0c             	mov    %ecx,0xc(%eax)
    if (M->left != &T->nil)
 8049b96:	8b 4a 08             	mov    0x8(%edx),%ecx
 8049b99:	39 cb                	cmp    %ecx,%ebx
 8049b9b:	74 06                	je     8049ba3 <RBTreeInsert+0x1f3>
        M->left->parent = N;
 8049b9d:	89 41 10             	mov    %eax,0x10(%ecx)
 8049ba0:	8b 78 10             	mov    0x10(%eax),%edi
    M->parent = N->parent;
 8049ba3:	89 7a 10             	mov    %edi,0x10(%edx)
    if (N->parent == &T->nil)
 8049ba6:	8b 48 10             	mov    0x10(%eax),%ecx
 8049ba9:	39 cb                	cmp    %ecx,%ebx
 8049bab:	74 43                	je     8049bf0 <RBTreeInsert+0x240>
        T->root = M;
    else if (N == N->parent->left)
 8049bad:	3b 41 08             	cmp    0x8(%ecx),%eax
 8049bb0:	74 42                	je     8049bf4 <RBTreeInsert+0x244>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049bb2:	89 51 0c             	mov    %edx,0xc(%ecx)
    M->left = N;
    N->parent = M;
 8049bb5:	89 d1                	mov    %edx,%ecx
        T->root = M;
    else if (N == N->parent->left)
        N->parent->left = M;
    else
        N->parent->right = M;
    M->left = N;
 8049bb7:	89 42 08             	mov    %eax,0x8(%edx)
    N->parent = M;
 8049bba:	89 50 10             	mov    %edx,0x10(%eax)
 8049bbd:	89 c2                	mov    %eax,%edx
 8049bbf:	89 c8                	mov    %ecx,%eax
 8049bc1:	e9 03 ff ff ff       	jmp    8049ac9 <RBTreeInsert+0x119>
 8049bc6:	8d 76 00             	lea    0x0(%esi),%esi
 8049bc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    N->left = M->right;
    if (M->right != &T->nil)
        M->right->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 8049bd0:	89 0e                	mov    %ecx,(%esi)
 8049bd2:	e9 3a ff ff ff       	jmp    8049b11 <RBTreeInsert+0x161>
        if (key < Tc->key)
            Tc = Tc->left;
        else
            Tc = Tc->right;
    }
    N->parent = Tp;
 8049bd7:	89 5a 10             	mov    %ebx,0x10(%edx)
    if (Tp == &T->nil)
        T->root = N;
 8049bda:	89 16                	mov    %edx,(%esi)
 8049bdc:	e9 1f fe ff ff       	jmp    8049a00 <RBTreeInsert+0x50>
        M->right->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
    else if (N == N->parent->left)
        N->parent->left = M;
 8049be1:	89 4f 08             	mov    %ecx,0x8(%edi)
 8049be4:	e9 28 ff ff ff       	jmp    8049b11 <RBTreeInsert+0x161>
    N->left = M->right;
    if (M->right != &T->nil)
        M->right->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 8049be9:	89 16                	mov    %edx,(%esi)
 8049beb:	e9 59 ff ff ff       	jmp    8049b49 <RBTreeInsert+0x199>
    N->right = M->left;
    if (M->left != &T->nil)
        M->left->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 8049bf0:	89 16                	mov    %edx,(%esi)
 8049bf2:	eb c1                	jmp    8049bb5 <RBTreeInsert+0x205>
    else if (N == N->parent->left)
        N->parent->left = M;
 8049bf4:	89 51 08             	mov    %edx,0x8(%ecx)
 8049bf7:	eb bc                	jmp    8049bb5 <RBTreeInsert+0x205>
 8049bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

08049c00 <RBTreeDeleteNode>:
    }
    N->color = BLACK;
}

void RBTreeDeleteNode(RBTree T, RBNode N)
{
 8049c00:	55                   	push   %ebp
 8049c01:	89 e5                	mov    %esp,%ebp
 8049c03:	57                   	push   %edi
 8049c04:	56                   	push   %esi
 8049c05:	53                   	push   %ebx
 8049c06:	83 ec 04             	sub    $0x4,%esp
 8049c09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 8049c0c:	8b 75 08             	mov    0x8(%ebp),%esi
    RBNode Tx;
    RBNode Ty = N;
    int TyOriginalColor = Ty->color;

    if (N->left == &T->nil) {
 8049c0f:	8b 53 08             	mov    0x8(%ebx),%edx

void RBTreeDeleteNode(RBTree T, RBNode N)
{
    RBNode Tx;
    RBNode Ty = N;
    int TyOriginalColor = Ty->color;
 8049c12:	8b 03                	mov    (%ebx),%eax

    if (N->left == &T->nil) {
 8049c14:	8d 4e 04             	lea    0x4(%esi),%ecx
 8049c17:	39 ca                	cmp    %ecx,%edx

void RBTreeDeleteNode(RBTree T, RBNode N)
{
    RBNode Tx;
    RBNode Ty = N;
    int TyOriginalColor = Ty->color;
 8049c19:	89 45 f0             	mov    %eax,-0x10(%ebp)

    if (N->left == &T->nil) {
 8049c1c:	0f 84 1e 03 00 00    	je     8049f40 <RBTreeDeleteNode+0x340>
        Tx = N->right;
        RBTreeTransplant(T, N, Tx); 
    } else if (N->right == &T->nil) {
 8049c22:	8b 43 0c             	mov    0xc(%ebx),%eax
 8049c25:	39 c1                	cmp    %eax,%ecx
 8049c27:	75 09                	jne    8049c32 <RBTreeDeleteNode+0x32>
 8049c29:	e9 42 03 00 00       	jmp    8049f70 <RBTreeDeleteNode+0x370>
 8049c2e:	66 90                	xchg   %ax,%ax

// nil is a struct
// root is a pointer.
RBNode RBTreeMinimum(RBTree T, RBNode N)
{
    while (N->left != &T->nil)
 8049c30:	89 d0                	mov    %edx,%eax
 8049c32:	8b 50 08             	mov    0x8(%eax),%edx
 8049c35:	39 d1                	cmp    %edx,%ecx
 8049c37:	75 f7                	jne    8049c30 <RBTreeDeleteNode+0x30>
    } else if (N->right == &T->nil) {
        Tx = N->left;
        RBTreeTransplant(T, N, Tx);
    } else {
        Ty = RBTreeMinimum(T, N->right);
        TyOriginalColor = Ty->color;
 8049c39:	8b 38                	mov    (%eax),%edi
        Tx = Ty->right;
 8049c3b:	8b 50 0c             	mov    0xc(%eax),%edx
    } else if (N->right == &T->nil) {
        Tx = N->left;
        RBTreeTransplant(T, N, Tx);
    } else {
        Ty = RBTreeMinimum(T, N->right);
        TyOriginalColor = Ty->color;
 8049c3e:	89 7d f0             	mov    %edi,-0x10(%ebp)
        Tx = Ty->right;
        if (Ty->parent == N) {
 8049c41:	8b 78 10             	mov    0x10(%eax),%edi
 8049c44:	39 fb                	cmp    %edi,%ebx
 8049c46:	0f 84 54 03 00 00    	je     8049fa0 <RBTreeDeleteNode+0x3a0>
    N->parent = M;
}

static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
 8049c4c:	39 f9                	cmp    %edi,%ecx
 8049c4e:	0f 84 7c 03 00 00    	je     8049fd0 <RBTreeDeleteNode+0x3d0>
        T->root = dst;
    else if (src == src->parent->left)
 8049c54:	3b 47 08             	cmp    0x8(%edi),%eax
 8049c57:	0f 84 d8 02 00 00    	je     8049f35 <RBTreeDeleteNode+0x335>
        src->parent->left = dst;
    else
        src->parent->right = dst;
 8049c5d:	89 57 0c             	mov    %edx,0xc(%edi)
    dst->parent = src->parent;
 8049c60:	8b 78 10             	mov    0x10(%eax),%edi
 8049c63:	89 7a 10             	mov    %edi,0x10(%edx)
        Tx = Ty->right;
        if (Ty->parent == N) {
            Tx->parent = Ty;        // what will happen if Tx is T->nil?
        } else {
            RBTreeTransplant(T, Ty, Ty->right);
            Ty->right = N->right;
 8049c66:	8b 7b 0c             	mov    0xc(%ebx),%edi
 8049c69:	89 78 0c             	mov    %edi,0xc(%eax)
            Ty->right->parent = Ty;
 8049c6c:	89 47 10             	mov    %eax,0x10(%edi)
    N->parent = M;
}

static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
 8049c6f:	8b 7b 10             	mov    0x10(%ebx),%edi
 8049c72:	39 f9                	cmp    %edi,%ecx
 8049c74:	0f 84 16 03 00 00    	je     8049f90 <RBTreeDeleteNode+0x390>
        T->root = dst;
    else if (src == src->parent->left)
 8049c7a:	3b 5f 08             	cmp    0x8(%edi),%ebx
 8049c7d:	0f 84 3d 03 00 00    	je     8049fc0 <RBTreeDeleteNode+0x3c0>
        src->parent->left = dst;
    else
        src->parent->right = dst;
 8049c83:	89 47 0c             	mov    %eax,0xc(%edi)
    dst->parent = src->parent;
 8049c86:	8b 7b 10             	mov    0x10(%ebx),%edi
 8049c89:	89 78 10             	mov    %edi,0x10(%eax)
            RBTreeTransplant(T, Ty, Ty->right);
            Ty->right = N->right;
            Ty->right->parent = Ty;
        }
        RBTreeTransplant(T, N, Ty);
        Ty->left = N->left;
 8049c8c:	8b 7b 08             	mov    0x8(%ebx),%edi
 8049c8f:	89 78 08             	mov    %edi,0x8(%eax)
        Ty->left->parent = Ty;
 8049c92:	89 47 10             	mov    %eax,0x10(%edi)
        Ty->color = N->color;
 8049c95:	8b 3b                	mov    (%ebx),%edi
 8049c97:	89 38                	mov    %edi,(%eax)
    }
    // must be set to null.
    N->left = &T->nil;
    N->right = &T->nil;
    if (TyOriginalColor == BLACK)
 8049c99:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
        Ty->left = N->left;
        Ty->left->parent = Ty;
        Ty->color = N->color;
    }
    // must be set to null.
    N->left = &T->nil;
 8049c9d:	89 4b 08             	mov    %ecx,0x8(%ebx)
    N->right = &T->nil;
 8049ca0:	89 4b 0c             	mov    %ecx,0xc(%ebx)
    if (TyOriginalColor == BLACK)
 8049ca3:	74 24                	je     8049cc9 <RBTreeDeleteNode+0xc9>
        RBTreeDeleteFixup(T, Tx);
 8049ca5:	83 c4 04             	add    $0x4,%esp
 8049ca8:	5b                   	pop    %ebx
 8049ca9:	5e                   	pop    %esi
 8049caa:	5f                   	pop    %edi
 8049cab:	5d                   	pop    %ebp
 8049cac:	c3                   	ret    
 8049cad:	8d 76 00             	lea    0x0(%esi),%esi
                Tw->color = BLACK;
                Tw->parent->color = RED;
                LeftRotate(T, N->parent);
                Tw = N->parent->right;
            }
            if (Tw->left->color == BLACK && Tw->right->color == BLACK) {
 8049cb0:	8b 58 0c             	mov    0xc(%eax),%ebx
 8049cb3:	83 3b 01             	cmpl   $0x1,(%ebx)
 8049cb6:	0f 85 bf 01 00 00    	jne    8049e7b <RBTreeDeleteNode+0x27b>
 8049cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
                Tw->color = RED;
 8049cc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                N = N->parent;
 8049cc6:	8b 52 10             	mov    0x10(%edx),%edx
 8049cc9:	8b 06                	mov    (%esi),%eax

static void RBTreeDeleteFixup(RBTree T, RBNode N)
{
    RBNode Tw;

    while (N != T->root && N->color == BLACK) {
 8049ccb:	39 c2                	cmp    %eax,%edx
 8049ccd:	0f 84 ce 00 00 00    	je     8049da1 <RBTreeDeleteNode+0x1a1>
 8049cd3:	83 3a 01             	cmpl   $0x1,(%edx)
 8049cd6:	0f 85 d4 02 00 00    	jne    8049fb0 <RBTreeDeleteNode+0x3b0>
        if (N == N->parent->left) {
 8049cdc:	8b 5a 10             	mov    0x10(%edx),%ebx
 8049cdf:	8b 43 08             	mov    0x8(%ebx),%eax
 8049ce2:	39 c2                	cmp    %eax,%edx
 8049ce4:	0f 84 26 01 00 00    	je     8049e10 <RBTreeDeleteNode+0x210>
            Tw->right->color = BLACK;
            LeftRotate(T, N->parent);
            N = T->root;
        } else {
            Tw = N->parent->left;
            if (Tw->color == RED) {
 8049cea:	8b 38                	mov    (%eax),%edi
 8049cec:	85 ff                	test   %edi,%edi
 8049cee:	75 4e                	jne    8049d3e <RBTreeDeleteNode+0x13e>
                Tw->color = BLACK;
 8049cf0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
                Tw->parent->color = RED;
 8049cf6:	8b 40 10             	mov    0x10(%eax),%eax
 8049cf9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                RightRotate(T, N->parent);
 8049cff:	8b 42 10             	mov    0x10(%edx),%eax
    N->parent = M;
}

static void RightRotate(RBTree T, RBNode N)
{
    RBNode M = N->left;
 8049d02:	8b 58 08             	mov    0x8(%eax),%ebx
    N->left = M->right;
 8049d05:	8b 7b 0c             	mov    0xc(%ebx),%edi
 8049d08:	89 78 08             	mov    %edi,0x8(%eax)
    if (M->right != &T->nil)
 8049d0b:	8b 7b 0c             	mov    0xc(%ebx),%edi
 8049d0e:	39 f9                	cmp    %edi,%ecx
 8049d10:	74 03                	je     8049d15 <RBTreeDeleteNode+0x115>
        M->right->parent = N;
 8049d12:	89 47 10             	mov    %eax,0x10(%edi)
    M->parent = N->parent;
 8049d15:	8b 78 10             	mov    0x10(%eax),%edi
 8049d18:	89 7b 10             	mov    %edi,0x10(%ebx)
    if (N->parent == &T->nil)
 8049d1b:	8b 78 10             	mov    0x10(%eax),%edi
 8049d1e:	39 f9                	cmp    %edi,%ecx
 8049d20:	0f 84 42 02 00 00    	je     8049f68 <RBTreeDeleteNode+0x368>
        T->root = M;
    else if (N == N->parent->left)
 8049d26:	3b 47 08             	cmp    0x8(%edi),%eax
 8049d29:	0f 84 51 02 00 00    	je     8049f80 <RBTreeDeleteNode+0x380>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049d2f:	89 5f 0c             	mov    %ebx,0xc(%edi)
    M->right = N;
 8049d32:	89 43 0c             	mov    %eax,0xc(%ebx)
    N->parent = M;
 8049d35:	89 58 10             	mov    %ebx,0x10(%eax)
            Tw = N->parent->left;
            if (Tw->color == RED) {
                Tw->color = BLACK;
                Tw->parent->color = RED;
                RightRotate(T, N->parent);
                Tw = N->parent->left;
 8049d38:	8b 5a 10             	mov    0x10(%edx),%ebx
 8049d3b:	8b 43 08             	mov    0x8(%ebx),%eax
            }
            if (Tw->left->color == BLACK && Tw->right->color == BLACK) {
 8049d3e:	8b 78 08             	mov    0x8(%eax),%edi
 8049d41:	83 3f 01             	cmpl   $0x1,(%edi)
 8049d44:	74 6a                	je     8049db0 <RBTreeDeleteNode+0x1b0>
                Tw->right->color = BLACK;
                Tw->color = RED;
                LeftRotate(T, Tw);
                Tw = N->parent->left;
            }
            Tw->color = N->parent->color;
 8049d46:	8b 1b                	mov    (%ebx),%ebx
 8049d48:	89 18                	mov    %ebx,(%eax)
            N->parent->color = BLACK;
 8049d4a:	8b 5a 10             	mov    0x10(%edx),%ebx
 8049d4d:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
            Tw->left->color = BLACK;
 8049d53:	8b 40 08             	mov    0x8(%eax),%eax
 8049d56:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
            RightRotate(T, N->parent);
 8049d5c:	8b 42 10             	mov    0x10(%edx),%eax
    N->parent = M;
}

static void RightRotate(RBTree T, RBNode N)
{
    RBNode M = N->left;
 8049d5f:	8b 50 08             	mov    0x8(%eax),%edx
    N->left = M->right;
 8049d62:	8b 5a 0c             	mov    0xc(%edx),%ebx
 8049d65:	89 58 08             	mov    %ebx,0x8(%eax)
    if (M->right != &T->nil)
 8049d68:	8b 5a 0c             	mov    0xc(%edx),%ebx
 8049d6b:	39 d9                	cmp    %ebx,%ecx
 8049d6d:	74 03                	je     8049d72 <RBTreeDeleteNode+0x172>
        M->right->parent = N;
 8049d6f:	89 43 10             	mov    %eax,0x10(%ebx)
    M->parent = N->parent;
 8049d72:	8b 58 10             	mov    0x10(%eax),%ebx
 8049d75:	89 5a 10             	mov    %ebx,0x10(%edx)
    if (N->parent == &T->nil)
 8049d78:	8b 58 10             	mov    0x10(%eax),%ebx
 8049d7b:	39 d9                	cmp    %ebx,%ecx
 8049d7d:	0f 84 55 01 00 00    	je     8049ed8 <RBTreeDeleteNode+0x2d8>
        T->root = M;
    else if (N == N->parent->left)
 8049d83:	3b 43 08             	cmp    0x8(%ebx),%eax
 8049d86:	0f 84 54 01 00 00    	je     8049ee0 <RBTreeDeleteNode+0x2e0>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049d8c:	89 53 0c             	mov    %edx,0xc(%ebx)
    M->right = N;
 8049d8f:	89 42 0c             	mov    %eax,0xc(%edx)
    N->parent = M;
 8049d92:	89 50 10             	mov    %edx,0x10(%eax)
            }
            Tw->color = N->parent->color;
            N->parent->color = BLACK;
            Tw->left->color = BLACK;
            RightRotate(T, N->parent);
            N = T->root;
 8049d95:	8b 16                	mov    (%esi),%edx
 8049d97:	89 d0                	mov    %edx,%eax

static void RBTreeDeleteFixup(RBTree T, RBNode N)
{
    RBNode Tw;

    while (N != T->root && N->color == BLACK) {
 8049d99:	39 c2                	cmp    %eax,%edx
 8049d9b:	0f 85 32 ff ff ff    	jne    8049cd3 <RBTreeDeleteNode+0xd3>
            Tw->left->color = BLACK;
            RightRotate(T, N->parent);
            N = T->root;
        }
    }
    N->color = BLACK;
 8049da1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    // must be set to null.
    N->left = &T->nil;
    N->right = &T->nil;
    if (TyOriginalColor == BLACK)
        RBTreeDeleteFixup(T, Tx);
 8049da7:	83 c4 04             	add    $0x4,%esp
 8049daa:	5b                   	pop    %ebx
 8049dab:	5e                   	pop    %esi
 8049dac:	5f                   	pop    %edi
 8049dad:	5d                   	pop    %ebp
 8049dae:	c3                   	ret    
 8049daf:	90                   	nop
                Tw->color = BLACK;
                Tw->parent->color = RED;
                RightRotate(T, N->parent);
                Tw = N->parent->left;
            }
            if (Tw->left->color == BLACK && Tw->right->color == BLACK) {
 8049db0:	8b 58 0c             	mov    0xc(%eax),%ebx
 8049db3:	83 3b 01             	cmpl   $0x1,(%ebx)
 8049db6:	0f 84 04 ff ff ff    	je     8049cc0 <RBTreeDeleteNode+0xc0>
                Tw->color = RED;
                N = N->parent;
                continue;
            } else if (Tw->left->color == BLACK) {
                Tw->right->color = BLACK;
 8049dbc:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
    return Tx->parent;
}

static void LeftRotate(RBTree T, RBNode N)
{
    RBNode M = N->right;
 8049dc2:	8b 58 0c             	mov    0xc(%eax),%ebx
                Tw->color = RED;
                N = N->parent;
                continue;
            } else if (Tw->left->color == BLACK) {
                Tw->right->color = BLACK;
                Tw->color = RED;
 8049dc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static void LeftRotate(RBTree T, RBNode N)
{
    RBNode M = N->right;
    N->right = M->left;
 8049dcb:	8b 7b 08             	mov    0x8(%ebx),%edi
 8049dce:	89 78 0c             	mov    %edi,0xc(%eax)
    if (M->left != &T->nil)
 8049dd1:	8b 7b 08             	mov    0x8(%ebx),%edi
 8049dd4:	39 f9                	cmp    %edi,%ecx
 8049dd6:	74 03                	je     8049ddb <RBTreeDeleteNode+0x1db>
        M->left->parent = N;
 8049dd8:	89 47 10             	mov    %eax,0x10(%edi)
    M->parent = N->parent;
 8049ddb:	8b 78 10             	mov    0x10(%eax),%edi
 8049dde:	89 7b 10             	mov    %edi,0x10(%ebx)
    if (N->parent == &T->nil)
 8049de1:	8b 78 10             	mov    0x10(%eax),%edi
 8049de4:	39 f9                	cmp    %edi,%ecx
 8049de6:	0f 84 eb 01 00 00    	je     8049fd7 <RBTreeDeleteNode+0x3d7>
        T->root = M;
    else if (N == N->parent->left)
 8049dec:	3b 47 08             	cmp    0x8(%edi),%eax
 8049def:	0f 84 e9 01 00 00    	je     8049fde <RBTreeDeleteNode+0x3de>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049df5:	89 5f 0c             	mov    %ebx,0xc(%edi)
    M->left = N;
 8049df8:	89 43 08             	mov    %eax,0x8(%ebx)
    N->parent = M;
 8049dfb:	89 58 10             	mov    %ebx,0x10(%eax)
                continue;
            } else if (Tw->left->color == BLACK) {
                Tw->right->color = BLACK;
                Tw->color = RED;
                LeftRotate(T, Tw);
                Tw = N->parent->left;
 8049dfe:	8b 5a 10             	mov    0x10(%edx),%ebx
 8049e01:	8b 43 08             	mov    0x8(%ebx),%eax
 8049e04:	e9 3d ff ff ff       	jmp    8049d46 <RBTreeDeleteNode+0x146>
 8049e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
    RBNode Tw;

    while (N != T->root && N->color == BLACK) {
        if (N == N->parent->left) {
            Tw = N->parent->right;
 8049e10:	8b 43 0c             	mov    0xc(%ebx),%eax
            if (Tw->color == RED) {
 8049e13:	8b 18                	mov    (%eax),%ebx
 8049e15:	85 db                	test   %ebx,%ebx
 8049e17:	75 4e                	jne    8049e67 <RBTreeDeleteNode+0x267>
                Tw->color = BLACK;
 8049e19:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
                Tw->parent->color = RED;
 8049e1f:	8b 40 10             	mov    0x10(%eax),%eax
 8049e22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                LeftRotate(T, N->parent);
 8049e28:	8b 42 10             	mov    0x10(%edx),%eax
    return Tx->parent;
}

static void LeftRotate(RBTree T, RBNode N)
{
    RBNode M = N->right;
 8049e2b:	8b 58 0c             	mov    0xc(%eax),%ebx
    N->right = M->left;
 8049e2e:	8b 7b 08             	mov    0x8(%ebx),%edi
 8049e31:	89 78 0c             	mov    %edi,0xc(%eax)
    if (M->left != &T->nil)
 8049e34:	8b 7b 08             	mov    0x8(%ebx),%edi
 8049e37:	39 f9                	cmp    %edi,%ecx
 8049e39:	74 03                	je     8049e3e <RBTreeDeleteNode+0x23e>
        M->left->parent = N;
 8049e3b:	89 47 10             	mov    %eax,0x10(%edi)
    M->parent = N->parent;
 8049e3e:	8b 78 10             	mov    0x10(%eax),%edi
 8049e41:	89 7b 10             	mov    %edi,0x10(%ebx)
    if (N->parent == &T->nil)
 8049e44:	8b 78 10             	mov    0x10(%eax),%edi
 8049e47:	39 f9                	cmp    %edi,%ecx
 8049e49:	0f 84 ae 01 00 00    	je     8049ffd <RBTreeDeleteNode+0x3fd>
        T->root = M;
    else if (N == N->parent->left)
 8049e4f:	3b 47 08             	cmp    0x8(%edi),%eax
 8049e52:	0f 84 ac 01 00 00    	je     804a004 <RBTreeDeleteNode+0x404>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049e58:	89 5f 0c             	mov    %ebx,0xc(%edi)
    M->left = N;
 8049e5b:	89 43 08             	mov    %eax,0x8(%ebx)
    N->parent = M;
 8049e5e:	89 58 10             	mov    %ebx,0x10(%eax)
            Tw = N->parent->right;
            if (Tw->color == RED) {
                Tw->color = BLACK;
                Tw->parent->color = RED;
                LeftRotate(T, N->parent);
                Tw = N->parent->right;
 8049e61:	8b 42 10             	mov    0x10(%edx),%eax
 8049e64:	8b 40 0c             	mov    0xc(%eax),%eax
            }
            if (Tw->left->color == BLACK && Tw->right->color == BLACK) {
 8049e67:	8b 58 08             	mov    0x8(%eax),%ebx
 8049e6a:	83 3b 01             	cmpl   $0x1,(%ebx)
 8049e6d:	0f 84 3d fe ff ff    	je     8049cb0 <RBTreeDeleteNode+0xb0>
                Tw->color = RED;
                N = N->parent;
                continue;
            } else if (Tw->right->color == BLACK) {
 8049e73:	8b 78 0c             	mov    0xc(%eax),%edi
 8049e76:	83 3f 01             	cmpl   $0x1,(%edi)
 8049e79:	74 6d                	je     8049ee8 <RBTreeDeleteNode+0x2e8>
                Tw->left->color = BLACK;
                Tw->color = RED;
                RightRotate(T, Tw);
                Tw = N->parent->right;
            }
            Tw->color = RED;
 8049e7b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            N->parent->color = BLACK;
 8049e81:	8b 5a 10             	mov    0x10(%edx),%ebx
 8049e84:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
            Tw->right->color = BLACK;
 8049e8a:	8b 40 0c             	mov    0xc(%eax),%eax
 8049e8d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
            LeftRotate(T, N->parent);
 8049e93:	8b 42 10             	mov    0x10(%edx),%eax
    return Tx->parent;
}

static void LeftRotate(RBTree T, RBNode N)
{
    RBNode M = N->right;
 8049e96:	8b 50 0c             	mov    0xc(%eax),%edx
    N->right = M->left;
 8049e99:	8b 5a 08             	mov    0x8(%edx),%ebx
 8049e9c:	89 58 0c             	mov    %ebx,0xc(%eax)
    if (M->left != &T->nil)
 8049e9f:	8b 5a 08             	mov    0x8(%edx),%ebx
 8049ea2:	39 d9                	cmp    %ebx,%ecx
 8049ea4:	74 03                	je     8049ea9 <RBTreeDeleteNode+0x2a9>
        M->left->parent = N;
 8049ea6:	89 43 10             	mov    %eax,0x10(%ebx)
    M->parent = N->parent;
 8049ea9:	8b 58 10             	mov    0x10(%eax),%ebx
 8049eac:	89 5a 10             	mov    %ebx,0x10(%edx)
    if (N->parent == &T->nil)
 8049eaf:	8b 58 10             	mov    0x10(%eax),%ebx
 8049eb2:	39 d9                	cmp    %ebx,%ecx
 8049eb4:	0f 84 2c 01 00 00    	je     8049fe6 <RBTreeDeleteNode+0x3e6>
        T->root = M;
    else if (N == N->parent->left)
 8049eba:	3b 43 08             	cmp    0x8(%ebx),%eax
 8049ebd:	0f 84 2a 01 00 00    	je     8049fed <RBTreeDeleteNode+0x3ed>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049ec3:	89 53 0c             	mov    %edx,0xc(%ebx)
    M->left = N;
 8049ec6:	89 42 08             	mov    %eax,0x8(%edx)
    N->parent = M;
 8049ec9:	89 50 10             	mov    %edx,0x10(%eax)
            }
            Tw->color = RED;
            N->parent->color = BLACK;
            Tw->right->color = BLACK;
            LeftRotate(T, N->parent);
            N = T->root;
 8049ecc:	8b 16                	mov    (%esi),%edx
 8049ece:	89 d0                	mov    %edx,%eax
 8049ed0:	e9 f6 fd ff ff       	jmp    8049ccb <RBTreeDeleteNode+0xcb>
 8049ed5:	8d 76 00             	lea    0x0(%esi),%esi
    N->left = M->right;
    if (M->right != &T->nil)
        M->right->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 8049ed8:	89 16                	mov    %edx,(%esi)
 8049eda:	e9 b0 fe ff ff       	jmp    8049d8f <RBTreeDeleteNode+0x18f>
 8049edf:	90                   	nop
    else if (N == N->parent->left)
        N->parent->left = M;
 8049ee0:	89 53 08             	mov    %edx,0x8(%ebx)
 8049ee3:	e9 a7 fe ff ff       	jmp    8049d8f <RBTreeDeleteNode+0x18f>
            if (Tw->left->color == BLACK && Tw->right->color == BLACK) {
                Tw->color = RED;
                N = N->parent;
                continue;
            } else if (Tw->right->color == BLACK) {
                Tw->left->color = BLACK;
 8049ee8:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
    N->parent = M;
}

static void RightRotate(RBTree T, RBNode N)
{
    RBNode M = N->left;
 8049eee:	8b 58 08             	mov    0x8(%eax),%ebx
                Tw->color = RED;
                N = N->parent;
                continue;
            } else if (Tw->right->color == BLACK) {
                Tw->left->color = BLACK;
                Tw->color = RED;
 8049ef1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static void RightRotate(RBTree T, RBNode N)
{
    RBNode M = N->left;
    N->left = M->right;
 8049ef7:	8b 7b 0c             	mov    0xc(%ebx),%edi
 8049efa:	89 78 08             	mov    %edi,0x8(%eax)
    if (M->right != &T->nil)
 8049efd:	8b 7b 0c             	mov    0xc(%ebx),%edi
 8049f00:	39 f9                	cmp    %edi,%ecx
 8049f02:	74 03                	je     8049f07 <RBTreeDeleteNode+0x307>
        M->right->parent = N;
 8049f04:	89 47 10             	mov    %eax,0x10(%edi)
    M->parent = N->parent;
 8049f07:	8b 78 10             	mov    0x10(%eax),%edi
 8049f0a:	89 7b 10             	mov    %edi,0x10(%ebx)
    if (N->parent == &T->nil)
 8049f0d:	8b 78 10             	mov    0x10(%eax),%edi
 8049f10:	39 f9                	cmp    %edi,%ecx
 8049f12:	0f 84 f4 00 00 00    	je     804a00c <RBTreeDeleteNode+0x40c>
        T->root = M;
    else if (N == N->parent->left)
 8049f18:	3b 47 08             	cmp    0x8(%edi),%eax
 8049f1b:	0f 84 f2 00 00 00    	je     804a013 <RBTreeDeleteNode+0x413>
        N->parent->left = M;
    else
        N->parent->right = M;
 8049f21:	89 5f 0c             	mov    %ebx,0xc(%edi)
    M->right = N;
 8049f24:	89 43 0c             	mov    %eax,0xc(%ebx)
    N->parent = M;
 8049f27:	89 58 10             	mov    %ebx,0x10(%eax)
                continue;
            } else if (Tw->right->color == BLACK) {
                Tw->left->color = BLACK;
                Tw->color = RED;
                RightRotate(T, Tw);
                Tw = N->parent->right;
 8049f2a:	8b 42 10             	mov    0x10(%edx),%eax
 8049f2d:	8b 40 0c             	mov    0xc(%eax),%eax
 8049f30:	e9 46 ff ff ff       	jmp    8049e7b <RBTreeDeleteNode+0x27b>
static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
        T->root = dst;
    else if (src == src->parent->left)
        src->parent->left = dst;
 8049f35:	89 57 08             	mov    %edx,0x8(%edi)
 8049f38:	e9 23 fd ff ff       	jmp    8049c60 <RBTreeDeleteNode+0x60>
 8049f3d:	8d 76 00             	lea    0x0(%esi),%esi
    N->parent = M;
}

static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
 8049f40:	8b 43 10             	mov    0x10(%ebx),%eax
    RBNode Tx;
    RBNode Ty = N;
    int TyOriginalColor = Ty->color;

    if (N->left == &T->nil) {
        Tx = N->right;
 8049f43:	8b 53 0c             	mov    0xc(%ebx),%edx
    N->parent = M;
}

static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
 8049f46:	39 c1                	cmp    %eax,%ecx
 8049f48:	74 2d                	je     8049f77 <RBTreeDeleteNode+0x377>
        T->root = dst;
    else if (src == src->parent->left)
 8049f4a:	3b 58 08             	cmp    0x8(%eax),%ebx
 8049f4d:	0f 84 a2 00 00 00    	je     8049ff5 <RBTreeDeleteNode+0x3f5>
        src->parent->left = dst;
    else
        src->parent->right = dst;
 8049f53:	89 50 0c             	mov    %edx,0xc(%eax)
    dst->parent = src->parent;
 8049f56:	8b 43 10             	mov    0x10(%ebx),%eax
 8049f59:	89 42 10             	mov    %eax,0x10(%edx)
 8049f5c:	e9 38 fd ff ff       	jmp    8049c99 <RBTreeDeleteNode+0x99>
 8049f61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    N->left = M->right;
    if (M->right != &T->nil)
        M->right->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 8049f68:	89 1e                	mov    %ebx,(%esi)
 8049f6a:	e9 c3 fd ff ff       	jmp    8049d32 <RBTreeDeleteNode+0x132>
 8049f6f:	90                   	nop
    N->parent = M;
}

static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
 8049f70:	8b 43 10             	mov    0x10(%ebx),%eax
 8049f73:	39 c1                	cmp    %eax,%ecx
 8049f75:	75 d3                	jne    8049f4a <RBTreeDeleteNode+0x34a>
        T->root = dst;
 8049f77:	89 16                	mov    %edx,(%esi)
 8049f79:	eb db                	jmp    8049f56 <RBTreeDeleteNode+0x356>
 8049f7b:	90                   	nop
 8049f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        M->right->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
    else if (N == N->parent->left)
        N->parent->left = M;
 8049f80:	89 5f 08             	mov    %ebx,0x8(%edi)
 8049f83:	e9 aa fd ff ff       	jmp    8049d32 <RBTreeDeleteNode+0x132>
 8049f88:	90                   	nop
 8049f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}

static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
        T->root = dst;
 8049f90:	89 06                	mov    %eax,(%esi)
 8049f92:	e9 ef fc ff ff       	jmp    8049c86 <RBTreeDeleteNode+0x86>
 8049f97:	89 f6                	mov    %esi,%esi
 8049f99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    } else {
        Ty = RBTreeMinimum(T, N->right);
        TyOriginalColor = Ty->color;
        Tx = Ty->right;
        if (Ty->parent == N) {
            Tx->parent = Ty;        // what will happen if Tx is T->nil?
 8049fa0:	89 42 10             	mov    %eax,0x10(%edx)
 8049fa3:	e9 c7 fc ff ff       	jmp    8049c6f <RBTreeDeleteNode+0x6f>
 8049fa8:	90                   	nop
 8049fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

static void RBTreeDeleteFixup(RBTree T, RBNode N)
{
    RBNode Tw;

    while (N != T->root && N->color == BLACK) {
 8049fb0:	89 d0                	mov    %edx,%eax
 8049fb2:	e9 ea fd ff ff       	jmp    8049da1 <RBTreeDeleteNode+0x1a1>
 8049fb7:	89 f6                	mov    %esi,%esi
 8049fb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
        T->root = dst;
    else if (src == src->parent->left)
        src->parent->left = dst;
 8049fc0:	89 47 08             	mov    %eax,0x8(%edi)
 8049fc3:	e9 be fc ff ff       	jmp    8049c86 <RBTreeDeleteNode+0x86>
 8049fc8:	90                   	nop
 8049fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}

static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
        T->root = dst;
 8049fd0:	89 16                	mov    %edx,(%esi)
 8049fd2:	e9 89 fc ff ff       	jmp    8049c60 <RBTreeDeleteNode+0x60>
    N->right = M->left;
    if (M->left != &T->nil)
        M->left->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 8049fd7:	89 1e                	mov    %ebx,(%esi)
 8049fd9:	e9 1a fe ff ff       	jmp    8049df8 <RBTreeDeleteNode+0x1f8>
    else if (N == N->parent->left)
        N->parent->left = M;
 8049fde:	89 5f 08             	mov    %ebx,0x8(%edi)
 8049fe1:	e9 12 fe ff ff       	jmp    8049df8 <RBTreeDeleteNode+0x1f8>
    N->right = M->left;
    if (M->left != &T->nil)
        M->left->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 8049fe6:	89 16                	mov    %edx,(%esi)
 8049fe8:	e9 d9 fe ff ff       	jmp    8049ec6 <RBTreeDeleteNode+0x2c6>
    else if (N == N->parent->left)
        N->parent->left = M;
 8049fed:	89 53 08             	mov    %edx,0x8(%ebx)
 8049ff0:	e9 d1 fe ff ff       	jmp    8049ec6 <RBTreeDeleteNode+0x2c6>
static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
        T->root = dst;
    else if (src == src->parent->left)
        src->parent->left = dst;
 8049ff5:	89 50 08             	mov    %edx,0x8(%eax)
 8049ff8:	e9 59 ff ff ff       	jmp    8049f56 <RBTreeDeleteNode+0x356>
    N->right = M->left;
    if (M->left != &T->nil)
        M->left->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 8049ffd:	89 1e                	mov    %ebx,(%esi)
 8049fff:	e9 57 fe ff ff       	jmp    8049e5b <RBTreeDeleteNode+0x25b>
    else if (N == N->parent->left)
        N->parent->left = M;
 804a004:	89 5f 08             	mov    %ebx,0x8(%edi)
 804a007:	e9 4f fe ff ff       	jmp    8049e5b <RBTreeDeleteNode+0x25b>
    N->left = M->right;
    if (M->right != &T->nil)
        M->right->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
 804a00c:	89 1e                	mov    %ebx,(%esi)
 804a00e:	e9 11 ff ff ff       	jmp    8049f24 <RBTreeDeleteNode+0x324>
    else if (N == N->parent->left)
        N->parent->left = M;
 804a013:	89 5f 08             	mov    %ebx,0x8(%edi)
 804a016:	e9 09 ff ff ff       	jmp    8049f24 <RBTreeDeleteNode+0x324>
