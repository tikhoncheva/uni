
Project "Force-Directed Graph Drawing Algorithms:
	 Approach by T.Kamada and S.Kawai and multi-scale algorithm by D.Harel and Y.Koren" 

Authors:
    Ekaterina Tikhoncheva
    Elias Roeger

University of Heidelberg    
February, 2015    

References:
T.Kamada, S.Kawai "An Algorithm for drawing general undirected graphs", 1989
D.Harel & Y.Koren "A fast multi-scale method for drawing large graphs", 2002 


------------------------------------------------------------------------------------------------------------------------------------------------

Implementation language : Python (version 2.7.6)
Additional libraries:	  numpy (version 1.8.2), scipy (version 0.13.3), matplotlib(1.3.1), PyQt (version 4.11) 
Additional programms:	  QT Creator 3.2.2 (designing of GUI)


------------------------------------------------------------------------------------------------------------------------------------------------
README for the GUI implementation
------------------------------------------------------------------------------------------------------------------------------------------------
For visualisation purposes of our implementation of the algorithms we also implemented a simple GUI. 
A user can select which algorithm he want to use. The most test examples were taken from the corresponding papers and are hard coded. Nevertheless it is possible to generate complete binary trees with arbitrary number of vertices. 

Both algorithms can be called to run completely from start till end, or it is possible to run one step of the algorithm after another and on some point continue till the end.

It is also possible to change default setting of the algorithms.


------------------------------------------------------------------------------------------------------------------------------------------------
Run
------------------------------------------------------------------------------------------------------------------------------------------------
Type

    python main.py

------------------------------------------------------------------------------------------------------------------------------------------------
Overview
------------------------------------------------------------------------------------------------------------------------------------------------

Algorithm_HarelKoren2002.py
  
    contains the implementation of the algorithm by Harel and Koren

Algorithm_KamadaKawai89.py

    contains the implementation of the algorithm by Kamada and Kawai

Algorithm_KamadaKawai89_kN.py

    contains the implementation of the algorithm by Kamada and Kawai, that considers r-neighbourhood of each vertex (used in the algorithm by Harel and Koren)

examplesHarelKoren02.py

    examples from the paper by Harel and Koren
    (square grid graph, sparse grid graphs, J.Petit collection)

examplesKamadaKawai89.py

    examples from the paper by Kamada and Kawai

generate_graphs.py

    function for reading an adjacency matrix and coordinates of vertices of a graph from a given file
    function for generation of complete binary trees given depth of a tree
    function for generation a arbitrary graph (sometimes result graph is not connected)

graphToDraw.py
    
    class definition of a graph given adjacency matrix and number of vertices
    function to initialise nodes of the graph on a plane
    floyed algorithm 
    dijkstra algorihtm

main.py

    main file, that starts the main window, defines it's behavior on user actions and binds all other files

mainform.py

    definition of the main window, obtained by pyuic4 applied on mainform.ui
    
mainform.ui
    
    GUI interface designed in QT Creator
    
matplotlibwidget.py

    definition of the class for drawing graphs on the QT widget using matplotlib library
    
------------------------------------------------------------------------------------------------------------------------------------------------