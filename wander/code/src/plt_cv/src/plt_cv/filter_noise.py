#WANDER 25/11/23
#LUCIANO 25/11/23
#Filter Noise

import cv2
import numpy as np
import sys

class FilterNoise:
    def __init__(self, kernel_size):
        self.kernel_size = kernel_size       
        self.get_img = self.bilateral

    def bilateral(self, img):
        return cv2.bilateralFilter(img, self.kernel_size, 75, 75) # geralmente kernel_size eh < 10

if __name__ == '__main__':
    from matplotlib import pyplot as plt

    print ('test filter')

    images = ['image_raw_1.png', 'image_raw_2.png', 'image_raw_3.png', 'image_raw_0.png']

    for file in images:
        img = cv2.imread("./tests/" + str(file))
        kernel_size = (int)(sys.argv[1])

        img_H, img_W, _ = img.shape
    
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        F = FilterNoise(kernel_size)
        R = F.get_img(gray)

        cv2.imshow("bilateral", R)
        cv2.waitKey(0)
        cv2.destroyWindow("bilateral")
