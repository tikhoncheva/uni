
import sys
from PyQt4 import QtCore, QtGui, uic

from form2 import Ui_MainWindow

import numpy

import matplotlib.pyplot as plot  

import random 
      
from floyed import *
from graphToDraw import Graph
from examplesKamadaKawai89 import *

from Algorithm_KamadaKawai89 import mainAlgorithm as newtonraphson1
from Algorithm_KamadaKawai89 import dEnergyOfSprings
from Algorithm_KamadaKawai89 import moveNode_m
# ---------------------------------------------------------------------------
# Class MyWindow defines behavior of the main application

class MyWindowClass(QtGui.QMainWindow):#, form_class):
    def __init__(self, parent=None):
        QtGui.QMainWindow.__init__(self, parent)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self) 
        
        # move to screen center
        screen = QtGui.QDesktopWidget().screenGeometry()
        windowsize = self.geometry()
        xcenter = (screen.width()  - windowsize.width())/2
        ycenter = (screen.height() - windowsize.height() - windowsize.height())/2
        self.move(xcenter, ycenter)
        
        # Attributes
        self.G = Graph(0, np.zeros((0,0), dtype = np.int32) )   # input graph
        self.p = [] # coordinates of the nodes
        self.pnew = []  # coordinates of the nodes after applying Force-Directed Graph Drawing Algorithm
        self.dist = np.zeros((0,0), dtype = np.int32)   # distance matrix of the graph
        self.step = 0   # iteration step
        
        # constants
        self.L_0 = 1
        self.K = 1
        self.eps = 0.0001
        
        self.k = np.zeros((0,0), dtype = np.int32)
        self.l = np.zeros((0,0), dtype = np.int32)
        
        # Methods        
        # plot initial graph on the matplotWidget1
        self.ui.pButton_generateG.clicked.connect(self.pButton_generateG_clicked)
        # run complete algorithm
        self.ui.pbuttonStart.clicked.connect(self.pButtonStart_clicked)
        # make one step of the algorithm
        self.ui.pbuttonStep.clicked.connect(self.pButtonStep_clicked)
        # run till the end from the current position

        # save current graph image
        self.ui.pbuttonSave_InitialG.clicked.connect(self.pButtonSaveImage1_clicked)
        self.ui.pbuttonSave.clicked.connect(self.pButtonSaveImage2_clicked)
    # end __init__
    # --------------------------------------------------------------------         
    # --------------------------------------------------------------------         
    def pButton_generateG_clicked(self):
        
        # init graph
        A = examplePicture2()
        n = np.size(A,0)   
        
        self.G = Graph(n, A)
        self.dist = floyed(A,n)
        
        # init coordinates
        self.p = init_particles(n, self.L_0)  #particles p1, ... ,pn
        self.pnew = self.p
        # plot initial graph
        self.plotGraph_onStart(A, self.p, n)
        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonSave.setEnabled(True)
        
    # end pButton_generateG_clicke
        
    # --------------------------------------------------------------------                   
    def pButtonStart_clicked(self):
        L = self.L_0 / np.max(self.dist)
        self.l = L * self.dist # length is matrix l_ij all those matrices (d, l k) are bigger than needed 
        self.k = self.K * 1./(self.dist**2) # ttention, infinity on diagonals, we dont need them so i dont care atm
        
#        self.pnew, self.step = newtonraphson1(self.l, self.p, self.k, self.G.get_n(), 0.0001)
        self.pnew, self.step = newtonraphson1(self.G.get_n(), self.p, self.k, self.l, self.eps)
        
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        self.plotGraph_Step(self.G.get_A(), self.pnew, self.G.get_n())        
    # end pButtonStart_clicked

    # --------------------------------------------------------------------         
    def pButtonStep_clicked(self):
        
        Ex, Ey = dEnergyOfSprings(self.G.get_n(), self.pnew, self.k, self.l)   
        Delta = np.sqrt(Ex*Ex + Ey*Ey)
        
        if np.max(Delta) > self.eps:            
            m = np.argmax(Delta)
     
            self.pnew = moveNode_m(self.G.get_n(), self.pnew, self.k, self.l, \
                                   self.eps, Ex, Ey, Delta[m], m)  

            self.step += 1
        # end if
        
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step))) 
        self.plotGraph_Step(self.G.get_A(), self.pnew, self.G.get_n())  
    # end pButtonStep_clicked

    # --------------------------------------------------------------------                 
    def pButtonSaveImage1_clicked(self):
        fileName, flagOK= QtGui.QInputDialog.getText(self, 'Save image', 'File name to save:')
    
        if flagOK:
            fileName += ".png" 
            self.ui.MatplotlibWidget1.canvas.fig.savefig(str(fileName))
            print "Image saved as " + fileName
    # end pButtonSaveImage1_clicked

    # --------------------------------------------------------------------         
    def pButtonSaveImage2_clicked(self):
        fileName, flagOK= QtGui.QInputDialog.getText(self, 'Save image', 'File name to save:')
    
        if flagOK:
            fileName += ".png" 
            self.ui.MatplotlibWidget2.canvas.fig.savefig(str(fileName))
            print "Image saved as " + fileName
    # end pButtonSaveImage2_clicked            

    # --------------------------------------------------------------------                 
    def plotGraph_onStart(self, A, particls, n):
        self.ui.MatplotlibWidget1.canvas.ax.clear()
        plot.scatter(particls[0,],particls[1,])
        self.ui.MatplotlibWidget1.canvas.ax.scatter(particls[0,],particls[1,])
        for i in range(n):
            for j in range(i+1,n):
                if A[i,j] < np.Infinity :
                    self.ui.MatplotlibWidget1.canvas.ax.plot([particls[0,i],particls[0,j]],
                                                             [particls[1,i],particls[1,j]])
                # end if
            # end for j
            # Annotate the points
            self.ui.MatplotlibWidget1.canvas.ax.annotate('{}'.format(i+1), 
                                                         xy=(particls[0,i],particls[1,i]),
                                                         xytext=(particls[0,i], particls[1,i]))
        # end for i        

        self.ui.MatplotlibWidget1.canvas.draw() 
    # end plotGraph_onStart

    # --------------------------------------------------------------------                 
    def plotGraph_Step(self, A, particls, n):
        self.ui.MatplotlibWidget2.canvas.ax.clear()
        plot.scatter(particls[0,],particls[1,])
        self.ui.MatplotlibWidget2.canvas.ax.scatter(particls[0,],particls[1,])
        for i in range(n):
            for j in range(i+1,n):
                if A[i,j] < np.Infinity :
                    self.ui.MatplotlibWidget2.canvas.ax.plot([particls[0,i],particls[0,j]],
                                                             [particls[1,i],particls[1,j]])
                # end if
            # end for j
            # Annotate the points
            self.ui.MatplotlibWidget2.canvas.ax.annotate('{}'.format(i+1), 
                                                         xy=(particls[0,i],particls[1,i]),
                                                         xytext=(particls[0,i], particls[1,i]))                    
        # end for i
        self.ui.MatplotlibWidget2.canvas.draw() 
    # end plotGraph_Step
    # --------------------------------------------------------------------                 
# end class MyWindowClass
# ---------------------------------------------------------------------------



# ----------------------------------------------------------------------------
#                            Main Function 
if __name__ == "__main__": 
    app = QtGui.QApplication(sys.argv)

    myWindow = MyWindowClass()
    myWindow.show()
    
    app.exec_()



