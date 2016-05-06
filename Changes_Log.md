
# S0AndS0's Change Log 05(May)/05/2016
 - Line 1 : changed `/bin/sh` to `/bin/bash` to allow for easier editing

 - Lines 2-22 : Added checks to prevent running with `sudo` or `root` level permissions

 - Line 12 : Added auto calucating CPU count and assigning related value to global `make` variable, this allowed my system to compile and install ffmpeg in around two hours; not bad for a RPi.

 - Line 13 : Added archetecture check/assignment to allow for PiCAST to compile on non-armel ARM CPU's, this maybe or may not be a good idea as there are systems that will report hardfloat when thier really softfloat point devices.

 - Lines 20-21 : Moved creation of `~/PiCAST` dir to allow for writing error logs there. These will include system info minux identifying info such as serial number of processer such that they can be shared with GitHub easily.

 - Lines 23-46 : Added custom error logger that gets triggered when setain scripted processes fail spactaculaly.

 - Line 49 : combined apt-get update & upgrade to one line, because it really doesn't effect readablilaty that much.

 - Lind 51, 58-60 & 67-69 : Added error handler call if apt-get or source install commands fail. These can be removed or more maybe added if other commands show a prefferance towards faulure.

 - Lines 70-74 : Added `ffmpeg` checks to ensure that it can atleast print it's own version info without erroring

 - Lines 80-84 : Added checks for /var/run/forever` directory and commands to make this path with permissive enough permissions for `forever` to write log files to. This should fix the following error

```bash
Error: ENOENT, no such file or directory '/var/run/forever/CoJV.log'
```

 - Lines 99-127 : Replaced old `read` command with `if then` checks with a Bash hack that should fix Linux Mint issues

```bash
setup.sh: 63: read: Illegal option -n
setup.sh: 65: setup.sh: [[: not found
```

 - Lines 109-110 : Prepended `sudo` to allow downloading Daemon file for PiCAST to restictive write permissions directory. This should fix the following errors

```bash
[Yy/nN]: Do you want to start PiCAST automatically on system boot? y
Downloading PiCAST Daemon file to: /etc/init.d...
--2016-05-05 17:30:24--  https://raw.githubusercontent.com/lanceseidman/PiCAST/master/picast_daemon
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 199.27.76.133
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|199.27.76.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 360 [text/plain]
picast_daemon: Permission denied

Cannot write to picast_daemon (Permission denied).
mv: cannot stat picast_daemon: No such file or directory
chown: cannot access picast: No such file or directory
chmod: cannot access picast: No such file or directory
update-rc.d: error: initscript does not exist: /etc/init.d/picast
```

 - Lines 47-138 : Encapsulated each section of installation process inside it's own custom functions

 - Lines 140-146 : Added required function calls in proper order.


