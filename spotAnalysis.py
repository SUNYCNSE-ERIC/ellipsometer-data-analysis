import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import math
from scipy.interpolate import griddata

def spotRead(spotFile):

    x = []
    y = []

    # Reading in spot file
    with open(spotFile,'r') as spot:
        for i, line in enumerate(spot.readlines()):
            line = [float(j) for j in line.strip().split(',')];
            if i==0:
                x = line[1:]
            else:
                y.append(line[0])
                if i==1:
                    z = np.array([line[1:]])
                else:
                    z = np.concatenate((z,[line[1:]]))

    return [x, y, z]

def minCentroid(x,y,z,eps):
    data_min = min([min(row) for row in z])
    xypairs = []
    for i in xrange(len(x)):
        for j in xrange(len(y)):
            if abs(z[j][i]-data_min) < eps:
                xypairs.append([x[i],y[j]])
    return [sum([pair[0] for pair in xypairs])/len(xypairs), sum([pair[1] for pair in xypairs])/len(xypairs)]