
if test -z "${QMAKE}" ; then
	if test -f /usr/bin/qmake-qt4; then
		QMAKE=qmake-qt4
	else
		QMAKE=qmake
	fi
fi

## REMEMBER: any changes below should also be applied to
## qtutils.pro.win

echo "

## NOTE: autogenerated by createProject.sh -- do not modify!!

TEMPLATE = lib

# Input

HEADERS += RSyntaxHighlighter.h editor.h
HEADERS += scenedevice.hpp devhelpers.hpp

SOURCES += init.c imports.cpp 
SOURCES += RSyntaxHighlighter.cpp editor.cpp 
SOURCES += scenedevice.cpp devhelpers.cpp

INCLUDEPATH += ${R_INCLUDE_DIR}
INCLUDEPATH += ${CLINK_CPPFLAGS/-I/}


#CFLAGS += -g
#CPPFLAGS += ${CLINK_CPPFLAGS}

## LIBS += -L${R_HOME/lib}


macx{
LIBS += -framework R
}
unix{
LIBS += -L${R_HOME}/lib -lR
}
win32{
LIBS += -L${R_HOME}/bin -lR
}

" > qtutils.pro

if test `uname` == "Darwin" ; then
    ${QMAKE} -spec macx-g++ -o Makefile.qtutils
else 
    ${QMAKE} -o Makefile.qtutils
fi

## if macx; do 
##     ${QMAKE} -spec macx-g++ -o Makefile.qtutils
## else



