
import sys

from PyQt4 import QtGui, QtCore, QtWidgets
from PyQt4.QtWidgets import QApplication
from PyQt4.QtWidgets import QTextEdit, QMainWindow
   
from form1 import Ui_MainWindow		# import Mainwindow Form   

#from floyed import plotGraph

from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar

import numpy

import matplotlib.pyplot as plot       



class MyWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super(MyWindow, self).__init__()
        ui = Ui_MainWindow()
        ui.setupUi(self)
        self.show()
        
# main function, that starts the application

if __name__ == "__main__":
    
    app = QtWidgets.QApplication(sys.argv)
    
#    MainWindow = QtWidgets.QMainWindow()
#    ui = Ui_MainWindow()
#    ui.setupUi(MainWindow)
#    MainWindow.show()
    
    window = MyWindow()        
    
    sys.exit(app.exec_())
    
        
        