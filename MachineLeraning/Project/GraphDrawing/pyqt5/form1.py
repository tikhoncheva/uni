# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'mainwindow.ui'
#
# Created: Fri Feb  6 11:17:44 2015
#      by: PyQt5 UI code generator 5.2.1
#
# WARNING! All changes made in this file will be lost!

from PyQt5 import QtCore, QtGui, QtWidgets

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(430, 486)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Preferred, QtWidgets.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(5)
        sizePolicy.setVerticalStretch(5)
        sizePolicy.setHeightForWidth(MainWindow.sizePolicy().hasHeightForWidth())
        MainWindow.setSizePolicy(sizePolicy)
        MainWindow.setMaximumSize(QtCore.QSize(600, 700))
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.gridLayout = QtWidgets.QGridLayout(self.centralwidget)
        self.gridLayout.setObjectName("gridLayout")
        self.labelResult_2 = QtWidgets.QLabel(self.centralwidget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.labelResult_2.sizePolicy().hasHeightForWidth())
        self.labelResult_2.setSizePolicy(sizePolicy)
        self.labelResult_2.setObjectName("labelResult_2")
        self.gridLayout.addWidget(self.labelResult_2, 0, 1, 1, 1)
        self.groupBox_InitialG = QtWidgets.QGroupBox(self.centralwidget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.groupBox_InitialG.sizePolicy().hasHeightForWidth())
        self.groupBox_InitialG.setSizePolicy(sizePolicy)
        self.groupBox_InitialG.setMinimumSize(QtCore.QSize(150, 150))
        self.groupBox_InitialG.setStyleSheet("QGroupBox{\n"
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
"    margin-top: 2px;\n"
" }")
        self.groupBox_InitialG.setObjectName("groupBox_InitialG")
        self.textEdit_nV = QtWidgets.QTextEdit(self.groupBox_InitialG)
        self.textEdit_nV.setGeometry(QtCore.QRect(60, 30, 61, 21))
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.textEdit_nV.sizePolicy().hasHeightForWidth())
        self.textEdit_nV.setSizePolicy(sizePolicy)
        self.textEdit_nV.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_nV.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nV.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nV.setObjectName("textEdit_nV")
        self.label = QtWidgets.QLabel(self.groupBox_InitialG)
        self.label.setGeometry(QtCore.QRect(10, 30, 41, 21))
        self.label.setObjectName("label")
        self.label_2 = QtWidgets.QLabel(self.groupBox_InitialG)
        self.label_2.setGeometry(QtCore.QRect(10, 60, 41, 21))
        self.label_2.setObjectName("label_2")
        self.textEdit_nE = QtWidgets.QTextEdit(self.groupBox_InitialG)
        self.textEdit_nE.setGeometry(QtCore.QRect(60, 60, 61, 21))
        self.textEdit_nE.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_nE.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nE.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nE.setObjectName("textEdit_nE")
        self.pButton_generateG = QtWidgets.QPushButton(self.groupBox_InitialG)
        self.pButton_generateG.setGeometry(QtCore.QRect(30, 100, 81, 23))
        self.pButton_generateG.setObjectName("pButton_generateG")
        self.gridLayout.addWidget(self.groupBox_InitialG, 1, 0, 1, 1)
        self.MatplotlibWidget1 = QtWidgets.QWidget(self.centralwidget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.MatplotlibWidget1.sizePolicy().hasHeightForWidth())
        self.MatplotlibWidget1.setSizePolicy(sizePolicy)
        self.MatplotlibWidget1.setMinimumSize(QtCore.QSize(200, 200))
        self.MatplotlibWidget1.setStyleSheet("background-color: rgb(255, 255, 255);")
        self.MatplotlibWidget1.setObjectName("MatplotlibWidget1")
        self.gridLayout.addWidget(self.MatplotlibWidget1, 1, 1, 1, 1)
        self.labelResult = QtWidgets.QLabel(self.centralwidget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.labelResult.sizePolicy().hasHeightForWidth())
        self.labelResult.setSizePolicy(sizePolicy)
        self.labelResult.setObjectName("labelResult")
        self.gridLayout.addWidget(self.labelResult, 2, 1, 1, 1)
        self.groupBox_GDrawing = QtWidgets.QGroupBox(self.centralwidget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.groupBox_GDrawing.sizePolicy().hasHeightForWidth())
        self.groupBox_GDrawing.setSizePolicy(sizePolicy)
        self.groupBox_GDrawing.setMinimumSize(QtCore.QSize(150, 150))
        self.groupBox_GDrawing.setStyleSheet("QGroupBox{\n"
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
"    margin-top: 2px;\n"
" }")
        self.groupBox_GDrawing.setObjectName("groupBox_GDrawing")
        self.pbuttonStart = QtWidgets.QPushButton(self.groupBox_GDrawing)
        self.pbuttonStart.setGeometry(QtCore.QRect(40, 40, 61, 23))
        self.pbuttonStart.setObjectName("pbuttonStart")
        self.pbuttonStep = QtWidgets.QPushButton(self.groupBox_GDrawing)
        self.pbuttonStep.setGeometry(QtCore.QRect(40, 70, 61, 23))
        self.pbuttonStep.setObjectName("pbuttonStep")
        self.pbuttonSave = QtWidgets.QPushButton(self.groupBox_GDrawing)
        self.pbuttonSave.setGeometry(QtCore.QRect(40, 100, 61, 23))
        self.pbuttonSave.setObjectName("pbuttonSave")
        self.gridLayout.addWidget(self.groupBox_GDrawing, 3, 0, 1, 1)
        self.MatplotlibWidget2 = QtWidgets.QWidget(self.centralwidget)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.MatplotlibWidget2.sizePolicy().hasHeightForWidth())
        self.MatplotlibWidget2.setSizePolicy(sizePolicy)
        self.MatplotlibWidget2.setMinimumSize(QtCore.QSize(200, 200))
        self.MatplotlibWidget2.setStyleSheet("background-color: rgb(255, 255, 255);")
        self.MatplotlibWidget2.setObjectName("MatplotlibWidget2")
        self.gridLayout.addWidget(self.MatplotlibWidget2, 3, 1, 1, 1)
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtWidgets.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 430, 20))
        self.menubar.setObjectName("menubar")
        MainWindow.setMenuBar(self.menubar)
        self.toolBar = QtWidgets.QToolBar(MainWindow)
        self.toolBar.setObjectName("toolBar")
        MainWindow.addToolBar(QtCore.Qt.TopToolBarArea, self.toolBar)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "Force-directed graph drawing"))
        self.labelResult_2.setText(_translate("MainWindow", "Start"))
        self.groupBox_InitialG.setTitle(_translate("MainWindow", "Initial graph"))
        self.textEdit_nV.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">6</p></body></html>"))
        self.label.setText(_translate("MainWindow", "|V| = "))
        self.label_2.setText(_translate("MainWindow", "|E| = "))
        self.textEdit_nE.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">7</p></body></html>"))
        self.pButton_generateG.setText(_translate("MainWindow", "generate"))
        self.labelResult.setText(_translate("MainWindow", "Result: Step 0"))
        self.groupBox_GDrawing.setTitle(_translate("MainWindow", "Draw graph"))
        self.pbuttonStart.setText(_translate("MainWindow", "Start"))
        self.pbuttonStep.setText(_translate("MainWindow", "Step"))
        self.pbuttonSave.setText(_translate("MainWindow", "Step"))
        self.toolBar.setWindowTitle(_translate("MainWindow", "toolBar"))

