#WANDER 25/11/23
#LUCIANO 25/11/23
#Utils

import cv2
import numpy as np
import sys

from plt_msgs.msg import Line
from plt_msgs.msg import Lines

RHO_MIN = 10
THETA_MAX = (5.0*np.pi/180.0)

RED   = (0,0,255)
GREEN = (0,255,0)
BLUE  = (255,0,0)

def soma(u, v):
    return (u[0] + v[0], u[1] + v[1])

def subtrai(u, v):
    return (u[0] - v[0], u[1] - v[1])

def cross(u, v):
    return u[0]*v[1] - u[1]*v[0]

def dot(u, v):
    return u[0]*v[0] + u[1]*v[1]

def distance(u, v):
    uv = subtrai(u, v)
    return int(np.sqrt(dot(uv, uv)))

def rad2deg(rad):
    ''' Convert radians to degrees '''
    deg = rad * 180.0/np.pi
    return deg

def deg2rad(deg):
    ''' Convert degrees to radians '''
    rad = deg * np.pi/180.0
    return rad

def set_plt_msgs_Lines(std_hough_lines):
    ''' Populate a plt_msgs/Lines message with the content of Hough Lines return '''
    lines = []

    for line in std_hough_lines:
        for rho,theta in line:
            aux = Line()
            aux.rho, aux.theta = rho, theta
            lines.append(aux)
    return lines

def get_head(pt, rho, theta):
    x1, y1 = pt
    pt2 = ( (int)(x1+np.cos(theta)*rho),  (int)(y1+np.sin(theta)*rho) )
    return pt2

def get_points(rho, theta):
    ''' Return a point in image plane give the rho, theta returned by Hough Transform '''
    a = np.cos(theta)
    b = np.sin(theta)
    x0 = a*rho
    y0 = b*rho
    pt1 = ( int(x0+1000*(-b)), int(y0+1000*(a)) )
    pt2 = ( int(x0-1000*(-b)), int(y0-1000*(a)) )
    return (pt1, pt2)

def get_best_lines(lines, n):
    ''' Returns the best N lines from Hough Space in a way that all N lines are parallel to
    to each other and not coincident '''
    
    rt = []
    x = len(lines)
    for i in range(x):
        if len(rt) == n:
            break
        ok = 1
        rho, theta = lines[i].rho, lines[i].theta
        for r, t in rt:
            if( abs(r - rho) > RHO_MIN and abs(t - theta) < THETA_MAX ):
                pass
            else:
                ok = 0
                break
        if( ok ):
            rt.append( (rho, theta) )
    return rt

def draw_lines(img, lines, cor=RED, thickness=1):
    ''' Give a array of lines of the type plt_msgs/Line and a img, this function will draw
    the correspondent lines '''
    if ( lines is not None ):
        img_lines = img.copy()
        n = len(lines)
        for i in range(n):
            rho, theta   = lines[i].rho,  lines[i].theta
            pt1, pt2 = get_points(rho, theta)
            cv2.line(img_lines, pt1, pt2, cor, thickness)
    return img_lines

if __name__ == '__main__':

    H = 360
    W = 640

    h = 360/2
    w = 640/2

    img = np.zeros( (H, W, 3), np.uint8 )  
    
    cv2.circle(img, (w, h), 5, (0,0,255))
    
    ww, hh = get_head( (w, h), -50, deg2rad(45) )
    
    cv2.circle(img, (ww, hh), 5, (255,0,0))

    cv2.imshow("img", img)
    cv2.waitKey(0)