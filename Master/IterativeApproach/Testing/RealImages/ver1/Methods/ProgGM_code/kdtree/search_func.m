function [ idxs ] = search_func( tree, q )

idxs = kdtree_nearest_neighbor(tree,q);
