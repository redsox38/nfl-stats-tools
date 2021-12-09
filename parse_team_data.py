# Used for plotting data
import matplotlib.pyplot as plt

# Used for data storage and manipulation 
import numpy as np
import pandas as pd

# Used for Regression Modelling
from sklearn.linear_model import LinearRegression
from sklearn import linear_model
from sklearn.model_selection import train_test_split

# Used for Acc metrics
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score

# For stepwise regression
import statsmodels.api as sm

# box plots
import seaborn as sns
# pairplot
from seaborn import pairplot
# Correlation plot
from statsmodels.graphics.correlation import plot_corr

# Load NFL data 
data = pd.read_csv("nfl2021.csv")

# adding .head() to your dataset allows you to see the first rows in the dataset. 
# Add a # inside the brackets to specificy how many rows are returned or else 5 rows are returned.
print(data.shape)
# (180,16)
print(data.head())

print("Data validation")
print(data.isna().sum())

ss1 = data.dropna()
print(ss1.head())

# Predict winner score
# Away_Team,Home_Team,Away_PR,Home_PR,Winner,Home_Score,Away_Score,Total_Score,Away_Passer_Rating,Home_Passer_Rating,Away_Def_Passer_Rating

df = ss1[['Home_Score','Home_Passer_Rating','SQ_Home_Passer_Rating']]
df.info()
pairplot(df)

plt.show()

corr = df.corr()
print(corr)

# now model our data

# create training set
x_set = pd.DataFrame(df, columns=['SQ_Home_Passer_Rating'])
y_set = pd.DataFrame(df, columns=['Home_Score'])

X_train, X_test, y_train, y_test = train_test_split(x_set, y_set, random_state=1)

# Create linear regression model
lin_reg_mod = LinearRegression()
# Fit linear regression
lin_reg_mod.fit(X_train, y_train)
# Make prediction on the testing data
pred = lin_reg_mod.predict(X_test)

print(lin_reg_mod.intercept_)
print(lin_reg_mod.coef_)
# Calculate the R^2 or coefficent of determination between the actual & predicted
test_set_r2 = r2_score(y_test, pred)
# The closer towards 1, the better the fit
print(test_set_r2)

df2 = df[['Home_Score','Home_Passer_Rating','SQ_Home_Passer_Rating']]

corr2 = df2.corr()
fig = plot_corr(corr2,xnames=corr2.columns)

plt.show()
