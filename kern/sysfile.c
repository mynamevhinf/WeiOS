#include <include/types.h>
#include <include/param.h>
#include <include/log.h>
#include <include/file.h>
#include <include/proc.h>
#include <include/stdio.h>
#include <include/string.h>
#include <include/sysfile.h>

// fd[0] for read, fd[1] for write.
int pipe(int fd[2])
{
	int i;
	int fd1, fd2;

	if ((NOFILE - curproc->n_opfiles) < 2)
		return -1;

	for (i = 0; i < NOFILE; i++)
		if (curproc->open_file_table[i])
			break;
	fd1 = i;

	for (i += 1; i < NOFILE; i++)
		if (curproc->open_file_table[i])
			break;
	fd2 = i;

	if (pipe_alloc(&(curproc->open_file_table[fd1]), 
					&(curproc->open_file_table[fd2])) < 0)
		return -1;

	fd[0] = fd1;
	fd[1] = fd2;
	return 0;
}

static int fd_alloc(void)
{
	int fd;

	if (curproc->n_opfiles == NOFILE)
		return -1;

	for (fd = 0; fd < NOFILE; fd++)
		if (curproc->open_file_table[fd] == 0)
			return fd;
	return -1;
}

static inline int is_bad_fd(int fd)
{
	if (fd < 0 || fd >= NOFILE)
		return 1;
	return 0;
}

int dup(int fd)
{
	int fd2;

	if (is_bad_fd(fd))
		return -1;
	if (!(curproc->open_file_table[fd]) || (curproc->n_opfiles == NOFILE))
		return -1;
	if ((fd2 = fd_alloc()) < 0)
		return -1;
	curproc->open_file_table[fd2] = file_dup(curproc->open_file_table[fd]);
	curproc->n_opfiles++;
	return fd2;
}

int dup2(int oldfd, int newfd)
{
	struct file *f1, *f2;

	if (is_bad_fd(oldfd) || is_bad_fd(newfd))
		return -1;

	if (oldfd == newfd)
		return newfd;
	if (curproc->open_file_table[newfd]) {
		file_close(curproc->open_file_table[newfd]);
		curproc->n_opfiles--;
	}

	curproc->open_file_table[newfd] = curproc->open_file_table[oldfd];
	if (curproc->open_file_table[oldfd]) {
		file_dup(curproc->open_file_table[oldfd]);
		curproc->n_opfiles++;
	}
	return 0;
}

int read(int fd, char *des, uint32_t nbytes)
{
	if (is_bad_fd(fd) || !des)
		return -1;
	return file_read(curproc->open_file_table[fd], des, nbytes);
}

int write(int fd, char *src, uint32_t nbytes)
{
	if (is_bad_fd(fd) || !src)
		return -1;
	return file_write(curproc->open_file_table[fd], src, nbytes);
}

int close(int fd)
{
	struct file *f;

	if (is_bad_fd(fd))
		return -1;
	f = curproc->open_file_table[fd];
	if (f) {
		file_close(f);
		curproc->n_opfiles--;
	}
	curproc->open_file_table[fd] = 0;
	return 0;
}

int fstat(int fd, struct stat *sbuf)
{
	struct file *f;

	if (is_bad_fd(fd))
		return -1;
	f = curproc->open_file_table[fd];
	return file_stat(f, sbuf);
}

int link(char *oldpname, char *newpname)
{
	char name[DIRSIZ];
	struct inode *di, *i;

	begin_transaction();
	if (!(i = namei(oldpname))) {
		end_transaction();
		return -1;
	}

	ilock(i);
	if (i->type == T_DIR)
		goto link_bad;

	i->nlink++;
	iupdate(i);
	iunlock(i);

	if (!(di = namep(newpname, name))) 
		goto link_err;
	ilock(di);
	if ((i->dev != di->dev) || dirlink(di, name, i->ino) < 0) {
		iunlockput(di);
		goto link_err;
	}
	//di->file_siz += sizeof(struct dirent);
	iupdate(di);

	iput(i);
	iunlockput(di);
	end_transaction();
	return 0;

link_err:
	ilock(i);
	i->nlink--;
	iupdate(i);
link_bad:
	iunlockput(i);
	end_transaction();
	return -1;	

}

// only "." and ".."?
static inline int is_dir_empty(struct inode *i)
{
	struct dirent direntry;

	for (uint offset = 0; offset < i->file_siz; offset += sizeof(struct dirent)) {
		if (readi(i, (char *)&direntry, offset, sizeof(struct dirent)) < 0)
			panic("is_dir_empty(): error occurs when reading inode.\n");
		if (direntry.ino == 0)
			continue;
		if (strcmp(direntry.name, "..") && strcmp(direntry.name, "."))
			return 0;
	}
	return 1;
}

int unlink(char *pathname)
{
	int offset, size;
	char name[DIRSIZ];
	struct dirent dentry; 
	struct inode *di, *i;

	begin_transaction();
	if (!(di = namep(pathname, name))) {
		end_transaction();
		return -1;
	}

	ilock(di);
	if (dirlookup(di, name, &i, &offset) < 0) {
		iunlockput(di);
		end_transaction();
		return -1;
	}
	size = sizeof(struct dirent);

	ilock(i);
	if (i->type == T_DIR) {
		if (!is_dir_empty(i)) {
			iunlockput(i);
			iunlockput(di);
			end_transaction();
			return -1;
		}
		di->nlink--;
	}

	memset(&dentry, 0, size);
	if (writei(di, (char *)(&dentry), offset, size) != size)
		panic("unlink: system error!!!\n");

	//di->file_siz -= size;
	iupdate(di);
	iunlockput(di);
	i->nlink--;
	iupdate(i);
	iunlockput(i);

	end_transaction();
	return 0;
}

// In fact, i don't care about major, minor at all.
static struct inode *creat(char *pathname, ushort type, ushort major, ushort minor)
{
	char name[DIRSIZ];
	struct inode *i, *di;

	// parent dir does not exist!!!
	if (!(di = namep(pathname, name)))
		return 0;
	ilock(di);

	// we have found it, no need to create
	if (dirlookup(di, name, &i, 0) >= 0) {
		iunlockput(di);
		ilock(i);
		if ((i->type == type) && (i->type == T_FILE))
			return i;
		// we have to delete it.
		iunlockput(i);
		return 0;
	}

	if (!(i = ialloc(di->dev, type)))
		panic("creat: can not create a new in-memory inode!!!\n");

	ilock(i);
	i->major = major;
	i->minor = minor;
	i->nlink = 1;
	iupdate(i);
	if (type == T_DIR) {
		if (dirlink(i, ".", i->ino) < 0 || dirlink(i, "..", di->ino) < 0) {
			iunlockput(i);
			return 0;
		}
		di->nlink++;	// i->".." = di
		iupdate(di);
	}

	if (dirlink(di, name, i->ino) < 0)
		panic("creat(): system broken down!!!\n");

	iunlockput(di);
	return i;
}

int mknod(char *pathname, ushort major, ushort minor)
{
	struct inode *i;

	begin_transaction();
	if (!(i = creat(pathname, T_DEV, major, minor))) {
		end_transaction();
		return -1;
	}
	iunlockput(i);
	end_transaction();
	return 0;
}

// O_RDONLY, O_WRONLY and O_RDWR can not be used At the same time
int open(char *pathname, int flag)
{
	int fd, exclus;
	struct file *f;
	struct inode *i;

	// check if O_RDONLY, O_WRONLY and O_RDWR 
	// used At the same time or not.
 	exclus = (flag & O_RDONLY);
	exclus += ((((flag & O_WRONLY)) >> 1) + ((flag & O_RDWR) >> 2));
	if (exclus > 1)
		return -1;

	begin_transaction();
	if (flag & O_CREAT) {
		if (!(i = creat(pathname, T_FILE, 0, 0)))
			goto open_failure2;
	} else {
		if (!(i = namei(pathname)))
			goto open_failure2;
		ilock(i);
		if ((i->type == T_DIR) && !(flag & O_RDONLY))
			goto open_failure;
	}

	if ((fd = fd_alloc()) < 0)
		goto open_failure;
	if (!(f = file_alloc()))
		goto open_failure;

	// we have no need to read or write data.
	iunlock(i);
	end_transaction();
	f->inode = i;
	f->type = i->type;
	f->offset = 0;
	f->flag |= flag;

	curproc->open_file_table[fd] = f;
	curproc->n_opfiles++;
	return fd;

open_failure:
	iunlockput(i);
open_failure2:
	end_transaction();
	return -1;
}

int mkdir(char *pathname)
{
	struct inode *i;

	begin_transaction();
	if (!(i = creat(pathname, T_DIR, 0, 0))) {
		end_transaction();
		return -1;
	}

	iunlockput(i);
	end_transaction();
	return 0;
}

int chdir(char *pathname)
{
	struct inode *i;

	begin_transaction();
	if (!(i = namei(pathname))) {
		end_transaction();
		return -1;
	}

	ilock(i);
	if (i->type != T_DIR) {
		iunlockput(i);
		end_transaction();
		prink("%s is not a directory!!!\n", pathname);
		return -1;
	}
	iunlock(i);
	iput(curproc->pwd);
	curproc->pwd = i;
	end_transaction();

	return 0;
}

int ls_test(const char *str)
{
	int cnt = 1;
	struct dirent direntry;
	
	ilock(curproc->pwd);
	prink("\t");
	for (uint offset = 0; offset < curproc->pwd->file_siz; offset += sizeof(struct dirent)) {
		if (readi(curproc->pwd, (char *)&direntry, offset, sizeof(struct dirent)) < 0)
			panic("is_dir_empty(): error occurs when reading inode.\n");
		if (direntry.ino == 0) 
			continue;
		if (strcmp(direntry.name, "..") == 0
			 || strcmp(direntry.name, ".") == 0)
			continue;
		if (!(cnt++ % 9))
			prink("\n\t");		
		prink("%s\t", direntry.name);
	}
	prink("\n");
	iunlock(curproc->pwd);
	return 0;
}