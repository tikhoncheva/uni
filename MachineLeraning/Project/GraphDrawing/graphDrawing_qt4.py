
import sys
from PyQt4 import QtCore, QtGui

#from form2 import Ui_MainWindow
from mainform import Ui_MainWindow

import numpy as np
import scipy.sparse
import matplotlib.pyplot as plot  

from graphToDraw import *

from generate_graphs import generate_full_binary_tree

import examplesKamadaKawai89 
import examplesHarelKoren02

from Algorithm_HarelKoren2002 import Algorithm_HarelKoren
from Algorithm_HarelKoren2002 import Algorithm_HarelKoren_step

from Algorithm_KamadaKawai89 import Algorithm_KamadaKawai
from Algorithm_KamadaKawai89 import Algorithm_KamadaKawai_step


class sparamKK:              # parameters of KamadaKawai Algorithm
    def __init__(self, _K, _L0, _eps):
        self.K = _K     # constant (needed for strength of the springs)
        self.L0 = _L0   # side of display are
        self.eps = _eps # convergence parameter
# end class def        

class sparamHK:              # parameters of HarelKoren Algorithm
    def __init__(self,_L, _Rad, _It, _Ratio, _Minsize):
        self.L   = _L
        self.Rad = _Rad         # radius of local neighborhood
        self.It = _It           # number of iterations of local beautification
        self.Ratio = _Ratio     # ration between number of nodes in two censecutive levels
        self.Minsize = _Minsize # min size of the coarsest graph
        self.Startsize = _Minsize# start size of the neighborhood
# end class def        
        
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
        self.paramKK = sparamKK(1,1, 0.0001) # K, L0, eps
        self.paramHK = sparamHK(1, 7, 4, 3, 10) # L, Rad, It, Ratio, Minsize
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

        # plot labels
        self.showLabels = True
        self.ui.cBox_ShowLabels.clicked.connect(self.cBox_ShowLabels_clicked)
        # save current graph image
        self.ui.pbuttonSave_InitialG.clicked.connect(self.pButtonSaveImage1_clicked)
        self.ui.pbuttonSave.clicked.connect(self.pButtonSaveImage2_clicked)
    
        # delete result of algorithms 
        self.ui.pbuttonReset.clicked.connect(self.pButtonReset_clicked)     
        
        # hard coded examples
        self.connect(self.ui.actionExample_1, QtCore.SIGNAL('triggered()'), self.startExample_1)
        self.connect(self.ui.actionExample_2, QtCore.SIGNAL('triggered()'), self.startExample_2)
        self.connect(self.ui.actionExample_3, QtCore.SIGNAL('triggered()'), self.startExample_3)  

        self.readFromFile = False
        self.connect(self.ui.action_3eltGraph, QtCore.SIGNAL('triggered()'), self.startExample_3elt)
#        self.connect(self.ui.actionExample_2, QtCore.SIGNAL('triggered()'), self.startExample_2)
#        self.connect(self.ui.actionExample_3, QtCore.SIGNAL('triggered()'), self.startExample_3)  
        
        self.connect(self.ui.action_16x16, QtCore.SIGNAL('triggered()'), self.startExample_grid_16)
        self.connect(self.ui.action_grid32x32, QtCore.SIGNAL('triggered()'), self.startExample_grid_32)
        self.connect(self.ui.action_grid55x55, QtCore.SIGNAL('triggered()'), self.startExample_grid_55)
        
        # on parameter changed
        self.ui.textEdit_h.textChanged.connect(self.h_changed)
        self.ui.textEdit_eps.textChanged.connect(self.eps_changed)
        self.ui.textEdit_K.textChanged.connect(self.K_changed)
        self.ui.textEdit_L0.textChanged.connect(self.L0_changed)
        self.ui.textEdit_maxit.textChanged.connect(self.maxit_changed)
        
        self.ui.textEdit_l.textChanged.connect(self.L_changed)
        self.ui.textEdit_radius.textChanged.connect(self.Radius_changed)
        self.ui.textEdit_iterator.textChanged.connect(self.It_changed)
        self.ui.textEdit_ratio.textChanged.connect(self.Ratio_changed)
        self.ui.textEdit_minsize.textChanged.connect(self.Minsize_changed)
        
        # select Algorithm
        self.Alg_KamadaKawai = True
        self.Alg_HarelKoren = False
        self.connect(self.ui.rB_KamadaKawai, QtCore.SIGNAL('toggled(bool)'), self.select_Alg_KamadaKawai)
        self.connect(self.ui.rB_HarelKoren, QtCore.SIGNAL('toggled(bool)'), self.select_Alg_HarelKoren)
    # end __init__
        
    # --------------------------------------------------------------------                 
    # Initialise graph 
    # --------------------------------------------------------------------       
    def h_changed(self):
        if self.ui.textEdit_h.toPlainText() != '':
            h = int(self.ui.textEdit_h.toPlainText())   # height of the complete binary tree
            self.ui.textEdit_nV.setText(QtCore.QString(str(2**h-1)))
        #end if    
    #end h_changed      
        
    def pButton_generateG_clicked(self):
        
        # init graph
        h = int(self.ui.textEdit_h.toPlainText())   # height of the complete binary tree
        n = 2**h-1
        self.ui.textEdit_nV.setText(QtCore.QString(str(n)))
        A = generate_full_binary_tree(h)
        
        self.G = Graph(n, A)
        
        # get values of the parameters
        self.paramKK.L0 = int(self.ui.textEdit_L0.toPlainText())   # length of rectangle side of display area
        self.paramKK.K   = int(self.ui.textEdit_K.toPlainText())
        self.paramKK.eps = float(self.ui.textEdit_eps.toPlainText())
        
        
        self.paramHK.L       = int(self.ui.textEdit_l.toPlainText())        # desired length of the edges
        self.paramHK.Rad     = int(self.ui.textEdit_radius.toPlainText())   # radius of local neighborhood
        self.paramHK.It      = int(self.ui.textEdit_iterator.toPlainText()) # number of iterations of local beautification
        self.paramHK.Ratio   = int(self.ui.textEdit_ratio.toPlainText())    # ration between number of nodes in two censecutive levels
        self.paramHK.Minsize = int(self.ui.textEdit_minsize.toPlainText())  # min size of the coarsest graph
        
        self.maxit = int(self.ui.textEdit_maxit.toPlainText())       
        
        # calculate graph distance
#        self.dist = floyed(A,n)
#        self.dist = dist_with_DijkstraAlg(A)
        self.dist = scipy.sparse.csgraph.dijkstra(A, directed = False, return_predecessors = False, unweighted = True)
     
        
        # calculate desirable length of single edge
        if self.Alg_HarelKoren:
            L = self.paramHK.L  
        else:
            L = self.paramKK.L0 / np.max(self.dist)           

        # calculate length of edges
        self.l = L * self.dist
        # calculate strength of spring between two nodes
        self.dist[range(n), range(n)] = np.Infinity         # just to get rif of division by zero error
        self.k = self.paramKK.K * 1./(self.dist**2) # attention, infinity on diagonals, but we dont need diagonal element
        
        self.dist[range(n), range(n)] = 0        # just to get rif of division by zero error
        
        # init coordinates
        self.readFromFile = False
        self.p = init_particles(n, self.paramKK.L0)  #particles p1, ... ,pn
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
        self.ui.groupBox_Algorithm.setEnabled(True)
    # end pButton_generateG_clicke

    # --------------------------------------------------------------------                 
    # Run complete algorithm 
    # --------------------------------------------------------------------                   
    def pButtonStart_clicked(self):
        
        # pnew      coordinates of the nodes
        # dist      distance matrix of the graph
        # k         strength of the edges
        # l         desired length of the edges
        # maxit     maximal number of iterations 
        
        self.pnew = (self.p).copy()
        
        if self.Alg_KamadaKawai:
            self.pnew, self.step = Algorithm_KamadaKawai(self.G.get_n(), self.pnew,            self.k, self.l, self.paramKK.eps, self.maxit)
        else:
            self.pnew, self.step = Algorithm_HarelKoren (self.G.get_n(), self.pnew, self.dist, self.k, self.l, self.paramHK)
        
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        self.plotGraph_Step()        
    # end pButtonStart_clicked

    # --------------------------------------------------------------------                 
    # Make one step of the algorithm
    # --------------------------------------------------------------------         
    def pButtonStep_clicked(self):
        
        if self.Alg_KamadaKawai:
            self.pnew = Algorithm_KamadaKawai_step(self.G.get_n(), self.pnew,            self.k, self.l, self.paramKK.eps, self.maxit)
        else:
            self.pnew = Algorithm_HarelKoren_step(self.G.get_n(), self.pnew, self.dist, self.k, self.l, self.paramHK)
        # end if
        # plot result of the step
        self.plotGraph_Step()
        
        self.step += 1
        
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))         
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonContinue.setEnabled(True)
    # end pButtonStep_clicked

    # --------------------------------------------------------------------                 
    # Run algorithm till end from the current position
    # --------------------------------------------------------------------         
    def pButtonContinue_clicked(self):
        
        # pnew      coordinates of the nodes
        # dist      distance matrix of the graph
        # k         strength of the edges
        # l         desired length of the edges
        # maxit     maximal number of iterations
        
        if self.Alg_KamadaKawai:
            self.pnew, nContSteps = Algorithm_KamadaKawai(self.G.get_n(), self.pnew,            self.k, self.l, self.paramKK.eps, self.maxit)
        else:
            self.pnew, nContSteps = Algorithm_HarelKoren (self.G.get_n(), self.pnew, self.dist, self.k, self.l, self.paramHK)
        
        self.step += nContSteps
        
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        self.plotGraph_Step() 
        
        self.ui.pbuttonStart.setEnabled(True)
    # end pButtonStep_clicked

    # --------------------------------------------------------------------                 
    # Delete result of algorithms 
    # --------------------------------------------------------------------  
    def pButtonReset_clicked(self):
               
        n = self.G.get_n()        
        self.step = 0
        
        # get values of the parameters
        self.paramKK.L0  = int(self.ui.textEdit_L0.toPlainText())   # length of rectangle side of display area
        self.paramKK.K   = int(self.ui.textEdit_K.toPlainText())
        self.paramKK.eps = float(self.ui.textEdit_eps.toPlainText())
        self.maxit       = int(self.ui.textEdit_maxit.toPlainText())
        
        self.paramHK.L       = int(self.ui.textEdit_l.toPlainText())        # desired length of the edges
        self.paramHK.Rad     = int(self.ui.textEdit_radius.toPlainText())   # radius of local neighborhood
        self.paramHK.It      = int(self.ui.textEdit_iterator.toPlainText()) # number of iterations of local beautification
        self.paramHK.Ratio   = int(self.ui.textEdit_ratio.toPlainText())    # ration between number of nodes in two censecutive levels
        self.paramHK.Minsize = int(self.ui.textEdit_minsize.toPlainText())  # min size of the coarsest graph
        self.paramHK.Startsize = self.paramHK.Minsize
               
        # calculate desirable length of single edge
        if self.Alg_HarelKoren:
            L = self.paramHK.L  
        else:
            L = self.paramKK.L0 / np.max(self.dist)            
        # calculate length of edges
        self.l = L * self.dist
        # calculate length of edges
        self.l = L * self.dist
        # calculate strength of spring between two nodes
        self.dist[range(n), range(n)] = np.Infinity         # just to get rif of division by zero error
        self.k = self.paramKK.K * 1./(self.dist**2) # attention, infinity on diagonals, but we dont need diagonal element
        self.dist[range(n), range(n)] = 0        # just to get rif of division by zero error
        
        # init coordinates
        if not self.readFromFile :
            self.p = init_particles(self.G.get_n(), self.paramKK.L0)  #particles p1, ... ,pn
        self.pnew = (self.p).copy()
        
        self.plotGraph_onStart()
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
    def cBox_ShowLabels_clicked(self):  # show labels or not
        if self.ui.cBox_ShowLabels.isChecked():
            self.showLabels = True
        else:
            self.showLabels = False
        if len(self.p)!=0:
            self.plotGraph_onStart()
            self.plotGraph_Step()
    #end cBox_ShowLabels_clicked
        
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
            if self.showLabels:
                self.ui.MatplotlibWidget1.canvas.ax.annotate('{}'.format(i+1), 
                                                         xy=(particls[0,i],particls[1,i]),
                                                         xytext=(particls[0,i], particls[1,i]))
            #end if show labels
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
        plot.scatter(particls[0,:],particls[1,:])
        self.ui.MatplotlibWidget2.canvas.ax.scatter(particls[0,],particls[1,])
        for i in range(n):
            for j in range(i+1,n):
                if i!=j and A[i,j] < np.Infinity :
                    self.ui.MatplotlibWidget2.canvas.ax.plot([particls[0,i],particls[0,j]],
                                                             [particls[1,i],particls[1,j]])
                # end if
            # end for j
            # Annotate the points                                           
            if self.showLabels:
                self.ui.MatplotlibWidget2.canvas.ax.annotate('{}'.format(i+1), 
                                                         xy=(particls[0,i],particls[1,i]),
                                                         xytext=(particls[0,i], particls[1,i]))
            #end if show labels                  
        # end for i
        self.ui.MatplotlibWidget2.canvas.draw() 
    # end plotGraph_Step
            
    # -------------------------------------------------------------------- 
    # Hard coded examples
    # --------------------------------------------------------------------     
    def startExample_1(self):
        self.readFromFile = False
        
        # init graph
        A = examplesKamadaKawai89.examplePicture2()
        n = np.size(A,0)   
        self.G = Graph(n, A)

#        self.dist = floyed(A,n)
        self.dist = dist_with_DijkstraAlg(A)    
                        
        self.pButtonReset_clicked()     # reset the algorithm

        # set buttons enabled        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonContinue.setEnabled(False)

        self.ui.pbuttonSave.setEnabled(True)
        self.ui.pbuttonReset.setEnabled(True)        
                
        self.ui.labelStart.setText(QtCore.QString("Start: example1"))
        self.ui.groupBox_Algorithm.setEnabled(True)
    # end startExample_1
        
    def startExample_2(self):
        self.readFromFile = False
        
        # init graph
        A = examplesKamadaKawai89.examplePicture3a()
        n = np.size(A,0)   
        self.G = Graph(n, A)
        
#        self.dist = floyed(A,n)
        self.dist = dist_with_DijkstraAlg(A)  

        self.pButtonReset_clicked()     # reset the algorithm

        # set buttons enabled        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonContinue.setEnabled(False)

        self.ui.pbuttonSave.setEnabled(True)
        self.ui.pbuttonReset.setEnabled(True)        
        
        self.ui.labelStart.setText(QtCore.QString("Start: example2"))
        self.ui.groupBox_Algorithm.setEnabled(True)
    # end startExample_2
        
    def startExample_3(self):
        self.readFromFile = False                
        # init graph
        A = examplesKamadaKawai89.examplePicture5a()
        n = np.size(A,0)   
        self.G = Graph(n, A)
        
#        self.dist = floyed(A,n)
        self.dist = dist_with_DijkstraAlg(A)
 
        self.pButtonReset_clicked()     # reset the algorithm

        # set buttons enabled        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonContinue.setEnabled(False)

        self.ui.pbuttonSave.setEnabled(True)
        self.ui.pbuttonReset.setEnabled(True)        
        
        self.ui.labelStart.setText(QtCore.QString("Start: example3"))
        self.ui.groupBox_Algorithm.setEnabled(True)
    # end startExample_3    
    
    def startExample_3elt(self):
        self.readFromFile = True
        
        # not show labels by plotting
        self.showLabels = False
        self.ui.cBox_ShowLabels.setChecked(False)                
        
        # init graph (load adjacency matrix and read coordinates of nodes)
        A, p = examplesHarelKoren02.example_3elt()
        
        n = np.size(A,0)   
        self.G = Graph(n, A)

        self.p = p
        self.pnew = (self.p).copy()
        

#        self.dist = floyed(A,n)
#        self.dist = dist_with_DijkstraAlg(A)
        
#        starttime = time.time()
#        self.dist = scipy.sparse.csgraph.dijkstra(A, directed = False, return_predecessors = False, unweighted = True)
#        stoptime = time.time()        
#        print "Time spent to calculate distance matrix of the graph({0:5d} nodes) with Scipy Dijkstra Alg: {1:0.6f} sec". format(n, stoptime-starttime)          
        
#        np.save('3elt_dist',self.dist)
        self.dist = np.load('3elt_dist.npy')
                            
        self.pButtonReset_clicked()     # reset the algorithm
        
        # set buttons enabled        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonContinue.setEnabled(False)

        self.ui.pbuttonSave.setEnabled(True)
        self.ui.pbuttonReset.setEnabled(True)        
        
        self.ui.labelStart.setText(QtCore.QString("Start: 3elt |V|="+str(n)))
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        self.ui.groupBox_Algorithm.setEnabled(True)
    # end startExample_3elt

    def startExample_grid_16(self):
        self.startExample_grid(16*16)
#        self.startExample_grid(8*8)    
    #end startExample_grid_32:
        
    def startExample_grid_32(self):
        self.startExample_grid(32*32)
    #end startExample_grid_32:

    def startExample_grid_55(self):
        self.startExample_grid(55*55)
    #end startExample_grid_55:
        
        
    def startExample_grid(self, n):

        self.readFromFile = False
        
        # not show labels by plotting
        self.showLabels = False
        self.ui.cBox_ShowLabels.setChecked(False)                
        
        # init graph (load adjacency matrix)
        A = examplesHarelKoren02.example_grid(n)
        self.G = Graph(n, A)

#        self.dist = floyed(A,n)
#        self.dist = dist_with_DijkstraAlg(A)

        starttime = time.time()
        self.dist = scipy.sparse.csgraph.dijkstra(A, directed = False, return_predecessors = False, unweighted = True)
        stoptime = time.time()        
        print "Time spent to calculate distance matrix of the graph({0:5d} nodes) with Scipy Dijkstra Alg: {1:0.6f} sec". format(n, stoptime-starttime)          

 
        self.pButtonReset_clicked()     # reset the algorithm
 
        # set buttons enabled        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)
        self.ui.pbuttonContinue.setEnabled(False)

        self.ui.pbuttonSave.setEnabled(True)
        self.ui.pbuttonReset.setEnabled(True)        
        
        self.ui.labelStart.setText(QtCore.QString("Start: Grid Graph|V|="+str(n)))
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        self.ui.groupBox_Algorithm.setEnabled(True)
    # end startExample_grid        
    
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

    def L_changed(self):
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonStep.setEnabled(False)    
    #end maxit_changed  
        
    def Radius_changed(self):
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonStep.setEnabled(False)    
    #end maxit_changed     
        
    def It_changed(self):
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonStep.setEnabled(False)    
    #end maxit_changed     
        
    def Ratio_changed(self):
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonStep.setEnabled(False)    
    #end maxit_changed     
    def Minsize_changed(self):
        self.ui.pbuttonStart.setEnabled(False)
        self.ui.pbuttonStep.setEnabled(False)    
        if self.ui.textEdit_minsize.toPlainText() != '' and  \
                                    int(self.ui.textEdit_minsize.toPlainText()<2):
            self.ui.textEdit_minsize.setText(QtCore.QString(str(2)))
            
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
            self.paramHK.Startsize = self.paramHK.Minsize# start size of the neighborhood
        #end if
        

        self.step = 0
        self.pnew = (self.p).copy()
        
        # calculate desirable length of single edge
        if self.Alg_HarelKoren:
            L = self.paramHK.L  
        else:
            L = self.paramKK.L0 / np.max(self.dist)           
        # calculate length of edges
        self.l = L * self.dist
        
#        self.plotGraph_onStart()
#        self.plotGraph_Step()
        
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)  
        self.ui.pbuttonContinue.setEnabled(False)        
    #end select_Alg_KamadaKawai(self)
    
    def select_Alg_HarelKoren(self):
        if self.ui.rB_HarelKoren.isChecked():
            self.Alg_KamadaKawai = False
            self.Alg_HarelKoren = True
            self.paramHK.Startsize = self.paramHK.Minsize# start size of the neighborhood
        else:
            self.Alg_KamadaKawai = True
            self.Alg_HarelKoren = False    #end select_Alg_HarelKoren(self):    
        #end if
                              
        self.step = 0
        self.pnew = (self.p).copy()
        
        # calculate desirable length of single edge
        if self.Alg_HarelKoren:
            L = self.paramHK.L  
        else:
            L = self.paramKK.L0 / np.max(self.dist)           

        # calculate length of edges
        self.l = L * self.dist
        
#        self.plotGraph_onStart()
#        self.plotGraph_Step()
        
        self.ui.labelResult.setText(QtCore.QString("Result: Step " + str(self.step)))
        
        self.ui.pbuttonStart.setEnabled(True)
        self.ui.pbuttonStep.setEnabled(True)  
        self.ui.pbuttonContinue.setEnabled(False)
        
    
# end class MyWindowClass
# ---------------------------------------------------------------------------



# ----------------------------------------------------------------------------
#                            Main Function 
if __name__ == "__main__": 
    app = QtGui.QApplication(sys.argv)

    myWindow = MyWindowClass()
    myWindow.show()
    
    app.exec_()



