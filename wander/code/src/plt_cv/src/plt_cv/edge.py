#WANDER 25/11/23
#LUCIANO 25/11/23
#Canny Edge Detection 

import cv2
import numpy as np
import sys

class EdgeDetection:
    def __init__(self, min, max):
        self.get_edges = self.canny

    def canny(self, img):
        return cv2.Canny(img, min, max)

def usage():
    print ('pls run:\npython edge.py <algorithm>\nwhere <algorithm> can be sobel, canny or laplacian')

if __name__ == '__main__':
    if (len(sys.argv) < 2):
        print usage()
        exit(0)
    edge = EdgeDetection(sys.argv[1],100,200)

    img = cv2.imread('./tests/image_raw_0.png', 0)
    img = cv2.blur(img, (3,3))

    cv2.imshow("original", img)
    
    image_edges = edge.get_edges(img)
    cv2.imshow("edges", image_edges)
    cv2.waitKey(0)