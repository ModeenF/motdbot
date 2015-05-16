# compilation flags used under any OS or compiler (may be appended to, below)
CXXFLAGS   += -Imuscle -DMUSCLE_SINGLE_THREAD_ONLY

# compilation flags that are specific to the gcc compiler (hard-coded)
GCCFLAGS    = -g -fno-exceptions -DMUSCLE_NO_EXCEPTIONS -Wall -W -Wno-multichar

# flags to include when compiling the optimized version (with 'make optimized')
CCOPTFLAGS  =

# flags to include when linking (set per operating system, below)
LFLAGS      =

# libraries to include when linking (set per operating system, below)
LIBS        =

# names of the executables to compile
EXECUTABLES = motdbot

# object files to include in all executables
OBJFILES = Message.o AbstractMessageIOGateway.o MessageIOGateway.o String.o AbstractReflectSession.o DataNode.o FilePathInfo.o Directory.o DumbReflectSession.o MiscUtilityFunctions.o StorageReflectSession.o ReflectServer.o SignalHandlerSession.o SignalMultiplexer.o SocketMultiplexer.o StringMatcher.o motdbot.o NetworkUtilityFunctions.o SysLog.o PulseNode.o PathMatcher.o FilterSessionFactory.o RateLimitSessionIOPolicy.o MemoryAllocator.o SetupSystem.o ServerComponent.o ZLibCodec.o ByteBuffer.o QueryFilter.o

# Where to find .cpp files
VPATH = muscle/message muscle/iogateway muscle/reflector muscle/regex muscle/util muscle/syslog muscle/system muscle/zlib muscle/zlib/zlib

# if the OS type variable is unset, try to set it using the uname shell command
ifeq ($(OSTYPE),)
  OSTYPE = $(strip $(shell uname))
endif

# IRIX may report itself as IRIX or as IRIX64.  They are both the same to us.
ifeq ($(OSTYPE),IRIX64)
  OSTYPE = IRIX
endif

ifeq ($(OSTYPE),beos)
  ifeq ($(BE_HOST_CPU),ppc)
    CXX = mwcc
    OBJFILES += regcomp.o regerror.o regexec.o regfree.o
    VPATH += ../regex/regex
    CFLAGS += -I../regex/regex
  else # not ppc
    CXXFLAGS += $(GCCFLAGS) $(CCOPTFLAGS)
    LIBS = -lbe -lnet -lroot
    ifeq ($(shell ls 2>/dev/null -1 /boot/develop/headers/be/bone/bone_api.h), /boot/develop/headers/be/bone/bone_api.h)
      CXXFLAGS += -I/boot/develop/headers/be/bone -DBONE
      LIBS = -nodefaultlibs -lbind -lsocket -lbe -lroot -L/boot/beos/system/lib
    endif
  endif # END ifeq ($(BE_HOST_CPU),ppc)
else # not beos
  CXXFLAGS += $(GCCFLAGS) $(CCOPTFLAGS)
endif

ifeq ($(OSTYPE),freebsd4.0)
  CXXFLAGS += -I/usr/include/machine
endif

ifeq ($(OSTYPE),darwin)
  CXX = c++
  CXXFLAGS += -I/usr/include/machine
endif

ifeq ($(OSTYPE),IRIX)
  CXXFLAGS += -DSGI -DMIPS
  ifneq (,$(findstring g++,$(CXX))) # if we are using SGI's CC compiler, we gotta change a few things
    CXX = CC
    CCFLAGS = -g2 -n32 -LANG:std -woff 1110,1174,1552,1460,3303
    LFLAGS  = -g2 -n32
    CXXFLAGS += -DNEW_H_NOT_AVAILABLE
  endif # END ifneq (,$(findstring g++,$(CXX)))
endif

ifneq (,$(findstring MINGW32,$(OSTYPE)))
  OSTYPE=MINGW
endif

ifneq (,$(findstring MINGW64,$(OSTYPE)))
  OSTYPE=MINGW
endif

ifeq ($(OSTYPE),MINGW)
  CC = gcc
  ARCH = $(shell gcc -dumpmachine | sed 's/-.*//g')
  ifeq ($(ARCH),x86_64)
    CXXFLAGS += -m64 -D__MINGW64__ -I/mingw64/x86_64-w64-mingw32/include
    LFLAGS = -L/mingw64/x86_64-w64-mingw32/lib -L/lib
    LIBS = -lregex -lws2_32 -lwinmm -liphlpapi -lmingwex -lmsvcrt
  else
    OBJFILES += regcomp.o regerror.o regexec.o regfree.o
    VPATH += muscle/regex/regex
    CXXFLAGS += -m32 -D__MINGW32__ -DMUSCLE_AVOID_IPV6 -D_WIN32_WINNT=0x0501 -I/mingw32/i686-w64-mingw32/include
    CFLAGS += -Imuscle/regex/regex
    LFLAGS = -L/mingw32/i686-w64-mingw32/lib -L/lib
    LIBS = -lws2_32 -lwinmm -liphlpapi -lmingwex -lmsvcrt
  endif
endif

# Makes all the programs that can be made using just cross-platform code
all : $(EXECUTABLES)

optimized : CCOPTFLAGS = -O3
optimized : all

motdbot : $(OBJFILES)
	$(CXX) $(LFLAGS) -o $@ $^ $(LIBS)

clean :
	rm -f *.o *.xSYM $(EXECUTABLES)
