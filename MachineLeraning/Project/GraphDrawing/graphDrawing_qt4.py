
import sys
from PyQt4 import QtCore, QtGui, uic

from form2 import Ui_MainWindow


from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

import numpy
import matplotlib.pyplot as plot  
import random 
      
from floyed import *
from graphToDraw import Graph
# -----------------------------------------------------------------------

#form_class = uic.loadUiType("mainwindow.ui")[0]                 # Load the UI
 
class MyWindowClass(QtGui.QMainWindow):#, form_class):
    def __init__(self, parent=None):
        QtGui.QMainWindow.__init__(self, parent)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self) 
        
        self.ui.pButton_generateG.clicked.connect(self.pButton_generateG_clicked)

#    def __init__(self, parent=None):
#        QtGui.QMainWindow.__init__(self, parent)
#        self.setupUi(self)
#        self.pButton_generateG.clicked.connect(self.pButton_generateG_clicked) 
     
    def pButton_generateG_clicked(self):
        A = testMpaper
        n = np.size(A,0)   
        dist = floyed(A,n)
        
#        self.G = Graph( n, A)
#        self.dist = floyed(A,n)
        
        L_0 = 1     #constant
        L = L_0 / np.max(dist)
        K = 1       #constant
        
        length = L * dist # length is matrix l_ij all those matrices (d, l k) are bigger than needed 
        k = K * 1./(dist**2) # ttention, infinity on diagonals, we dont need them so i dont care atm
        
        p =  init_particles(n,L_0)  #particles p1, ... ,pn
        self.plotGraph_onStart(A, p, n, "start.png")
        pa = newtonraphson(length,p,k,n)
        self.plotGraph_Step(A, pa, n, "stop.png")
         
    def plotGraph_onStart(self, A, particls, n, fileNameToSave):
        
        self.ui.MatplotlibWidget1.canvas.ax.clear()
        plot.scatter(particls[0,],particls[1,])
        self.ui.MatplotlibWidget1.canvas.ax.scatter(particls[0,],particls[1,])
        for i in range(n):
            for j in range(i+1,n):
                if A[i,j] < np.Infinity :
                    self.ui.MatplotlibWidget1.canvas.ax.plot([particls[0,i],particls[0,j]],[particls[1,i],particls[1,j]])
        self.ui.MatplotlibWidget1.canvas.draw() 

    def plotGraph_Step(self, A, particls, n, fileNameToSave):
        
        self.ui.MatplotlibWidget2.canvas.ax.clear()
        plot.scatter(particls[0,],particls[1,])
        self.ui.MatplotlibWidget2.canvas.ax.scatter(particls[0,],particls[1,])
        for i in range(n):
            for j in range(i+1,n):
                if A[i,j] < np.Infinity :
                    self.ui.MatplotlibWidget2.canvas.ax.plot([particls[0,i],particls[0,j]],[particls[1,i],particls[1,j]])
        self.ui.MatplotlibWidget2.canvas.draw() 


#    def btn_CtoF_clicked(self):                  # CtoF button event handler
#        cel = float(self.editCel.text())         #
#        fahr = cel * 9 / 5.0 + 32                #
#        self.spinFahr.setValue(int(fahr + 0.5))  #
 
#    def btn_FtoC_clicked(self):                  # FtoC button event handler
#        fahr = self.spinFahr.value()             #
#        cel = (fahr - 32) *                      #
#        self.editCel.setText(str(cel))           #
 
if __name__ == "__main__": 
    app = QtGui.QApplication(sys.argv)

    myWindow = MyWindowClass()
    myWindow.show()
    
    app.exec_()



