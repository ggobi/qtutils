
all:
	. createProject.sh
	make -f Makefile.qtutils
	if test -e libqtutils.so; then cp libqtutils.so qtutils.so; fi
	## for macx:
	if test -e libqtutils.dylib; then cp libqtutils.dylib qtutils.so; fi


clean:
	rm -f *.so *.o *.a libqt* qtutils.pro Makefile.qtutils moc*.cpp


