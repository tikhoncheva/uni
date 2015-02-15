
import sys
from PyQt4 import QtCore, QtGui, uic

#from form2 import Ui_MainWindow
from mainform import Ui_MainWindow

import numpy as np
import matplotlib.pyplot as plot  
import time

from graphToDraw import *
import examplesKamadaKawai89 

from Algorithm_HarelKoren2002 import Algorithm_HarelKoren

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
        self.maxit = 1000
        
        self.k = np.zeros((0,0), dtype = np.int32)
        self.l = np.zeros((0,0), dtype = np.int32)
        
        # Methods        
        # initialise graph
        self.ui.pButton_generateG.clicked.connect(self.pButton_generateG_clicked)
        # run complete algorithm
        self.ui.pbuttonStart.clicked.connect(self.pButtonStart_clicked)
        # make one step of the algorithm
        self.ui.pbuttonStep.clicked.connect(self.pButtonStep_clicked)
        # run till the end from the current position
        self.ui.pbuttonContinue.clicked.connect(self.pButtonContinue_clicked)

        # save current graph image
        self.ui.pbuttonSave_InitialG.clicked.connect(self.pButtonSaveImage1_clicked)
        self.ui.pbuttonSave.clicked.connect(self.pButtonSaveImage2_clicked)
    
        # delete result of algorithms 
        self.ui.pbuttonReset.clicked.connect(self.pButtonReset_clicked)     
        
        # hard coded examples
        self.connect(self.ui.actionExample_1, QtCore.SIGNAL('triggered()'), self.startExample_1)
        self.connect(self.ui.actionExample_2, QtCore.SIGNAL('triggered()'), self.startExample_2)
        self.connect(self.ui.actionExample_3, QtCore.SIGNAL('triggered()'), self.startExample_3)  
        
        # on parameter changed
        self.ui.textEdit_eps.textChanged.connect(self.eps_changed)
        self.ui.textEdit_K.textChanged.connect(self.K_changed)
        self.ui.textEdit_L0.textChanged.connect(self.L0_changed)
        self.ui.textEdit_maxit.textChanged.connect(self.maxit_changed)
        
        # select Algorithm
        self.Alg_KamadaKawai = True
        self.Alg_HarelKoren = False
        self.connect(self.ui.rB_KamadaKawai, QtCore.SIGNAL('toggled(bool)'), self.select_Alg_KamadaKawai)
        self.connect(self.ui.rB_HarelKoren, QtCore.SIGNAL('toggled(bool)'), self.select_Alg_HarelKoren)
    # end __init__
        
    # --------------------------------------------------------------------                 
    # Initialise graph 
    # --------------------------------------------------------------------         
    def pButton_generateG_clicked(self):
        
        # init graph
        A = examplesKamadaKawai89.examplePicture2()
        n = np.size(A,0)   
        self.G = Graph(n, A)
        
        
        # get parameter values
        self.L_0 = int(self.ui.textEdit_L0.toPlainText())   # length of rectangle side of display area
        self.K   = int(self.ui.textEdit_K.toPlainText())
        self.eps = float(self.ui.textEdit_eps.toPlainText())
        self.maxit = int(self.ui.textEdit_maxit.toPlainText())
        
        # calculate graph distance
        starttime = time.time()
#        self.dist = floyed(A,n)
        self.dist = dist_with_DijkstraAlg(A)
        stoptime = time.time()
        print "Time spent to calculate distance matrix of the graph ({0:5d} nodes): {1:0.6f} sec". format(n, stoptime-starttime)        
        
        # calculate desirable length of single edge
        
        L = self.L_0 / np.max(self.dist)
        # calculate length of edges
        self.l = L * self.dist
        # calculate strength of spring between two nodes
        self.k = self.K * 1./(self.dist**2) # attention, infinity on diagonals, but we dont need diagonal element
        
        # init coordinates
        self.p = init_particles(n, self.L_0)  #particles p1, ... ,pn
        self.pnew = (self.p).copy()
        
        # plot initial graph
        self.plotGraph_onStart()
        self.plotGraph_Step()

        # set buttons enabled        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonContinue.setEnabled(False)

        self.ui.pbuttonSave.setEnabled(True)
        self.ui.pbuttonReset.setEnabled(True)        
        
        self.ui.labelStart.setText(QtCore.QString("Start: generated"))
    # end pButton_generateG_clicke

    # --------------------------------------------------------------------                 
    # Run complete algorithm 
    # --------------------------------------------------------------------                   
    def pButtonStart_clicked(self):
        
        self.pnew = (self.p).copy()
        
        starttime = time.time()
        if self.Alg_KamadaKawai:
            self.pnew, self.step = newtonraphson1(self.G.get_n(), self.pnew, self.k, self.l, self.eps, self.maxit)
        else:
            self.pnew, self.step = Algorithm_HarelKoren(self.G, self.pnew, self.K, self.L_0, self.eps, self.maxit)
        stoptime = time.time()
        print "Time spent to draw the graph ({0:5d} nodes): {1:0.6f} sec". format(self.G.get_n(), stoptime-starttime)
        
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        self.plotGraph_Step()        
    # end pButtonStart_clicked

    # --------------------------------------------------------------------                 
    # Make one step of the algorithm
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
        
        self.plotGraph_Step()
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step))) 
        self.ui.pbuttonContinue.setEnabled(True)
    # end pButtonStep_clicked

    # --------------------------------------------------------------------                 
    # Run algorithm till end from the current position
    # --------------------------------------------------------------------         
    def pButtonContinue_clicked(self):
        
#        self.pnew, self.step = newtonraphson1(self.l, self.p, self.k, self.G.get_n(), 0.0001)
        self.pnew, nContSteps = newtonraphson1(self.G.get_n(), self.pnew, self.k, self.l, self.eps,self.maxit)
        self.step += nContSteps
        
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        self.plotGraph_Step() 
        
    # end pButtonStep_clicked

    # --------------------------------------------------------------------                 
    # Delete result of algorithms 
    # --------------------------------------------------------------------  
    def pButtonReset_clicked(self):
        
        self.ui.MatplotlibWidget2.canvas.ax.clear()
        self.ui.MatplotlibWidget2.canvas.draw() 

        self.step = 0
        
        # get parameter values
        self.L_0 = int(self.ui.textEdit_L0.toPlainText())   # length of rectangle side of display area
        self.K   = int(self.ui.textEdit_K.toPlainText())
        self.eps = float(self.ui.textEdit_eps.toPlainText())
        self.maxit = int(self.ui.textEdit_maxit.toPlainText())
               
        # calculate desirable length of single edge
        L = self.L_0 / np.max(self.dist)
        # calculate length of edges
        self.l = L * self.dist
        # calculate strength of spring between two nodes
        self.k = self.K * 1./(self.dist**2) # attention, infinity on diagonals, but we dont need diagonal element
        
        # init coordinates
        self.p = init_particles(self.G.get_n(), self.L_0)  #particles p1, ... ,pn
        self.pnew = (self.p).copy()
        
        self.plotGraph_Step()
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)  
        self.ui.pbuttonContinue.setEnabled(False)
    #end pButtonReset_clicked        

    # --------------------------------------------------------------------                 
    # Save initial graph
    # --------------------------------------------------------------------                 
    def pButtonSaveImage1_clicked(self):
        fileName, flagOK= QtGui.QInputDialog.getText(self, 'Save image', 'File name to save:')
    
        if flagOK:
            fileName += ".png" 
            self.ui.MatplotlibWidget1.canvas.fig.savefig(str(fileName))
    # end pButtonSaveImage1_clicked
            
    # --------------------------------------------------------------------                 
    # Save new graph
    # --------------------------------------------------------------------         
    def pButtonSaveImage2_clicked(self):
        fileName, flagOK= QtGui.QInputDialog.getText(self, 'Save image', 'File name to save:')
    
        if flagOK:
            fileName += ".png" 
            self.ui.MatplotlibWidget2.canvas.fig.savefig(str(fileName))
    # end pButtonSaveImage2_clicked        
            
    # --------------------------------------------------------------------                 
    # Plot initial graph
    # --------------------------------------------------------------------                 
    def plotGraph_onStart(self):
        n = self.G.get_n()
        A = self.G.get_A()
        particls = self.p
        
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
    # Plot new graph
    # --------------------------------------------------------------------                 
    def plotGraph_Step(self):
        n = self.G.get_n()
        A = self.G.get_A()
        particls = self.pnew
        
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
    # Hard coded examples
    # --------------------------------------------------------------------     
    def startExample_1(self):
                
        # init graph
        A = examplesKamadaKawai89.examplePicture2()
        n = np.size(A,0)   
        self.G = Graph(n, A)

        # get parameter values
        self.L_0 = int(self.ui.textEdit_L0.toPlainText())   # length of rectangle side of display area
        self.K   = int(self.ui.textEdit_K.toPlainText())
        self.eps = float(self.ui.textEdit_eps.toPlainText())
        
        # calculate graph distance
        self.dist = floyed(A,n)
        
        # calculate desirable length of single edge
        L = self.L_0 / np.max(self.dist)
        # calculate length of edges
        self.l = L * self.dist
        # calculate strength of spring between two nodes
        self.k = self.K * 1./(self.dist**2) # attention, infinity on diagonals, but we dont need diagonal element
        
        # init coordinates
        self.p = init_particles(n, self.L_0)  #particles p1, ... ,pn
        self.pnew = (self.p).copy()
        
        # plot initial graph
        self.plotGraph_onStart()
        self.plotGraph_Step()

        # set buttons enabled        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonContinue.setEnabled(False)

        self.ui.pbuttonSave.setEnabled(True)
        self.ui.pbuttonReset.setEnabled(True)        
                
        self.ui.labelStart.setText(QtCore.QString("Start: example1"))
    # end startExample_1
        
    def startExample_2(self):
                
        # init graph
        A = examplesKamadaKawai89.examplePicture3a()
        n = np.size(A,0)   
        self.G = Graph(n, A)
        
        
        # get parameter values
        self.L_0 = int(self.ui.textEdit_L0.toPlainText())   # length of rectangle side of display area
        self.K   = int(self.ui.textEdit_K.toPlainText())
        self.eps = float(self.ui.textEdit_eps.toPlainText())
        
        # calculate graph distance
        self.dist = floyed(A,n)
        
        # calculate desirable length of single edge
        L = self.L_0 / np.max(self.dist)
        # calculate length of edges
        self.l = L * self.dist
        # calculate strength of spring between two nodes        
        self.k = self.K * 1./(self.dist**2) # attention, infinity on diagonals, but we dont need diagonal element
        
        # init coordinates
        self.p = init_particles(n, self.L_0)  #particles p1, ... ,pn
        self.pnew = (self.p).copy()
        
        # plot initial graph
        self.plotGraph_onStart()
        self.plotGraph_Step()

        # set buttons enabled        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonContinue.setEnabled(False)

        self.ui.pbuttonSave.setEnabled(True)
        self.ui.pbuttonReset.setEnabled(True)        
        
        self.ui.labelStart.setText(QtCore.QString("Start: example2"))
    # end startExample_2
        
    def startExample_3(self):
                
        # init graph
        A = examplesKamadaKawai89.examplePicture5a()
        n = np.size(A,0)   
        self.G = Graph(n, A)
        
        
        # get parameter values
        self.L_0 = int(self.ui.textEdit_L0.toPlainText())   # length of rectangle side of display area
        self.K   = int(self.ui.textEdit_K.toPlainText())
        self.eps = float(self.ui.textEdit_eps.toPlainText())
        
        # calculate graph distance
        self.dist = floyed(A,n)
        
        # calculate desirable length of single edge
        L = self.L_0 / np.max(self.dist)
        # calculate length of edges
        self.l = L * self.dist
        # calculate strength of spring between two nodes
        self.k = self.K * 1./(self.dist**2) # attention, infinity on diagonals, but we dont need diagonal element
        
        # init coordinates
        self.p = init_particles(n, self.L_0)  #particles p1, ... ,pn
        self.pnew = (self.p).copy()
        
        # plot initial graph
        self.plotGraph_onStart()
        self.plotGraph_Step()

        # set buttons enabled        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonContinue.setEnabled(False)

        self.ui.pbuttonSave.setEnabled(True)
        self.ui.pbuttonReset.setEnabled(True)        
        
        self.ui.labelStart.setText(QtCore.QString("Start: example3"))
    # end startExample_3    
    
    # -------------------------------------------------------------------- 
    # If parameter were changed
    # --------------------------------------------------------------------      
    def eps_changed(self):
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonStep.setEnabled(False)    
    #end eps_changed  

    def K_changed(self):
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonStep.setEnabled(False)    
    #end K_changed  

    def L0_changed(self):
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonStep.setEnabled(False)    
    #end maxit_changed  
        
    def maxit_changed(self):
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonStep.setEnabled(False)    
    #end maxit_changed 
        
    # -------------------------------------------------------------------- 
    # select Algorithm
    # --------------------------------------------------------------------      
        
    def select_Alg_KamadaKawai(self):
        if self.ui.rB_KamadaKawai.isChecked():
            self.Alg_KamadaKawai = True
            self.Alg_HarelKoren = False
        else:
            self.Alg_KamadaKawai = False
            self.Alg_HarelKoren = True
    #end select_Alg_KamadaKawai(self):
    
    def select_Alg_HarelKoren(self):
        if self.ui.rB_HarelKoren.isChecked():
            self.Alg_KamadaKawai = False
            self.Alg_HarelKoren = True
        else:
            self.Alg_KamadaKawai = True
            self.Alg_HarelKoren = False    #end select_Alg_HarelKoren(self):    
        
    
# end class MyWindowClass
# ---------------------------------------------------------------------------



# ----------------------------------------------------------------------------
#                            Main Function 
if __name__ == "__main__": 
    app = QtGui.QApplication(sys.argv)

    myWindow = MyWindowClass()
    myWindow.show()
    
    app.exec_()



