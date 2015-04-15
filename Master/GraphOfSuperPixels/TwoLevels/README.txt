 -----------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------------------------------
 Build two level graph structure of input image using superpixel segmentation
 -----------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------------------------------
 
 Extract edge points (Piotr Dollar Toolbox) and compute their descriptors (SIFT).
 We use coarse superpixel segmentation to build Higher Level Graph and fine superpixel segementation of each coarse 
 superpixel to construct Lower Level Graph.
 
 -----------------------------------------------------------------------------------------------------------------------
 Higher Level Graph (HLGraph)
 -----------------------------------------------------------------------------------------------------------------------
 
 For construction of a HLGraph we use the superpixel segmentation of the entire image.
 
 - Set of vertices
      We consider only superpixels that contain edge points. Each such superpixel is represented by the node (anchor)
      of HLGraph. The coordinates of an anchor are caclculated as center of mass of all edge points inside of corresponding
      superpixels.
      
 - Set of edges
      Connect anchors if the rectnagles around corresponding superpixels intersect
      
 - List of rectangles around each superpixel
      A rectangle around a superpixel is defined by four values: coordinates of upper left corner, width and height
      This list will be used to construct Lower Level Graph
      
 -----------------------------------------------------------------------------------------------------------------------
 Lower Level Graph (LLGraph)
 -----------------------------------------------------------------------------------------------------------------------
 
 Construction of LLGraph is done stepwise for each anchor node from HLGraph.
 
 For each anchor we crop image inside the rectangle around corresponding coarse superpixel and segment it in finer
 superpixels. The number of fine superpixels is the same for all anchors. We consider further one image part after 
 another and build a graph (subgraph of whole LLGraph) of superpixels for each of them.
 The nodes of this subgraph are represented by edge points inside selected image region. The nodes inside of one fine
 superpixel build a fully conencted component. The nodes betwenn two adjacent superpixels are connected with one other.
 To decide if two superpixels are adjacent we use the same strategy as for HLGraph. That means, two superpixel are 
 adjacent if the rectangle around them intersect.
 
 Because of intersection of rectangles around coarse superpixels some edge points will belong to several lower level subgraph.
 This creates connections between subgraphs.
 
 For the complete LLGraph holds:
 - Set of vertices V is a union of subgraph vertices without repetitions
 - Set of edges E is a uniion of edges in each subgraph
 
 Additionaly we save information about correspondences between nodes on two level. We use for this a logical matrix U 
 with number of rows equal to number of nodes of the LLGraph and number of columns equal to number of nodes in the HLGraphe.
 Nodes of LLGraph correspond to an anchor in HLGraph if they lie in the rectangle around coarse superpixel, that corresponds 
 to this anchor.
 
 -----------------------------------------------------------------------------------------------------------------------
       