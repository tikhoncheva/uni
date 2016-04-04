# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'mainwindow.ui'
#
# Created: Tue Feb 10 12:51:34 2015
#      by: PyQt4 UI code generator 4.10.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName(_fromUtf8("MainWindow"))
        MainWindow.resize(458, 507)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(5)
        sizePolicy.setVerticalStretch(5)
        sizePolicy.setHeightForWidth(MainWindow.sizePolicy().hasHeightForWidth())
        MainWindow.setSizePolicy(sizePolicy)
        MainWindow.setMaximumSize(QtCore.QSize(600, 700))
        self.centralwidget = QtGui.QWidget(MainWindow)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        self.gridLayout = QtGui.QGridLayout(self.centralwidget)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.labelStart = QtGui.QLabel(self.centralwidget)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.labelStart.sizePolicy().hasHeightForWidth())
        self.labelStart.setSizePolicy(sizePolicy)
        self.labelStart.setObjectName(_fromUtf8("labelStart"))
        self.gridLayout.addWidget(self.labelStart, 0, 1, 1, 1)
        self.groupBox_InitialG = QtGui.QGroupBox(self.centralwidget)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.groupBox_InitialG.sizePolicy().hasHeightForWidth())
        self.groupBox_InitialG.setSizePolicy(sizePolicy)
        self.groupBox_InitialG.setMinimumSize(QtCore.QSize(150, 150))
        self.groupBox_InitialG.setStyleSheet(_fromUtf8("QGroupBox{\n"
"border: 2px solid gray;\n"
"border-radius: 10px;\n"
"padding: 0.8px;\n"
"background: white;\n"
"selection-background-color: darkgray;\n"
"}\n"
"\n"
"QGroupBox::title {\n"
"     subcontrol-origin: margin;\n"
"     subcontrol-position: top center; /* position at the top center */\n"
"     padding: 0 3px;\n"
"    margin-top: 0px;\n"
" }"))
        self.groupBox_InitialG.setObjectName(_fromUtf8("groupBox_InitialG"))
        self.textEdit_nV = QtGui.QTextEdit(self.groupBox_InitialG)
        self.textEdit_nV.setGeometry(QtCore.QRect(60, 30, 61, 21))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.textEdit_nV.sizePolicy().hasHeightForWidth())
        self.textEdit_nV.setSizePolicy(sizePolicy)
        self.textEdit_nV.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_nV.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nV.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nV.setObjectName(_fromUtf8("textEdit_nV"))
        self.label = QtGui.QLabel(self.groupBox_InitialG)
        self.label.setGeometry(QtCore.QRect(10, 30, 41, 21))
        self.label.setObjectName(_fromUtf8("label"))
        self.label_2 = QtGui.QLabel(self.groupBox_InitialG)
        self.label_2.setGeometry(QtCore.QRect(10, 60, 41, 21))
        self.label_2.setObjectName(_fromUtf8("label_2"))
        self.textEdit_nE = QtGui.QTextEdit(self.groupBox_InitialG)
        self.textEdit_nE.setGeometry(QtCore.QRect(60, 60, 61, 21))
        self.textEdit_nE.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_nE.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nE.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nE.setObjectName(_fromUtf8("textEdit_nE"))
        self.pButton_generateG = QtGui.QPushButton(self.groupBox_InitialG)
        self.pButton_generateG.setGeometry(QtCore.QRect(30, 90, 81, 23))
        self.pButton_generateG.setObjectName(_fromUtf8("pButton_generateG"))
        self.pbuttonSave_InitialG = QtGui.QPushButton(self.groupBox_InitialG)
        self.pbuttonSave_InitialG.setGeometry(QtCore.QRect(30, 120, 81, 23))
        self.pbuttonSave_InitialG.setObjectName(_fromUtf8("pbuttonSave_InitialG"))
        self.gridLayout.addWidget(self.groupBox_InitialG, 1, 0, 1, 1)
        self.labelResult = QtGui.QLabel(self.centralwidget)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.labelResult.sizePolicy().hasHeightForWidth())
        self.labelResult.setSizePolicy(sizePolicy)
        self.labelResult.setObjectName(_fromUtf8("labelResult"))
        self.gridLayout.addWidget(self.labelResult, 2, 1, 1, 1)
        self.groupBox_GDrawing = QtGui.QGroupBox(self.centralwidget)
        self.groupBox_GDrawing.setEnabled(True)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.groupBox_GDrawing.sizePolicy().hasHeightForWidth())
        self.groupBox_GDrawing.setSizePolicy(sizePolicy)
        self.groupBox_GDrawing.setMinimumSize(QtCore.QSize(150, 150))
        self.groupBox_GDrawing.setStyleSheet(_fromUtf8("QGroupBox{\n"
"border: 2px solid gray;\n"
"border-radius: 10px;\n"
"padding: 0.8px;\n"
"background: white;\n"
"selection-background-color: darkgray;\n"
"}\n"
"\n"
"QGroupBox::title {\n"
"     subcontrol-origin: margin;\n"
"     subcontrol-position: top center; /* position at the top center */\n"
"     padding: 0 3px;\n"
"    margin-top: 0px;\n"
" }"))
        self.groupBox_GDrawing.setObjectName(_fromUtf8("groupBox_GDrawing"))
        self.pbuttonStart = QtGui.QPushButton(self.groupBox_GDrawing)
        self.pbuttonStart.setEnabled(False)
        self.pbuttonStart.setGeometry(QtCore.QRect(40, 40, 61, 23))
        self.pbuttonStart.setObjectName(_fromUtf8("pbuttonStart"))
        self.pbuttonStep = QtGui.QPushButton(self.groupBox_GDrawing)
        self.pbuttonStep.setEnabled(False)
        self.pbuttonStep.setGeometry(QtCore.QRect(40, 70, 61, 23))
        self.pbuttonStep.setObjectName(_fromUtf8("pbuttonStep"))
        self.pbuttonSave = QtGui.QPushButton(self.groupBox_GDrawing)
        self.pbuttonSave.setEnabled(False)
        self.pbuttonSave.setGeometry(QtCore.QRect(40, 100, 61, 23))
        self.pbuttonSave.setObjectName(_fromUtf8("pbuttonSave"))
        self.gridLayout.addWidget(self.groupBox_GDrawing, 3, 0, 1, 1)
        self.MatplotlibWidget2 = matplotlibWidget(self.centralwidget)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.MatplotlibWidget2.sizePolicy().hasHeightForWidth())
        self.MatplotlibWidget2.setSizePolicy(sizePolicy)
        self.MatplotlibWidget2.setMinimumSize(QtCore.QSize(200, 200))
        self.MatplotlibWidget2.setStyleSheet(_fromUtf8("background-color: rgb(255, 255, 255);"))
        self.MatplotlibWidget2.setObjectName(_fromUtf8("MatplotlibWidget2"))
        self.gridLayout.addWidget(self.MatplotlibWidget2, 3, 1, 1, 1)
        self.MatplotlibWidget1 = matplotlibWidget(self.centralwidget)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.MatplotlibWidget1.sizePolicy().hasHeightForWidth())
        self.MatplotlibWidget1.setSizePolicy(sizePolicy)
        self.MatplotlibWidget1.setMinimumSize(QtCore.QSize(200, 200))
        self.MatplotlibWidget1.setStyleSheet(_fromUtf8("background-color: rgb(255, 255, 255);"))
        self.MatplotlibWidget1.setObjectName(_fromUtf8("MatplotlibWidget1"))
        self.gridLayout.addWidget(self.MatplotlibWidget1, 1, 1, 1, 1)
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtGui.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 458, 20))
        self.menubar.setObjectName(_fromUtf8("menubar"))
        MainWindow.setMenuBar(self.menubar)
        self.toolBar = QtGui.QToolBar(MainWindow)
        self.toolBar.setObjectName(_fromUtf8("toolBar"))
        MainWindow.addToolBar(QtCore.Qt.TopToolBarArea, self.toolBar)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(_translate("MainWindow", "Force-directed graph drawing", None))
        self.labelStart.setText(_translate("MainWindow", "Start", None))
        self.groupBox_InitialG.setTitle(_translate("MainWindow", "Initial graph", None))
        self.textEdit_nV.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">6</p></body></html>", None))
        self.label.setText(_translate("MainWindow", "|V| = ", None))
        self.label_2.setText(_translate("MainWindow", "|E| = ", None))
        self.textEdit_nE.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">7</p></body></html>", None))
        self.pButton_generateG.setText(_translate("MainWindow", "generate", None))
        self.pbuttonSave_InitialG.setText(_translate("MainWindow", "Save img", None))
        self.labelResult.setText(_translate("MainWindow", "Result: Step 0", None))
        self.groupBox_GDrawing.setTitle(_translate("MainWindow", "Draw graph", None))
        self.pbuttonStart.setText(_translate("MainWindow", "Start", None))
        self.pbuttonStep.setText(_translate("MainWindow", "Step", None))
        self.pbuttonSave.setText(_translate("MainWindow", "Save img", None))
        self.toolBar.setWindowTitle(_translate("MainWindow", "toolBar", None))

from matplotlibwidged import matplotlibWidget

if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    MainWindow = QtGui.QMainWindow()
    ui = Ui_MainWindow()
    ui.setupUi(MainWindow)
    MainWindow.show()
    sys.exit(app.exec_())

