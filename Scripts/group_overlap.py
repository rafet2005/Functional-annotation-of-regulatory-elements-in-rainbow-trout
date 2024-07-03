from pathlib import Path
import numpy as np
import pandas as pd

df2=pd.DataFrame() #index=['State'])
#df2['State']=[]
path = Path(".")  # current directory
extension = "overlap.txt"
count = 0
for filename in path.glob(f"*{extension}"): 
    with open(filename, encoding='utf-8') as infile:
      count+=1
      #print(filename)#for line in infile:
      df =  pd.read_csv(filename , delimiter="," ,header =0  ,index_col='State'   ) # ,nrows=10 , skiprows= -1  )  
      #print(df)
      df = df.add(df2, fill_value=0)
      df2 =df.copy()
df=df.div(count)
print (df)
df.to_csv('All_overlap.csv')
