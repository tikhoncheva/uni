
import sys
from PyQt4 import QtCore, QtGui, uic

from form2 import Ui_MainWindow

import numpy

import matplotlib.pyplot as plot  

import random 
      
from floyed import *
from graphToDraw import Graph
from examplesKamadaKawai89 import *

# ---------------------------------------------------------------------------
# Class MyWindow defines behavior of the main application

class MyWindowClass(QtGui.QMainWindow):#, form_class):
    def __init__(self, parent=None):
        QtGui.QMainWindow.__init__(self, parent)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self) 
        
        # plot initial graph on the matplotWidget1
        self.ui.pButton_generateG.clicked.connect(self.pButton_generateG_clicked)
        # run complete algorithm
        self.ui.pbuttonStart.clicked.connect(self.pButtonStart_clicked)
        # make one step of the algorithm
        self.ui.pbuttonStep.clicked.connect(self.pButtonStep_clicked)
        # run till the end from the current position

        # save current graph image
        self.ui.pbuttonSave.clicked.connect(self.pButtonSaveImage_clicked)
    # end __init__
        
    # --------------------------------------------------------------------         
    def pButton_generateG_clicked(self):
        
        A = examplePicture2()
        n = np.size(A,0)   
        dist = floyed(A,n)
        
#        self.G = Graph( n, A)
#        self.dist = floyed(A,n)
        
        L_0 = 1     #constant
        L = L_0 / np.max(dist)
        K = 1       #constant
        
        length = L * dist # length is matrix l_ij all those matrices (d, l k) are bigger than needed 
        k = K * 1./(dist**2) # ttention, infinity on diagonals, we dont need them so i dont care atm
        
        p =  init_particles(n, L_0)  #particles p1, ... ,pn

        self.plotGraph_onStart(A, p, n, "start.png")

        pa = newtonraphson(length,p,k,n, 0.0001)

        self.plotGraph_Step(A, pa, n, "stop.png")
    # end pButton_generateG_clicke
        
    def plotGraph_onStart(self, A, particls, n, fileNameToSave):
        
        self.ui.MatplotlibWidget1.canvas.ax.clear()
        plot.scatter(particls[0,],particls[1,])
        self.ui.MatplotlibWidget1.canvas.ax.scatter(particls[0,],particls[1,])
        for i in range(n):
            for j in range(i+1,n):
                if A[i,j] < np.Infinity :
                    self.ui.MatplotlibWidget1.canvas.ax.plot([particls[0,i],particls[0,j]],[particls[1,i],particls[1,j]])
        self.ui.MatplotlibWidget1.canvas.draw() 
    # end plotGraph_onStart
        
    def plotGraph_Step(self, A, particls, n, fileNameToSave):
        
        self.ui.MatplotlibWidget2.canvas.ax.clear()
        plot.scatter(particls[0,],particls[1,])
        self.ui.MatplotlibWidget2.canvas.ax.scatter(particls[0,],particls[1,])
        for i in range(n):
            for j in range(i+1,n):
                if A[i,j] < np.Infinity :
                    self.ui.MatplotlibWidget2.canvas.ax.plot([particls[0,i],particls[0,j]],[particls[1,i],particls[1,j]])
        self.ui.MatplotlibWidget2.canvas.draw() 
    # end plotGraph_Step
        
    def pButtonStart_clicked(self):
        print "pButtonStart_clicked"
    # end pButtonStart_clicked

    def pButtonStep_clicked(self):
        print "pButtonStep_clicked"
    # end pButtonStep_clicked
        
    def pButtonSaveImage_clicked(self):
        fileName, flagOK= QtGui.QInputDialog.getText(self, 'Save image', 'File name to save:')
    
        if flagOK:
            fileName += ".png" 
            self.ui.MatplotlibWidget2.canvas.fig.savefig(str(fileName))
            print "Image saved as " + fileName
    
#        fileName = QtGui.QFileDialog.getSaveFileName(self, 'Save image', './', selectedFilter='*.png')
#        if fileName:
#            print fileName
    # end pButtonStart_clicked
        

# end class MyWindowClass
# ---------------------------------------------------------------------------



# ----------------------------------------------------------------------------
#                            Main Function 
if __name__ == "__main__": 
    app = QtGui.QApplication(sys.argv)

    myWindow = MyWindowClass()
    myWindow.show()
    
    app.exec_()



