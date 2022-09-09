# -*- coding: utf-8 -*-
"""
Created on Fri Sep  9 13:36:35 2022

@author: u668173
"""

import numpy as np
from pathlib import Path 
import matplotlib.pyplot as plt
import os
import pandas as pd

#input
datainputfolder = './data_input/'
dataoutputfolder = './data_output/'
datafols = os.listdir(datainputfolder)

for fil in datafols:
    #for testing
    for f in ['_smoothed', '']:
        nam = fil+f
        dats = datainputfolder+fil +'/DataArrays/mediaPipeSkel_3d' + f + '.npy'
        #cols = datainputfolder+fil +'/DataArrays/charuco_3d_points.npy'
        #load data
        skel_fr_mar_dim = np.load(dats) 
        sk_x = skel_fr_mar_dim[:, :, 0] #543 points
        sk_y = skel_fr_mar_dim[:, :, 1]
        sk_z = skel_fr_mar_dim[:, :, 2] 
        dfx = pd.DataFrame(sk_x)
        dfx = dfx.add_suffix('_x')
        dfy = pd.DataFrame(sk_y)
        dfy = dfy.add_suffix('_y')
        dfz = pd.DataFrame(sk_z)
        dfz = dfz.add_suffix('_z')
        df = dfx.join(dfy)
        df = df.join(dfz)
        df.to_csv(dataoutputfolder + 'mediaPipeSkel_3d' + nam + ".csv")
        print('processed file: ' + dataoutputfolder + 'mediaPipeSkel_3d' + nam + ".csv")

