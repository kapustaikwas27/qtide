
VERSION = 1.4.1
JDLLVER = 8.0.4    # ignored if not FHS

# DEFINES += BIGENDIAN # uncomment this line for ppc mac
# DEFINES += TABCOMPLETION # uncomment this line for tab completion

DEFINES += QTWEBSOCKET  # comment this line if QtWebsocket is unwanted

greaterThan(QT_VERSION,4.7.0): DEFINES += QT47
greaterThan(QT_VERSION,4.8.0): DEFINES += QT48
equals(QT_MAJOR_VERSION, 5): DEFINES += QT50
!lessThan(QT_VERSION,5.3.0): DEFINES += QT53
!lessThan(QT_VERSION,5.4.0): DEFINES += QT54

android  {
  !contains(DEFINES,QT50): error(requires Qt5)
  CONFIG += mobility
  MOBILITY +=
  QT += androidextras
  QT += opengl
  DEFINES += QT_OS_ANDROID
  DEFINES += QT_NO_PRINTER
  DEFINES += SMALL_SCREEN
  TEMPLATE = lib
  TARGET = jqt
} else {
  TEMPLATE = lib
  contains(DEFINES,QT54) {
    QT += webkit
  } else {
    QT += webkit
    QT += opengl
  }
  TARGET = jqt
}

contains(DEFINES,QT47): QT += declarative
contains(DEFINES,QT50): QT -= declarative
contains(DEFINES,QT53) {
  QT += quick quickwidgets
} else {
  QT -= quick quickwidgets
}

# to exclude QtWebKit QtWebEngine, uncomment the following line
# QT -= webkit webengine
# (pre QT54) to exclude OpenGL, uncomment the following line
# QT -= opengl

# pre QT50
# to exclude quickview1, uncomment the following line
# QT -= declarative

# QT5 or later
# to exclude quickview2 and quickview, uncomment the following line
# QT -= quick quickwidgets

contains(DEFINES,QT50) {
  QT +=  multimedia
} else {
  QT -=  multimedia
}

# export JQTSLIM before qmake
JQTSLIM = $$(JQTSLIM)
!isEmpty(JQTSLIM) {
  message(building slim jqt)
  QT -= declarative multimedia multimediawidgets opengl quick qml quickwidgets webkit webkitwidgets webengine webenginewidgets
  DEFINES -= QTWEBSOCKET
}

# export JQTRASPI before qmake
JQTRASPI = $$(JQTRASPI)
!isEmpty(JQTRASPI) {
  message(building raspi jqt)
  QT -= declarative multimedia multimediawidgets opengl quick qml quickwidgets webkit webkitwidgets webengine webenginewidgets
}

CONFIG(debug, debug|release) {
  rel = debug
} else {
  rel = release
}

contains(DEFINES,QTWEBSOCKET): contains(DEFINES,QT53): QT += websockets
contains(DEFINES,QTWEBSOCKET): !contains(DEFINES,QT53): QT += network

linux-g++: QMAKE_TARGET.arch = $$QMAKE_HOST.arch
linux-g++-32: QMAKE_TARGET.arch = x86
linux-g++-64: QMAKE_TARGET.arch = x86_64
linux-cross: QMAKE_TARGET.arch = x86
win32-cross-32: QMAKE_TARGET.arch = x86
win32-cross: QMAKE_TARGET.arch = x86_64
win32-g++: QMAKE_TARGET.arch = $$QMAKE_HOST.arch
win32-msvc*: QMAKE_TARGET.arch = $$QMAKE_HOST.arch
android: QMAKE_TARGET.arch = armeabi
linux-raspi: QMAKE_TARGET.arch = arm

equals(QMAKE_TARGET.arch , i686): QMAKE_TARGET.arch = x86
ABI=$$(ABI)
android {
!isEmpty(ABI): QMAKE_TARGET.arch = $$ABI
}

win32: arch = win-$$QMAKE_TARGET.arch
android: arch = android-$$QMAKE_TARGET.arch
macx: arch = mac-$$QMAKE_TARGET.arch
unix:!macx: arch = linux-$$QMAKE_TARGET.arch
android: arch = android-$$QMAKE_TARGET.arch

BUILDROOT = build/$$arch/$$rel
TARGETROOT = ../bin/$$arch/$$rel
DESTDIR = $$TARGETROOT
DLLDESTDIR = $$TARGETROOT

OBJECTS_DIR = $$BUILDROOT/obj
MOC_DIR = $$BUILDROOT/moc
RCC_DIR = $$BUILDROOT/rcc
UI_DIR = $$BUILDROOT/ui

linux-raspi: DEFINES += RASPI
DEFINES += JDLLVER=\\\"$$JDLLVER\\\"

win32:CONFIG += dll console
win32-msvc*:DEFINES += _CRT_SECURE_NO_WARNINGS
equals(QT_MAJOR_VERSION, 5): QT += widgets
equals(QT_MAJOR_VERSION, 5):!android: QT += printsupport
CONFIG+= release
DEPENDPATH += .
INCLUDEPATH += .

DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += "JQT"

contains(QT,webengine): !contains(DEFINES,QT54):  error(webengine requires QT54)
!contains(QT,webkit) {
  DEFINES += QT_NO_WEBKIT
  DEFINES -= QT_WEBKIT
} else {
  equals(QT_MAJOR_VERSION, 5) QT += webkitwidgets
  DEFINES -= QT_NO_WEBKIT
  DEFINES += QT_WEBKIT
}
!contains(QT,webengine) {
  DEFINES += QT_NO_WEBENGINE
  DEFINES -= QT_WEBENGINE
} else {
  QT += webenginewidgets
  DEFINES -= QT_NO_WEBENGINE
  DEFINES += QT_WEBENGINE
}

contains(DEFINES,QT54) {
  android: DEFINES += QT_OPENGL_ES_2
  DEFINES -= QT_NO_OPENGL
  DEFINES += QT_OPENGL
} else {
!contains(QT,opengl) {
  DEFINES += QT_NO_OPENGL
  DEFINES -= QT_OPENGL
} else {
  android: DEFINES += QT_OPENGL_ES_2
  DEFINES -= QT_NO_OPENGL
  DEFINES += QT_OPENGL
}
}

contains(DEFINES,QT50) {

# QT50 or later
  !contains(QT,quick) {
    DEFINES += QT_NO_QUICKVIEW2
    DEFINES -= QT_QUICKVIEW2
    QT -= quickwidgets
  } else {
    DEFINES -= QT_NO_QUICKVIEW2
    DEFINES += QT_QUICKVIEW2
  }

  !contains(QT,declarative) {
    DEFINES += QT_NO_QUICKVIEW1
    DEFINES -= QT_QUICKVIEW1
  } else {
    DEFINES -= QT_NO_QUICKVIEW1
    DEFINES += QT_QUICKVIEW1
  }

} else {
  DEFINES += QT_NO_QUICKVIEW2
  DEFINES -= QT_QUICKVIEW2
# pre QT50
  !contains(QT,declarative) {
    DEFINES += QT_NO_QUICKVIEW1
    DEFINES -= QT_QUICKVIEW1
  } else {
    DEFINES -= QT_NO_QUICKVIEW1
    DEFINES += QT_QUICKVIEW1
  }

}

!contains(QT,quickwidgets) {
  DEFINES += QT_NO_QUICKWIDGET
  DEFINES -= QT_QUICKWIDGET
} else {
  DEFINES -= QT_NO_QUICKWIDGET
  DEFINES += QT_QUICKWIDGET
}

!contains(QT,multimedia) {
  QT -=  multimediawidgets
  DEFINES += QT_NO_MULTIMEDIA
  DEFINES -= QT_MULTIMEDIA
} else {
  contains(DEFINES,QT54) QT +=  multimediawidgets
  DEFINES -= QT_NO_MULTIMEDIA
  DEFINES += QT_MULTIMEDIA
}

# Input
HEADERS += \
 base/base.h base/bedit.h base/comp.h base/dialog.h base/dirm.h base/dlog.h \
 base/fif.h base/fiw.h base/jsvr.h base/menu.h \
 base/nedit.h base/nmain.h base/note.h base/nside.h base/ntabs.h \
 base/plaintextedit.h base/pcombobox.h \
 base/pnew.h base/proj.h base/psel.h base/qmlje.h base/recent.h base/rsel.h \
 base/snap.h base/spic.h base/state.h base/style.h base/svr.h \
 base/tedit.h base/term.h base/util.h base/utils.h \
 base/view.h base/widget.h high/high.h high/highj.h \
 grid/qgrid.h grid/qutil.h grid/wgrid.h \
 wd/bitmap.h wd/button.h wd/child.h wd/clipboard.h wd/cmd.h \
 wd/checkbox.h wd/combobox.h wd/dateedit.h wd/dial.h wd/dspinbox.h wd/dummy.h \
 wd/edit.h wd/editm.h wd/edith.h wd/font.h wd/form.h \
 wd/gl2.h wd/glz.h wd/prtobj.h wd/image.h \
 wd/isidraw.h wd/isigraph.h wd/isigraph2.h wd/isigrid.h \
 wd/layout.h wd/lineedit.h wd/listbox.h \
 wd/menus.h wd/pane.h wd/progressbar.h wd/qtstate.h wd/radiobutton.h \
 wd/slider.h wd/spinbox.h wd/static.h wd/statusbar.h wd/table.h \
 wd/tabs.h wd/tabwidget.h \
 wd/timeedit.h wd/toolbar.h wd/wd.h \
 wd/ogl2.h wd/opengl.h wd/opengl2.h \
 wd/webview.h wd/webengine.h wd/webkitview.h wd/webengineview.h wd/quickview1.h wd/quickview2.h wd/quickwidget.h \
 wd/qwidget.h wd/scrollarea.h wd/scrollbar.h wd/gl2class.h wd/drawobj.h wd/glc.h wd/webviewclass.h wd/webviewclass2.h \
 wd/multimedia.h

contains(DEFINES,QT_NO_OPENGL): HEADERS -= wd/ogl2.h wd/opengl.h wd/opengl2.h
!contains(QT,webkit): HEADERS -= wd/webview.h wd/webkitview.h
!contains(QT,webengine): HEADERS -= wd/webengine.h wd/webengineview.h
contains(DEFINES,QT50) {
  !contains(QT,quick): HEADERS -= wd/quickview2.h
  !contains(QT,declarative): HEADERS -= wd/quickview1.h
  !contains(QT,quick): !contains(QT,declarative): HEADERS -= base/qmlje.h
} else {
  !contains(QT,declarative): HEADERS -= wd/quickview1.h wd/quickview2.h base/qmlje.h
  HEADERS -= wd/quickview2.h
}
!contains(QT,quickwidgets): HEADERS -= wd/quickwidget.h
contains(DEFINES,QT_NO_MULTIMEDIA): HEADERS -= wd/multimedia.h
contains(DEFINES,QT_NO_PRINTER): HEADERS -= wd/glz.h wd/prtobj.h
contains(DEFINES,QTWEBSOCKET): !contains(DEFINES,QT53): HEADERS += QtWebsocket/compat.h QtWebsocket/QWsServer.h QtWebsocket/QWsSocket.h QtWebsocket/QWsHandshake.h QtWebsocket/QWsFrame.h QtWebsocket/QTlsServer.h QtWebsocket/functions.h QtWebsocket/WsEnums.h
contains(DEFINES,QTWEBSOCKET): HEADERS += base/wssvr.h base/wscln.h
android:HEADERS += base/androidextras.h base/qtjni.h

SOURCES += \
 base/comp.cpp base/bedit.cpp base/dialog.cpp \
 base/dirm.cpp base/dirmx.cpp base/dlog.cpp \
 base/fif.cpp base/fifx.cpp base/fiw.cpp base/jsvr.cpp \
 base/menu.cpp base/menuhelp.cpp \
 base/nedit.cpp base/nmain.cpp base/note.cpp base/nside.cpp base/ntabs.cpp \
 base/plaintextedit.cpp base/pcombobox.cpp \
 base/pnew.cpp base/proj.cpp base/psel.cpp base/qmlje.cpp \
 base/recent.cpp base/rsel.cpp base/run.cpp \
 base/snap.cpp base/spic.cpp base/state.cpp base/statex.cpp \
 base/style.cpp base/svr.cpp base/tedit.cpp base/term.cpp \
 base/userkeys.cpp base/util.cpp base/utils.cpp base/view.cpp base/widget.cpp \
 grid/cell.cpp grid/cubedata.cpp grid/cubedraw.cpp grid/cubewidget.cpp \
 grid/defs.cpp grid/draw.cpp grid/header.cpp grid/hierdraw.cpp \
 grid/hierwidget.cpp grid/label.cpp grid/qgrid.cpp grid/qutil.cpp \
 grid/sizes.cpp grid/top.cpp grid/wgrid.cpp high/highj.cpp \
 wd/bitmap.cpp wd/button.cpp wd/child.cpp wd/clipboard.cpp wd/cmd.cpp \
 wd/checkbox.cpp wd/combobox.cpp wd/dateedit.cpp wd/dial.cpp wd/dspinbox.cpp wd/dummy.cpp \
 wd/edit.cpp wd/editm.cpp wd/edith.cpp wd/font.cpp \
 wd/form.cpp wd/gl2.cpp wd/glz.cpp wd/prtobj.cpp wd/image.cpp  \
 wd/isidraw.cpp wd/isigraph.cpp wd/isigraph2.cpp wd/isigrid.cpp \
 wd/layout.cpp wd/lineedit.cpp wd/listbox.cpp wd/mb.cpp \
 wd/menus.cpp wd/pane.cpp wd/progressbar.cpp wd/qtstate.cpp wd/radiobutton.cpp \
 wd/slider.cpp wd/sm.cpp wd/spinbox.cpp wd/static.cpp wd/statusbar.cpp \
 wd/table.cpp wd/tabs.cpp wd/tabwidget.cpp \
 wd/timeedit.cpp wd/toolbar.cpp wd/wd.cpp \
 wd/ogl2.cpp wd/opengl.cpp wd/opengl2.cpp \
 wd/webview.cpp wd/webengine.cpp wd/webkitview.cpp wd/webengineview.cpp wd/quickview1.cpp wd/quickview2.cpp wd/quickwidget.cpp \
 wd/qwidget.cpp wd/scrollarea.cpp wd/scrollbar.cpp wd/drawobj.cpp wd/glc.cpp \
 wd/multimedia.cpp

contains(DEFINES,QT_NO_OPENGL): SOURCES -= wd/ogl2.cpp wd/opengl.cpp wd/opengl2.cpp
!contains(QT,webkit): SOURCES -= wd/webview.cpp wd/webkitview.cpp
!contains(QT,webengine): SOURCES -= wd/webengine.cpp wd/webengineview.cpp
contains(DEFINES,QT50) {
  !contains(QT,quick): SOURCES -= wd/quickview2.cpp
  !contains(QT,declarative): SOURCES -= wd/quickview1.cpp
  !contains(QT,quick): !contains(QT,declarative): SOURCES -= base/qmlje.cpp
} else {
  !contains(QT,declarative): SOURCES -= wd/quickview1.cpp wd/quickview2.cpp base/qmlje.cpp
  SOURCES -= wd/quickview2.cpp
}
!contains(QT,quickwidgets): SOURCES -= wd/quickwidget.cpp
contains(DEFINES,QT_NO_MULTIMEDIA): SOURCES -= wd/multimedia.cpp
contains(DEFINES,QT_NO_PRINTER ): SOURCES -= wd/glz.cpp wd/prtobj.cpp
contains(DEFINES,QTWEBSOCKET): !contains(DEFINES,QT53): SOURCES += QtWebsocket/QWsServer.cpp QtWebsocket/QWsSocket.cpp QtWebsocket/QWsHandshake.cpp QtWebsocket/QWsFrame.cpp QtWebsocket/QTlsServer.cpp QtWebsocket/functions.cpp
contains(DEFINES,QTWEBSOCKET): SOURCES += base/wssvr.cpp base/wscln.cpp wd/ws.cpp
android:SOURCES += base/androidextras.cpp base/qtjni.cpp ../main/main.cpp

RESOURCES += lib.qrc

win32:!win32-msvc*:LIBS += -shared
win32-msvc*:LIBS += /DLL
unix:LIBS += -ldl
android:LIBS += -ldl

win32:!win32-msvc*:QMAKE_LFLAGS += -static-libgcc
win32-msvc*:QMAKE_LFLAGS +=
macx:QMAKE_CXXFLAGS_WARN_ON += -Wno-unused-private-field
