# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'mainwindow.ui'
#
# Created: Fri Feb 20 22:45:30 2015
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
        MainWindow.resize(1255, 620)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(5)
        sizePolicy.setVerticalStretch(5)
        sizePolicy.setHeightForWidth(MainWindow.sizePolicy().hasHeightForWidth())
        MainWindow.setSizePolicy(sizePolicy)
        MainWindow.setMinimumSize(QtCore.QSize(0, 620))
        MainWindow.setMaximumSize(QtCore.QSize(1255, 620))
        self.centralwidget = QtGui.QWidget(MainWindow)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        self.labelStart = QtGui.QLabel(self.centralwidget)
        self.labelStart.setGeometry(QtCore.QRect(170, 10, 411, 17))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.labelStart.sizePolicy().hasHeightForWidth())
        self.labelStart.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(10)
        font.setBold(True)
        font.setWeight(75)
        self.labelStart.setFont(font)
        self.labelStart.setObjectName(_fromUtf8("labelStart"))
        self.labelResult = QtGui.QLabel(self.centralwidget)
        self.labelResult.setGeometry(QtCore.QRect(709, 10, 521, 17))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.labelResult.sizePolicy().hasHeightForWidth())
        self.labelResult.setSizePolicy(sizePolicy)
        self.labelResult.setMinimumSize(QtCore.QSize(0, 0))
        self.labelResult.setMaximumSize(QtCore.QSize(16777215, 100))
        font = QtGui.QFont()
        font.setPointSize(10)
        font.setBold(True)
        font.setWeight(75)
        self.labelResult.setFont(font)
        self.labelResult.setObjectName(_fromUtf8("labelResult"))
        self.groupBox_InitialG = QtGui.QGroupBox(self.centralwidget)
        self.groupBox_InitialG.setGeometry(QtCore.QRect(10, 10, 150, 100))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.groupBox_InitialG.sizePolicy().hasHeightForWidth())
        self.groupBox_InitialG.setSizePolicy(sizePolicy)
        self.groupBox_InitialG.setMinimumSize(QtCore.QSize(150, 100))
        self.groupBox_InitialG.setMaximumSize(QtCore.QSize(16777215, 100))
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
        self.textEdit_h = QtGui.QTextEdit(self.groupBox_InitialG)
        self.textEdit_h.setGeometry(QtCore.QRect(60, 20, 61, 21))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.textEdit_h.sizePolicy().hasHeightForWidth())
        self.textEdit_h.setSizePolicy(sizePolicy)
        self.textEdit_h.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_h.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_h.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_h.setObjectName(_fromUtf8("textEdit_h"))
        self.label = QtGui.QLabel(self.groupBox_InitialG)
        self.label.setGeometry(QtCore.QRect(10, 20, 41, 21))
        self.label.setObjectName(_fromUtf8("label"))
        self.label_2 = QtGui.QLabel(self.groupBox_InitialG)
        self.label_2.setGeometry(QtCore.QRect(10, 40, 41, 21))
        self.label_2.setObjectName(_fromUtf8("label_2"))
        self.textEdit_nV = QtGui.QTextEdit(self.groupBox_InitialG)
        self.textEdit_nV.setEnabled(False)
        self.textEdit_nV.setGeometry(QtCore.QRect(60, 40, 61, 21))
        self.textEdit_nV.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_nV.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nV.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_nV.setObjectName(_fromUtf8("textEdit_nV"))
        self.pButton_generateG = QtGui.QPushButton(self.groupBox_InitialG)
        self.pButton_generateG.setGeometry(QtCore.QRect(30, 70, 81, 23))
        self.pButton_generateG.setObjectName(_fromUtf8("pButton_generateG"))
        self.MatplotlibWidget1 = matplotlibWidget(self.centralwidget)
        self.MatplotlibWidget1.setGeometry(QtCore.QRect(165, 30, 538, 532))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.MatplotlibWidget1.sizePolicy().hasHeightForWidth())
        self.MatplotlibWidget1.setSizePolicy(sizePolicy)
        self.MatplotlibWidget1.setMinimumSize(QtCore.QSize(530, 530))
        self.MatplotlibWidget1.setStyleSheet(_fromUtf8("background-color: rgb(255, 255, 255);"))
        self.MatplotlibWidget1.setObjectName(_fromUtf8("MatplotlibWidget1"))
        self.MatplotlibWidget2 = matplotlibWidget(self.centralwidget)
        self.MatplotlibWidget2.setGeometry(QtCore.QRect(709, 30, 537, 532))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.MatplotlibWidget2.sizePolicy().hasHeightForWidth())
        self.MatplotlibWidget2.setSizePolicy(sizePolicy)
        self.MatplotlibWidget2.setMinimumSize(QtCore.QSize(530, 530))
        self.MatplotlibWidget2.setStyleSheet(_fromUtf8("background-color: rgb(255, 255, 255);"))
        self.MatplotlibWidget2.setObjectName(_fromUtf8("MatplotlibWidget2"))
        self.groupBox_GDrawing = QtGui.QGroupBox(self.centralwidget)
        self.groupBox_GDrawing.setEnabled(True)
        self.groupBox_GDrawing.setGeometry(QtCore.QRect(10, 200, 150, 100))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.groupBox_GDrawing.sizePolicy().hasHeightForWidth())
        self.groupBox_GDrawing.setSizePolicy(sizePolicy)
        self.groupBox_GDrawing.setMinimumSize(QtCore.QSize(150, 100))
        self.groupBox_GDrawing.setMaximumSize(QtCore.QSize(150, 100))
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
        self.pbuttonStart.setGeometry(QtCore.QRect(10, 20, 61, 23))
        self.pbuttonStart.setObjectName(_fromUtf8("pbuttonStart"))
        self.pbuttonStep = QtGui.QPushButton(self.groupBox_GDrawing)
        self.pbuttonStep.setEnabled(False)
        self.pbuttonStep.setGeometry(QtCore.QRect(80, 20, 61, 23))
        self.pbuttonStep.setObjectName(_fromUtf8("pbuttonStep"))
        self.pbuttonContinue = QtGui.QPushButton(self.groupBox_GDrawing)
        self.pbuttonContinue.setEnabled(False)
        self.pbuttonContinue.setGeometry(QtCore.QRect(80, 50, 61, 23))
        self.pbuttonContinue.setObjectName(_fromUtf8("pbuttonContinue"))
        self.groupBox_Param = QtGui.QGroupBox(self.centralwidget)
        self.groupBox_Param.setGeometry(QtCore.QRect(10, 310, 150, 275))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.groupBox_Param.sizePolicy().hasHeightForWidth())
        self.groupBox_Param.setSizePolicy(sizePolicy)
        self.groupBox_Param.setMinimumSize(QtCore.QSize(150, 0))
        self.groupBox_Param.setMaximumSize(QtCore.QSize(150, 275))
        font = QtGui.QFont()
        font.setBold(False)
        font.setWeight(50)
        self.groupBox_Param.setFont(font)
        self.groupBox_Param.setStyleSheet(_fromUtf8("QGroupBox{\n"
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
        self.groupBox_Param.setObjectName(_fromUtf8("groupBox_Param"))
        self.label_L0 = QtGui.QLabel(self.groupBox_Param)
        self.label_L0.setGeometry(QtCore.QRect(20, 50, 41, 21))
        self.label_L0.setObjectName(_fromUtf8("label_L0"))
        self.textEdit_K = QtGui.QTextEdit(self.groupBox_Param)
        self.textEdit_K.setGeometry(QtCore.QRect(70, 30, 61, 21))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.textEdit_K.sizePolicy().hasHeightForWidth())
        self.textEdit_K.setSizePolicy(sizePolicy)
        self.textEdit_K.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_K.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_K.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_K.setObjectName(_fromUtf8("textEdit_K"))
        self.label_K = QtGui.QLabel(self.groupBox_Param)
        self.label_K.setGeometry(QtCore.QRect(20, 30, 41, 21))
        self.label_K.setObjectName(_fromUtf8("label_K"))
        self.textEdit_L0 = QtGui.QTextEdit(self.groupBox_Param)
        self.textEdit_L0.setGeometry(QtCore.QRect(70, 50, 61, 21))
        self.textEdit_L0.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_L0.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_L0.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_L0.setObjectName(_fromUtf8("textEdit_L0"))
        self.label_eps = QtGui.QLabel(self.groupBox_Param)
        self.label_eps.setGeometry(QtCore.QRect(20, 70, 41, 21))
        self.label_eps.setObjectName(_fromUtf8("label_eps"))
        self.textEdit_eps = QtGui.QTextEdit(self.groupBox_Param)
        self.textEdit_eps.setGeometry(QtCore.QRect(70, 70, 61, 21))
        self.textEdit_eps.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_eps.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_eps.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_eps.setObjectName(_fromUtf8("textEdit_eps"))
        self.pbuttonReset = QtGui.QPushButton(self.groupBox_Param)
        self.pbuttonReset.setEnabled(False)
        self.pbuttonReset.setGeometry(QtCore.QRect(40, 246, 61, 23))
        self.pbuttonReset.setObjectName(_fromUtf8("pbuttonReset"))
        self.textEdit_maxit = QtGui.QTextEdit(self.groupBox_Param)
        self.textEdit_maxit.setGeometry(QtCore.QRect(70, 90, 61, 21))
        self.textEdit_maxit.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_maxit.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_maxit.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_maxit.setObjectName(_fromUtf8("textEdit_maxit"))
        self.label_max_it = QtGui.QLabel(self.groupBox_Param)
        self.label_max_it.setGeometry(QtCore.QRect(20, 90, 41, 21))
        self.label_max_it.setObjectName(_fromUtf8("label_max_it"))
        self.line = QtGui.QFrame(self.groupBox_Param)
        self.line.setGeometry(QtCore.QRect(15, 120, 120, 3))
        self.line.setFrameShape(QtGui.QFrame.HLine)
        self.line.setFrameShadow(QtGui.QFrame.Sunken)
        self.line.setObjectName(_fromUtf8("line"))
        self.label_Minsize = QtGui.QLabel(self.groupBox_Param)
        self.label_Minsize.setGeometry(QtCore.QRect(10, 220, 51, 21))
        self.label_Minsize.setObjectName(_fromUtf8("label_Minsize"))
        self.textEdit_iterator = QtGui.QTextEdit(self.groupBox_Param)
        self.textEdit_iterator.setGeometry(QtCore.QRect(70, 180, 61, 21))
        self.textEdit_iterator.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_iterator.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_iterator.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_iterator.setObjectName(_fromUtf8("textEdit_iterator"))
        self.textEdit_ratio = QtGui.QTextEdit(self.groupBox_Param)
        self.textEdit_ratio.setGeometry(QtCore.QRect(70, 200, 61, 21))
        self.textEdit_ratio.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_ratio.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_ratio.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_ratio.setObjectName(_fromUtf8("textEdit_ratio"))
        self.label_Ratio = QtGui.QLabel(self.groupBox_Param)
        self.label_Ratio.setGeometry(QtCore.QRect(10, 200, 51, 21))
        self.label_Ratio.setObjectName(_fromUtf8("label_Ratio"))
        self.textEdit_minsize = QtGui.QTextEdit(self.groupBox_Param)
        self.textEdit_minsize.setGeometry(QtCore.QRect(70, 220, 61, 21))
        self.textEdit_minsize.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_minsize.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_minsize.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_minsize.setObjectName(_fromUtf8("textEdit_minsize"))
        self.label_It = QtGui.QLabel(self.groupBox_Param)
        self.label_It.setGeometry(QtCore.QRect(10, 180, 51, 21))
        self.label_It.setObjectName(_fromUtf8("label_It"))
        self.textEdit_radius = QtGui.QTextEdit(self.groupBox_Param)
        self.textEdit_radius.setGeometry(QtCore.QRect(70, 160, 61, 21))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.textEdit_radius.sizePolicy().hasHeightForWidth())
        self.textEdit_radius.setSizePolicy(sizePolicy)
        self.textEdit_radius.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_radius.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_radius.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_radius.setObjectName(_fromUtf8("textEdit_radius"))
        self.label_Radius = QtGui.QLabel(self.groupBox_Param)
        self.label_Radius.setGeometry(QtCore.QRect(10, 160, 51, 21))
        self.label_Radius.setObjectName(_fromUtf8("label_Radius"))
        self.label_3 = QtGui.QLabel(self.groupBox_Param)
        self.label_3.setGeometry(QtCore.QRect(20, 120, 111, 20))
        font = QtGui.QFont()
        font.setBold(True)
        font.setWeight(75)
        self.label_3.setFont(font)
        self.label_3.setObjectName(_fromUtf8("label_3"))
        self.label_4 = QtGui.QLabel(self.groupBox_Param)
        self.label_4.setGeometry(QtCore.QRect(16, 10, 131, 20))
        font = QtGui.QFont()
        font.setBold(True)
        font.setWeight(75)
        self.label_4.setFont(font)
        self.label_4.setObjectName(_fromUtf8("label_4"))
        self.label_l = QtGui.QLabel(self.groupBox_Param)
        self.label_l.setGeometry(QtCore.QRect(10, 140, 51, 21))
        self.label_l.setObjectName(_fromUtf8("label_l"))
        self.textEdit_l = QtGui.QTextEdit(self.groupBox_Param)
        self.textEdit_l.setGeometry(QtCore.QRect(70, 140, 61, 21))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.textEdit_l.sizePolicy().hasHeightForWidth())
        self.textEdit_l.setSizePolicy(sizePolicy)
        self.textEdit_l.setInputMethodHints(QtCore.Qt.ImhDigitsOnly)
        self.textEdit_l.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_l.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.textEdit_l.setObjectName(_fromUtf8("textEdit_l"))
        self.groupBox_Algorithm = QtGui.QGroupBox(self.centralwidget)
        self.groupBox_Algorithm.setEnabled(False)
        self.groupBox_Algorithm.setGeometry(QtCore.QRect(10, 120, 150, 70))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.groupBox_Algorithm.sizePolicy().hasHeightForWidth())
        self.groupBox_Algorithm.setSizePolicy(sizePolicy)
        self.groupBox_Algorithm.setMinimumSize(QtCore.QSize(150, 70))
        self.groupBox_Algorithm.setMaximumSize(QtCore.QSize(150, 70))
        self.groupBox_Algorithm.setStyleSheet(_fromUtf8("QGroupBox{\n"
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
        self.groupBox_Algorithm.setObjectName(_fromUtf8("groupBox_Algorithm"))
        self.rB_KamadaKawai = QtGui.QRadioButton(self.groupBox_Algorithm)
        self.rB_KamadaKawai.setGeometry(QtCore.QRect(10, 20, 121, 21))
        self.rB_KamadaKawai.setChecked(True)
        self.rB_KamadaKawai.setObjectName(_fromUtf8("rB_KamadaKawai"))
        self.rB_HarelKoren = QtGui.QRadioButton(self.groupBox_Algorithm)
        self.rB_HarelKoren.setGeometry(QtCore.QRect(10, 40, 121, 21))
        self.rB_HarelKoren.setObjectName(_fromUtf8("rB_HarelKoren"))
        self.pbuttonSave_InitialG = QtGui.QPushButton(self.centralwidget)
        self.pbuttonSave_InitialG.setGeometry(QtCore.QRect(370, 565, 121, 23))
        self.pbuttonSave_InitialG.setObjectName(_fromUtf8("pbuttonSave_InitialG"))
        self.pbuttonSave = QtGui.QPushButton(self.centralwidget)
        self.pbuttonSave.setEnabled(True)
        self.pbuttonSave.setGeometry(QtCore.QRect(940, 565, 111, 23))
        self.pbuttonSave.setObjectName(_fromUtf8("pbuttonSave"))
        self.cBox_ShowLabels = QtGui.QCheckBox(self.centralwidget)
        self.cBox_ShowLabels.setGeometry(QtCore.QRect(660, 565, 111, 21))
        self.cBox_ShowLabels.setChecked(True)
        self.cBox_ShowLabels.setObjectName(_fromUtf8("cBox_ShowLabels"))
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtGui.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 1255, 20))
        self.menubar.setStyleSheet(_fromUtf8("QMenuBar{\n"
"background: rgb(199, 199, 199)\n"
"}"))
        self.menubar.setObjectName(_fromUtf8("menubar"))
        self.menuExamples = QtGui.QMenu(self.menubar)
        self.menuExamples.setObjectName(_fromUtf8("menuExamples"))
        self.menuScotch_collection = QtGui.QMenu(self.menuExamples)
        self.menuScotch_collection.setObjectName(_fromUtf8("menuScotch_collection"))
        self.menuGrid_graph = QtGui.QMenu(self.menuExamples)
        self.menuGrid_graph.setObjectName(_fromUtf8("menuGrid_graph"))
        self.menuSparse_grid_graph = QtGui.QMenu(self.menuExamples)
        self.menuSparse_grid_graph.setObjectName(_fromUtf8("menuSparse_grid_graph"))
        MainWindow.setMenuBar(self.menubar)
        self.actionExample_1 = QtGui.QAction(MainWindow)
        self.actionExample_1.setObjectName(_fromUtf8("actionExample_1"))
        self.actionExample_2 = QtGui.QAction(MainWindow)
        self.actionExample_2.setObjectName(_fromUtf8("actionExample_2"))
        self.actionExample_3 = QtGui.QAction(MainWindow)
        self.actionExample_3.setObjectName(_fromUtf8("actionExample_3"))
        self.action_3eltGraph = QtGui.QAction(MainWindow)
        self.action_3eltGraph.setObjectName(_fromUtf8("action_3eltGraph"))
        self.action4elt_Graph = QtGui.QAction(MainWindow)
        self.action4elt_Graph.setObjectName(_fromUtf8("action4elt_Graph"))
        self.actionCrack = QtGui.QAction(MainWindow)
        self.actionCrack.setObjectName(_fromUtf8("actionCrack"))
        self.action_grid32x32 = QtGui.QAction(MainWindow)
        self.action_grid32x32.setObjectName(_fromUtf8("action_grid32x32"))
        self.action_grid55x55 = QtGui.QAction(MainWindow)
        self.action_grid55x55.setObjectName(_fromUtf8("action_grid55x55"))
        self.action_16x16 = QtGui.QAction(MainWindow)
        self.action_16x16.setObjectName(_fromUtf8("action_16x16"))
        self.action_sgrid32x32 = QtGui.QAction(MainWindow)
        self.action_sgrid32x32.setObjectName(_fromUtf8("action_sgrid32x32"))
        self.action_sgrid40x40 = QtGui.QAction(MainWindow)
        self.action_sgrid40x40.setObjectName(_fromUtf8("action_sgrid40x40"))
        self.actionExample_4 = QtGui.QAction(MainWindow)
        self.actionExample_4.setObjectName(_fromUtf8("actionExample_4"))
        self.action_sgrid16x16 = QtGui.QAction(MainWindow)
        self.action_sgrid16x16.setObjectName(_fromUtf8("action_sgrid16x16"))
        self.menuScotch_collection.addAction(self.action_3eltGraph)
        self.menuScotch_collection.addAction(self.action4elt_Graph)
        self.menuScotch_collection.addAction(self.actionCrack)
        self.menuGrid_graph.addAction(self.action_16x16)
        self.menuGrid_graph.addAction(self.action_grid32x32)
        self.menuGrid_graph.addAction(self.action_grid55x55)
        self.menuSparse_grid_graph.addAction(self.action_sgrid16x16)
        self.menuSparse_grid_graph.addAction(self.action_sgrid32x32)
        self.menuSparse_grid_graph.addAction(self.action_sgrid40x40)
        self.menuExamples.addAction(self.actionExample_1)
        self.menuExamples.addAction(self.actionExample_2)
        self.menuExamples.addSeparator()
        self.menuExamples.addAction(self.actionExample_3)
        self.menuExamples.addSeparator()
        self.menuExamples.addAction(self.menuGrid_graph.menuAction())
        self.menuExamples.addAction(self.menuSparse_grid_graph.menuAction())
        self.menuExamples.addAction(self.menuScotch_collection.menuAction())
        self.menubar.addAction(self.menuExamples.menuAction())

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(_translate("MainWindow", "Force-directed graph drawing", None))
        self.labelStart.setText(_translate("MainWindow", "Start", None))
        self.labelResult.setText(_translate("MainWindow", "Result: Step 0", None))
        self.groupBox_InitialG.setTitle(_translate("MainWindow", "Generate binary tree", None))
        self.textEdit_h.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">5</p></body></html>", None))
        self.label.setText(_translate("MainWindow", "Height", None))
        self.label_2.setText(_translate("MainWindow", "|V| = ", None))
        self.textEdit_nV.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">31</p></body></html>", None))
        self.pButton_generateG.setText(_translate("MainWindow", "generate", None))
        self.groupBox_GDrawing.setTitle(_translate("MainWindow", "Draw graph", None))
        self.pbuttonStart.setText(_translate("MainWindow", "Run", None))
        self.pbuttonStep.setText(_translate("MainWindow", "Step", None))
        self.pbuttonContinue.setText(_translate("MainWindow", "Continue", None))
        self.groupBox_Param.setTitle(_translate("MainWindow", "Parameters", None))
        self.label_L0.setText(_translate("MainWindow", "L_0 = ", None))
        self.textEdit_K.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">1</p></body></html>", None))
        self.label_K.setText(_translate("MainWindow", "K = ", None))
        self.textEdit_L0.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">1</p></body></html>", None))
        self.label_eps.setText(_translate("MainWindow", "eps", None))
        self.textEdit_eps.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">0.001</p></body></html>", None))
        self.pbuttonReset.setText(_translate("MainWindow", "Reset", None))
        self.textEdit_maxit.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">1000</p></body></html>", None))
        self.label_max_it.setText(_translate("MainWindow", "maxit", None))
        self.label_Minsize.setText(_translate("MainWindow", "MinSize", None))
        self.textEdit_iterator.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">4</p></body></html>", None))
        self.textEdit_ratio.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">3</p></body></html>", None))
        self.label_Ratio.setText(_translate("MainWindow", "Ratio", None))
        self.textEdit_minsize.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">10</p></body></html>", None))
        self.label_It.setText(_translate("MainWindow", "Itaretions", None))
        self.textEdit_radius.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">7</p></body></html>", None))
        self.label_Radius.setText(_translate("MainWindow", "Radius", None))
        self.label_3.setText(_translate("MainWindow", "HarelKoren Alg", None))
        self.label_4.setText(_translate("MainWindow", "KamadaKawai Alg", None))
        self.label_l.setText(_translate("MainWindow", "L", None))
        self.textEdit_l.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">1</p></body></html>", None))
        self.groupBox_Algorithm.setTitle(_translate("MainWindow", "Algorithm", None))
        self.rB_KamadaKawai.setText(_translate("MainWindow", "Kamada_Kawai", None))
        self.rB_HarelKoren.setText(_translate("MainWindow", "Harel_Koren", None))
        self.pbuttonSave_InitialG.setText(_translate("MainWindow", "Save image", None))
        self.pbuttonSave.setText(_translate("MainWindow", "Save image", None))
        self.cBox_ShowLabels.setText(_translate("MainWindow", "show labels", None))
        self.menuExamples.setTitle(_translate("MainWindow", "Examples", None))
        self.menuScotch_collection.setTitle(_translate("MainWindow", "Collection of Jordi Petit", None))
        self.menuGrid_graph.setTitle(_translate("MainWindow", "Square Grid", None))
        self.menuSparse_grid_graph.setTitle(_translate("MainWindow", "Sparse Square Grid", None))
        self.actionExample_1.setText(_translate("MainWindow", "Example 1", None))
        self.actionExample_2.setText(_translate("MainWindow", "Example 2", None))
        self.actionExample_3.setText(_translate("MainWindow", "Example 3", None))
        self.action_3eltGraph.setText(_translate("MainWindow", "3elt Graph", None))
        self.action4elt_Graph.setText(_translate("MainWindow", "4elt Graph", None))
        self.actionCrack.setText(_translate("MainWindow", "Crack", None))
        self.action_grid32x32.setText(_translate("MainWindow", "32x32", None))
        self.action_grid55x55.setText(_translate("MainWindow", "55x55", None))
        self.action_16x16.setText(_translate("MainWindow", "16x16", None))
        self.action_sgrid32x32.setText(_translate("MainWindow", "32x32", None))
        self.action_sgrid40x40.setText(_translate("MainWindow", "40x40", None))
        self.actionExample_4.setText(_translate("MainWindow", "Example 4", None))
        self.action_sgrid16x16.setText(_translate("MainWindow", "16x16", None))

from matplotlibwidged import matplotlibWidget

if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    MainWindow = QtGui.QMainWindow()
    ui = Ui_MainWindow()
    ui.setupUi(MainWindow)
    MainWindow.show()
    sys.exit(app.exec_())

